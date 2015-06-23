-- ########################################################
-- #        << ATLAS Project - Data Register File >>      #
-- # **************************************************** #
-- #  Main data register file, organized in two bank,     #
-- #  separated for each operating mode. Each bank holds  #
-- #  8 16-bit data registers.                            #
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

entity reg_file is
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

        wb_ctrl_bus_i   : in  std_ulogic_vector(ctrl_width_c-1 downto 0); -- wb stage control
        of_ctrl_bus_i   : in  std_ulogic_vector(ctrl_width_c-1 downto 0); -- of stage control

-- ###############################################################################################
-- ##           Data Input                                                                      ##
-- ###############################################################################################

        wb_data_i       : in  std_ulogic_vector(data_width_c-1 downto 0); -- write back data
        immediate_i     : in  std_ulogic_vector(data_width_c-1 downto 0); -- immediates
        pc_1d_i         : in  std_ulogic_vector(data_width_c-1 downto 0); -- pc 1x delayed
        wb_fwd_i        : in  std_ulogic_vector(fwd_width_c-1  downto 0); -- WB stage forwarding path

-- ###############################################################################################
-- ##           Data Output                                                                     ##
-- ###############################################################################################

        op_a_data_o     : out std_ulogic_vector(data_width_c-1 downto 0); -- operand a output
        op_b_data_o     : out std_ulogic_vector(data_width_c-1 downto 0); -- operand b output
        op_c_data_o     : out std_ulogic_vector(data_width_c-1 downto 0)  -- operand c output
      );
end reg_file;

architecture rf_structure of reg_file is

  -- register file --
  type   reg_file_mem_type is array (2*8-1 downto 0) of std_ulogic_vector(data_width_c-1 downto 0);
  signal reg_file_mem : reg_file_mem_type := (others => (others => '0'));

  -- operand multiplexer --
  signal op_a_int : std_ulogic_vector(data_width_c-1 downto 0);
  signal op_b_int : std_ulogic_vector(data_width_c-1 downto 0);

begin

  -- Data Register File ----------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    data_register_file: process(clk_i)
    begin
      -- sync write access --
      if rising_edge(clk_i) then
        if (wb_ctrl_bus_i(ctrl_wb_en_c) = '1') and (ce_i = '1') then -- valid write back
          reg_file_mem(to_integer(unsigned(wb_ctrl_bus_i(ctrl_rd_3_c downto ctrl_rd_0_c)))) <= wb_data_i;
        end if;
      end if;
    end process data_register_file;


  -- Operand Fetch Forwarding Unit -----------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    of_fwd: process(wb_fwd_i, of_ctrl_bus_i, reg_file_mem)
    begin
      -- operand a forwarding --
      if (wb_fwd_i(fwd_en_c) = '1') and (of_ctrl_bus_i(ctrl_ra_3_c downto ctrl_ra_0_c) = wb_fwd_i(fwd_adr_3_c downto fwd_adr_0_c)) then
        op_a_int <= wb_fwd_i(fwd_dat_msb_c downto fwd_dat_lsb_c);
      else
        op_a_int <= reg_file_mem(to_integer(unsigned(of_ctrl_bus_i(ctrl_ra_3_c downto ctrl_ra_0_c))));
      end if;

      -- operand b forwarding --
      if (wb_fwd_i(fwd_en_c) = '1') and (of_ctrl_bus_i(ctrl_rb_3_c downto ctrl_rb_0_c) = wb_fwd_i(fwd_adr_3_c downto fwd_adr_0_c)) then
        op_b_int <= wb_fwd_i(fwd_dat_msb_c downto fwd_dat_lsb_c);
      else
        op_b_int <= reg_file_mem(to_integer(unsigned(of_ctrl_bus_i(ctrl_rb_3_c downto ctrl_rb_0_c))));
      end if;
    end process of_fwd;


  -- Operand Multiplexer ---------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    op_a_data_o <= pc_1d_i     when (of_ctrl_bus_i(ctrl_ra_is_pc_c)  = '1') else op_a_int;
    op_b_data_o <= immediate_i when (of_ctrl_bus_i(ctrl_rb_is_imm_c) = '1') else op_b_int;
    op_c_data_o <= op_b_int;



end rf_structure;
