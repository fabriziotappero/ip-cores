-- ########################################################
-- #       << ATLAS Project - System Coprocessor >>       #
-- # **************************************************** #
-- #  Top entity of the system extension coprocessor.     #
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

entity system_cp is
-- ###############################################################################################
-- ##           Module Configuration                                                            ##
-- ###############################################################################################
  generic	(
        clock_speed_g   : std_ulogic_vector(31 downto 0) := x"00000000" -- clock speed in Hz
      );
  port	(
-- ###############################################################################################
-- ##           Global Control                                                                  ##
-- ###############################################################################################

        clk_i           : in std_ulogic; -- global clock line
        rst_i           : in std_ulogic; -- global reset line, sync, high-active
        ice_i           : in std_ulogic; -- interface clock enable, high-active

-- ###############################################################################################
-- ##           Processor Interface                                                             ##
-- ###############################################################################################

        cp_en_i         : in  std_ulogic; -- access coprocessor
        cp_op_i         : in  std_ulogic; -- data transfer/processing
        cp_rw_i         : in  std_ulogic; -- read/write access
        cp_cmd_i        : in  std_ulogic_vector(cp_cmd_width_c-1 downto 0); -- register addresses / cmd
        cp_dat_i        : in  std_ulogic_vector(data_width_c-1   downto 0); -- write data
        cp_dat_o        : out std_ulogic_vector(data_width_c-1   downto 0); -- read data
        cp_irq_o        : out std_ulogic; -- unit interrupt request

        sys_mode_i      : in  std_ulogic; -- current operating mode
        int_exe_i       : in  std_ulogic; -- interrupt beeing executed

-- ###############################################################################################
-- ##           Memory Interface                                                                ##
-- ###############################################################################################

        mem_ip_adr_o    : out std_ulogic_vector(15 downto 0); -- instruction page
        mem_dp_adr_o    : out std_ulogic_vector(15 downto 0); -- data page

-- ###############################################################################################
-- ##           Peripheral Communication Interface                                              ##
-- ###############################################################################################

        -- uart --
        uart_rxd_i      : in  std_ulogic; -- receiver input
        uart_txd_o      : out std_ulogic; -- uart transmitter output

        -- spi --
        spi_mosi_o      : out std_ulogic_vector(07 downto 0); -- serial data out
        spi_miso_i      : in  std_ulogic_vector(07 downto 0); -- serial data in
        spi_sck_o       : out std_ulogic_vector(07 downto 0); -- serial clock out
        spi_cs_o        : out std_ulogic_vector(07 downto 0); -- chip select (low active)

        -- parallel io --
        pio_out_o       : out std_ulogic_vector(15 downto 0); -- parallel output
        pio_in_i        : in  std_ulogic_vector(15 downto 0); -- parallel input

        -- system io --
        sys_out_o       : out std_ulogic_vector(07 downto 0); -- system output
        sys_in_i        : in  std_ulogic_vector(07 downto 0); -- system input

        -- irqs --
        irq_i           : in  std_ulogic; -- IRQ

-- ###############################################################################################
-- ##           Wishbone Bus                                                                    ##
-- ###############################################################################################

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
end system_cp;

architecture system_cp_behav of system_cp is

  -- module addresses --
  constant sys0_module_c : std_ulogic_vector(1 downto 0) := "00";
  constant sys1_module_c : std_ulogic_vector(1 downto 0) := "01";
  constant com0_module_c : std_ulogic_vector(1 downto 0) := "10";
  constant com1_module_c : std_ulogic_vector(1 downto 0) := "11";

  -- module interface --
  type module_interface_t is record
    data_o  : std_ulogic_vector(data_width_c-1 downto 0);
    w_en    : std_ulogic;
    r_en    : std_ulogic;
    cmd_exe : std_ulogic;
  end record;

  signal sys_0_module : module_interface_t;
  signal sys_1_module : module_interface_t;
  signal com_0_module : module_interface_t;
  signal com_1_module : module_interface_t;

  -- raw interrupt signals --
  signal int_assign  : std_ulogic_vector(7 downto 0);
  signal timer_irq   : std_ulogic;
  signal uart_rx_irq : std_ulogic;
  signal uart_tx_irq : std_ulogic;
  signal spi_irq     : std_ulogic;
  signal pio_irq     : std_ulogic;
  signal wb_core_irq : std_ulogic;

  -- internals --
  signal read_acc : std_ulogic; -- true read access
  signal cmd_exe  : std_ulogic; -- true coprocessor command

begin

  -- Write Access Logic ----------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    ctrl_w_acc: process(cp_en_i, cp_rw_i, cp_op_i, cp_cmd_i)
      variable valid_acc_v : std_ulogic;
    begin
      -- valid write access? --
      valid_acc_v := cp_en_i and cp_rw_i and cp_op_i;

      -- address decoder --
      sys_0_module.w_en <= '0';
      sys_1_module.w_en <= '0';
      com_0_module.w_en <= '0';
      com_1_module.w_en <= '0';
      case (cp_cmd_i(cp_op_a_msb_c-1 downto cp_op_a_lsb_c)) is
        when sys0_module_c => sys_0_module.w_en <= valid_acc_v;
        when sys1_module_c => sys_1_module.w_en <= valid_acc_v;
        when com0_module_c => com_0_module.w_en <= valid_acc_v;
        when com1_module_c => com_1_module.w_en <= valid_acc_v;
        when others        => null;
      end case;
    end process ctrl_w_acc;


  -- Read Access Logic -----------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    ctrl_r_acc: process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          cp_dat_o <= (others => '0');
        elsif (ice_i = '1') then -- clock enabled
          if (read_acc = '1') then -- valid read
            case (cp_cmd_i(cp_op_b_msb_c-1 downto cp_op_b_lsb_c)) is
              when sys0_module_c => cp_dat_o <= sys_0_module.data_o;
              when sys1_module_c => cp_dat_o <= sys_1_module.data_o;
              when com0_module_c => cp_dat_o <= com_0_module.data_o;
              when com1_module_c => cp_dat_o <= com_1_module.data_o;
              when others        => cp_dat_o <= (others => '0');
            end case;
          else
            cp_dat_o <= (others => '0');
          end if;
        end if;
      end if;
    end process ctrl_r_acc;

    -- module read enable --
    read_acc <= cp_en_i and (not cp_rw_i) and cp_op_i; -- true read access
    sys_0_module.r_en    <= read_acc when (cp_cmd_i(cp_op_b_msb_c-1 downto cp_op_b_lsb_c) = sys0_module_c) else '0';
    sys_1_module.r_en    <= read_acc when (cp_cmd_i(cp_op_b_msb_c-1 downto cp_op_b_lsb_c) = sys1_module_c) else '0';
    com_0_module.r_en    <= read_acc when (cp_cmd_i(cp_op_b_msb_c-1 downto cp_op_b_lsb_c) = com0_module_c) else '0';
    com_1_module.r_en    <= read_acc when (cp_cmd_i(cp_op_b_msb_c-1 downto cp_op_b_lsb_c) = com1_module_c) else '0';

    -- module execute command --
    cmd_exe  <= cp_en_i and (not cp_op_i); -- true coprocessor command
    sys_0_module.cmd_exe <= cmd_exe  when (cp_cmd_i(cp_op_b_msb_c-1 downto cp_op_b_lsb_c) = sys0_module_c) else '0';
    sys_1_module.cmd_exe <= cmd_exe  when (cp_cmd_i(cp_op_b_msb_c-1 downto cp_op_b_lsb_c) = sys1_module_c) else '0';
    com_0_module.cmd_exe <= cmd_exe  when (cp_cmd_i(cp_op_b_msb_c-1 downto cp_op_b_lsb_c) = com0_module_c) else '0';
    com_1_module.cmd_exe <= cmd_exe  when (cp_cmd_i(cp_op_b_msb_c-1 downto cp_op_b_lsb_c) = com1_module_c) else '0';


  -- System Controller 0 ---------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    system_ctrl_0: sys_0_core
    port map (
          -- host interface --
          clk_i           => clk_i,               -- global clock line
          rst_i           => rst_i,               -- global reset line, sync, high-active
          ice_i           => ice_i,               -- interface clock enable, high-active
          w_en_i          => sys_0_module.w_en,   -- write enable
          r_en_i          => sys_0_module.r_en,   -- read enable
          adr_i           => cp_cmd_i(cp_cmd_msb_c downto cp_cmd_lsb_c), -- access address
          dat_i           => cp_dat_i,            -- write data
          dat_o           => sys_0_module.data_o, -- read data

          -- irq lines --
          timer_irq_o     => timer_irq,           -- timer irq
          irq_i           => int_assign,          -- irq input
          irq_o           => cp_irq_o             -- interrupt request to cpu
        );

    -- irq assignment --
    int_assign(0) <= timer_irq;   -- high precision timer irq
    int_assign(1) <= wb_core_irq; -- wishbone interface ctrl irq
    int_assign(2) <= uart_rx_irq; -- uart data received irq
    int_assign(3) <= uart_tx_irq; -- uart data send irq
    int_assign(4) <= spi_irq;     -- spi transfer done irq
    int_assign(5) <= pio_irq;     -- pio input change irq
    int_assign(6) <= '0';         -- reserved
    int_assign(7) <= irq_i;       -- 'external' irq


  -- System Controller 1 ---------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    system_ctrl_1: sys_1_core
    generic map (
            clk_speed_g => clock_speed_g         -- clock speed (inhz)
          )
    port map (
          -- host interface --
          clk_i           => clk_i,               -- global clock line
          rst_i           => rst_i,               -- global reset line, sync, high-active
          ice_i           => ice_i,               -- interface clock enable, high-active
          w_en_i          => sys_1_module.w_en,   -- write enable
          r_en_i          => sys_1_module.r_en,   -- read enable
          adr_i           => cp_cmd_i(cp_cmd_msb_c downto cp_cmd_lsb_c), -- access address
          dat_i           => cp_dat_i,            -- write data
          dat_o           => sys_1_module.data_o, -- read data

          -- cpu-special --
          sys_mode_i      => sys_mode_i,          -- current operating mode
          int_exe_i       => int_exe_i,           -- interrupt beeing executed

          -- memory interface --
          mem_ip_adr_o    => mem_ip_adr_o,        -- instruction page
          mem_dp_adr_o    => mem_dp_adr_o         -- data page
        );


  -- Communication Controller 0 --------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    communication_ctrl_0: com_0_core
    port map (
          -- host interface --
          clk_i           => clk_i,               -- global clock line
          rst_i           => rst_i,               -- global reset line, sync, high-active
          ice_i           => ice_i,               -- interface clock enable, high-active
          w_en_i          => com_0_module.w_en,   -- write enable
          r_en_i          => com_0_module.r_en,   -- read enable
          adr_i           => cp_cmd_i(cp_cmd_msb_c downto cp_cmd_lsb_c), -- access address
          dat_i           => cp_dat_i,            -- write data
          dat_o           => com_0_module.data_o, -- read data

          -- interrupt lines --
          uart_rx_irq_o   => uart_rx_irq,         -- uart irq "data available"
          uart_tx_irq_o   => uart_tx_irq,         -- uart irq "sending done"
          spi_irq_o       => spi_irq,             -- spi irq "transfer done"
          pio_irq_o       => pio_irq,             -- pio input pin change irq

          -- peripheral interface --
          uart_txd_o      => uart_txd_o,          -- uart transmitter
          uart_rxd_i      => uart_rxd_i,          -- uart receiver
          spi_mosi_o      => spi_mosi_o,          -- spi master out slave in
          spi_miso_i      => spi_miso_i,          -- spi master in slave out
          spi_sck_o       => spi_sck_o,           -- spi clock out
          spi_cs_o        => spi_cs_o,            -- spi chip select
          pio_in_i        => pio_in_i,            -- parallel input
          pio_out_o       => pio_out_o,           -- parallel output
          sys_io_i        => sys_in_i,            -- system input
          sys_io_o        => sys_out_o            -- system output
        );


  -- Communication Controller 1 --------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    communication_ctrl_1: com_1_core
    port map (
          -- host interface --
          wb_clk_o        => wb_clk_o,            -- bus clock
          wb_rst_o        => wb_rst_o,            -- bus reset, sync, high active
          clk_i           => clk_i,               -- global clock line
          rst_i           => rst_i,               -- global reset line, sync, high-active
          ice_i           => ice_i,               -- interface clock enable, high-active
          w_en_i          => com_1_module.w_en,   -- write enable
          r_en_i          => com_1_module.r_en,   -- read enable
          cmd_exe_i       => com_1_module.cmd_exe,-- execute command
          adr_i           => cp_cmd_i(cp_cmd_msb_c downto cp_cmd_lsb_c), -- access address/command
          dat_i           => cp_dat_i,            -- write data
          dat_o           => com_1_module.data_o, -- read data
          irq_o           => wb_core_irq,         -- interrupt request

          -- wishbone bus --
          wb_adr_o        => wb_adr_o,            -- address
          wb_sel_o        => wb_sel_o,            -- byte select
          wb_data_o       => wb_data_o,           -- data out
          wb_data_i       => wb_data_i,           -- data in
          wb_we_o         => wb_we_o,             -- read/write
          wb_cyc_o        => wb_cyc_o,            -- cycle enable
          wb_stb_o        => wb_stb_o,            -- strobe
          wb_ack_i        => wb_ack_i,            -- acknowledge
          wb_err_i        => wb_err_i             -- bus error
        );



end system_cp_behav;
