----------------------------------------------------------------------------------
-- Author:          Jonny Doin, jdoin@opencores.org, jonnydoin@gmail.com
-- 
-- Create Date:     01:21:32 06/30/2011 
-- Design Name: 
-- Module Name:     spi_master_atlys_top
-- Project Name:    spi_master_slave
-- Target Devices:  Spartan-6 LX45
-- Tool versions:   ISE 13.1
-- Description: 
--          This is a verification project for the Digilent Atlys board, to test the SPI_MASTER, SPI_SLAVE and GRP_DEBOUNCE cores.
--          It uses the board's 100MHz clock input, and clocks all sequential logic at this clock.
--
--          See the "spi_master_atlys.ucf" file for pin assignments.
--          The test circuit uses the VHDCI connector on the Atlys to implement a 16-pin debug port to be used
--          with a Tektronix MSO2014. The 16 debug pins are brought to 2 8x2 headers that form a umbilical
--          digital pod port.
--
------------------------------ REVISION HISTORY -----------------------------------------------------------------------
--
-- 2011/07/02   v0.01.0010  [JD]    implemented a wire-through from switches to LEDs, just to test the toolchain. It worked!
-- 2011/07/03   v0.01.0020  [JD]    added clock input, and a simple LED blinker for each LED. 
-- 2011/07/03   v0.01.0030  [JD]    added clear input, and instantiated a SPI_MASTER from my OpenCores project. 
-- 2011/07/04   v0.01.0040  [JD]    changed all clocks to clock enables, and use the 100MHz board pclk_i to clock all registers.
--                                  this change made the design go up to 288MHz, after synthesis.
-- 2011/07/07   v0.03.0050  [JD]    implemented a 16pin umbilical port for the MSO2014 in the Atlys VmodBB board, and moved all
--                                  external monitoring pins to the VHDCI ports.
-- 2011/07/10   v1.10.0075  [JD]    verified spi_master_slave at 50MHz, 25MHz, 16.666MHz, 12.5MHz, 10MHz, 8.333MHz, 7.1428MHz, 
--                                  6.25MHz, 1MHz and 500kHz 
-- 2011/07/29   v1.12.0105  [JD]    spi_master.vhd and spi_slave_vhd changed to fix CPHA='1' bug.
-- 2011/08/02   v1.13.0110  [JD]    testbed for continuous transfer in FPGA hardware.
--
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity spi_master_atlys_top is
    Generic (   
        N : positive := 8;                              -- 8bit serial word length is default
        CPOL : std_logic := '0';                        -- SPI mode selection (mode 0 default)
        CPHA : std_logic := '0';                        -- CPOL = clock polarity, CPHA = clock phase.
        PREFETCH : positive := 3;                       -- prefetch lookahead cycles
        CLK_PERIOD : time := 10 ns;                     -- clock period for pclk_i (default 100MHz)
        DEBOUNCE_TIME : time := 2 us);                  -- switch debounce time (use 200 us for silicon, 2 us for simulation)
    Port (
        sclk_i : in std_logic := 'X';                   -- board clock input 100MHz
        pclk_i : in std_logic := 'X';                   -- board clock input 100MHz
        --- SPI interface ---           
        spi_ssel_o : out std_logic;                     -- spi port SSEL
        spi_sck_o : out std_logic;                      -- spi port SCK
        spi_mosi_o : out std_logic;                     -- spi port MOSI
        spi_miso_o : out std_logic;                     -- spi port MISO
        --- input slide switches ---            
        sw_i : in std_logic_vector (7 downto 0);        -- 8 input slide switches
        --- input buttons ---           
        btn_i : in std_logic_vector (5 downto 0);       -- 6 input push buttons
        --- output LEDs ----            
        led_o : out std_logic_vector (7 downto 0);      -- output leds
        --- debug outputs ---
        s_do_o : out std_logic_vector (7 downto 0);
        m_do_o : out std_logic_vector (7 downto 0);
        m_state_o : out std_logic_vector (3 downto 0);  -- master spi fsm state
        s_state_o : out std_logic_vector (3 downto 0);  -- slave spi fsm state
        dbg_o : out std_logic_vector (11 downto 0)      -- 12 generic debug pins
    );                      
end spi_master_atlys_top;

