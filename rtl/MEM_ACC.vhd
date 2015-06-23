-- ########################################################
-- #      << ATLAS Project - Memory Access System >>      #
-- # **************************************************** #
-- #  This unit generates all neccessary signals for the  #
-- #  data memory interface. Furthermore, internal data   #
-- #  switching networks are located here.                #
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

entity MEM_ACC is
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

        ma_ctrl_bus_i   : in  std_ulogic_vector(ctrl_width_c-1 downto 0); -- ma stage control

-- ###############################################################################################
-- ##           Data Input                                                                      ##
-- ###############################################################################################

        alu_res_i       : in  std_ulogic_vector(data_width_c-1 downto 0); -- alu result
        mul_res_i       : in  std_ulogic_vector(2*data_width_c-1 downto 0); -- mul result
        adr_base_i      : in  std_ulogic_vector(data_width_c-1 downto 0); -- op_a bypass
        data_bp_i       : in  std_ulogic_vector(data_width_c-1 downto 0); -- op_b bypass
        cp_data_i       : in  std_ulogic_vector(data_width_c-1 downto 0); -- coprocessor rd data
        rd_msr_i        : in  std_ulogic_vector(data_width_c-1 downto 0); -- read data msr

        wb_fwd_i        : in  std_ulogic_vector(fwd_width_c-1  downto 0); -- wb stage forwarding path

-- ###############################################################################################
-- ##           Data Output                                                                     ##
-- ###############################################################################################

        data_o          : out std_ulogic_vector(data_width_c-1 downto 0); -- data output
        mem_adr_fb_o    : out std_ulogic_vector(data_width_c-1 downto 0); -- memory address feedback

        ma_fwd_o        : out std_ulogic_vector(fwd_width_c-1  downto 0); -- ma stage forwarding path

-- ###############################################################################################
-- ##           Memory (w) Interface                                                            ##
-- ###############################################################################################

        mem_adr_o       : out std_ulogic_vector(data_width_c-1 downto 0); -- address output
        mem_dat_o       : out std_ulogic_vector(data_width_c-1 downto 0); -- write data output
        mem_rw_o        : out std_ulogic -- read write
      );
end mem_acc;

architecture ma_structure of mem_acc is

  -- pipeline register --
  signal alu_res_ff  : std_ulogic_vector(data_width_c-1 downto 0);
  signal adr_base_ff : std_ulogic_vector(data_width_c-1 downto 0);
  signal data_bp_ff  : std_ulogic_vector(data_width_c-1 downto 0);

  -- alu data buffer --
  signal alu_res_buf : std_ulogic_vector(data_width_c-1 downto 0);

  -- internal signals --
  signal data_bp_int      : std_ulogic_vector(data_width_c-1 downto 0);
  signal alu_mac_dat      : std_ulogic_vector(data_width_c-1 downto 0);
  signal sys_cp_r_dat     : std_ulogic_vector(data_width_c-1 downto 0);
  signal sys_cp_alu_r_dat : std_ulogic_vector(data_width_c-1 downto 0);
  signal mul_res_int      : std_ulogic_vector(data_width_c-1 downto 0);

