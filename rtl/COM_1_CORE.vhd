-- #########################################################
-- #   << ATLAS Project - Communication Controller 1 >>    #
-- # ***************************************************** #
-- #  - Wishbone Bus Adapter                               #
-- #    -> 32-bit address, 16-bit data                     #
-- #    -> Variable Length Burst-Transfers                 #
-- #    -> Bus access is pipelined                         #
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

entity com_1_core is
  port	(
-- ###############################################################################################
-- ##           Host Interface                                                                  ##
-- ###############################################################################################

        clk_i           : in  std_ulogic; -- global clock line
        rst_i           : in  std_ulogic; -- global reset line, sync, high-active
        ice_i           : in  std_ulogic; -- interface clock enable, high-active
        w_en_i          : in  std_ulogic; -- write enable
        r_en_i          : in  std_ulogic; -- read enable
        cmd_exe_i       : in  std_ulogic; -- execute command
        adr_i           : in  std_ulogic_vector(02 downto 0); -- access address/command
        dat_i           : in  std_ulogic_vector(15 downto 0); -- write data
        dat_o           : out std_ulogic_vector(15 downto 0); -- read data
        irq_o           : out std_ulogic; -- interrupt request

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
--      wb_halt_i       : in  std_ulogic; -- halt transfer
        wb_err_i        : in  std_ulogic  -- bus error
      );
end com_1_core;