architecture rtl of spi_master_atlys_top is

    --=============================================================================================
    -- Constants
    --=============================================================================================
    -- clock divider count values from pclk_i (100MHz board clock)
    -- these constants shall not be zero
    constant FSM_CE_DIV         : integer := 1;     -- fsm operates at 100MHz
    constant SPI_2X_CLK_DIV     : integer := 1;     -- 50MHz SPI clock
    constant SAMP_CE_DIV        : integer := 1;     -- board signals sampled at 100MHz
    
    -- button definitions
    constant btRESET    : integer := 0;             -- these are constants to use as btn_i(x)
    constant btUP       : integer := 1;
    constant btLEFT     : integer := 2;
    constant btDOWN     : integer := 3;
    constant btRIGHT    : integer := 4;
    constant btCENTER   : integer := 5;

    --=============================================================================================
    -- Type definitions
    --=============================================================================================
    type fsm_master_write_state_type is 
            (st_reset, st_wait_spi_idle, st_wait_new_switch, st_send_spi_data_sw, st_wait_spi_ack_sw, 
            st_send_spi_data_1, st_wait_spi_ack_1, st_wait_spi_di_req_2, st_wait_spi_ack_2, 
            st_wait_spi_di_req_3, st_wait_spi_ack_3);

    type fsm_slave_write_state_type is 
            (st_reset, st_wait_spi_start, st_wait_spi_di_req_2, st_wait_spi_ack_2, st_wait_spi_do_valid_1,
            st_wait_spi_di_req_3, st_wait_spi_ack_3, st_wait_spi_end);

    type fsm_slave_read_state_type is
            (st_reset, st_wait_spi_do_valid_1, st_wait_spi_n_do_valid_1, st_wait_spi_do_valid_2, 
            st_wait_spi_n_do_valid_2, st_wait_spi_do_valid_3, st_wait_spi_n_do_valid_3);

    --=============================================================================================
    -- Signals for state machine control
    --=============================================================================================
    signal m_wr_st_reg  : fsm_master_write_state_type := st_reset;
    signal m_wr_st_next : fsm_master_write_state_type := st_reset;
    signal s_wr_st_reg  : fsm_slave_write_state_type := st_reset;
    signal s_wr_st_next : fsm_slave_write_state_type := st_reset;
    signal s_rd_st_reg  : fsm_slave_read_state_type := st_reset;
    signal s_rd_st_next : fsm_slave_read_state_type := st_reset;

    --=============================================================================================
    -- Signals for internal operation
    --=============================================================================================
    --- clock enable signals ---
    signal samp_ce          : std_logic := '1';         -- clock enable for sample inputs
    signal fsm_ce           : std_logic := '1';         -- clock enable for fsm logic
    --- switch debouncer signals ---
    signal sw_data          : std_logic_vector (7 downto 0) := (others => '0'); -- debounced switch data
    signal sw_reg           : std_logic_vector (7 downto 0) := (others => '0'); -- registered switch data 
    signal sw_next          : std_logic_vector (7 downto 0) := (others => '0'); -- combinatorial switch data
    signal new_switch       : std_logic := '0';                                 -- detector for new switch data
    --- pushbutton debouncer signals ---
    signal btn_data         : std_logic_vector (5 downto 0) := (others => '0'); -- debounced state of pushbuttons
    signal btn_reg          : std_logic_vector (5 downto 0) := (others => '0'); -- registered button data 
    signal btn_next         : std_logic_vector (5 downto 0) := (others => '0'); -- combinatorial button data
    signal new_button       : std_logic := '0';                                 -- detector for new button data
    --- spi port signals ---
    -- spi bus wires
    signal spi_ssel         : std_logic;
    signal spi_sck          : std_logic;
    signal spi_mosi         : std_logic;
    signal spi_miso         : std_logic;
    -- spi master port control signals
    signal spi_rst_reg      : std_logic := '1';
    signal spi_rst_next     : std_logic := '1';
    signal spi_ssel_reg     : std_logic;
    signal spi_wren_reg_m   : std_logic := '0';
    signal spi_wren_next_m  : std_logic := '0';
    -- spi master port flow control flags
    signal spi_di_req_m     : std_logic;
    signal spi_do_valid_m   : std_logic;
    -- spi master port parallel data bus
    signal spi_di_reg_m     : std_logic_vector (N-1 downto 0) := (others => '0');
    signal spi_di_next_m    : std_logic_vector (N-1 downto 0) := (others => '0');
    signal spi_do_m         : std_logic_vector (N-1 downto 0);
    signal spi_wr_ack_m     : std_logic;
    -- spi slave port control signals
    signal spi_wren_reg_s   : std_logic := '1';
    signal spi_wren_next_s  : std_logic := '1';
    -- spi slave port flow control flags
    signal spi_di_req_s     : std_logic;
    signal spi_do_valid_s   : std_logic;
    -- spi slave port parallel data bus
    signal spi_di_reg_s     : std_logic_vector (N-1 downto 0) := (others => '0');
    signal spi_di_next_s    : std_logic_vector (N-1 downto 0) := (others => '0');
    signal spi_do_s         : std_logic_vector (N-1 downto 0);
    signal spi_wr_ack_s     : std_logic;
    signal spi_rx_bit_s     : std_logic;
    -- spi debug data --
    signal spi_state_m      : std_logic_vector (3 downto 0);
    signal spi_state_s      : std_logic_vector (3 downto 0);
    -- slave data output regs --
    signal s_do_1_reg       : std_logic_vector (N-1 downto 0) := (others => '0');
    signal s_do_1_next      : std_logic_vector (N-1 downto 0) := (others => '0');
    signal s_do_2_reg       : std_logic_vector (N-1 downto 0) := (others => '0');
    signal s_do_2_next      : std_logic_vector (N-1 downto 0) := (others => '0');
    signal s_do_3_reg       : std_logic_vector (N-1 downto 0) := (others => '0');
    signal s_do_3_next      : std_logic_vector (N-1 downto 0) := (others => '0');
    -- other signals
    signal clear            : std_logic := '0';
    -- debug output signals
    signal leds_reg         : std_logic_vector (7 downto 0);
    signal leds_next        : std_logic_vector (7 downto 0) := (others => '0');
    signal dbg              : std_logic_vector (11 downto 0) := (others => '0');
