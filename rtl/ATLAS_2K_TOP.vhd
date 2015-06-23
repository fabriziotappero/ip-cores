-- ########################################################
-- #       << ATLAS Project - ATLAS 2k Processor >>       #
-- # **************************************************** #
-- #  This is the top entity oth ATLAS 2k processor.      #
-- #  See the core's data sheet for more information.     #
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

entity atlas_2k_top is
-- ###############################################################################################
-- ##           Configuration                                                                   ##
-- ###############################################################################################
  generic (
        clk_speed_g     : std_ulogic_vector(31 downto 0) := x"00000000" -- clock speed (in Hz)
      );
-- ###############################################################################################
-- ##           Global Control                                                                  ##
-- ###############################################################################################
  port	(
        clk_i           : in  std_ulogic; -- global clock line
        rst_i           : in  std_ulogic; -- global reset line, sync, high-active
        ce_i            : in  std_ulogic; -- global clock enable, high active

-- ###############################################################################################
-- ##           Coprocessor Interface                                                           ##
-- ###############################################################################################

        cp_en_o         : out std_ulogic; -- access to cp0
        cp_ice_o        : out std_ulogic; -- cp interface clock enable
        cp_op_o         : out std_ulogic; -- data transfer/processing
        cp_rw_o         : out std_ulogic; -- read/write access
        cp_cmd_o        : out std_ulogic_vector(08 downto 0); -- register addresses / cmd
        cp_dat_o        : out std_ulogic_vector(data_width_c-1 downto 0); -- write data
        cp_dat_i        : in  std_ulogic_vector(data_width_c-1 downto 0); -- read data cp0

-- ###############################################################################################
-- ##           Memory Interface                                                                ##
-- ###############################################################################################

        mem_i_page_o    : out std_ulogic_vector(data_width_c-1 downto 0); -- instruction page
        mem_i_adr_o     : out std_ulogic_vector(data_width_c-1 downto 0); -- instruction adr
        mem_i_dat_i     : in  std_ulogic_vector(data_width_c-1 downto 0); -- instruction input

        mem_d_en_o      : out std_ulogic; -- access enable
        mem_d_rw_o      : out std_ulogic; -- read/write
        mem_d_page_o    : out std_ulogic_vector(data_width_c-1 downto 0); -- data page
        mem_d_adr_o     : out std_ulogic_vector(data_width_c-1 downto 0); -- data adr
        mem_d_dat_o     : out std_ulogic_vector(data_width_c-1 downto 0); -- data out
        mem_d_dat_i     : in  std_ulogic_vector(data_width_c-1 downto 0); -- data in

        critical_irq_i  : in  std_ulogic; -- critical error irq

-- ###############################################################################################
-- ##           IO Interface                                                                    ##
-- ###############################################################################################

        -- uart --
        uart_rxd_i      : in  std_ulogic; -- uart receiver input
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
        irq_i           : in  std_ulogic; -- irq

-- ###############################################################################################
-- ##          Wishbone Bus                                                                     ##
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
end atlas_2k_top;

architecture atlas_2k_top_behav of atlas_2k_top is

  -- global control --
  signal sys_mode    : std_ulogic; -- current processor mode
  signal sys_int_exe : std_ulogic; -- processing irq

  -- coprocessor signals --
  signal usr_cp_en  : std_ulogic; -- access user coprocessor
  signal sys_cp_en  : std_ulogic; -- access system coprocessor
  signal cp_op      : std_ulogic; -- transfer/data processing
  signal cp_rw      : std_ulogic; -- read/write access
  signal cp_cmd     : std_ulogic_vector(08 downto 0); -- register addresses / cmd
  signal cp_w_data  : std_ulogic_vector(data_width_c-1 downto 0); -- write data
  signal sys_cp_drb : std_ulogic_vector(data_width_c-1 downto 0); -- system coprocessor data readback
  signal cp_data_rb : std_ulogic_vector(data_width_c-1 downto 0); -- coprocessor data readback

  -- cpu bus --
  signal cpu_d_req     : std_ulogic; -- data access request
  signal cpu_d_rw      : std_ulogic; -- read/write access
  signal cpu_d_adr     : std_ulogic_vector(data_width_c-1 downto 0); -- access address
  signal cpu_d_w_data  : std_ulogic_vector(data_width_c-1 downto 0); -- write data
  signal cpu_d_r_data  : std_ulogic_vector(data_width_c-1 downto 0); -- read data
  signal cpu_i_adr     : std_ulogic_vector(data_width_c-1 downto 0); -- instruction address
  signal cpu_i_data    : std_ulogic_vector(data_width_c-1 downto 0); -- instruction word
  signal cp_dat_i_sync : std_ulogic_vector(data_width_c-1 downto 0); -- external input sync

  -- mmu --
  signal i_page : std_ulogic_vector(data_width_c-1 downto 0); -- instruction page
  signal d_page : std_ulogic_vector(data_width_c-1 downto 0); -- data page

  -- boot mem --
  signal boot_i_adr   : std_ulogic_vector(15 downto 0); -- instruction adr
  signal boot_i_dat   : std_ulogic_vector(15 downto 0); -- instruction out
  signal boot_d_en    : std_ulogic; -- access enable
  signal boot_d_rw    : std_ulogic; -- read/write
  signal boot_d_adr   : std_ulogic_vector(15 downto 0); -- data adr
  signal boot_d_dat_o : std_ulogic_vector(15 downto 0); -- data in
  signal boot_d_dat_i : std_ulogic_vector(15 downto 0); -- data out

  -- irq lines --
  signal sys_cp_irq : std_ulogic; -- irq from system coprocessor

begin

  -- Atlas CPU Core --------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    cpu_core: atlas_cpu
    port map (
      -- global control --
      clk_i           => clk_i,          -- global clock line
      rst_i           => rst_i,          -- global reset line, sync, high-active
      ce_i            => ce_i,           -- clock enable
      
      -- instruction interface --
      instr_adr_o     => cpu_i_adr,      -- instruction byte adr
      instr_dat_i     => cpu_i_data,     -- instruction input
      
      -- data interface --
      sys_mode_o      => sys_mode,       -- current operating mode
      sys_int_o       => sys_int_exe,    -- interrupt processing
      mem_req_o       => cpu_d_req,      -- mem access in next cycle
      mem_rw_o        => cpu_d_rw,       -- read write
      mem_adr_o       => cpu_d_adr,      -- data byte adr
      mem_dat_o       => cpu_d_w_data,   -- write data
      mem_dat_i       => cpu_d_r_data,   -- read data
      
      -- coprocessor interface --
      usr_cp_en_o     => usr_cp_en,      -- access to cp0
      sys_cp_en_o     => sys_cp_en,      -- access to cp1
      cp_op_o         => cp_op,          -- data transfer/processing
      cp_rw_o         => cp_rw,          -- read/write access
      cp_cmd_o        => cp_cmd,         -- register addresses / cmd
      cp_dat_o        => cp_w_data,      -- write data
      cp_dat_i        => cp_data_rb,     -- read data cp0 or cp1
      
      -- interrupt lines --
      ext_int_0_i     => critical_irq_i, -- critical error irq
      ext_int_1_i     => sys_cp_irq      -- sys cp irq
    );

    -- external cp data in sync --
    cp_dat_in_sync: process (clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          cp_dat_i_sync <= (others => '0');
        elsif (ce_i = '1') then
          if (usr_cp_en = '1') then
            cp_dat_i_sync <= cp_dat_i;
          else
            cp_dat_i_sync <= (others => '0');
          end if;
        end if;
      end if;
    end process cp_dat_in_sync;

    -- external coprocessor interface --
    cp_en_o    <= usr_cp_en;
    cp_op_o    <= cp_op;
    cp_rw_o    <= cp_rw;
    cp_cmd_o   <= cp_cmd;
    cp_dat_o   <= cp_w_data;
    cp_data_rb <= sys_cp_drb or cp_dat_i_sync;
    cp_ice_o   <= ce_i;


  -- System Coprocessor ----------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    system_coprocessor: system_cp
    generic map	(
     clock_speed_g   => clk_speed_g     -- clock speed in hz
    )
    port map (
      -- global control --
      clk_i           => clk_i,          -- global clock line
      rst_i           => rst_i,          -- global reset line, sync, high-active
      ice_i           => ce_i,           -- interface clock enable, high-active
      
      -- processor interface --
      cp_en_i         => sys_cp_en,      -- access coprocessor
      cp_op_i         => cp_op,          -- data transfer/processing
      cp_rw_i         => cp_rw,          -- read/write access
      cp_cmd_i        => cp_cmd,         -- register addresses / cmd
      cp_dat_i        => cp_w_data,      -- write data
      cp_dat_o        => sys_cp_drb,     -- read data
      cp_irq_o        => sys_cp_irq,     -- unit interrupt request
      
      sys_mode_i      => sys_mode,       -- current operating mode
      int_exe_i       => sys_int_exe,    -- interrupt beeing executed
      
      -- memory interface --
      mem_ip_adr_o    => i_page,         -- instruction page
      mem_dp_adr_o    => d_page,         -- data page
      
      -- io interface --
      uart_rxd_i      => uart_rxd_i,     -- receiver input
      uart_txd_o      => uart_txd_o,     -- uart transmitter output
      spi_sck_o       => spi_sck_o,      -- serial clock output
      spi_mosi_o      => spi_mosi_o,     -- serial data output
      spi_miso_i      => spi_miso_i,     -- serial data input
      spi_cs_o        => spi_cs_o,       -- device select
      pio_out_o       => pio_out_o,      -- parallel output
      pio_in_i        => pio_in_i,       -- parallel input
      
      -- system io --
      sys_out_o       => sys_out_o,      -- system parallel output
      sys_in_i        => sys_in_i,       -- system parallel input
      
      -- irq lines --
      irq_i           => irq_i,          -- external irq
      
      -- wishbone bus --
      wb_clk_o        => wb_clk_o,       -- bus clock
      wb_rst_o        => wb_rst_o,       -- bus reset, sync, high active
      wb_adr_o        => wb_adr_o,       -- address
      wb_sel_o        => wb_sel_o,       -- byte select
      wb_data_o       => wb_data_o,      -- data out
      wb_data_i       => wb_data_i,      -- data in
      wb_we_o         => wb_we_o,        -- read/write
      wb_cyc_o        => wb_cyc_o,       -- cycle enable
      wb_stb_o        => wb_stb_o,       -- strobe
      wb_ack_i        => wb_ack_i,       -- acknowledge
      wb_err_i        => wb_err_i        -- bus error
    );


  -- Memory Gate -----------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    memory_gate: mem_gate
    port map (
      -- host interface --
      clk_i           => clk_i,          -- global clock line
      rst_i           => rst_i,          -- global reset line, sync, high-active
      
      i_adr_i         => cpu_i_adr,      -- instruction adr
      i_dat_o         => cpu_i_data,     -- instruction out
      d_req_i         => cpu_d_req,      -- request access in next cycle
      d_rw_i          => cpu_d_rw,       -- read/write
      d_adr_i         => cpu_d_adr,      -- data adr
      d_dat_i         => cpu_d_w_data,   -- data in
      d_dat_o         => cpu_d_r_data,   -- data out
      mem_ip_adr_i    => i_page,         -- instruction page
      mem_dp_adr_i    => d_page,         -- data page
      
      -- boot rom interface --
      boot_i_adr_o    => boot_i_adr,     -- instruction adr
      boot_i_dat_i    => boot_i_dat,     -- instruction out
      boot_d_en_o     => boot_d_en,      -- access enable
      boot_d_rw_o     => boot_d_rw,      -- read/write
      boot_d_adr_o    => boot_d_adr,     -- data adr
      boot_d_dat_o    => boot_d_dat_o,   -- data in
      boot_d_dat_i    => boot_d_dat_i,   -- data out
      
      -- memory interface --
      mem_i_page_o    => mem_i_page_o,   -- instruction page
      mem_i_adr_o     => mem_i_adr_o,    -- instruction adr
      mem_i_dat_i     => mem_i_dat_i,    -- instruction out
      mem_d_en_o      => mem_d_en_o,     -- access enable
      mem_d_rw_o      => mem_d_rw_o,     -- read/write
      mem_d_page_o    => mem_d_page_o,   -- instruction page
      mem_d_adr_o     => mem_d_adr_o,    -- data adr
      mem_d_dat_o     => mem_d_dat_o,    -- data in
      mem_d_dat_i     => mem_d_dat_i     -- data out
    );


  -- Bootloader Memory -----------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    bootloader_mem: boot_mem
    port map (
      -- host interface --
      clk_i           => clk_i,          -- global clock line
      i_adr_i         => boot_i_adr,     -- instruction adr
      i_dat_o         => boot_i_dat,     -- instruction out
      d_en_i          => boot_d_en,      -- access enable
      d_rw_i          => boot_d_rw,      -- read/write
      d_adr_i         => boot_d_adr,     -- data adr
      d_dat_i         => boot_d_dat_o,   -- data in
      d_dat_o         => boot_d_dat_i    -- data out
    );



end atlas_2k_top_behav;