begin

  -- Pipeline Register -----------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    pipe_reg: process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          alu_res_ff  <= (others => '0');
          adr_base_ff <= (others => '0');
          data_bp_ff  <= (others => '0');
          alu_res_buf <= (others => '0');
        elsif (ce_i = '1') then
          alu_res_ff  <= alu_res_i;
          adr_base_ff <= adr_base_i;
          data_bp_ff  <= data_bp_i;
          alu_res_buf <= alu_res_ff;
        end if;
      end if;
    end process pipe_reg;


  -- Memory Access Forwarding Unit -----------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    ma_fwd: process(wb_fwd_i, ma_ctrl_bus_i, data_bp_ff)
    begin
      -- memory write data (op_b) forwarding --
      if (wb_fwd_i(fwd_en_c) = '1') and (ma_ctrl_bus_i(ctrl_mcyc_c) = '0') and (ma_ctrl_bus_i(ctrl_rb_3_c downto ctrl_rb_0_c) = wb_fwd_i(fwd_adr_3_c downto fwd_adr_0_c)) then
        data_bp_int <= wb_fwd_i(fwd_dat_msb_c downto fwd_dat_lsb_c); -- wb stage
      else
        data_bp_int <= data_bp_ff;
      end if;
    end process ma_fwd;


  -- Memory Address Generator and Data Alignment ---------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    w_mem_acc: process(ma_ctrl_bus_i, alu_res_buf, adr_base_ff, alu_res_ff, data_bp_int)
      variable mem_adr_v : std_ulogic_vector(data_width_c-1 downto 0);
      variable dat_end_v : std_ulogic_vector(data_width_c-1 downto 0);
    begin
      -- address origin --
      if (ma_ctrl_bus_i(ctrl_mem_daa_c) = '1') then
        mem_adr_v := alu_res_buf; -- use delayed address
      elsif (ma_ctrl_bus_i(ctrl_mem_bpba_c) = '1') then
        mem_adr_v := adr_base_ff; -- use bypassed address
      else
        mem_adr_v := alu_res_ff;
      end if;
      mem_adr_fb_o <= mem_adr_v; -- data alignment address
      mem_adr_o    <= mem_adr_v; -- memory address output

      -- endianness converter --
      if (big_endian_c = false) then
        dat_end_v := data_bp_int(data_width_c/2-1 downto 0) & data_bp_int(data_width_c-1 downto data_width_c/2);
      else
        dat_end_v := data_bp_int;
      end if;

      -- data alignment --
      if (word_mode_en_c = false) then -- byte-addressed memory
        if (mem_adr_v(0) = '1') then -- unaligned? -> swap bytes
          mem_dat_o <= dat_end_v(data_width_c/2-1 downto 0) & dat_end_v(data_width_c-1 downto data_width_c/2);
        else -- aligned
          mem_dat_o <= dat_end_v;
        end if;
      else -- word-addressed memory
        mem_dat_o <= dat_end_v;
      end if;
    end process w_mem_acc;

    -- r/w control --
    mem_rw_o <= ma_ctrl_bus_i(ctrl_mem_wr_c) and ma_ctrl_bus_i(ctrl_en_c);


  -- Stage Data Multiplexer ------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    no_mul_unit: -- syntheszie no mul unit at all
      if (build_mul_c = false) generate
        mul_res_int <= (others => '0');
        alu_mac_dat <= alu_res_ff;
      end generate no_mul_unit;

    synhesize_mul16_unit: -- synthesize 16-bit mul unit
      if (build_mul_c = true) and (build_mul32_c = false) generate
        mul_res_int <= (others => '0');
        alu_mac_dat <= mul_res_i(15 downto 0) when (ma_ctrl_bus_i(ctrl_use_mul_c) = '1') else alu_res_ff;
      end generate synhesize_mul16_unit;

    synhesize_mul32_unit: -- synthesize 32-bit mul unit
      if (build_mul_c = true) and (build_mul32_c = true) generate
        mul_res_int <= mul_res_i(31 downto 16) when (ma_ctrl_bus_i(ctrl_ext_mul_c) = '1') else mul_res_i(15 downto 0);
        alu_mac_dat <= mul_res_int when (ma_ctrl_bus_i(ctrl_use_mul_c) = '1') else alu_res_ff;
      end generate synhesize_mul32_unit;

    -- coprocessor input --
    sys_cp_r_dat <= cp_data_i when (ma_ctrl_bus_i(ctrl_rd_cp_acc_c) = '1') else rd_msr_i;

    -- multiplexers --
    sys_cp_alu_r_dat <= sys_cp_r_dat when (ma_ctrl_bus_i(ctrl_cp_msr_rd_c) = '1') else alu_mac_dat;
    data_o           <= data_bp_ff   when (ma_ctrl_bus_i(ctrl_link_c)      = '1') else sys_cp_alu_r_dat;


  -- Forwarding Path Output ------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------

    -- forwarding data --
    ma_fwd_o(fwd_dat_msb_c downto fwd_dat_lsb_c) <= sys_cp_alu_r_dat;

    -- destination address --
    ma_fwd_o(fwd_adr_3_c downto fwd_adr_0_c) <= ma_ctrl_bus_i(ctrl_rd_3_c downto ctrl_rd_0_c);

    -- valid forwarding --
    ma_fwd_o(fwd_en_c) <= ma_ctrl_bus_i(ctrl_wb_en_c);



end MA_STRUCTURE;