begin

    --=============================================================================================
    -- COMPONENT INSTANTIATIONS FOR THE CORES UNDER TEST
    --=============================================================================================
    -- spi master port: data and control signals driven by the master fsm
    Inst_spi_master_port: entity work.spi_master(rtl) 
        generic map (N => N, CPOL => CPOL, CPHA => CPHA, PREFETCH => PREFETCH, SPI_2X_CLK_DIV => SPI_2X_CLK_DIV)
        port map( 
            sclk_i => sclk_i,                   -- system clock is used for serial and parallel ports
            pclk_i => pclk_i,
            rst_i => spi_rst_reg,
            spi_ssel_o => spi_ssel,
            spi_sck_o => spi_sck,
            spi_mosi_o => spi_mosi,
            spi_miso_i => spi_miso,             -- driven by the spi slave 
            di_req_o => spi_di_req_m,
            di_i => spi_di_reg_m,
            wren_i => spi_wren_reg_m,
            wr_ack_o => spi_wr_ack_m,
            do_valid_o => spi_do_valid_m,
            do_o => spi_do_m,
            ------------ debug pins ------------
            state_dbg_o => spi_state_m          -- debug: internal state register
        );

    -- spi slave port: data and control signals driven by the slave fsm
    Inst_spi_slave_port: entity work.spi_slave(rtl) 
        generic map (N => N, CPOL => CPOL, CPHA => CPHA, PREFETCH => PREFETCH)
        port map( 
            clk_i => pclk_i,
            spi_ssel_i => spi_ssel,             -- driven by the spi master
            spi_sck_i => spi_sck,               -- driven by the spi master
            spi_mosi_i => spi_mosi,             -- driven by the spi master
            spi_miso_o => spi_miso,
            di_req_o => spi_di_req_s,
            di_i => spi_di_reg_s,
            wren_i => spi_wren_reg_s,
            wr_ack_o => spi_wr_ack_s,
            do_valid_o => spi_do_valid_s,
            do_o => spi_do_s,
            ------------ debug pins ------------
            state_dbg_o => spi_state_s          -- debug: internal state register
        );                      

    -- debounce for the input switches, with new data strobe output
    Inst_sw_debouncer: entity work.grp_debouncer(rtl)
        generic map (N => 8, CNT_VAL => DEBOUNCE_TIME / CLK_PERIOD) -- debounce 8 inputs with selected settling time
        port map(  
            clk_i => pclk_i,                    -- system clock
            data_i => sw_i,                     -- noisy input data
            data_o => sw_data                   -- registered stable output data
        );

    -- debounce for the input pushbuttons, with new data strobe output
    Inst_btn_debouncer: entity work.grp_debouncer(rtl)
        generic map (N => 6, CNT_VAL => DEBOUNCE_TIME / CLK_PERIOD) -- debounce 6 inputs with selected settling time
        port map(  
            clk_i => pclk_i,                    -- system clock
            data_i => btn_i,                    -- noisy input data
            data_o => btn_data                  -- registered stable output data
        );

    --=============================================================================================
    --  CONSTANTS CONSTRAINTS CHECKING
    --=============================================================================================
    -- clock dividers shall not be zero
    assert FSM_CE_DIV > 0
    report "Constant 'FSM_CE_DIV' should not be zero"
    severity FAILURE;
    -- minimum prefetch lookahead check
    assert SPI_2X_CLK_DIV > 0
    report "Constant 'SPI_2X_CLK_DIV' should not be zero"
    severity FAILURE;
    -- maximum prefetch lookahead check
    assert SAMP_CE_DIV > 0
    report "Constant 'SAMP_CE_DIV' should not be zero"
    severity FAILURE;

    --=============================================================================================
    --  CLOCK GENERATION
    --=============================================================================================
    -- All registers are clocked directly from the 100MHz system clock.
    -- The clock generation block derives 2 clock enable signals, divided down from the 100MHz input 
    -- clock. 
    --      input sample clock enable, 
    --      fsm clock enable,
    -----------------------------------------------------------------------------------------------
    -- generate the sampling clock enable from the 100MHz board input clock 
    samp_ce_gen_proc: process (pclk_i) is
        variable clk_cnt : integer range SAMP_CE_DIV-1 downto 0 := 0;
    begin
        if pclk_i'event and pclk_i = '1' then
            if clk_cnt = SAMP_CE_DIV-1 then
                samp_ce <= '1';                 -- generate a single pulse every SAMP_CE_DIV clocks
                clk_cnt := 0;
            else
                samp_ce <= '0';
                clk_cnt := clk_cnt + 1;
            end if;
        end if;
    end process samp_ce_gen_proc;
    -- generate the fsm clock enable from the 100MHz board input clock 
    fsm_ce_gen_proc: process (pclk_i) is
        variable clk_cnt : integer range FSM_CE_DIV-1 downto 0 := 0;
    begin
        if pclk_i'event and pclk_i = '1' then
            if clk_cnt = FSM_CE_DIV-1 then
                fsm_ce <= '1';                  -- generate a single pulse every FSM_CE_DIV clocks
                clk_cnt := 0;
            else
                fsm_ce <= '0';
                clk_cnt := clk_cnt + 1;
            end if;
        end if;
    end process fsm_ce_gen_proc;

    --=============================================================================================
    -- INPUTS LOGIC
    --=============================================================================================
    -- registered inputs
    samp_inputs_proc: process (pclk_i) is
    begin
        if pclk_i'event and pclk_i = '1' then
            if samp_ce = '1' then
                clear <= btn_data(btUP);        -- clear is button UP
                leds_reg <= leds_next;          -- update LEDs with spi_slave received data
            end if;
        end if;
    end process samp_inputs_proc;

    --=============================================================================================
    --  REGISTER TRANSFER PROCESSES
    --=============================================================================================
    -- fsm state and data registers: synchronous to the system clock
    fsm_reg_proc : process (pclk_i) is
    begin
        -- FFD registers clocked on rising edge and cleared on sync 'clear'
        if pclk_i'event and pclk_i = '1' then
            if clear = '1' then                     -- sync reset
                m_wr_st_reg <= st_reset;            -- only provide local reset for the state registers
            else
                if fsm_ce = '1' then
                    m_wr_st_reg <= m_wr_st_next;    -- master write state register update
                end if;
            end if;
        end if;
        -- FFD registers clocked on rising edge and cleared on ssel = '1'
        if pclk_i'event and pclk_i = '1' then
            if spi_ssel = '1' then                  -- sync reset
                s_wr_st_reg <= st_reset;            -- only provide local reset for the state registers
                s_rd_st_reg <= st_reset;
            else
                if fsm_ce = '1' then
                    s_wr_st_reg <= s_wr_st_next;    -- slave write state register update
                    s_rd_st_reg <= s_rd_st_next;    -- slave read state register update
                end if;
            end if;
        end if;
        -- FFD registers clocked on rising edge, with no reset
        if pclk_i'event and pclk_i = '1' then
            if fsm_ce = '1' then
                --------- master write fsm signals -----------
                spi_wren_reg_m <= spi_wren_next_m;
                spi_di_reg_m <= spi_di_next_m;
                spi_rst_reg <= spi_rst_next;
                spi_ssel_reg <= spi_ssel;
                sw_reg <= sw_next;
                btn_reg <= btn_next;
                --------- slave write fsm signals -----------
                spi_wren_reg_s <= spi_wren_next_s;
                spi_di_reg_s <= spi_di_next_s;
                --------- slave read fsm signals -----------
                s_do_1_reg <= s_do_1_next;
                s_do_2_reg <= s_do_2_next;
                s_do_3_reg <= s_do_3_next;
            end if;
        end if;
    end process fsm_reg_proc;

    --=============================================================================================
    --  COMBINATORIAL NEXT-STATE LOGIC PROCESSES
    --=============================================================================================
    -- edge detector for new switch data
    new_switch_proc: new_switch <= '1' when sw_data /= sw_reg else '0';     -- '1' for change edge

    -- edge detector for new button data
    new_button_proc: new_button <= '1' when btn_data /= btn_reg else '0';   -- '1' for change edge

    -- master port write fsmd logic
    fsm_m_wr_combi_proc: process ( m_wr_st_reg, spi_wren_reg_m, spi_di_reg_m, spi_di_req_m, spi_wr_ack_m, 
                                spi_ssel_reg, spi_rst_reg, sw_data, sw_reg, new_switch, btn_data, btn_reg, 
                                new_button, clear) is
    begin
        spi_rst_next <= spi_rst_reg;
        spi_di_next_m <= spi_di_reg_m;
        spi_wren_next_m <= spi_wren_reg_m;
        sw_next <= sw_reg;
        btn_next <= btn_reg;
        m_wr_st_next <= m_wr_st_reg;
        case m_wr_st_reg is
            when st_reset =>
                spi_rst_next <= '1';                        -- place spi interface on reset
                spi_di_next_m <= (others => '0');           -- clear spi data port
                spi_wren_next_m <= '0';                     -- deassert write enable
                m_wr_st_next <= st_wait_spi_idle;
                
            when st_wait_spi_idle =>
                spi_wren_next_m <= '0';                     -- remove write strobe on next clock
                if spi_ssel_reg = '1' then
                    spi_rst_next <= '0';                    -- remove reset when interface is idle
                    m_wr_st_next <= st_wait_new_switch;
                end if;

            when st_wait_new_switch =>
                if new_switch = '1' then                    -- wait for new stable switch data
                    sw_next <= sw_data;                     -- load new switch data (end the mismatch condition)
                    m_wr_st_next <= st_send_spi_data_sw;
                elsif new_button = '1' then
                    btn_next <= btn_data;                   -- load new button data (end the mismatch condition)
                    if clear = '0' then
                        if btn_data(btDOWN) = '1' then
                            m_wr_st_next <= st_send_spi_data_sw;
                        elsif btn_data(btLEFT) = '1' then
                            m_wr_st_next <= st_send_spi_data_1;
                        elsif btn_data(btCENTER) = '1' then
                            m_wr_st_next <= st_send_spi_data_1;
                        elsif btn_data(btRIGHT) = '1' then
                            m_wr_st_next <= st_send_spi_data_1;
                        end if;
                    end if;
                end if;
            
            when st_send_spi_data_sw =>
                spi_di_next_m <= sw_reg;                    -- load switch register to the spi port
                spi_wren_next_m <= '1';                     -- write data on next clock
                m_wr_st_next <= st_wait_spi_ack_sw;

            when st_wait_spi_ack_sw =>                      -- the actual write happens on this state
                if spi_wr_ack_m = '1' then
                    spi_wren_next_m <= '0';                 -- remove write strobe on next clock
                    m_wr_st_next <= st_wait_spi_di_req_2;
                end if;
                
            when st_send_spi_data_1 =>
                spi_di_next_m <= X"A1";                     -- load switch register to the spi port
                spi_wren_next_m <= '1';                     -- write data on next clock
                m_wr_st_next <= st_wait_spi_ack_1;

            when st_wait_spi_ack_1 =>                       -- the actual write happens on this state
                if spi_wr_ack_m = '1' then
                    spi_wren_next_m <= '0';                 -- remove write strobe on next clock
                    m_wr_st_next <= st_wait_spi_di_req_2;
                end if;
                
            when st_wait_spi_di_req_2 =>
                if spi_di_req_m = '1' then
                    spi_di_next_m <= X"A2";
                    spi_wren_next_m <= '1';
                    m_wr_st_next <= st_wait_spi_ack_2;
                end if;
        
            when st_wait_spi_ack_2 =>                       -- the actual write happens on this state
                if spi_wr_ack_m = '1' then
                    spi_wren_next_m <= '0';                 -- remove write strobe on next clock
                    m_wr_st_next <= st_wait_spi_di_req_3;
                end if;
                
            when st_wait_spi_di_req_3 =>
                if spi_di_req_m = '1' then
                    spi_di_next_m <= X"A3";
                    spi_wren_next_m <= '1';
                    m_wr_st_next <= st_wait_spi_ack_3;
                end if;

            when st_wait_spi_ack_3 =>                       -- the actual write happens on this state
                if spi_wr_ack_m = '1' then
                    spi_wren_next_m <= '0';                 -- remove write strobe on next clock
                    m_wr_st_next <= st_wait_spi_idle;       -- wait transmission end
                end if;
                
            when others =>
                m_wr_st_next <= st_reset;                   -- state st_reset is safe state
                
        end case; 
    end process fsm_m_wr_combi_proc;

    -- slave port write fsmd logic
    fsm_s_wr_combi_proc: process (  s_wr_st_reg, spi_di_req_s, spi_wr_ack_s, spi_do_valid_s,
                                    spi_di_reg_s, spi_wren_reg_s, spi_ssel_reg) is
    begin
        spi_wren_next_s <= spi_wren_reg_s;
        spi_di_next_s <= spi_di_reg_s;
        s_wr_st_next <= s_wr_st_reg;
        case s_wr_st_reg is
            when st_reset =>
                spi_di_next_s <= X"51";                     -- write first data word
                spi_wren_next_s <= '1';                     -- set write enable
                s_wr_st_next <= st_wait_spi_start;
                
            when st_wait_spi_start =>
                if spi_ssel_reg = '0' then                  -- wait for slave select
                    spi_wren_next_s <= '0';                 -- remove write enable
                    s_wr_st_next <= st_wait_spi_di_req_2;
                end if;

            when st_wait_spi_di_req_2 =>
                if spi_di_req_s = '1' then
