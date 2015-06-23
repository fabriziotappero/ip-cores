-- #########################################################
-- #          << ATLAS Project - Basic System >>           #
-- # ***************************************************** #
-- #  This is the top entity of a simple implementation    #
-- #  of the ATLAS 2k and a compatible memory component.   #
-- #                                                       #
-- #  The number of pages as well as the page size can be  #
-- #  configured via constant in the 'USER CONFIGURATION'  #
-- #  section. Both values must be a number of 2!          #
-- #  Also, the frequency of the 'CLK_I' signal must be    #
-- #  declared in this section (in Hz).                    #
-- #                                                       #
-- # ***************************************************** #
-- #  Last modified: 28.11.2014                            #
-- # ***************************************************** #
-- #  by Stephan Nolting 4788, Hanover, Germany            #
-- #########################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.atlas_core_package.all;

entity atlas_2k_base_top is
  port	(
-- ###############################################################################################
-- ##           Global Signals                                                                  ##
-- ###############################################################################################

        clk_i           : in  std_ulogic; -- global clock line
        rstn_i          : in  std_ulogic; -- global reset line, low-active

-- ###############################################################################################
-- ##           IO Interface                                                                    ##
-- ###############################################################################################

        -- uart --
        uart_rxd_i      : in  std_ulogic; -- receiver input
        uart_txd_o      : out std_ulogic; -- uart transmitter output

        -- spi --
        spi_mosi_o      : out std_ulogic_vector(07 downto 0); -- serial data out
        spi_miso_i      : in  std_ulogic_vector(07 downto 0); -- serial data in
        spi_sck_o       : out std_ulogic_vector(07 downto 0); -- serial clock out
        spi_cs_o        : out std_ulogic_vector(07 downto 0); -- chip select (low active)

        -- pio --
        pio_out_o       : out std_ulogic_vector(15 downto 0); -- parallel output
        pio_in_i        : in  std_ulogic_vector(15 downto 0); -- parallel input

        -- system io (bootloader, nos, ...) --
        sys_out_o       : out std_ulogic_vector(07 downto 0); -- system output
        sys_in_i        : in  std_ulogic_vector(07 downto 0); -- system input

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
end atlas_2k_base_top;

architecture atlas_2k_base_top_structure of atlas_2k_base_top is

  -- Component: Atlas-2K Processor ----------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  component atlas_2k_top
  generic (
    clk_speed_g     : std_ulogic_vector(31 downto 0) := (others => '0') -- clock speed (in hz)
  );
  port (
    clk_i           : in  std_ulogic; -- global clock line
    rst_i           : in  std_ulogic; -- global reset line, sync, high-active
    ce_i            : in  std_ulogic; -- global clock enable, high active
    cp_en_o         : out std_ulogic; -- access to cp0
    cp_ice_o        : out std_ulogic; -- cp interface clock enable
    cp_op_o         : out std_ulogic; -- data transfer/processing
    cp_rw_o         : out std_ulogic; -- read/write access
    cp_cmd_o        : out std_ulogic_vector(08 downto 0); -- register addresses / cmd
    cp_dat_o        : out std_ulogic_vector(data_width_c-1 downto 0); -- write data
    cp_dat_i        : in  std_ulogic_vector(data_width_c-1 downto 0); -- read data cp0
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
    uart_rxd_i      : in  std_ulogic; -- receiver input
    uart_txd_o      : out std_ulogic; -- uart transmitter output
    spi_mosi_o      : out std_ulogic_vector(07 downto 0); -- serial data out
    spi_miso_i      : in  std_ulogic_vector(07 downto 0); -- serial data in
    spi_sck_o       : out std_ulogic_vector(07 downto 0); -- serial clock out
    spi_cs_o        : out std_ulogic_vector(07 downto 0); -- chip select (low active)
    pio_out_o       : out std_ulogic_vector(15 downto 0); -- parallel output
    pio_in_i        : in  std_ulogic_vector(15 downto 0); -- parallel input
    sys_out_o       : out std_ulogic_vector(07 downto 0); -- system parallel output
    sys_in_i        : in  std_ulogic_vector(07 downto 0); -- system parallel input
    irq_i           : in  std_ulogic; -- irq
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

  -- RAM ------------------------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  component int_ram
  generic	(
    mem_size_g      : natural := 256 -- memory size in words
  );
  port (
    -- host interface --
    clk_i           : in  std_ulogic; -- global clock line
    i_adr_i         : in  std_ulogic_vector(31 downto 0); -- instruction adr
    i_dat_o         : out std_ulogic_vector(15 downto 0); -- instruction out
    d_en_i          : in  std_ulogic; -- access enable
    d_rw_i          : in  std_ulogic; -- read/write
    d_adr_i         : in  std_ulogic_vector(31 downto 0); -- data adr
    d_dat_i         : in  std_ulogic_vector(15 downto 0); -- data in
    d_dat_o         : out std_ulogic_vector(15 downto 0)  -- data out
  );
  end component;

-- *** USER CONFIGURATION ***
-- ***********************************************************************************************
  constant clk_speed_c : std_ulogic_vector(31 downto 0) := x"02FAF080"; -- clock speed in Hz (here =50MHz)
  constant num_pages_c : natural := 4; -- number of pages (must be a power of 2)
  constant page_size_c : natural := 4096; -- page size in bytes (must be a power of 2)
-- ***********************************************************************************************

  -- internals... -
  constant ram_size_c   : natural := num_pages_c*page_size_c; -- internal ram size in bytes
  constant ld_pg_size_c : natural := log2(page_size_c); -- page select address width
  constant ld_num_pg_c  : natural := log2(num_pages_c); -- page size address width

  -- global signals --
  signal g_clk : std_ulogic;
  signal g_rst : std_ulogic;

  -- memory interface --
  signal i_adr,   d_adr   : std_ulogic_vector(data_width_c-1 downto 0);
  signal i_page,  d_page  : std_ulogic_vector(data_width_c-1 downto 0);
  signal d_en             : std_ulogic;
  signal d_rw             : std_ulogic;
  signal i_dat_o, d_dat_o : std_ulogic_vector(data_width_c-1 downto 0);
  signal d_dat_i          : std_ulogic_vector(data_width_c-1 downto 0);
  signal mem_d_adr        : std_ulogic_vector(31 downto 0);
  signal mem_i_adr        : std_ulogic_vector(31 downto 0);

  -- irq --
  signal critical_irq : std_ulogic;

begin

  -- Clock/Reset -----------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    g_rst <= not rstn_i;
    g_clk <= clk_i;


  -- Core ------------------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    the_core_of_the_problem: atlas_2k_top
    generic map (
      clk_speed_g => clk_speed_c     -- clock speed (in hz)
    )
    port map (
      clk_i           => g_clk,          -- global clock line
      rst_i           => g_rst,          -- global reset line, sync, high-active
      ce_i            => '1',            -- global clock enable, high active

      cp_en_o         => open,           -- access to cp0
      cp_ice_o        => open,           -- cp interface clock enable
      cp_op_o         => open,           -- data transfer/processing
      cp_rw_o         => open,           -- read/write access
      cp_cmd_o        => open,           -- register addresses / cmd
      cp_dat_o        => open,           -- write data
      cp_dat_i        => x"0000",        -- read data cp0

      mem_i_page_o    => i_page,         -- instruction page
      mem_i_adr_o     => i_adr,          -- instruction adr
      mem_i_dat_i     => i_dat_o,        -- instruction input
      mem_d_en_o      => d_en,           -- access enable
      mem_d_rw_o      => d_rw,           -- read/write
      mem_d_page_o    => d_page,         -- data page
      mem_d_adr_o     => d_adr,          -- data adr
      mem_d_dat_o     => d_dat_i,        -- data out
      mem_d_dat_i     => d_dat_o,        -- data in
      critical_irq_i  => critical_irq,   -- critical error irq

      uart_rxd_i      => uart_rxd_i,     -- receiver input
      uart_txd_o      => uart_txd_o,     -- uart transmitter output

      spi_sck_o       => spi_sck_o,      -- serial clock output
      spi_mosi_o      => spi_mosi_o,     -- serial data output
      spi_miso_i      => spi_miso_i,     -- serial data input
      spi_cs_o        => spi_cs_o,       -- device select - low-active

      pio_out_o       => pio_out_o,      -- parallel output
      pio_in_i        => pio_in_i,       -- parallel input

      sys_out_o       => sys_out_o,      -- system parallel output
      sys_in_i        => sys_in_i,       -- system parallel input

      irq_i           => '0',            -- irq - not used here

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


  -- Memory Mapping --------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    memory_mapping: process(i_page, d_page, i_adr, d_adr)
    begin
      -- default --
      mem_i_adr <= (others => '0');
      mem_d_adr <= (others => '0');

      -- page address --
      mem_i_adr(ld_pg_size_c-1 downto 0) <= i_adr(ld_pg_size_c-1 downto 0);
      mem_d_adr(ld_pg_size_c-1 downto 0) <= d_adr(ld_pg_size_c-1 downto 0);

      -- page number --
      mem_i_adr((ld_pg_size_c+ld_num_pg_c)-1 downto ld_pg_size_c) <= i_page(ld_num_pg_c-1 downto 0);
      mem_d_adr((ld_pg_size_c+ld_num_pg_c)-1 downto ld_pg_size_c) <= d_page(ld_num_pg_c-1 downto 0);
    end process memory_mapping;


  -- Internal RAM ----------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    internal_ram: int_ram
    generic	map (
      mem_size_g  => ram_size_c      -- memory size in bytes
    )
    port map (
      -- host interface --
      clk_i           => g_clk,          -- global clock line
      i_adr_i         => mem_i_adr,      -- instruction adr
      i_dat_o         => i_dat_o,        -- instruction out
      d_en_i          => d_en,           -- access enable
      d_rw_i          => d_rw,           -- read/write
      d_adr_i         => mem_d_adr,      -- data adr
      d_dat_i         => d_dat_i,        -- data in
      d_dat_o         => d_dat_o         -- data out
    );


  -- User Section ----------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    critical_irq <= '0';


end atlas_2k_base_top_structure;
