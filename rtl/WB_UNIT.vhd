-- ########################################################
-- #        << ATLAS Project - Data Write-Back >>         #
-- # **************************************************** #
-- #  Data write back selector for register file input.   #
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

entity wb_unit is
  port	(
-- ###############################################################################################
-- ##           Global Control                                                                  ##
-- ###############################################################################################

        clk_i         : in  std_ulogic; -- global clock line
        ce_i          : in  std_ulogic; -- clock enable
        rst_i         : in  std_ulogic; -- global reset line, sync, high-active

-- ###############################################################################################
-- ##           Function Control                                                                ##
-- ###############################################################################################

        wb_ctrl_bus_i : in  std_ulogic_vector(ctrl_width_c-1 downto 0); -- wb stage control

-- ###############################################################################################
-- ##           Data Input                                                                      ##
-- ###############################################################################################

        mem_wb_dat_i  : in  std_ulogic_vector(data_width_c-1 downto 0); -- memory read data
        alu_wb_dat_i  : in  std_ulogic_vector(data_width_c-1 downto 0); -- alu read data
        mem_adr_fb_i  : in  std_ulogic_vector(data_width_c-1 downto 0); -- memory address feedback

-- ###############################################################################################
-- ##           Data Output                                                                     ##
-- ###############################################################################################

        wb_data_o     : out std_ulogic_vector(data_width_c-1 downto 0); -- write back data
        wb_fwd_o      : out std_ulogic_vector(fwd_width_c-1  downto 0)  -- wb stage forwarding path
      );
end wb_unit;

architecture wb_structure of wb_unit is

  -- pipeline register --
  signal alu_ff : std_ulogic_vector(data_width_c-1 downto 0);

  -- write-back source select --
  signal wb_data_int : std_ulogic_vector(data_width_c-1 downto 0);

  -- aligned mem data --
  signal mem_adr_fb     : std_ulogic_vector(data_width_c-1 downto 0);
  signal mem_wb_dat_int : std_ulogic_vector(data_width_c-1 downto 0);

begin

  -- Pipeline Register -----------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    pipe_reg: process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          alu_ff     <= (others => '0');
          mem_adr_fb <= (others => '0');
        elsif (ce_i = '1') then
          alu_ff     <= alu_wb_dat_i;
          mem_adr_fb <= mem_adr_fb_i;
        end if;
      end if;
    end process pipe_reg;


  -- Data Alignment --------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    dat_align: process(mem_adr_fb, mem_wb_dat_i)
      variable dat_end_v : std_ulogic_vector(data_width_c-1 downto 0);
    begin
      -- endianness converter --
      if (big_endian_c = false) then
        dat_end_v := mem_wb_dat_i(data_width_c/2-1 downto 0) & mem_wb_dat_i(data_width_c-1 downto data_width_c/2);
      else
        dat_end_v := mem_wb_dat_i;
      end if;

      -- unaligned access? --
      if (word_mode_en_c = false) then -- byte-addressed memory
        if (mem_adr_fb(0) = '1') then -- swap bytes
          mem_wb_dat_int <= dat_end_v(data_width_c/2-1 downto 0) & dat_end_v(data_width_c-1 downto data_width_c/2);
        else
          mem_wb_dat_int <= dat_end_v;
        end if;
      else -- word-addressed memory
        mem_wb_dat_int <= dat_end_v;
      end if;
    end process dat_align;


  -- Module Data Output ----------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    -- route mem data if valid mem-read-access
    wb_data_int <= mem_wb_dat_int when (wb_ctrl_bus_i(ctrl_rd_mem_acc_c) = '1') else alu_ff;
    wb_data_o   <= wb_data_int;


  -- Forwarding Path Output ------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------

    -- forwarding data --
    wb_fwd_o(fwd_dat_msb_c downto fwd_dat_lsb_c) <= wb_data_int;

    -- destination address --
    wb_fwd_o(fwd_adr_3_c downto fwd_adr_0_c) <= wb_ctrl_bus_i(ctrl_rd_3_c downto ctrl_rd_0_c);

    -- valid forwarding --
    wb_fwd_o(fwd_en_c) <= wb_ctrl_bus_i(ctrl_wb_en_c);



end wb_structure;
