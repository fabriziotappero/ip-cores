library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.atlas_core_package.all;

entity atlas_2k_base_tb is
end atlas_2k_base_tb;

architecture atlas_2k_base_tb_structure of atlas_2k_base_tb is

  -- Component: Atlas-2K Processor ----------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  component atlas_2k_base_top
  port	(
        -- globals --
        clk_i           : in  std_logic; -- global clock line
        rstn_i          : in  std_logic; -- global reset line, low-active

        -- uart --
        uart_rxd_i      : in  std_logic; -- receiver input
        uart_txd_o      : out std_logic; -- uart transmitter output

        -- spi --
        spi_mosi_o      : out std_logic_vector(07 downto 0); -- serial data out
        spi_miso_i      : in  std_logic_vector(07 downto 0); -- serial data in
        spi_sck_o       : out std_logic_vector(07 downto 0); -- serial clock out
        spi_cs_o        : out std_logic_vector(07 downto 0); -- chip select (low active)

        -- pio --
        pio_out_o       : out std_logic_vector(15 downto 0); -- parallel output
        pio_in_i        : in  std_logic_vector(15 downto 0); -- parallel input

        -- system io --
        sys_out_o       : out std_logic_vector(07 downto 0); -- system output
        sys_in_i        : in  std_logic_vector(07 downto 0); -- system input

        -- wishbone bus --
        wb_clk_o        : out std_logic; -- bus clock
        wb_rst_o        : out std_logic; -- bus reset, sync, high active
        wb_adr_o        : out std_logic_vector(31 downto 0); -- address
        wb_sel_o        : out std_logic_vector(01 downto 0); -- byte select
        wb_data_o       : out std_logic_vector(15 downto 0); -- data out
        wb_data_i       : in  std_logic_vector(15 downto 0); -- data in
        wb_we_o         : out std_logic; -- read/write
        wb_cyc_o        : out std_logic; -- cycle enable
        wb_stb_o        : out std_logic; -- strobe
        wb_ack_i        : in  std_logic; -- acknowledge
        wb_err_i        : in  std_logic  -- bus error
      );
  end component;

  -- global signals --
  signal clk_gen          : std_logic := '0';
  signal rstn_gen         : std_logic := '0';

  -- io --
  signal rxd, txd         : std_logic;                     -- uart
  signal pio_out, pio_in  : std_logic_vector(15 downto 0); -- pio
  signal boot_c_in        : std_logic_vector(07 downto 0); -- boot/sys condfig
  signal boot_c_out       : std_logic_vector(07 downto 0); -- boot/sys status
  signal spi_miso         : std_logic_vector(07 downto 0); -- spi master out slave in
  signal spi_mosi         : std_logic_vector(07 downto 0); -- spi master in slave out
  signal spi_csn          : std_logic_vector(07 downto 0); -- spi chip select (low-active)
  signal spi_sck          : std_logic_vector(07 downto 0); -- spi master clock out

  -- wishbone bus --
  signal wb_clk, wb_rst   : std_logic;
  signal wb_adr           : std_logic_vector(31 downto 0); -- address
  signal wb_sel           : std_logic_vector(01 downto 0); -- byte select
  signal wb_data_o        : std_logic_vector(15 downto 0); -- data out
  signal wb_data_i        : std_logic_vector(15 downto 0); -- data in
  signal wb_we            : std_logic; -- read/write
  signal wb_cyc           : std_logic; -- cycle enable
  signal wb_stb           : std_logic; -- strobe
  signal wb_ack           : std_logic; -- acknowledge
  signal wb_err           : std_logic; -- bus error

  -- wishbone dummy memory --
  constant wm_mem_size_c : natural := 256; -- byte
  constant log2_mem_size_c : natural := log2(wm_mem_size_c/2); -- address width
  signal   wb_ack_buf : std_logic;
  type     mem_file_t is array (0 to (wm_mem_size_c/2)-1) of std_logic_vector(15 downto 0);
  signal   mem_file : mem_file_t := (others => (others => '0'));

begin

  -- Stimulus --------------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    stimulus: process
    begin
      -- all idle --
      rxd      <= '1'; -- idle
      spi_miso <= "00000000";
      pio_in   <= x"0000";
      wb_err   <= '0';
      wait;
    end process stimulus;



  -- Clock/Reset Generator -------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    clk_gen  <= not clk_gen after 10 ns; -- 50mhz
    rstn_gen <= '0', '1' after 35 ns;



  -- Processor Core --------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    dut: atlas_2k_base_top
      port map (
            -- globals --
            clk_i           => clk_gen,      -- global clock line
            rstn_i          => rstn_gen,     -- global reset line, low-active

            -- uart --
            uart_rxd_i      => rxd,          -- receiver input
            uart_txd_o      => txd,          -- uart transmitter output

            -- spi --
            spi_mosi_o      => spi_mosi,     -- serial data out
            spi_miso_i      => spi_miso,     -- serial data in
            spi_sck_o       => spi_sck,      -- serial clock out
            spi_cs_o        => spi_csn,      -- chip select (low active)

            -- pio --
            pio_out_o       => pio_out,      -- parallel output
            pio_in_i        => pio_in,       -- parallel input

            -- system io --
            sys_out_o       => boot_c_out,   -- system output
            sys_in_i        => boot_c_in,    -- system input

            -- wishbone bus --
            wb_clk_o        => wb_clk,       -- bus clock
            wb_rst_o        => wb_rst,       -- bus reset, sync, high active
            wb_adr_o        => wb_adr,       -- address
            wb_sel_o        => wb_sel,       -- byte select
            wb_data_o       => wb_data_o,    -- data out
            wb_data_i       => wb_data_i,    -- data in
            wb_we_o         => wb_we,        -- read/write
            wb_cyc_o        => wb_cyc,       -- cycle enable
            wb_stb_o        => wb_stb,       -- strobe
            wb_ack_i        => wb_ack,       -- acknowledge
            wb_err_i        => wb_err        -- bus error
          );

    -- boot config --
    boot_c_in(7 downto 2) <= "000000"; -- unused
    boot_c_in(1 downto 0) <= "11"; -- boot from internal memory!!!



  -- WB Memory -------------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    wb_mem_file_access: process(wb_clk)
    begin
      if rising_edge(wb_clk) then

        --- data read/write ---
        if (wb_stb = '1') and (wb_cyc = '1') then
          if (wb_we = '1') then
            mem_file(to_integer(unsigned(wb_adr(log2_mem_size_c downto 1)))) <= wb_data_o;
          end if;
          wb_data_i <= mem_file(to_integer(unsigned(wb_adr(log2_mem_size_c downto 1))));
        end if;

        --- ack control ---
        if (wb_rst = '1') then
          wb_ack_buf <= '0';
        else
          wb_ack_buf <= wb_cyc and wb_stb;
        end if;

      end if;
    end process wb_mem_file_access;

    --- ack signal ---
    wb_ack <= wb_ack_buf and wb_cyc;



end atlas_2k_base_tb_structure;
