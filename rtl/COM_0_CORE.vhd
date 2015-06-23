-- #########################################################
-- #   << ATLAS Project - Communication Controller 0 >>    #
-- # ***************************************************** #
-- #  -> UART (RXD, TXD)                                   #
-- #  -> SPI (8 channels)                                  #
-- #  -> Parallel IO  (16 in, 16 out)                      #
-- #  -> System IO (8 in, 8 out)                           #
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

entity com_0_core is
  port	(
-- ###############################################################################################
-- ##           Host Interface                                                                  ##
-- ###############################################################################################

        clk_i           : in  std_ulogic; -- global clock line
        rst_i           : in  std_ulogic; -- global reset line, sync, high-active
        ice_i           : in  std_ulogic; -- interface clock enable, high-active
        w_en_i          : in  std_ulogic; -- write enable
        r_en_i          : in  std_ulogic; -- read enable
        adr_i           : in  std_ulogic_vector(02 downto 0); -- access address
        dat_i           : in  std_ulogic_vector(15 downto 0); -- write data
        dat_o           : out std_ulogic_vector(15 downto 0); -- read data

-- ###############################################################################################
-- ##           Interrupt Lines                                                                 ##
-- ###############################################################################################

        uart_rx_irq_o   : out std_ulogic; -- uart irq "data available"
        uart_tx_irq_o   : out std_ulogic; -- uart irq "sending done"
        spi_irq_o       : out std_ulogic; -- spi irq "transfer done"
        pio_irq_o       : out std_ulogic; -- pio input pin change irq

-- ###############################################################################################
-- ##           Communication Lines                                                             ##
-- ###############################################################################################

        uart_txd_o      : out std_ulogic; -- uart serial output
        uart_rxd_i      : in  std_ulogic; -- uart serial input
        spi_mosi_o      : out std_ulogic_vector(07 downto 0); -- serial data out
        spi_miso_i      : in  std_ulogic_vector(07 downto 0); -- serial data in
        spi_sck_o       : out std_ulogic_vector(07 downto 0); -- serial clock out
        spi_cs_o        : out std_ulogic_vector(07 downto 0); -- chip select (low active)
        pio_in_i        : in  std_ulogic_vector(15 downto 0); -- parallel input
        pio_out_o       : out std_ulogic_vector(15 downto 0); -- parallel output
        sys_io_i        : in  std_ulogic_vector(07 downto 0); -- system input
        sys_io_o        : out std_ulogic_vector(07 downto 0)  -- system output
      );
end com_0_core;

