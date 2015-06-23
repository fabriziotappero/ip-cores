--------------------------------------------------------------------------------
--  File:       quad_decoder.vhd
--  Desc:       HDL implementation of a quadrature decoder with a Wishbone bus
--              interface. See the "quad_decoder" datasheet for more information.
--  Date:       Initiated October, 2009
--  Auth:       Scott Nortman, COPYRIGHT 2009 Bridge Electronic Design LLC
--              scott.nortman@gmail.com
--
--  NOTE:       If you find this file useful / helpful, please let me know :)
--
--------------------------------------------------------------------------------
--
--      REVISION INFORMATION
--
--      Current Version:    1.0.0
--
--      Nov. 2009
--      1)Initial beta release, upload to OpenCores.org.
--      2)Tested HDL implementation with in a Xilinx Spartan 3 AN FPGA, with
--      a softcore processor, the Tasking TSK3000.  Emulated a quadrature
--      encoder for initial verification.
--
--      July, 2010
--      1)Release version v1.0.0
--      2)Changes from prior release:
--      a) Bit 3 of the Quadrature Control Register (offset 0x00) is now changed
--      functions, to enable / disable of the Index Zero Count function.  When
--      the bit is 0, an index event does not affect the count. When the bit is
--      1, and index events are permitted, the internal quadrature count is set
--      to 0.
--      b) Added control bit 13, Index Read Count Bit.  When set to 0, no count
--      is latched. When set to 1, and index events are permitted, the internal
--      quadrature count is automatically latched to the QRW (offset 0x08)
--      register when an index event is true.  This is VERY useful for detection
--      of missed encoder counts, as you can assume that the delta counts in
--      between each index event is fixed, so any deviation from the expected
--      amount indicates that there were missed encoder counts.
--      3)Tested the FPGA implementation with a real encoder, verified proper
--      operation with count frequencies up to  1.3MHz (50MHz system clock)
--      This test used an instrumented motor driver, with a hardware qudrature
--      decoder in parallel with this encoder module.  This module did not miss
--      any counts with a 2048 quad counts / rev encoder running at 40e3 rpm.
--      4) Fixed a minor bug with the QCR_PLCT bit and the QCR_INZC bit; under
--      a specific condition that both the PLCT bit and the INZC bit were asserted
--      at the same clock cycle, the PLCT would have been executed while the INZC
--      event would have been missed.
--      5) Added an additional feature:  Quadrature Count Compare Match Event;
--      when the CCME bit is set in the QCR register, and the quadrature count
--      matches the QRW register, a signal is asserted and the status bit of the
--      QSR register is set.  This event can also generate an interrupt.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity quad_decoder is
    --Configurable quadrature counter width; default is 32 bits
    generic(    QUAD_COUNT_WIDTH    : integer   := 32 );
    port(   --Wishbone bus signals
            wb_clk_i    : in    std_logic;
            wb_rst_i    : in    std_logic;
            wb_stb_i    : in    std_logic;
            wb_cyc_i    : in    std_logic;
            wb_ack_o    : out   std_logic;
            --wb_adr_i    : in    std_logic_vector(3 downto 0);
            wb_adr_i    : in    std_logic_vector(1 downto 0); --assumes 32 bit alignment
            wb_dat_o    : out   std_logic_vector(31 downto 0);
            wb_dat_i    : in    std_logic_vector(31 downto 0);
            wb_we_i     : in    std_logic;
            --Quadrature inputs
            quad_cha_i  : in    std_logic;  --Qudrature channel A
            quad_chb_i  : in    std_logic;  --Quadrature channel B
            quad_idx_i  : in    std_logic;  --Quadrature index
            quad_lat_i  : in    std_logic;  --Quadrature latch cnt input
            quad_irq_o  : out   std_logic   --Quadrature IRQ out
    );
end quad_decoder;

