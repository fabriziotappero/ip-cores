-- ########################################################
-- #    << ATLAS Project - Arithmetical/Logical Unit >>   #
-- # **************************************************** #
-- #  The main data processing is done here. Also the CP  #
-- #  interface emerges from this unit.                   #
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

entity alu is
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

        ex_ctrl_bus_i   : in  std_ulogic_vector(ctrl_width_c-1 downto 0); -- stage control
        flag_bus_i      : in  std_ulogic_vector(flag_bus_width_c-1 downto 0); -- flag input

-- ###############################################################################################
-- ##           Data Input                                                                      ##
-- ###############################################################################################

        op_a_i          : in  std_ulogic_vector(data_width_c-1 downto 0); -- operand a input
        op_b_i          : in  std_ulogic_vector(data_width_c-1 downto 0); -- operand b input
        op_c_i          : in  std_ulogic_vector(data_width_c-1 downto 0); -- operand c input

        pc_1d_i         : in  std_ulogic_vector(data_width_c-1 downto 0); -- 1x delayed pc

        ma_fwd_i        : in  std_ulogic_vector(fwd_width_c-1  downto 0); -- ma stage forwarding path
        wb_fwd_i        : in  std_ulogic_vector(fwd_width_c-1  downto 0); -- wb stage forwarding path

-- ###############################################################################################
-- ##           Data Output                                                                     ##
-- ###############################################################################################

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
end alu;

architecture alu_structure of alu is

  -- pipeline register --
  signal op_a_ff : std_ulogic_vector(data_width_c-1 downto 0);
  signal op_b_ff : std_ulogic_vector(data_width_c-1 downto 0);
  signal op_c_ff : std_ulogic_vector(data_width_c-1 downto 0);

  -- functional units output --
  signal fu_arith_res : std_ulogic_vector(data_width_c-1 downto 0);
  signal fu_arith_flg : std_ulogic_vector(1 downto 0); -- overflow & carry
  signal fu_logic_res : std_ulogic_vector(data_width_c-1 downto 0);
  signal fu_logic_flg : std_ulogic_vector(1 downto 0);
  signal fu_shift_res : std_ulogic_vector(data_width_c-1 downto 0);
  signal fu_shift_flg : std_ulogic_vector(1 downto 0);

  -- internal data lines  --
  signal op_a_int    : std_ulogic_vector(data_width_c-1 downto 0);
  signal op_b_int    : std_ulogic_vector(data_width_c-1 downto 0);
  signal op_c_int    : std_ulogic_vector(data_width_c-1 downto 0);
  signal alu_res_int : std_ulogic_vector(data_width_c-1 downto 0);
  signal t_flag_func : std_ulogic;
  signal parity_bit  : std_ulogic;
  signal transf_int  : std_ulogic;
  signal sel_bit     : std_ulogic;
  signal inv_bit     : std_ulogic;
  signal is_zero     : std_ulogic;
  signal extnd_zero  : std_ulogic;

  -- multiplier --
  signal mul_op_a : std_ulogic_vector(data_width_c-1 downto 0);
  signal mul_op_b : std_ulogic_vector(data_width_c-1 downto 0);