architecture com_0_core_behav of com_0_core is

  -- Module Addresses --
  constant uart_rtx_sd_reg_c : std_ulogic_vector(02 downto 0) := "000"; -- R/W: UART RTX data + status flags
  constant uart_prsc_reg_c   : std_ulogic_vector(02 downto 0) := "001"; -- R/W: UART prescaler register
  constant com_ctrl_reg_c    : std_ulogic_vector(02 downto 0) := "010"; -- R/W: COM control register
  constant spi_data_reg_c    : std_ulogic_vector(02 downto 0) := "011"; -- R/W: SPI RTX data register
  constant spi_cs_reg_c      : std_ulogic_vector(02 downto 0) := "100"; -- R/W: SPI chip select register
  constant pio_in_reg_c      : std_ulogic_vector(02 downto 0) := "101"; -- R:   PIO input register
  constant pio_out_reg_c     : std_ulogic_vector(02 downto 0) := "110"; -- R/W: PIO output register
  constant sys_io_reg_c      : std_ulogic_vector(02 downto 0) := "111"; -- R/W: System parallel in/out

  -- CTRL Register --
  constant spi_cr_dir_flag_c : natural :=  0; -- R/W: 0: MSB first, 1: LSB first
  constant spi_cr_cpol_c     : natural :=  1; -- R/W: clock polarity, 1: idle '1' clock, 0: idle '0' clock
  constant spi_cr_cpha_c     : natural :=  2; -- R/W: edge offset: 0: first edge, 1: second edge
  constant spi_cr_bsy_c      : natural :=  3; -- R:   transceiver is busy when '1'
  constant spi_cr_auto_cs_c  : natural :=  4; -- R/W: Auto apply CS when '1'
  constant uart_tx_busy_c    : natural :=  5; -- R:   UART transmitter is busy
  constant uart_en_c         : natural :=  6; -- R/W: UART enable
  constant uart_ry_ovf_c     : natural :=  7; -- R:   UART Rx overflow corruption
  constant spi_cr_ln_lsb_c   : natural :=  8; -- R/W: data length lsb
  constant spi_cr_ln_msb_c   : natural := 11; -- R/W: data length msb
  constant spi_cr_prsc_lsb_c : natural := 12; -- R/W: SPI clock prescaler lsb
  constant spi_cr_prsc_msb_c : natural := 15; -- R/W: SPI clock prescaler msb

  -- UART Control Flags (UART RTX REG) --
  constant uart_rx_ready_c : natural := 15; -- R: Data received

  -- uart registers --
  signal uart_rx_reg   : std_ulogic_vector(07 downto 0);
  signal uart_prsc_reg : std_ulogic_vector(15 downto 0);

  -- uart transceiver --
  signal uart_rx_sync       : std_ulogic_vector(03 downto 0);
  signal uart_tx_bsy_flag   : std_ulogic;
  signal uart_dcor_flag     : std_ulogic;
  signal uart_rx_bsy_flag   : std_ulogic;
  signal uart_tx_sreg       : std_ulogic_vector(09 downto 0);
  signal uart_rx_sreg       : std_ulogic_vector(09 downto 0);
  signal uart_tx_bit_cnt    : std_ulogic_vector(03 downto 0);
  signal uart_rx_bit_cnt    : std_ulogic_vector(03 downto 0);
  signal uart_tx_baud_cnt   : std_ulogic_vector(15 downto 0);
  signal uart_rx_baud_cnt   : std_ulogic_vector(15 downto 0);
  signal uart_rx_ready      : std_ulogic;
  signal uart_rx_ready_sync : std_ulogic;

  -- spi registers --
  signal spi_tx_reg     : std_ulogic_vector(15 downto 0);
  signal spi_rx_reg     : std_ulogic_vector(15 downto 0);
  signal spi_rx_reg_nxt : std_ulogic_vector(15 downto 0);
  signal spi_cs_reg     : std_ulogic_vector(07 downto 0);
  signal com_config_reg : std_ulogic_vector(15 downto 0);

  -- spi transceiver --
  signal spi_in_buf    : std_ulogic_vector(01 downto 0);
  signal spi_mosi_nxt  : std_ulogic;
  signal spi_sck_nxt   : std_ulogic;
  signal spi_mosi_ff   : std_ulogic;
  signal spi_cs_ff     : std_ulogic_vector(07 downto 0);
  signal spi_cs_ff_nxt : std_ulogic_vector(07 downto 0);
  signal spi_irq       : std_ulogic;

  -- spi arbiter --
  type   spi_arb_state_type is (idle, start_trans, transmit_0, transmit_1, finish);
  signal spi_arb_state     : spi_arb_state_type;
  signal spi_arb_state_nxt : spi_arb_state_type;
  signal spi_bit_cnt       : std_ulogic_vector(04 downto 0);
  signal spi_bit_cnt_nxt   : std_ulogic_vector(04 downto 0);
  signal spi_rx_sft        : std_ulogic_vector(15 downto 0); -- rx shift registers
  signal spi_rx_sft_nxt    : std_ulogic_vector(15 downto 0); -- rx shift registers
  signal spi_tx_sft        : std_ulogic_vector(15 downto 0); -- tx shift registers
  signal spi_tx_sft_nxt    : std_ulogic_vector(15 downto 0); -- tx shift registers
  signal spi_prsc_cnt      : std_ulogic_vector(15 downto 0);
  signal spi_prsc_cnt_nxt  : std_ulogic_vector(15 downto 0);
  signal spi_busy_flag     : std_ulogic;
  signal spi_busy_flag_nxt : std_ulogic;
  signal spi_sck_ff        : std_ulogic;
  signal spi_miso          : std_ulogic;

  -- pio registers --
  signal pio_out_data : std_ulogic_vector(15 downto 0);
  signal pio_in_data  : std_ulogic_vector(15 downto 0);
  signal pio_sync     : std_ulogic_vector(15 downto 0);
  signal sys_io_i_ff  : std_ulogic_vector(07 downto 0);
  signal sys_io_o_ff  : std_ulogic_vector(07 downto 0);