architecture com_1_core_behav of com_1_core is

  -- Module Addresses --
  constant ctrl_reg_c       : std_ulogic_vector(02 downto 0) := "000"; -- R/W: control register (see below)
  constant base_adr_l_reg_c : std_ulogic_vector(02 downto 0) := "001"; -- R/W: base address low
  constant base_adr_h_reg_c : std_ulogic_vector(02 downto 0) := "010"; -- R/W: base address high
  constant adr_offset_c     : std_ulogic_vector(02 downto 0) := "011"; -- R/W: address offset (2's comp)
  constant rtx_fifo_c       : std_ulogic_vector(02 downto 0) := "100"; -- R/W: Read/write FIFO
  constant timeout_val_c    : std_ulogic_vector(02 downto 0) := "101"; -- R/W: Bus timeout cycles

  -- Module Operations --
  constant cmd_init_rtrans_c : std_ulogic_vector(02 downto 0) := "000"; -- start READ transfer
  constant cmd_init_wtrans_c : std_ulogic_vector(02 downto 0) := "001"; -- start WRITE transfer

  -- CTRL Register Bits --
  constant done_irq_c       : natural :=  0; -- R:   Transfer done (interrupt) flag
  constant bus_err_irq_c    : natural :=  1; -- R:   Wishbone bus error (interrupt) flag
  constant timeout_irq_c    : natural :=  2; -- R:   Wishbone bus timeout (interrupt) flag
  constant done_irq_en_c    : natural :=  3; -- R/W: Allow IRQ for <transfer done>
  constant bus_err_en_irq_c : natural :=  4; -- R/W: Allow IRQ for <bus error>
  constant timeout_en_irq_c : natural :=  5; -- R/W: Allow IRQ for <bus timeout>
  constant busy_flag_c      : natural :=  6; -- R:   Transfer in progress (busy)
  constant dir_flag_c       : natural :=  7; -- R:   Direction of last transfer (1: write, 0: read)
  constant burst_size_lsb_c : natural :=  8; -- R/W: Burst size LSB
  constant burst_size_msb_c : natural := 15; -- R/W: Burst size MSB

  -- Config Regs --
  signal base_adr    : std_ulogic_vector(31 downto 0); -- base address
  signal adr_offset  : std_ulogic_vector(15 downto 0); -- address offset (2's comp)
  signal timeout_val : std_ulogic_vector(15 downto 0); -- timeout in cycles

  -- arbiter --
  signal arb_busy      : std_ulogic; -- arbiter busy flag
  signal dir_ctrl      : std_ulogic; -- direction of current/last transfer (0:read, 1:write)
  signal burst_size    : std_ulogic_vector(log2(wb_fifo_size_c)-1 downto 0);
  signal ack_cnt       : std_ulogic_vector(log2(wb_fifo_size_c)-1 downto 0);
  signal wb_adr_offset : std_ulogic_vector(31 downto 0);
  signal timeout_cnt   : std_ulogic_vector(15 downto 0);

  -- irq system --
  signal bus_err_irq_en    : std_ulogic;
  signal trans_done_irq_en : std_ulogic;
  signal timeout_irq_en    : std_ulogic;
  signal bus_err_irq       : std_ulogic;
  signal trans_done_irq    : std_ulogic;
  signal timeout_irq       : std_ulogic;

  -- rtx fifo --
  type   rtx_fifo_t is array (0 to wb_fifo_size_c-1) of std_ulogic_vector(15 downto 0);
  signal tx_fifo, rx_fifo : rtx_fifo_t := (others => (others => '0'));
  signal rx_fifo_r_pnt    : std_ulogic_vector(log2(wb_fifo_size_c)-1 downto 0);
  signal rx_fifo_w_pnt    : std_ulogic_vector(log2(wb_fifo_size_c)-1 downto 0);
  signal tx_fifo_r_pnt    : std_ulogic_vector(log2(wb_fifo_size_c)-1 downto 0);
  signal tx_fifo_w_pnt    : std_ulogic_vector(log2(wb_fifo_size_c)-1 downto 0);

  -- wb sync --
  signal wb_data_i_ff : std_ulogic_vector(15 downto 0); -- data in buffer
  signal wb_ack_ff    : std_ulogic; -- acknowledge buffer
  signal wb_err_ff    : std_ulogic; -- bus error
  signal wb_adr       : std_ulogic_vector(31 downto 0);
  signal wb_adr_buf   : std_ulogic_vector(31 downto 0);
  signal wb_stb_buf   : std_ulogic;
  signal wb_cyc_buf   : std_ulogic;

begin

  -- Write Access ----------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    w_acc: process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          base_adr          <= (others => '0');
          burst_size        <= (others => '0');
          adr_offset        <= (others => '0');
          timeout_val       <= (others => '0');
          bus_err_irq_en    <= '0';
          trans_done_irq_en <= '0';
          timeout_irq_en    <= '0';
        elsif (ice_i = '1') then -- interface enable
          if (w_en_i = '1') and (arb_busy = '0') then -- register update only if not busy
            case (adr_i) is
              when ctrl_reg_c =>
                burst_size        <= dat_i(burst_size_lsb_c+log2(wb_fifo_size_c)-1 downto burst_size_lsb_c);
                bus_err_irq_en    <= dat_i(bus_err_en_irq_c);
                trans_done_irq_en <= dat_i(done_irq_en_c);
                timeout_irq_en    <= dat_i(timeout_en_irq_c);
              when base_adr_l_reg_c => base_adr(15 downto 00) <= dat_i;
              when base_adr_h_reg_c => base_adr(31 downto 16) <= dat_i;
              when adr_offset_c     => adr_offset  <= dat_i;
              when timeout_val_c    => timeout_val <= dat_i;
              when others => null;
            end case;
          end if;
        end if;
      end if;
    end process w_acc;


  -- Read Access -----------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    r_acc: process(adr_i, base_adr, adr_offset, arb_busy, dir_ctrl, burst_size, bus_err_irq_en,
                       trans_done_irq_en, bus_err_irq, trans_done_irq, rx_fifo, rx_fifo_r_pnt,
                       timeout_irq_en, timeout_irq, timeout_val)
    begin
      case (adr_i) is
        when ctrl_reg_c =>
          dat_o <= (others => '0');
          dat_o(busy_flag_c)      <= arb_busy;
          dat_o(dir_flag_c)       <= dir_ctrl;
          dat_o(bus_err_irq_c)    <= bus_err_irq;
          dat_o(bus_err_en_irq_c) <= bus_err_irq_en;
          dat_o(done_irq_c)       <= trans_done_irq;
          dat_o(done_irq_en_c)    <= trans_done_irq_en;
          dat_o(timeout_irq_c)    <= timeout_irq;
          dat_o(timeout_en_irq_c) <= timeout_irq_en;
          dat_o(burst_size_lsb_c+log2(wb_fifo_size_c)-1 downto burst_size_lsb_c) <= burst_size;
        when base_adr_l_reg_c => dat_o <= base_adr(15 downto 00);
        when base_adr_h_reg_c => dat_o <= base_adr(31 downto 16);
        when adr_offset_c     => dat_o <= adr_offset;
        when rtx_fifo_c       => dat_o <= rx_fifo(to_integer(unsigned(rx_fifo_r_pnt)));
        when timeout_val_c    => dat_o <= timeout_val;
        when others           => dat_o <= x"0000";
      end case;
    end process r_acc;


  -- Host FIFO Access ------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    fifo_acc: process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          tx_fifo_w_pnt <= (others => '0');
          rx_fifo_r_pnt <= (others => '0');
        elsif (ice_i = '1') then -- interface enabled
          if (adr_i = rtx_fifo_c) then -- fifo access
            if ((w_en_i and (arb_busy nand dir_ctrl)) = '1') then -- valid write to tx fifo?
              tx_fifo(to_integer(unsigned(tx_fifo_w_pnt))) <= dat_i;
              if (tx_fifo_w_pnt /= burst_size) then
                tx_fifo_w_pnt <= std_ulogic_vector(unsigned(tx_fifo_w_pnt) + 1); -- inc tx fifo write pointer
              else
                tx_fifo_w_pnt <= (others => '0');
              end if;
            end if;
            if ((r_en_i and (arb_busy nand (not dir_ctrl))) = '1') then -- valid read from rx fifo?
              if (rx_fifo_r_pnt /= burst_size) then
                rx_fifo_r_pnt <= std_ulogic_vector(unsigned(rx_fifo_r_pnt) + 1); -- inc rx fifo read pointer
              else
                rx_fifo_r_pnt <= (others => '0');
              end if;
            end if;
          end if;
        end if;
      end if;
    end process fifo_acc;


  -- Address Offset --------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    adr_offset_comp: process(adr_offset)
    begin
      wb_adr_offset(15 downto 0) <= adr_offset;
      for i in 16 to 31 loop -- sign extension
        wb_adr_offset(i) <= adr_offset(15);
      end loop;
    end process adr_offset_comp;


  -- Interrupt Output ------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    irq_o <= (bus_err_irq and bus_err_irq_en) or
             (trans_done_irq and trans_done_irq_en) or
             (timeout_irq and timeout_irq_en); -- use edge trigger!


  -- Bus Synchronizer ------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    bus_sync: process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          wb_data_i_ff <= (others => '0');
          wb_ack_ff    <= '0';
          wb_err_ff    <= '0';
        else
          wb_data_i_ff <= wb_data_i;
          wb_ack_ff    <= wb_ack_i;
          wb_err_ff    <= wb_err_i;
        end if;
      end if;
    end process bus_sync;

    -- static output --
    wb_sel_o <= (others => '1');
    wb_adr_o <= wb_adr;
    wb_clk_o <= clk_i;
    wb_rst_o <= rst_i;


  -- Bus Arbiter ------------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    bus_arbiter: process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          dir_ctrl       <= '0';
          arb_busy       <= '0';
          ack_cnt        <= (others => '0');
          timeout_cnt    <= (others => '0');
          tx_fifo_r_pnt  <= (others => '0');
          rx_fifo_w_pnt  <= (others => '0');
          bus_err_irq    <= '0';
          trans_done_irq <= '0';
          timeout_irq    <= '0';
          wb_data_o      <= (others => '0');
          wb_adr         <= (others => '0');
          wb_adr_buf     <= (others => '0');
          wb_cyc_o       <= '0';
          wb_stb_o       <= '0';
          wb_stb_buf     <= '0';
          wb_cyc_buf     <= '0';
          wb_we_o        <= '0';
        else
          -- idle mode ------------------------------
          if (arb_busy = '0') then
              ack_cnt       <= (others => '0');
              timeout_cnt   <= (others => '0');
              arb_busy      <= '0';
              rx_fifo_w_pnt <= (others => '0');
              tx_fifo_r_pnt <= (others => '0');
              wb_adr        <= (others => '0');
              wb_adr_buf    <= base_adr;
              wb_stb_o      <= '0';
              wb_stb_buf    <= '0';
              wb_cyc_o      <= '0';
              wb_cyc_buf    <= '0';

              -- interface --
              if (ice_i = '1') then
                  if (r_en_i = '1') and (adr_i = ctrl_reg_c) then -- read ctrl reg?
                      bus_err_irq    <= '0';
                      trans_done_irq <= '0';
                      timeout_irq    <= '0';
                  end if;
                  if (cmd_exe_i = '1') then -- execute transfer command?
                      if (adr_i = cmd_init_rtrans_c) then
                          dir_ctrl       <= '0'; -- read transfer
                          arb_busy       <= '1'; -- start!
                          bus_err_irq    <= '0';
                          trans_done_irq <= '0';
                          timeout_irq    <= '0';
                          wb_stb_buf     <= '1';
                          wb_cyc_buf     <= '1';
                      elsif (adr_i = cmd_init_wtrans_c) then
                          dir_ctrl       <= '1'; -- write transfer
                          arb_busy       <= '1'; -- start!
                          bus_err_irq    <= '0';
                          trans_done_irq <= '0';
                          timeout_irq    <= '0';
                          wb_stb_buf     <= '1';
                          wb_cyc_buf     <= '1';
                      end if;
                  end if;
              end if;

          -- transfer in progress -------------------
          else --elsif (wb_halt_i = '0') then
            wb_we_o     <= dir_ctrl;
            wb_adr      <= wb_adr_buf;
            wb_stb_o    <= wb_stb_buf;
            wb_cyc_o    <= wb_cyc_buf;
            timeout_cnt <= std_ulogic_vector(unsigned(timeout_cnt) + 1);

            -- read transfer ------------------------
            if (dir_ctrl = '0') then
                if (wb_ack_ff = '1') then
                    rx_fifo(to_integer(unsigned(rx_fifo_w_pnt))) <= wb_data_i_ff;
                    rx_fifo_w_pnt <= std_ulogic_vector(unsigned(rx_fifo_w_pnt) + 1); -- inc rx fifo write pointer
                end if;
                if (rx_fifo_w_pnt /= burst_size) then -- all transfered?
                    wb_adr_buf    <= std_ulogic_vector(unsigned(wb_adr_buf) + unsigned(wb_adr_offset)); -- adr
                    wb_stb_buf    <= '1';
                else
                    wb_stb_buf    <= '0';
                end if;

            -- write transfer -----------------------
            else
                wb_data_o <= tx_fifo(to_integer(unsigned(tx_fifo_r_pnt)));
                if (tx_fifo_r_pnt /= burst_size) then -- all transfered?
                    tx_fifo_r_pnt <= std_ulogic_vector(unsigned(tx_fifo_r_pnt) + 1); -- inc tx fifo read pointer
                    wb_adr_buf    <= std_ulogic_vector(unsigned(wb_adr_buf) + unsigned(wb_adr_offset)); -- adr
                    wb_stb_buf    <= '1';
                else
                    wb_stb_buf    <= '0';
                end if;
            end if;

            -- ack counter --
            if (wb_ack_ff = '1') then
                if (ack_cnt = burst_size) then -- yeay, finished!
                    wb_cyc_buf     <= '0';
                    wb_cyc_o       <= '0';
                    arb_busy       <= '0'; -- done
                    trans_done_irq <= '1';
                else
                    ack_cnt        <= std_ulogic_vector(unsigned(ack_cnt) + 1);
                    wb_cyc_buf     <= '1';
                end if;
            end if;

            -- bus error/timeout? --
            if (wb_err_ff = '1') or (timeout_cnt = timeout_val) then
                wb_cyc_o       <= '0';
                wb_cyc_buf     <= '0';
                wb_stb_o       <= '0';
                wb_stb_buf     <= '0';
                arb_busy       <= '0'; -- terminate
                trans_done_irq <= '0';
                if (wb_err_ff = '1') then
                    bus_err_irq <= '1';
                else
                    timeout_irq <= '1';
                end if;
            end if;
          end if;
        end if;
      end if;
    end process bus_arbiter;



end com_1_core_behav;