architecture quad_decoder_rtl of quad_decoder is

    --Register and bit definitions
   -----------------------------------------------------------------------------
   --   Quadrature Control Register, QCR, offset 0x00
   --
   --   Bit 0:  Enable Counting, ECNT
   --       0 -> Quadrature counting disabled
   --       1 -> Quadrature counting enabled
   --   Bit 1:  Set Count Direction, CTDR
   --       0 -> Counts positive when A leads B
   --       1 -> Counts negative when A leads B
   --   Bit 2:  Index Enable Bit, INEN
   --       0 -> Index input disabled
   --       1 -> Index input enabled
   --   Bit 3:  Index Zero Count Bit, INZC
   --       0 -> Internal count not affected.
   --       1 -> Zero internal quad_count when quad_index is asserted.
   --   Bit 4:  Index Interrupt Enable, INIE
   --       0 -> Index interrupt request disabled
   --       1 -> Index interrupt request enabled
   --   Bit 5:  Pre Load Count register, PLCT
   --       0 -> No action.
   --       1 -> Load value currently in pre load reg into count reg, auto clear
   --   Bit 6:  Underflow Interrupt Enable, UNIE
   --       0 -> Underflow event will not trigger an interrupt.
   --       1 -> Underflow event will trigger an interrupt
   --   Bit 7:  Overflow Interrupt Enable, OVIE
   --       0 -> Overflow event will not trigger an interrupt
   --       1 -> Overflow event will trigger an interrupt
   --   Bit 8:  Quadrature Count Latch, QLAT
   --       0 -> No action.
   --       1 -> Latch and store quad count in QRW register, auto cleared
   --   Bit 9:  Index Channel A configuration, ICHA
   --       0 -> Index asserted when quadrature channel A logic low
   --       1 -> Index asserted when quadrature channel A logic high
   --   Bit 10: Index Channel B configuration, ICHB
   --       0 -> Index asserted when quadrature channel B logic low
   --       1 -> Index asserted when quadrature channel B logic high
   --   Bit 11: Index Level configuration, IDXL
   --       0 -> Index asserted when quadature index is logic low
   --       1 -> Index asserted when quadrature index is logic high
   --   Bit 12: Quadrature Error Interrupt enable, QEIE
   --        0 -> Quadrature Error Interrupt disabled
   --        1 -> Quadrature Error Interrupt enabled
   --   Bit 13: Index Read Count Bit, INRC
   --        0 -> Quadrature Read / Write register not affected.
   --        1 -> Read the value of the quad. count to the QRW reg, when index event is true.
   --   Bit 14: Count Compare Match Enable, CCME
   --        0 -> No compare match event may occur.
   --        1 -> Compare match event asserted when enabled and QRW == quad_count
   --   Bit 15:  Compare Match Interrupt Enable, CMIE
   --        0 -> No interrupt generated when a compare match event is asserted.
   --        1 -> An external interrupt will be generated when the compare event is asserted.
   --   Bits 31:16 -> Reserved, must always be written to 0
   --
   -----------------------------------------------------------------------------
    constant    QCR_ECNT    : integer := 0;
    constant    QCR_CTDR    : integer := 1;
    constant    QCR_INEN    : integer := 2;
    constant    QCR_INZC    : integer := 3;
    constant    QCR_INIE    : integer := 4;
    constant    QCR_PLCT    : integer := 5;
    constant    QCR_UNIE    : integer := 6;
    constant    QCR_OVIE    : integer := 7;
    constant    QCR_QLAT    : integer := 8;
    constant    QCR_ICHA    : integer := 9;
    constant    QCR_ICHB    : integer := 10;
    constant    QCR_IDXL    : integer := 11;
    constant    QCR_QEIE    : integer := 12;
    constant    QCR_INRC    : integer := 13;
    constant    QCR_CCME    : integer := 14;
    constant    QCR_CMIE    : integer := 15;
    constant    QCR_BITS    : integer := 16;    --Number of bits used in QCR register
    signal      qcr_reg     : std_logic_vector(QCR_BITS-1 downto 0);     --QCR register
    constant    QCR_ADDR    : std_logic_vector(1 downto 0) := "00";

    ----------------------------------------------------------------------------
    --  Quadrature Status Register, QSR, offset 0x04
    --  Note:  User clears set bits by writing a 1 to the correspoding register
    --         bit.
    --  Bit 0:  Quadrature decoder error status, QERR, auto set, user cleared
    --      0 -> No error
    --      1 -> Illegal state transition detected
    --  Bit 1:  Counter Overflow, CTOV, auto set, user cleared
    --      0 -> No overflow detected
    --      1 -> Counter overflow from 0xFFFF to 0x0000
    --  Bit 2:  Counter Underflow, CTUN, auto set, user cleared
    --      0 -> No underflow detected
    --      1 -> Counter underflow from 0x0000 to 0xFFFF
    --  Bit 3:  Index event, INEV, auto set, user cleared
    --      0 -> Index event has not occurred
    --      1 -> Index event occured, interrupt requested if INIE set
    --  Bit 4: Count Compare Match Event, CCME, auto set, user cleared
    --      0 -> Compare match event has not occurred
    --      1- > Compare match event occurred, interrupt genetated if enabled
    --  Bits 31:5   -> Reserved, will always read 0
    ----------------------------------------------------------------------------
    constant    QSR_QERR    : integer := 0;
    constant    QSR_CTOV    : integer := 1;
    constant    QSR_CTUN    : integer := 2;
    constant    QSR_INEV    : integer := 3;
    constant    QSR_CCME    : integer := 4;
    constant    QSR_BITS    : integer := 5;                             -- Num bits in QSR reg
    signal      qsr_reg     : std_logic_vector(QSR_BITS-1 downto 0);    --QSR register
    constant    QSR_ADDR    : std_logic_vector(1 downto 0) := "01";

    --Signals indicating status information for the QSR process
    signal      quad_error  : std_logic;
    signal      quad_ovflw  : std_logic;
    signal      quad_unflw  : std_logic;
    signal      quad_index  : std_logic;
    signal      quad_index_d : std_logic;
    signal      quad_index_d2: std_logic;
    signal      quad_comp   : std_logic;

    ----------------------------------------------------------------------------
    --  Quadrature Count Read / Write Register, QRW, offset 0x08
    --  Note:   The actual quadrature count value must be latched prior to
    --          reading from this register.  This may be triggered two ways:
    --          1) Writing a '1' to the QCR, bit 9 quadrature count latch
    --              (QLAT), -or-
    --          2) Asserting the external syncronous input quad_lat_i.
    --          Once either event occurs, the quadrature count value will be
    --          copied to the QCT register.
    --
    --          This register is also used to hold the pre-load count value.
    --          After writing to this register, the pre-load value is
    --          transferred to the quadrature count register by writing a '1'
    --          to bit location 5, quadrature pre-load count (PLCT) of the
    --          quadrature control register (QCR) offset 0x00.
    ----------------------------------------------------------------------------
    signal      qrw_reg     : std_logic_vector(QUAD_COUNT_WIDTH-1 downto 0);
    constant    QRW_ADDR    : std_logic_vector(1 downto 0) := "10";

    --Actual quadrature counter register, extra bit for over/underflow detect
    signal      quad_count  : std_logic_vector(QUAD_COUNT_WIDTH downto 0);

    --Input buffers / filters for quadrature signals
    signal      quad_cha_buf: std_logic_vector(3 downto 0);
    signal      quad_chb_buf: std_logic_vector(3 downto 0);
    signal      quad_idx_buf: std_logic_vector(3 downto 0);
    signal      quad_cha_flt: std_logic;
    signal      quad_chb_flt: std_logic;
    signal      quad_idx_flt: std_logic;
    signal      quad_cha_j  : std_logic;
    signal      quad_cha_k  : std_logic;
    signal      quad_chb_j  : std_logic;
    signal      quad_chb_k  : std_logic;
    signal      quad_idx_j  : std_logic;
    signal      quad_idx_k  : std_logic;

    signal      quad_lat_flt : std_logic;
    signal      quad_lat_q   : std_logic;
    signal      quad_lat_m   : std_logic;

    --Quadrature 4X decoding state machine signals
    signal      quad_st_new : std_logic_vector(1 downto 0);
    signal      quad_st_old : std_logic_vector(1 downto 0);
    signal      quad_trans  : std_logic;
    signal      quad_dir    : std_logic;
    -- State constants for 4x quad decoding, CH B is MSB, CH A is LSB
    constant    QUAD_STATE_0: std_logic_vector(1 downto 0) := "00";
    constant    QUAD_STATE_1: std_logic_vector(1 downto 0) := "01";
    constant    QUAD_STATE_2: std_logic_vector(1 downto 0) := "11";
    constant    QUAD_STATE_3: std_logic_vector(1 downto 0) := "10";

    --Wishbone internal signals
    signal      wb_request  : std_logic;
    signal      wb_write    : std_logic;

    --Signal for single clock delay of ack out
    signal      ack_dly     : std_logic;

    --Internal irq signal
    signal      quad_irq_int: std_logic;

    -- Internal signal to latch quad count on index assertion
    signal qcnt_idx_latch   : std_logic;
    
    ----------------------------------------------------------------------------
    --Start of RTL
    ----------------------------------------------------------------------------
    begin

        --Assign internal signal to external signal
        quad_irq_o  <= quad_irq_int;

        -- Handle wishbone ack generation / internal write signals
        wb_request  <= wb_stb_i and wb_cyc_i;
        wb_write    <= wb_request and wb_we_i;
        wb_ack_o    <= ack_dly;

        -----------------------------------------------------------------------
        --  Process:    qck_dly_proc( wb_clk_i )
        --  Desc:       Generates the wishbone ack signal after a single clock
        --              delay.  This insures that the internal read / write
        --              operations have completed before acknowledging the
        --              master device.
        --  Signals:    wb_clk_i
        --              ack_dly
        --              wb_rst_i
        --  Notes:      Verified using the Wishbone bus of the TSK3000 from
        --              Altium Designer.
        -----------------------------------------------------------------------
        ack_dly_proc: process( wb_clk_i ) begin
            if rising_edge( wb_clk_i ) then
                if wb_rst_i = '1' then
                    ack_dly <= '0';
                elsif wb_request = '1' then
                    ack_dly <= '1';
                end if;
                if ack_dly = '1' then
                    ack_dly <= '0';
                end if;
            end if;
        end process ack_dly_proc;

        -----------------------------------------------------------------------
        --  Process:    qcr_reg_wr_proc( wb_clk_i )
        --  Desc:       Handles writing of the Quadrature Control Regsiter
        --              signal, address offset 0x00.
        --  Signals:    qcr_reg, quadrature control register
        --              wb_rst_i, external reset input
        --              wb_write, internal write enable signal
        --              wb_adr_i, wishbone address inputs
        --              wb_dat_i, wishbone data inputs
        --  Notes:      See comments above for more info re the qcr_reg
        -----------------------------------------------------------------------
        qcr_reg_wr_proc: process( wb_clk_i ) begin
            if rising_edge( wb_clk_i ) then
                if wb_rst_i = '1' then
                    qcr_reg <= (others => '0');
                elsif wb_write = '1' and wb_adr_i = QCR_ADDR then
                    qcr_reg <= wb_dat_i(QCR_BITS-1 downto 0);
                end if;
                --See if PLCT asserted, should be auto-cleared
                if qcr_reg(QCR_PLCT) = '1' then
                    qcr_reg(QCR_PLCT) <= '0';
                end if;
                --See if QLAT asserted, should be auto-cleared
                if qcr_reg(QCR_QLAT) = '1' then
                    qcr_reg(QCR_QLAT) <= '0';
                end if;
            end if;
        end process qcr_reg_wr_proc;

        -----------------------------------------------------------------------
        --  Process:    qsr_reg_wr_proc( wb_clk_i )
        --  Desc:       Handles writing of the Quadrature Status Register, QSR,
        --              offset 0x04.
        --  Signals:    quad_error, internal error status signal
        --              quad_ovflw, internal counter overflow signal
        --              quad_unflw, internal counter underflow signal
        --              quad_index, internl index event signal
        --              wb_rst_i, external reset input
        --              wb_write, internal write enable signal
        --              wb_adr_i, wishbone address inputs
        --              wb_dat_i, wishbone data inputs
        --  Notes:      All of these bits are set automatically based on the
        --              states of the internal signals.  Once set, the user must
        --              write a '1' to the corresponding bit location to clear it.
        --              See the comments above for more information.
        -----------------------------------------------------------------------
        qsr_reg_wr_proc: process( wb_clk_i ) begin
            if rising_edge( wb_clk_i ) then
                if wb_rst_i = '1' then
                    qsr_reg     <= (others => '0');
                else
                    --Set qsr_reg bit from signal quad_error
                    if quad_error = '1' and qcr_reg(QCR_ECNT) = '1' then
                        qsr_reg(QSR_QERR) <= '1';
                    elsif wb_write = '1' and wb_adr_i = QSR_ADDR and qsr_reg(QSR_QERR) = '1' and wb_dat_i(QSR_QERR) = '1' then
                        qsr_reg(QSR_QERR) <= '0';
                    end if;
                    --Set qsr_reg bit rom signal quad_ovflw
                    if quad_ovflw = '1' then
                        qsr_reg(QSR_CTOV) <= '1';
                    elsif wb_write = '1' and wb_adr_i = QSR_ADDR and qsr_reg(QSR_CTOV) = '1' and wb_dat_i(QSR_CTOV) = '1' then
                        qsr_reg(QSR_CTOV) <= '0';
                    end if;
                    --Set qsr_reg bit from signal quad_unflw
                    if quad_unflw = '1' then
                        qsr_reg(QSR_CTUN) <= '1';
                    elsif wb_write = '1' and wb_adr_i = QSR_ADDR and qsr_reg(QSR_CTUN) = '1' and wb_dat_i(QSR_CTUN) = '1' then
                        qsr_reg(QSR_CTUN) <= '0';
                    end if;
                    --Set qsr_reg bit from signal quad_index
                    if quad_index = '1' then
                        qsr_reg(QSR_INEV) <= '1';
                    elsif wb_write = '1' and wb_adr_i = QSR_ADDR and qsr_reg(QSR_INEV) = '1' and wb_dat_i(QSR_INEV) = '1' then
                        qsr_reg(QSR_INEV) <= '0';
                    end if;
                    --check quadrature compare bit
                    if quad_comp = '1' then
                        qsr_reg(QSR_CCME) <= '1';
                    elsif wb_write = '1' and wb_adr_i = QSR_ADDR and qsr_reg(QSR_CCME) = '1' and wb_dat_i(QSR_CCME) = '1' then
                        qsr_reg(QSR_CCME) <= '0';
                    end if;
                end if;
            end if;
        end process qsr_reg_wr_proc;

        -----------------------------------------------------------------------
        --  Process:    qrw_reg_wr_proc( wb_clk_i )
        --  Desc:       Handles writing to the Quadrature Read / Write Register,
        --              offset 0x08.
        --  Signals:    wb_rst, reset signal
        --              QLAT bit of QCR reg, Quadrature latch
        --              quad_lat_flt, filtered external quadrature latch signal
        --  Notes:      Use of this register is required to access the
        --              quadrature count.
        -----------------------------------------------------------------------
        qrw_reg_wr_proc: process( wb_clk_i ) begin
            if rising_edge( wb_clk_i ) then
                if wb_rst_i = '1' then
                    qrw_reg <= (others =>'0');
                elsif wb_write = '1' and wb_adr_i = QRW_ADDR then
                    qrw_reg <= wb_dat_i;
                elsif qcr_reg(QCR_QLAT) = '1' or quad_lat_flt = '1' or (qcr_reg(QCR_INRC) = '1' and quad_index = '1') then
                    qrw_reg <= quad_count(QUAD_COUNT_WIDTH-1 downto 0);
                end if;
            end if;
        end process qrw_reg_wr_proc;

        -----------------------------------------------------------------------
        --  Process:    quad_regs_rd_proc( wb_clk_i )
        --  Desc:       Handles reading of all of the registers.
        --  Signals:    wb_adr_i, Wishbone address input
        --              qcr_reg, Quadrature control register
        --              qsr_reg, Quadrature status register
        --              qrw_reg, Quadrature read/write register
        --  Notes:      None.
        -----------------------------------------------------------------------
        quad_regs_rd_proc: process( wb_adr_i, qcr_reg, qsr_reg, qrw_reg ) begin
            case wb_adr_i is
                when QCR_ADDR   =>
                    wb_dat_o(QCR_BITS-1 downto 0) <= qcr_reg;
                    wb_dat_o(31 downto QCR_BITS) <= (others => '0');
                when QSR_ADDR   =>
                    wb_dat_o(QSR_BITS-1 downto 0) <= qsr_reg;
                    wb_dat_o(31 downto QSR_BITS) <= (others => '0');
                when QRW_ADDR   =>
                    wb_dat_o(QUAD_COUNT_WIDTH-1 downto 0) <= qrw_reg;
                when others =>
                    wb_dat_o    <= (others => '0' );
            end case;
        end process quad_regs_rd_proc;

        -----------------------------------------------------------------------
        --  Process:    quad_lat_m_proc( wb_clk_i )
        --  Desc:       Rising edge detect for input quad_lat_i
        --  Signals:    quad_lat_i, external quadratire latch input
        --              quad_lat_m, metastable quadature latch signal
        --  Note:       This is an asynchronous signal; the metastable
        --              output is later latched to a synchronized internal
        --              signal for other module processes.
        -----------------------------------------------------------------------
        quad_lat_m_proc : process( quad_lat_i ) begin
            if rising_edge( quad_lat_i ) then
                if wb_rst_i = '1' then
                    quad_lat_m <= '0';
                else
                    quad_lat_m <= '1';
                end if;

                if quad_lat_m = '1' then
                    quad_lat_m  <= '0';
                end if;
            end if;
        end process quad_lat_m_proc;

        -----------------------------------------------------------------------
        --  Process:    quad_lat_proc
        --  Desc:       Metastable filter for quad_lat_i, sets internal signal
        --  Signals:    quad_lat_m, metastable latch signal
        --              quad_lat_q, stable latched signal
        --              quad_lat_flt, filtered signal used by other processe
        --  Note:       Due to the filtering, there is a delay of 4 clk cycles
        --              from assertion of the signal until asserting internal
        --              processes.
        -----------------------------------------------------------------------
        quad_lat_proc: process( wb_clk_i) begin
            if rising_edge( wb_clk_i ) then
                if wb_rst_i = '1' then
                    quad_lat_flt    <= '0';
                    quad_lat_q      <= '0';
                else
                    if quad_lat_m = '1' then
                        quad_lat_q  <= '1';
                    end if;
                    if quad_lat_q = '1' then
                        quad_lat_q      <= '0';
                        quad_lat_flt    <= '1';
                    end if;
                    if quad_lat_flt = '1' then
                        quad_lat_flt <= '0';
                    end if;
                end if;
            end if;
        end process quad_lat_proc;

        --Combinatorial logic for JK flip flop filters
        quad_cha_j  <= quad_cha_buf(3) and quad_cha_buf(2) and quad_cha_buf(1);
        quad_cha_k  <= not( quad_cha_buf(3) or quad_cha_buf(2) or quad_cha_buf(1) );
        quad_chb_j  <= quad_chb_buf(3) and quad_chb_buf(2) and quad_chb_buf(1);
        quad_chb_k  <= not( quad_chb_buf(3) or quad_chb_buf(2) or quad_chb_buf(1) );
        quad_idx_j  <= quad_idx_buf(3) and quad_idx_buf(2) and quad_idx_buf(1);
        quad_idx_k  <= not( quad_idx_buf(3) or quad_idx_buf(2) or quad_idx_buf(1) );

        -----------------------------------------------------------------------
        --  Process:    quad_filt_proc
        --  Desc:       Digital filters for the quadrature inputs.  This is
        --              implemented with serial shift registers on all inputs;
        --              similar to the digital filters of the HCTL-2016.  See
        --              that datasheet for more information.
        --  Signals:    quad_cha_i, external input
        --              quad_chb_i, external input
        --              quad_idx_i, external input
        --              quad_cha_buf, input buffer for filtering
        --              quad_chb_buf, input buffer for filtering
        --              quad_cha_flt, filtered cha signal
        --              quad_chb_flt, filtered chb signal
        --              quad_cha_j, j signal for jk FF
        --              quad_cha_k, k signal for jk FF
        --  Note:       Upon reset, all buffers are filled with the values
        --              present on the input pins.
        -----------------------------------------------------------------------
        quad_filt_proc: process( wb_clk_i ) begin
            if rising_edge( wb_clk_i ) then
                if wb_rst_i = '1' then
                    quad_cha_buf    <= ( quad_cha_i & quad_cha_i & quad_cha_i & quad_cha_i );
                    quad_chb_buf    <= ( quad_chb_i & quad_chb_i & quad_chb_i & quad_chb_i );
                    quad_idx_buf    <= ( quad_idx_i & quad_idx_i & quad_idx_i & quad_idx_i );
                    quad_cha_flt    <= quad_cha_i;
                    quad_chb_flt    <= quad_chb_i;
                    quad_idx_flt    <= quad_idx_i;
                else
                    --sample inputs, place into shift registers
                    quad_cha_buf    <= ( quad_cha_buf(2) & quad_cha_buf(1) & quad_cha_buf(0) & quad_cha_i );
                    quad_chb_buf    <= ( quad_chb_buf(2) & quad_chb_buf(1) & quad_chb_buf(0) & quad_chb_i );
                    quad_idx_buf    <= ( quad_idx_buf(2) & quad_idx_buf(1) & quad_idx_buf(0) & quad_idx_i );

                    -- JK flip flop filters
                    if quad_cha_j = '1' then
                        quad_cha_flt    <= '1';
                    end if;
                    if quad_cha_k = '1' then
                        quad_cha_flt    <= '0';
                    end if;
                    if quad_chb_j = '1' then
                        quad_chb_flt    <= '1';
                    end if;
                    if quad_chb_k = '1' then
                        quad_chb_flt    <= '0';
                    end if;
                    if quad_idx_j = '1' then
                        quad_idx_flt <= '1';
                    end if;
                    if quad_idx_k = '1' then
                        quad_idx_flt <= '0';
                    end if;
                end if;
            end if;
        end process quad_filt_proc;

        -----------------------------------------------------------------------
        --  Process:    quad_state_proc
        --  Desc:       Reads filtered values quad_cha_flt, quad_chb_flt and
        --              asserts the quad_trans and quad_dir signals.
        --  Signals:    quad_st_old
        --              quad_st_new
        --              quad_trans
        --              quad_dir
        --              quad_error
        --  Notes:      See the datasheet for more info.
        -----------------------------------------------------------------------
        quad_state_proc: process( wb_clk_i ) begin
            if rising_edge( wb_clk_i ) then
                if wb_rst_i = '1' then
                    quad_st_old     <= (quad_chb_i & quad_cha_i);
                    quad_st_new     <= (quad_chb_i & quad_cha_i);
                    quad_trans      <= '0';
                    quad_dir        <= '0';
                    quad_error      <= '0';
                else
                    quad_st_new <= (quad_chb_flt & quad_cha_flt);
                    quad_st_old <= quad_st_new;
                    --state machine enabled if counting
                    if qcr_reg(QCR_ECNT) = '1' then
                        case quad_st_new is
                            when QUAD_STATE_0 =>    --"00"
                                case quad_st_old is
                                    when QUAD_STATE_0 =>
                                        quad_trans      <= '0';
                                    when QUAD_STATE_3 => --"10" -- dflt positive direction
                                        if qcr_reg(QCR_CTDR) = '1' then
                                            quad_trans  <= '1';
                                            quad_dir    <= '0';
                                        else
                                            quad_trans  <= '1';
                                            quad_dir    <= '1';
                                        end if;
                                    when QUAD_STATE_1 => --"01" -- dflt negative direction
                                        if qcr_reg(QCR_CTDR) = '1' then
                                            quad_trans  <= '1';
                                            quad_dir    <= '1';
                                        else
                                            quad_trans  <= '1';
                                            quad_dir    <= '0';
                                        end if;
                                    when others =>
                                        quad_error  <= '1';
                                        quad_trans  <= '0';
                                end case; --quad_st_old

                            when QUAD_STATE_1 =>    --"01"
                                case quad_st_old is
                                    when QUAD_STATE_1 =>
                                        quad_trans      <= '0';
                                    when QUAD_STATE_0 => --"10" -- dflt positive direction
                                        if qcr_reg(QCR_CTDR) = '1' then
                                            quad_trans  <= '1';
                                            quad_dir    <= '0';
                                        else
                                            quad_trans  <= '1';
                                            quad_dir    <= '1';
                                        end if;
                                    when QUAD_STATE_2 => --"01" -- dflt negative direction
                                        if qcr_reg(QCR_CTDR) = '1' then
                                            quad_trans  <= '1';
                                            quad_dir    <= '1';
                                        else
                                            quad_trans  <= '1';
                                            quad_dir    <= '0';
                                        end if;
                                    when others =>
                                        quad_error  <= '1';
                                        quad_trans  <= '0';
                                end case; --quad_st_old

                            when QUAD_STATE_2 =>    --"11"
                                case quad_st_old is
                                    when QUAD_STATE_2 =>
                                        quad_trans      <= '0';
                                    when QUAD_STATE_1 => --"10" -- dflt positive direction
                                        if qcr_reg(QCR_CTDR) = '1' then
                                            quad_trans  <= '1';
                                            quad_dir    <= '0';
                                        else
                                            quad_trans  <= '1';
                                            quad_dir    <= '1';
                                        end if;
                                    when QUAD_STATE_3 => --"01" -- dflt negative direction
                                        if qcr_reg(QCR_CTDR) = '1' then
                                            quad_trans  <= '1';
                                            quad_dir    <= '1';
                                        else
                                            quad_trans  <= '1';
                                            quad_dir    <= '0';
                                        end if;
                                    when others =>
                                        quad_error  <= '1';
                                        quad_trans  <= '0';
                                end case; --quad_st_old

                            when QUAD_STATE_3 =>    --"10"
                                case quad_st_old is
                                    when QUAD_STATE_3 =>
                                        quad_trans      <= '0';
                                    when QUAD_STATE_2 => --"10" -- dflt positive direction
                                        if qcr_reg(QCR_CTDR) = '1' then
                                            quad_trans  <= '1';
                                            quad_dir    <= '0';
                                        else
                                            quad_trans  <= '1';
                                            quad_dir    <= '1';
                                        end if;
                                    when QUAD_STATE_0 => --"01" -- dflt negative direction
                                        if qcr_reg(QCR_CTDR) = '1' then
                                            quad_trans  <= '1';
                                            quad_dir    <= '1';
                                        else
                                            quad_trans  <= '1';
                                            quad_dir    <= '0';
                                        end if;
                                    when others =>
                                        quad_error  <= '1';
                                        quad_trans  <= '0';
                                end case; --quad_st_old

                            when others =>
                                quad_error  <= '1';
                                quad_trans  <= '0';
                        end case; --quad_st_new

                    end if;

                    if quad_trans = '1' then
                        quad_trans  <= '0';
                    end if;

                    if quad_dir = '1' then
                        quad_dir    <= '0';
                    end if;

                    if quad_error = '1' then
                        quad_error  <= '0';
                    end if;
                end if;
            end if;
        end process quad_state_proc;

        -----------------------------------------------------------------------
        --  Process:    quad_count_proc( wb_clk_i )
        --  Desc:       Handles writing to the quad_count register.
        --              First, pre-load events are handled; this may be triggered
        --              by writing a '1' to the qcr_reg QCR_PLCT bit location, or
        --              by an index_event assertion. Next, count events may be
        --              triggered by an assertion of the 'quad_trans' signal,
        --              which causes the quad_count value to increment or
        --              decrement by one, based on the quad_dir signal.
        --              With each change on the count value, the counter is
        --              checked for over/underflow.  If either is detected, the
        --              corresponding signal is asserted for one clock cycle.
        --  Signals:    quad_count, QUAD_COUNT_WIDTH+1 bit length, holds the actual
        --                  4x quadrature counts.  The extra bit (i.e., as compared
        --                  to the user register qrw_reg) is for over / underflow
        --                  detection.  2's complement integer.
        --              quad_ovflw, single bit signal indicating an overflow event
        --                  has occurred; asserted one clock cycle then cleared.
        --              quad_unflw, single bit signal indicating that an underflow
        --                  event occured; asserted one clock cycle then cleared.
        --  Note:       See the comments for the qcr_reg register for more info
        --              regarding the index event control bits.
        -----------------------------------------------------------------------
        quad_count_proc: process( wb_clk_i ) begin
            if rising_edge( wb_clk_i ) then
                --Reset event
                if wb_rst_i = '1' then
                    quad_count  <= (others =>'0');
                    quad_ovflw  <= '0';
                    quad_unflw  <= '0';
                else
                --Pre-load count event; either from qcr_reg or index event
                    if qcr_reg(QCR_PLCT) = '1' then
                        quad_count(QUAD_COUNT_WIDTH-1 downto 0) <= qrw_reg;
                        quad_count(QUAD_COUNT_WIDTH)            <= '0';
                    end if;
                    if (quad_index = '1' and qcr_reg(QCR_INZC) = '1') then
                        quad_count  <= (others =>'0');
                    end if;                
                    if quad_trans = '1' then
                        if quad_dir = '1' then
                            quad_count  <= quad_count + 1;
                        else
                            quad_count  <= quad_count - 1;
                        end if;
                    end if;
                    --check for over/under flow
                    if quad_count(QUAD_COUNT_WIDTH) = '1' then
                        --reset overflow bit
                        quad_count(QUAD_COUNT_WIDTH)    <= '0';
                        --Check MSB-1 to see if it is under or over flow
                        if quad_count(QUAD_COUNT_WIDTH-1) = '1' then
                            quad_unflw  <= '1';
                        else
                            quad_ovflw  <= '1';
                        end if;
                    end if;
                end if;
                --reset signals
                if quad_ovflw = '1' then
                    quad_ovflw  <= '0';
                end if;
                if quad_unflw = '1' then
                    quad_unflw  <= '0';
                end if;
            end if;
        end process quad_count_proc;

        -----------------------------------------------------------------------
        --  Preocess:   quad_comp_proc( wb_clk_i )
        --  Desc:       Monitors the quad_count and the qwr_reg to assert the
        --              the quad_comp signal.
        --  Signals:    wb_clk_i
        --              wb_rst_i
        --              quad_comp
        --  Note:       When enabled, the quad_comp signal will get asserted
        --              every time the quad_count is latched into the qrw reg.
        -----------------------------------------------------------------------
        quad_comp_proc : process( wb_clk_i ) begin
            if rising_edge( wb_clk_i ) then
                if wb_rst_i = '1' then
                    quad_comp <= '0';
                elsif (quad_count(QUAD_COUNT_WIDTH-1 downto 0) = qrw_reg) and qcr_reg(QCR_CCME) = '1' and qsr_reg(QSR_CCME) = '0' then
                    quad_comp <= '1';
                end if;
                if quad_comp = '1' then
                    quad_comp <= '0';
                end if;
            end if;
        end process quad_comp_proc;

        -----------------------------------------------------------------------
        --  Process:    quad_index_proc( wb_clk_i )
        --  Desc:       Controls the internal quad_index signal.  This signal is
        --              asserted to indicated the occurance of an index event.
        --  Signals:    quad_index
        --              quad_cha_flt
        --              quad_chb_flt
        --              quad_index
        --  Note:       None.
        -----------------------------------------------------------------------
        quad_index_proc : process( wb_clk_i ) begin
            if rising_edge( wb_clk_i ) then
                if wb_rst_i = '1' then
                    quad_index <= '0';
                elsif qcr_reg(QCR_INEN) = '1'
                    and qcr_reg(QCR_ECNT) = '1'
                    and qcr_reg(QCR_ICHA) = quad_cha_flt
                    and qcr_reg(QCR_ICHB) = quad_chb_flt
                    and qcr_reg(QCR_IDXL) = quad_idx_flt then
                    quad_index_d  <= '1';
                end if;
                if quad_index_d = '1' then
                    quad_index_d <= '0';
                    quad_index_d2<= '1';
                end if;
                if quad_index_d2 ='1' then
                    quad_index_d2 <= '0';
                    quad_index <= '1';
                end if;
                if quad_index = '1' then
                    quad_index <= '0';
                end if;
            end if;
        end process quad_index_proc;

        -----------------------------------------------------------------------
        --  Process:    quad_irq_proc
        --  Desc:       Handles writing to the internal signal quad_irq_int.
        --              This process checks to see if a valid interrupt signal
        --              is asserted along with the corresponding enable bit; if
        --              so, the external interrupt is asserted.
        --  Signals:    quad_irq_int
        --              quad_error
        --              quad_ovflw
        --              quad_unflw
        --              quad_index
        --              quad_comp
        --  Note:       The external interrupt is cleared after assertion when
        --              all status bits are cleared in the QSR register.
        --
        -----------------------------------------------------------------------
        quad_irq_proc: process( wb_clk_i ) begin
            if rising_edge( wb_clk_i ) then
                if wb_rst_i = '1' then
                    quad_irq_int  <= '0';
                elsif       ( quad_error = '1' and qcr_reg(QCR_QEIE) = '1' )
                        or  ( quad_ovflw = '1' and qcr_reg(QCR_OVIE) = '1' )
                        or  ( quad_unflw = '1' and qcr_reg(QCR_UNIE) = '1' )
                        or  ( quad_index = '1' and qcr_reg(QCR_INIE) = '1' )
                        or  ( quad_comp  = '1' and qcr_reg(QCR_CMIE) = '1' ) then
                    quad_irq_int <= '1';
                elsif quad_irq_int = '1' and
                    not(    ( qsr_reg(QSR_QERR) = '1' and qcr_reg(QCR_QEIE) = '1' )
                        or  ( qsr_reg(QSR_CTOV) = '1' and qcr_reg(QCR_OVIE) = '1' )
                        or  ( qsr_reg(QSR_CTUN) = '1' and qcr_reg(QCR_UNIE) = '1' )
                        or  ( qsr_reg(QSR_INEV) = '1' and qcr_reg(QCR_INIE) = '1' )
                        or  ( qsr_reg(QSR_CCME) = '1' and qcr_reg(QCR_CMIE) = '1' ) ) then
                    quad_irq_int <= '0';
                end if;
            end if;
        end process quad_irq_proc;

end architecture quad_decoder_rtl;