begin

  -- Pipeline Register -----------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    pipe_reg: process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          op_a_ff <= (others => '0');
          op_b_ff <= (others => '0');
          op_c_ff <= (others => '0');
        elsif (ce_i = '1') then
          op_a_ff <= op_a_i;
          op_b_ff <= op_b_i;
          op_c_ff <= op_c_i;
        end if;
      end if;
    end process pipe_reg;


  -- Execution Forwarding Unit ---------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    ex_fwd: process(ma_fwd_i, wb_fwd_i, ex_ctrl_bus_i, op_a_ff, op_b_ff, op_c_ff)
      variable op_a_ma_match_v : std_ulogic;
      variable op_b_ma_match_v : std_ulogic;
      variable op_a_wb_match_v : std_ulogic;
      variable op_b_wb_match_v : std_ulogic;
      variable op_c_wb_match_v : std_ulogic;
      variable op_a_tmp_v      : std_ulogic_vector(data_width_c-1 downto 0);
    begin

      -- data from early stages -> higher priority than data from later stages
      -- no forwarding when op_a is the pc
      -- no forwarding when op_b is an immediate

      -- local data dependency detectors --
      op_a_ma_match_v := '0';
      if (ma_fwd_i(fwd_en_c) = '1') and (ex_ctrl_bus_i(ctrl_ra_is_pc_c) = '0')  and (ex_ctrl_bus_i(ctrl_ra_3_c downto ctrl_ra_0_c) = ma_fwd_i(fwd_adr_3_c downto fwd_adr_0_c)) then
        op_a_ma_match_v := '1';
      end if;
      op_a_wb_match_v := '0';
      if (wb_fwd_i(fwd_en_c) = '1') and (ex_ctrl_bus_i(ctrl_ra_is_pc_c) = '0')  and (ex_ctrl_bus_i(ctrl_ra_3_c downto ctrl_ra_0_c) = wb_fwd_i(fwd_adr_3_c downto fwd_adr_0_c)) then
        op_a_wb_match_v := '1';
      end if;

      op_b_ma_match_v := '0';
      if (ma_fwd_i(fwd_en_c) = '1') and (ex_ctrl_bus_i(ctrl_rb_is_imm_c) = '0') and (ex_ctrl_bus_i(ctrl_rb_3_c downto ctrl_rb_0_c) = ma_fwd_i(fwd_adr_3_c downto fwd_adr_0_c)) then
        op_b_ma_match_v := '1';
      end if;
      op_b_wb_match_v := '0';
      if (wb_fwd_i(fwd_en_c) = '1') and (ex_ctrl_bus_i(ctrl_rb_is_imm_c) = '0') and (ex_ctrl_bus_i(ctrl_rb_3_c downto ctrl_rb_0_c) = wb_fwd_i(fwd_adr_3_c downto fwd_adr_0_c)) then
        op_b_wb_match_v := '1';
      end if;

      op_c_wb_match_v := '0';
      if (wb_fwd_i(fwd_en_c) = '1') and (ex_ctrl_bus_i(ctrl_rb_3_c downto ctrl_rb_0_c) = wb_fwd_i(fwd_adr_3_c downto fwd_adr_0_c)) then
        op_c_wb_match_v := '1';
      end if;

      -- op a gating --
      if (ex_ctrl_bus_i(ctrl_en_c) = '1') then
        -- op a forwarding --
        if (op_a_ma_match_v = '1') then
          op_a_tmp_v := ma_fwd_i(fwd_dat_msb_c downto fwd_dat_lsb_c); -- ma stage
        elsif (op_a_wb_match_v = '1') then
          op_a_tmp_v := wb_fwd_i(fwd_dat_msb_c downto fwd_dat_lsb_c); -- wb stage
        else
          op_a_tmp_v := op_a_ff;
        end if;
      else
        op_a_tmp_v := (others => '0');
      end if;

      -- op a mask unit --
      op_a_int <= op_a_tmp_v;
      if (ex_ctrl_bus_i(ctrl_clr_ha_c) = '1') then -- clear high half word
        op_a_int(data_width_c-1 downto data_width_c/2) <= (others => '0');
      end if;
      if (ex_ctrl_bus_i(ctrl_clr_la_c) = '1') then -- clear low half word
        op_a_int(data_width_c/2-1 downto 0) <= (others => '0');
      end if;

      -- op b gating --
      if (ex_ctrl_bus_i(ctrl_en_c) = '1') then
        -- op b forwarding --
        if (op_b_ma_match_v = '1') then
          op_b_int <= ma_fwd_i(fwd_dat_msb_c downto fwd_dat_lsb_c); -- ma stage
        elsif (op_b_wb_match_v = '1') then
          op_b_int <= wb_fwd_i(fwd_dat_msb_c downto fwd_dat_lsb_c); -- wb stage
        else
          op_b_int <= op_b_ff;
        end if;
      else
        op_b_int <= (others => '0');
      end if;

      -- op c forwarding --
      if (op_c_wb_match_v = '1') then
        op_c_int <= wb_fwd_i(fwd_dat_msb_c downto fwd_dat_lsb_c); -- wb stage
      else
        op_c_int <= op_c_ff;
      end if;

    end process ex_fwd;


  -- Functional Unit: Arithmetic Core --------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    fu_arithmetic_core: process(ex_ctrl_bus_i, op_a_int, op_b_int, flag_bus_i)
      variable op_a_v, op_b_v   : std_ulogic_vector(data_width_c-1 downto 0);
      variable cflag_v          : std_ulogic;
      variable add_a_v, add_b_v : std_ulogic_vector(data_width_c downto 0);
      variable add_cf_in_v      : std_ulogic_vector(0 downto 0);
      variable adder_c_sel_v    : std_ulogic;
      variable adder_carry_in_v : std_ulogic;
      variable adder_tmp_v      : std_ulogic_vector(data_width_c downto 0);
    begin

      -- operand insulation --
      op_a_v  := (others => '0');
      op_b_v  := (others => '0');
      cflag_v := '0';
      if (ex_ctrl_bus_i(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) = alu_adc_c) or
      (ex_ctrl_bus_i(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) = alu_sbc_c) then
        op_a_v  := op_a_int;
        op_b_v  := op_b_int;
        cflag_v := flag_bus_i(flag_c_c);
      end if;

      -- add/sub select --
      if (ex_ctrl_bus_i(ctrl_alu_cf_opt_c) = '0') then -- propagate carry_in
        adder_c_sel_v := cflag_v;
      else -- invert carry_in
        adder_c_sel_v := not cflag_v;
      end if;
      add_a_v := '0' & op_a_v;
      adder_carry_in_v := adder_c_sel_v and ex_ctrl_bus_i(ctrl_alu_usec_c);
      case (ex_ctrl_bus_i(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c)) is
        when alu_sbc_c => -- (+op_a) + (-op_b) {+ (-carry)}
          add_b_v        := '0' & (not op_b_v);
          add_cf_in_v(0) := not adder_carry_in_v;
        when alu_adc_c => -- (+op_a) + (+op_b) {+ (+carry)}
          add_b_v        := '0' & op_b_v;
          add_cf_in_v(0) := adder_carry_in_v;
        when others => -- other function set, adder irrelevant
          add_b_v        := '0' & op_b_v;
          add_cf_in_v(0) := adder_carry_in_v;
      end case;

      -- adder core --
      adder_tmp_v  := std_ulogic_vector(unsigned(add_a_v) + unsigned(add_b_v) + unsigned(add_cf_in_v(0 downto 0)));
      fu_arith_res <= adder_tmp_v(data_width_c-1 downto 0); -- result, msb of adder_tmp_v is carry bit
      
      -- adder flag carry output logic --
      case (ex_ctrl_bus_i(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c)) is
        when alu_adc_c => -- add
          fu_arith_flg(0) <= adder_tmp_v(data_width_c);
        when alu_sbc_c => -- sub
          fu_arith_flg(0) <= not adder_tmp_v(data_width_c);
        when others => -- other function set, adder irrelevant
          fu_arith_flg(0) <= adder_tmp_v(data_width_c);
      end case;

      -- arithmetic overflow flag --
      fu_arith_flg(1) <= ((not add_a_v(data_width_c-1)) and (not add_b_v(data_width_c-1)) and (    adder_tmp_v(data_width_c-1))) or
                 ((    add_a_v(data_width_c-1)) and (    add_b_v(data_width_c-1)) and (not adder_tmp_v(data_width_c-1)));
    end process fu_arithmetic_core;


  -- Functional Unit: Shifter Core -----------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    fu_shifter_core: process(ex_ctrl_bus_i, op_a_int, op_b_ff, flag_bus_i)
      variable op_a_v, op_b_v   : std_ulogic_vector(data_width_c-1 downto 0);
      variable cflag_v          : std_ulogic;
      variable shifter_dat_v    : std_ulogic_vector(data_width_c-1 downto 0);
      variable shifter_carry_v  : std_ulogic;
      variable shifter_ovf_v    : std_ulogic;
    begin

      -- operand insulation --
      op_a_v  := (others => '0');
      op_b_v  := (others => '0');
      cflag_v := '0';
      if (ex_ctrl_bus_i(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c) = alu_sft_c) then
        op_a_v  := op_a_int;
        op_b_v  := op_b_ff;
        cflag_v := flag_bus_i(flag_c_c);
      end if;

      -- shifter core --
      case (op_b_v(2 downto 0)) is
        when sft_asr_c => -- arithmetical right shift
          shifter_dat_v   := op_a_v(data_width_c-1) & op_a_v(data_width_c-1 downto 1);
          fu_shift_flg(0) <= op_a_v(0);
        when sft_rol_c => -- rotate left
          shifter_dat_v   := op_a_v(data_width_c-2 downto 0) & op_a_v(data_width_c-1);
          fu_shift_flg(0) <= op_a_v(data_width_c-1);
        when sft_ror_c => -- rotate right
          shifter_dat_v   := op_a_v(0) & op_a_v(data_width_c-1 downto 1);
          fu_shift_flg(0) <= op_a_v(0);
        when sft_lsl_c => -- logical shift left
          shifter_dat_v   := op_a_v(data_width_c-2 downto 0) & '0';
          fu_shift_flg(0) <= op_a_v(data_width_c-1);
        when sft_lsr_c => -- logical shift right
          shifter_dat_v   := '0' & op_a_v(data_width_c-1 downto 1);
          fu_shift_flg(0) <= op_a_v(0);
        when sft_rlc_c => -- rotate left through carry
          shifter_dat_v   := op_a_v(data_width_c-2 downto 0) & cflag_v;
          fu_shift_flg(0) <= op_a_v(data_width_c-1);
        when sft_rrc_c => -- rotate right through carry
          shifter_dat_v   := cflag_v & op_a_v(data_width_c-1 downto 1);
          fu_shift_flg(0) <= op_a_v(0);
        when others    => -- swap halfwords (sft_swp_c)
          shifter_dat_v   := op_a_v(data_width_c/2-1 downto 0) & op_a_v(data_width_c-1 downto data_width_c/2);
          fu_shift_flg(0) <= op_a_v(data_width_c-1);
      end case;
      fu_shift_res <= shifter_dat_v;

      -- overflow flag --
      fu_shift_flg(1) <= op_a_v(data_width_c-1) xor shifter_dat_v(data_width_c-1);

    end process fu_shifter_core;


  -- Functional Unit: Logical Core -----------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    fu_logic_core: process(ex_ctrl_bus_i, op_a_int, op_b_int, flag_bus_i)
    begin
      -- keep flags --
      fu_logic_flg(0) <= flag_bus_i(flag_c_c);
      fu_logic_flg(1) <= flag_bus_i(flag_o_c);

      -- logic function --
      case (ex_ctrl_bus_i(ctrl_alu_fs_2_c downto ctrl_alu_fs_0_c)) is
        when alu_and_c  => fu_logic_res <= op_a_int and op_b_int;
        when alu_nand_c => fu_logic_res <= op_a_int nand op_b_int;
        when alu_orr_c  => fu_logic_res <= op_a_int or op_b_int;
        when alu_eor_c  => fu_logic_res <= op_a_int xor op_b_int;
        when alu_bic_c  => fu_logic_res <= op_a_int and (not op_b_int);
        when others     => fu_logic_res    <= (others => '0');
                fu_logic_flg(0) <= '0';
                fu_logic_flg(1) <= '0';
      end case;
    end process fu_logic_core;


  -- Function Selector -----------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    -- data result --
    alu_res_int <= fu_arith_res or fu_shift_res or fu_logic_res;

    -- carry flag --
    flag_bus_o(flag_c_c) <= fu_arith_flg(0) or fu_shift_flg(0) or fu_logic_flg(0);

    -- overflow flag --
    flag_bus_o(flag_o_c) <= fu_arith_flg(1) or fu_shift_flg(1) or fu_logic_flg(0);


  -- Parity Computation ----------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    parity_gen: process(op_a_int)
      variable par_v : std_ulogic;
    begin
      par_v := '0';
      for i in 0 to data_width_c-1 loop
        par_v := par_v xor op_a_int(i);
      end loop;
      parity_bit <= par_v;
    end process parity_gen;


  -- Additional Flag Computation -------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------

    -- zero detector --
    -- ladies and gentleman, the critical path!
    is_zero              <= '1' when (to_integer(unsigned(alu_res_int)) = 0) else '0'; -- zero detector
    extnd_zero           <= (flag_bus_i(flag_z_c) and is_zero) when (ex_ctrl_bus_i(ctrl_alu_zf_opt_c) = '0') else (flag_bus_i(flag_z_c) or is_zero); -- extended zero detector
    flag_bus_o(flag_z_c) <= extnd_zero when (ex_ctrl_bus_i(ctrl_alu_usez_c) = '1') else is_zero; -- (extended) zero flag

    -- negative flag --
    flag_bus_o(flag_n_c) <= alu_res_int(data_width_c-1); -- negative flag

    -- t-flag update --
    sel_bit              <= op_a_int(to_integer(unsigned(op_b_int(3 downto 0)))); -- selected bit
    t_flag_func          <= parity_bit when (ex_ctrl_bus_i(ctrl_get_par_c) = '1') else sel_bit; -- parity or selected bit
    inv_bit              <= (not t_flag_func) when (ex_ctrl_bus_i(ctrl_tf_inv_c) = '1') else t_flag_func; -- invert bit?
    transf_int           <= inv_bit when (ex_ctrl_bus_i(ctrl_tf_store_c) = '1') else flag_bus_i(flag_t_c); -- transfer flag
    flag_bus_o(flag_t_c) <= transf_int;

    -- t-flag for mask generation (this is some kind of forwarding to the opcode decoder) --
    mask_t_flag_o        <= transf_int when (ex_ctrl_bus_i(ctrl_en_c) = '1') and (ex_ctrl_bus_i(ctrl_tf_store_c) = '1') else flag_bus_i(flag_t_c);


  -- Multiplier Kernel (signed) --------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    -- operand gating --
    mul_op_a <= op_a_int when (ex_ctrl_bus_i(ctrl_use_mul_c) = '1') else (others => '0');
    mul_op_b <= op_b_int when (ex_ctrl_bus_i(ctrl_use_mul_c) = '1') else (others => '0');

    -- multiplier core (signed!) --
    mul_buffer: process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          mul_res_o <= (others => '0');
        elsif (ce_i = '1') then
          if (build_mul_c = true) then
            if (signed_mul_c = true) then
              mul_res_o <= std_ulogic_vector(signed(mul_op_a) * signed(mul_op_b));
            else
              mul_res_o <= std_ulogic_vector(unsigned(mul_op_a) * unsigned(mul_op_b));
            end if;
          else
            mul_res_o <= (others => '0');
          end if;
        end if;
      end if;
    end process mul_buffer;


  -- Module Data Output ----------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------

    -- coprocessor interface --
    cp_cp0_en_o <= ex_ctrl_bus_i(ctrl_en_c) and ex_ctrl_bus_i(ctrl_cp_acc_c) and (not ex_ctrl_bus_i(ctrl_cp_id_c)); -- cp 0 access
    cp_cp1_en_o <= ex_ctrl_bus_i(ctrl_en_c) and ex_ctrl_bus_i(ctrl_cp_acc_c) and      ex_ctrl_bus_i(ctrl_cp_id_c);  -- cp 1 access
    cp_op_o     <= ex_ctrl_bus_i(ctrl_cp_trans_c); -- data transfer / cp operation
    cp_dat_o    <= op_a_int; -- data output
    cp_rw_o     <= ex_ctrl_bus_i(ctrl_cp_wr_c); -- read/write transfer
    cp_cmd_o(cp_op_a_msb_c downto cp_op_a_lsb_c) <= ex_ctrl_bus_i(ctrl_cp_rd_2_c  downto ctrl_cp_rd_0_c)  when (ex_ctrl_bus_i(ctrl_cp_acc_c) = '1') else (others => '0');  -- cp destination / op a reg
    cp_cmd_o(cp_op_b_msb_c downto cp_op_b_lsb_c) <= ex_ctrl_bus_i(ctrl_cp_ra_2_c  downto ctrl_cp_ra_0_c)  when (ex_ctrl_bus_i(ctrl_cp_acc_c) = '1') else (others => '0');  -- cp op b reg
    cp_cmd_o(cp_cmd_msb_c  downto cp_cmd_lsb_c)  <= ex_ctrl_bus_i(ctrl_cp_cmd_2_c downto ctrl_cp_cmd_0_c) when (ex_ctrl_bus_i(ctrl_cp_acc_c) = '1') else (others => '0'); -- cp command

    -- data output --
    msr_data_o  <= op_b_int;    -- msr write data
    alu_res_o   <= alu_res_int; -- alu result
    bp_opa_o    <= op_a_int;    -- operand a bypass out (address base for mem access)

    -- link_address/mem_w_data port --
    bp_opc_o    <= pc_1d_i when (ex_ctrl_bus_i(ctrl_link_c) = '1') else op_c_int; -- operand c bypass out (data for mem write access) or link address

    -- memory system --
    mem_req_o   <= ex_ctrl_bus_i(ctrl_en_c) and ex_ctrl_bus_i(ctrl_mem_acc_c); -- mem access in next cycle



end alu_structure;