--                    spi_di_next_s <= X"D2";               -- do not write on this cycle (cycle miss)
--                    spi_wren_next_s <= '1';
--                    s_wr_st_next <= st_wait_spi_ack_2;
                    s_wr_st_next <= st_wait_spi_do_valid_1;
                end if;
        
            when st_wait_spi_ack_2 =>                       -- the actual write happens on this state
                if spi_wr_ack_s = '1' then
                    spi_wren_next_s <= '0';                 -- remove write strobe on next clock
                    s_wr_st_next <= st_wait_spi_di_req_3;
                end if;
                
            when st_wait_spi_do_valid_1 =>
                if spi_do_valid_s = '1' then
                    s_wr_st_next <= st_wait_spi_di_req_3;
                end if;

            when st_wait_spi_di_req_3 =>
                if spi_di_req_s = '1' then
                    spi_di_next_s <= X"D3";
                    spi_wren_next_s <= '1';
                    s_wr_st_next <= st_wait_spi_ack_3;
                end if;

            when st_wait_spi_ack_3 =>                       -- the actual write happens on this state
                if spi_wr_ack_s = '1' then
                    spi_wren_next_s <= '0';                 -- remove write strobe on next clock
                    s_wr_st_next <= st_wait_spi_end;        -- wait transmission end
                end if;
            
            when st_wait_spi_end =>                         -- wait interface to be deselected
                if spi_ssel_reg = '1' then
                    s_wr_st_next <= st_reset;               -- wait transmission start
                end if;
            
            when others =>
                s_wr_st_next <= st_reset;                   -- state st_reset is safe state
                
        end case; 
    end process fsm_s_wr_combi_proc;

    -- slave port read fsmd logic
    fsm_s_rd_combi_proc: process ( s_rd_st_reg, spi_do_valid_s, spi_do_s, s_do_1_reg, s_do_2_reg, s_do_3_reg) is
    begin
        s_do_1_next <= s_do_1_reg;
        s_do_2_next <= s_do_2_reg;
        s_do_3_next <= s_do_3_reg;
        s_rd_st_next <= s_rd_st_reg;
        case s_rd_st_reg is
            when st_reset =>
                s_rd_st_next <= st_wait_spi_do_valid_1;
                
            when st_wait_spi_do_valid_1 =>
                if spi_do_valid_s = '1' then                -- wait for receive data ready
                    s_do_1_next <= spi_do_s;                -- read data from output port
                    s_rd_st_next <= st_wait_spi_n_do_valid_1;
                end if;

            when st_wait_spi_n_do_valid_1 =>
                if spi_do_valid_s = '0' then
                    s_rd_st_next <= st_wait_spi_do_valid_2;
                end if;
        
            when st_wait_spi_do_valid_2 =>
                if spi_do_valid_s = '1' then                -- wait for receive data ready
                    s_do_2_next <= spi_do_s;                -- read data from output port
                    s_rd_st_next <= st_wait_spi_n_do_valid_2;
                end if;

            when st_wait_spi_n_do_valid_2 =>
                if spi_do_valid_s = '0' then
                    s_rd_st_next <= st_wait_spi_do_valid_3;
                end if;
        
            when st_wait_spi_do_valid_3 =>
                if spi_do_valid_s = '1' then                -- wait for receive data ready
                    s_do_3_next <= spi_do_s;                -- read data from output port
                    s_rd_st_next <= st_wait_spi_n_do_valid_3;
                end if;
                
            when st_wait_spi_n_do_valid_3 =>
                if spi_do_valid_s = '0' then
                    s_rd_st_next <= st_reset;
                end if;

            when others =>
                s_rd_st_next <= st_reset;                   -- state st_reset is safe state
                
        end case; 
    end process fsm_s_rd_combi_proc;

    leds_combi_proc: process (btn_data, leds_reg, s_do_1_reg, s_do_2_reg, s_do_3_reg) is
    begin
        leds_next <= leds_reg;
        if btn_data(btRIGHT) = '1' then
            leds_next <= s_do_3_reg;
        elsif btn_data(btCENTER) = '1' then
            leds_next <= s_do_2_reg;
        elsif btn_data(btLEFT) = '1' then
            leds_next <= s_do_1_reg;
        elsif btn_data(btDOWN) = '1' then
            leds_next <= s_do_1_reg;
        end if;
    end process leds_combi_proc;

    --=============================================================================================
    --  OUTPUT LOGIC PROCESSES
    --=============================================================================================
    -- connect the spi output wires
    spi_ssel_o_proc:        spi_ssel_o      <= spi_ssel;
    spi_sck_o_proc:         spi_sck_o       <= spi_sck;
    spi_mosi_o_proc:        spi_mosi_o      <= spi_mosi;
    spi_miso_o_proc:        spi_miso_o      <= spi_miso;
    -- connect leds_reg signal to LED outputs
    led_o_proc:             led_o           <= leds_reg;

    --=============================================================================================
    --  DEBUG LOGIC PROCESSES
    --=============================================================================================
    -- connect the debug vector outputs
    dbg_o_proc:             dbg_o <= dbg;
    
    -- connect debug port pins to spi ports instances interface signals
    -- master signals mapped on dbg
    dbg(11) <= spi_wren_reg_m;
    dbg(10) <= spi_wr_ack_m;
    dbg(9)  <= spi_di_req_m;
    dbg(8)  <= spi_do_valid_m;
    -- slave signals mapped on dbg
    dbg(7)  <= spi_wren_reg_s;
    dbg(6)  <= spi_wr_ack_s;
    dbg(5)  <= spi_di_req_s;
    dbg(4)  <= spi_do_valid_s;
    dbg(3 downto 0) <= spi_state_s;
    -- specific ports to test on testbench
    s_do_o <= spi_do_s;
    m_do_o <= spi_do_m;
    m_state_o <= spi_state_m;  -- master spi fsm state
    s_state_o <= spi_state_s;  -- slave spi fsm state

end rtl;