begin

  -- Write Access ----------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    w_acc: process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          uart_prsc_reg  <= (others => '0');
          com_config_reg <= (others => '0');
          spi_tx_reg     <= (others => '0');
          spi_cs_reg     <= (others => '0');
          pio_in_data    <= (others => '0');
          pio_out_data   <= (others => '0');
          pio_sync       <= (others => '0');
          sys_io_o_ff    <= (others => '0');
          sys_io_i_ff    <= (others => '0');
        elsif (ice_i = '1') then -- interface enable
          if (w_en_i = '1') then -- register update
            case (adr_i) is
              when uart_prsc_reg_c => uart_prsc_reg  <= dat_i;
              when com_ctrl_reg_c  => com_config_reg <= dat_i;
              when spi_data_reg_c  => spi_tx_reg     <= dat_i;
              when spi_cs_reg_c    => spi_cs_reg     <= dat_i(07 downto 00);
              when pio_out_reg_c   => pio_out_data   <= dat_i;
              when sys_io_reg_c    => sys_io_o_ff    <= dat_i(15 downto 08);
              when others          => null;
            end case;
          end if;
        end if;
        pio_sync    <= pio_in_data;
        pio_in_data <= pio_in_i; -- pio input
        sys_io_i_ff <= sys_io_i;
      end if;
    end process w_acc;

    -- output --
    pio_out_o <= pio_out_data;
    sys_io_o <= sys_io_o_ff;

    -- pio input pin change irq --
    pio_irq_o <= '0' when (pio_sync = pio_in_data) else '1';


  -- Read Access -----------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    r_acc: process(adr_i, uart_tx_bsy_flag, uart_rx_ready, uart_rx_reg, uart_prsc_reg, com_config_reg, sys_io_o_ff,
                   spi_busy_flag, spi_cs_reg, spi_rx_reg, pio_out_data, pio_in_data, sys_io_i_ff, uart_dcor_flag)
    begin
      case (adr_i) is
        when uart_rtx_sd_reg_c => dat_o                  <= (others => '0');
                                  dat_o(7 downto 0)      <= uart_rx_reg;
                                  dat_o(uart_rx_ready_c) <= uart_rx_ready;
        when uart_prsc_reg_c   => dat_o <= uart_prsc_reg;
        when com_ctrl_reg_c    => dat_o                  <= com_config_reg;
                                  dat_o(spi_cr_bsy_c)    <= spi_busy_flag;
                                  dat_o(uart_tx_busy_c)  <= uart_tx_bsy_flag;
                                  dat_o(uart_ry_ovf_c)   <= uart_dcor_flag;
        when spi_data_reg_c    => dat_o <= spi_rx_reg;
        when spi_cs_reg_c      => dat_o <= x"00" & spi_cs_reg;
        when pio_in_reg_c      => dat_o <= pio_in_data;
        when pio_out_reg_c     => dat_o <= pio_out_data;
        when sys_io_reg_c      => dat_o <= sys_io_o_ff & sys_io_i_ff;
        when others            => dat_o <= x"0000";
      end case;
    end process r_acc;


  -- UART Flag Arbiter -----------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    uart_flag_ctrl: process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          uart_rx_ready      <= '0';
          uart_rx_ready_sync <= '0';
                    uart_dcor_flag     <= '0';
        else
          -- ready flag and corruption flag --
          uart_rx_ready_sync <= uart_rx_bsy_flag;
          if (uart_rx_ready = '1') and (r_en_i = '1') and (adr_i = uart_rtx_sd_reg_c) and (ice_i = '1') then
            uart_rx_ready  <= '0';
                        uart_dcor_flag <= '0';
          elsif (uart_rx_ready_sync = '1') and (uart_rx_bsy_flag = '0') then -- falling edge
            uart_rx_ready  <= '1';
                        uart_dcor_flag <= uart_rx_ready;
          end if;
        end if;
      end if;
    end process uart_flag_ctrl;

    -- interrupt output --
    uart_rx_irq_o <= uart_rx_ready;
    uart_tx_irq_o <= not uart_tx_bsy_flag;


  -- Transmitter Unit ------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    uart_transmitter: process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          uart_tx_bsy_flag <= '0';
          uart_tx_sreg     <= (others => '1');
          uart_tx_bit_cnt  <= (others => '0');
          uart_tx_baud_cnt <= (others => '0');
        else
          -- uart disabled
          if (com_config_reg(uart_en_c) = '0') then
            uart_tx_bsy_flag <= '0';
            uart_tx_sreg     <= (others => '1');
            uart_tx_bit_cnt  <= (others => '0');
            uart_tx_baud_cnt <= (others => '0');

          -- uart tx register --
          elsif (uart_tx_bsy_flag = '0') then
            uart_tx_bit_cnt  <= "1010"; -- 10 bits
            uart_tx_baud_cnt <= uart_prsc_reg;
            if (w_en_i = '1') and (adr_i = uart_rtx_sd_reg_c) then
              uart_tx_bsy_flag <= '1';
              uart_tx_sreg     <= '1' & dat_i(7 downto 0) & '0'; -- stopbit & data & startbit
            end if;
          else
            if (uart_tx_baud_cnt = x"0000") then
              uart_tx_baud_cnt <= uart_prsc_reg;
              if (uart_tx_bit_cnt /= "0000") then
                uart_tx_sreg    <= '1' & uart_tx_sreg(9 downto 1);
                uart_tx_bit_cnt <= std_ulogic_vector(unsigned(uart_tx_bit_cnt) - 1);
              else
                uart_tx_bsy_flag <= '0'; -- done
              end if;
            else
              uart_tx_baud_cnt <= std_ulogic_vector(unsigned(uart_tx_baud_cnt) - 1);
            end if;
          end if;
        end if;
      end if;
    end process uart_transmitter;

    -- transmitter output --
    uart_txd_o <= uart_tx_sreg(0);


  -- UART Receiver Unit ----------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    uart_receiver: process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          uart_rx_bsy_flag <= '0';
          uart_rx_sreg     <= (others => '0');
          uart_rx_bit_cnt  <= (others => '0');
          uart_rx_baud_cnt <= (others => '0');
          uart_rx_sync     <= (others => '1');
          uart_rx_reg      <= (others => '0');
        else
          -- synchronizer --
          if (com_config_reg(uart_en_c) = '1') then
            uart_rx_sync <= uart_rxd_i & uart_rx_sync(3 downto 1);
          end if;

          -- uart disabled --
          if (com_config_reg(uart_en_c) = '0') then
            uart_rx_bsy_flag <= '0';
            uart_rx_sreg     <= (others => '0');
            uart_rx_bit_cnt  <= (others => '0');
            uart_rx_baud_cnt <= (others => '0');
            uart_rx_sync     <= (others => '1');
            uart_rx_reg      <= (others => '0');
          
          -- rx shift reg --
          elsif (uart_rx_bsy_flag = '0') then
            uart_rx_bit_cnt  <= "1001"; -- 9 bits (startbit + 8 data bits)
            uart_rx_baud_cnt <= '0' & uart_prsc_reg(15 downto 1); -- half baud rate, sample in middle
            if (uart_rx_sync(1 downto 0) = "01") then -- start 'bit' detected (falling logical edge)
              uart_rx_bsy_flag <= '1';
            end if;
          else
            if (uart_rx_baud_cnt = x"0000") then
              uart_rx_baud_cnt <= uart_prsc_reg;
              if (uart_rx_bit_cnt /= "0000") then
                uart_rx_sreg    <= uart_rx_sync(0) & uart_rx_sreg(9 downto 1);
                uart_rx_bit_cnt <= std_ulogic_vector(unsigned(uart_rx_bit_cnt) - 1);
              else
                uart_rx_bsy_flag <= '0'; -- done
                uart_rx_reg      <= uart_rx_sreg(9 downto 2);
              end if;
            else
              uart_rx_baud_cnt <= std_ulogic_vector(unsigned(uart_rx_baud_cnt) - 1);
            end if;
          end if;
        end if;
      end if;
    end process uart_receiver;


  -- SPI Transceiver Unit --------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    spi_arb_sync: process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          spi_arb_state  <= idle;
          spi_rx_sft     <= (others => '0');
          spi_tx_sft     <= (others => '0');
          spi_bit_cnt    <= (others => '0');
          spi_prsc_cnt   <= (others => '0');
          spi_rx_reg     <= (others => '0');
          spi_sck_ff     <= '0';
          spi_mosi_ff    <= '0';
          spi_in_buf     <= "00";
          spi_cs_ff      <= (others => '1');
          spi_busy_flag  <= '0';
          spi_irq_o      <= '0';
        else
          spi_arb_state  <= spi_arb_state_nxt;
          spi_rx_sft     <= spi_rx_sft_nxt;
          spi_tx_sft     <= spi_tx_sft_nxt;
          spi_bit_cnt    <= spi_bit_cnt_nxt;
          spi_prsc_cnt   <= spi_prsc_cnt_nxt;
          spi_rx_reg     <= spi_rx_reg_nxt;
          spi_sck_ff     <= spi_sck_nxt;
          spi_mosi_ff    <= spi_mosi_nxt;
          spi_in_buf     <= spi_in_buf(0) & spi_miso;
          if (com_config_reg(spi_cr_auto_cs_c) = '1') then -- auto apply chip select
            spi_cs_ff  <= spi_cs_ff_nxt;
          else -- manually apply chip select
            spi_cs_ff  <= not spi_cs_reg;
          end if;
          spi_busy_flag  <= spi_busy_flag_nxt;
          spi_irq_o      <= spi_irq;
        end if;
      end if;
    end process spi_arb_sync;


    spi_arb_comb: process(spi_arb_state, com_config_reg, spi_rx_sft, spi_tx_sft, spi_bit_cnt, spi_prsc_cnt, spi_in_buf,
                          spi_rx_reg, spi_mosi_ff, spi_cs_ff, spi_cs_reg, spi_tx_reg, w_en_i, adr_i, spi_busy_flag, ice_i)
      variable prsc_match_v : std_ulogic;
    begin
      -- defaults --
      spi_arb_state_nxt <= spi_arb_state; -- arbiter state
      spi_rx_sft_nxt    <= spi_rx_sft;    -- rx shift register
      spi_tx_sft_nxt    <= spi_tx_sft;    -- tx shift register
      spi_bit_cnt_nxt   <= spi_bit_cnt;   -- bit counter
      spi_prsc_cnt_nxt  <= spi_prsc_cnt;  -- spi clock prescaler
      spi_rx_reg_nxt    <= spi_rx_reg;    -- complete received data
      spi_sck_nxt       <= com_config_reg(spi_cr_cpol_c); -- clock polarity
      spi_mosi_nxt      <= spi_mosi_ff;   -- serial data output
      spi_busy_flag_nxt <= spi_busy_flag; -- busy flag
      spi_irq           <= '0';           -- no interrupt
      prsc_match_v      := spi_prsc_cnt(to_integer(unsigned(com_config_reg(spi_cr_prsc_msb_c downto spi_cr_prsc_lsb_c)))); -- prescaler match

      -- state machine --
      case (spi_arb_state) is -- idle, start_trans, transmit, end_trans

        when idle => -- wait for transmitter init
          spi_cs_ff_nxt     <= (others => '1'); -- deselct all slaves
          spi_bit_cnt_nxt   <= (others => '0');
          spi_rx_sft_nxt    <= (others => '0');
          spi_prsc_cnt_nxt  <= (others => '0');
          spi_mosi_nxt      <= '0';
          spi_sck_nxt       <= com_config_reg(spi_cr_cpol_c); -- idle clk polarity
          if (w_en_i = '1') and (adr_i = spi_data_reg_c) and (ice_i = '1') then
            spi_arb_state_nxt <= start_trans;
            spi_busy_flag_nxt <= '1';
          end if;

        when start_trans => -- apply slave select signal
          spi_tx_sft_nxt    <= spi_tx_reg;
          spi_cs_ff_nxt     <= not spi_cs_reg;
          spi_arb_state_nxt <= transmit_0;

        when transmit_0 => -- first half of bit transmission
          spi_cs_ff_nxt    <= spi_cs_ff; -- keep cs alive
          spi_prsc_cnt_nxt <= std_ulogic_vector(unsigned(spi_prsc_cnt) + 1);
          spi_sck_nxt      <= com_config_reg(spi_cr_cpol_c) xor com_config_reg(spi_cr_cpha_c);
          if (com_config_reg(spi_cr_dir_flag_c) = '0') then -- msb first
            spi_mosi_nxt <= spi_tx_sft(to_integer(unsigned(com_config_reg(spi_cr_ln_msb_c downto spi_cr_ln_lsb_c))));
          else -- lsb first
            spi_mosi_nxt <= spi_tx_sft(0);
          end if;
          if (prsc_match_v = '1') then -- first half completed
            spi_arb_state_nxt <= transmit_1;
            spi_prsc_cnt_nxt  <= (others => '0');
          end if;

        when transmit_1 => -- second half of bit transmission
          spi_cs_ff_nxt    <= spi_cs_ff; -- keep cs alive
          spi_prsc_cnt_nxt <= std_ulogic_vector(unsigned(spi_prsc_cnt) + 1);
          spi_sck_nxt      <= not (com_config_reg(spi_cr_cpol_c) xor com_config_reg(spi_cr_cpha_c));
          if (prsc_match_v = '1') then -- second half completed
            spi_bit_cnt_nxt  <= std_ulogic_vector(unsigned(spi_bit_cnt) + 1);
            spi_prsc_cnt_nxt <= (others => '0');
            if (com_config_reg(spi_cr_dir_flag_c) = '0') then -- msb first
              spi_tx_sft_nxt <= spi_tx_sft(14 downto 0) & '0'; -- left shift
              spi_rx_sft_nxt <= spi_rx_sft(14 downto 0) & spi_in_buf(1); -- left shift
            else -- lsb first
              spi_tx_sft_nxt <= '0' & spi_tx_sft(15 downto 1); -- right shift
              spi_rx_sft_nxt <= spi_in_buf(1) & spi_tx_sft(15 downto 1); -- right shift
            end if;
            if (to_integer(unsigned(spi_bit_cnt)) = to_integer(unsigned(com_config_reg(spi_cr_ln_msb_c downto spi_cr_ln_lsb_c)))) then
              spi_arb_state_nxt <= finish;
            else
              spi_arb_state_nxt <= transmit_0;
            end if;
          end if;

        when finish => -- finish transfer
          spi_cs_ff_nxt     <= spi_cs_ff; -- keep cs alive
          spi_busy_flag_nxt <= '0';
          spi_rx_reg_nxt    <= spi_rx_sft;
          spi_mosi_nxt      <= '0';
          spi_irq           <= '1'; -- irq tick
          spi_arb_state_nxt <= idle;

      end case;
    end process spi_arb_comb;


    -- spi io interface --
    spi_io: process(spi_cs_ff, spi_mosi_ff, spi_sck_ff, spi_miso_i)
      variable spi_miso_bus_v : std_ulogic_vector(7 downto 0);
      variable spi_miso_v     : std_ulogic;
    begin
      spi_miso_bus_v := spi_miso_i and (not spi_cs_ff);
      spi_miso_v := '0';
      for i in 0 to 7 loop -- for all channels
        spi_mosi_o(i) <= spi_mosi_ff and (not spi_cs_ff(i));
        spi_cs_o(i)   <= spi_cs_ff(i);
        spi_sck_o(i)  <= spi_sck_ff;
        spi_miso_v    := spi_miso_v or spi_miso_bus_v(i);
      end loop;
      spi_miso <= spi_miso_v;
    end process spi_io;



end com_0_core_behav;
