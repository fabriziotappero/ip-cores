-- TestBench Template 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end testbench;

architecture behavior of testbench is 

    --=============================================================================================
    -- Constants
    --=============================================================================================
    -- clock period
    constant SCLK_PERIOD : time := 11 ns;           -- serial high speed clock
    constant PCLK_PERIOD : time := 10 ns;           -- parallel high-speed clock

    -- button definitions
    constant btRESET    : integer := 0;             -- these are constants to use as btn_i(x)
    constant btUP       : integer := 1;
    constant btLEFT     : integer := 2;
    constant btDOWN     : integer := 3;
    constant btRIGHT    : integer := 4;
    constant btCENTER   : integer := 5;

    --=============================================================================================
    -- COMPONENT DECLARATIONS
    --=============================================================================================
    component spi_master_atlys_top
    port(
        sclk_i : in std_logic;
        pclk_i : in std_logic;
        sw_i : in std_logic_vector(7 downto 0);
        btn_i : in std_logic_vector(5 downto 0);          
        spi_ssel_o : out std_logic;
        spi_sck_o : out std_logic;
        spi_mosi_o : out std_logic;
        spi_miso_o : out std_logic;
        led_o : out std_logic_vector(7 downto 0);
        s_do_o : out std_logic_vector (7 downto 0);
        m_do_o : out std_logic_vector (7 downto 0);
        m_state_o : out std_logic_vector (3 downto 0);
        s_state_o : out std_logic_vector (3 downto 0);
        dbg_o : out std_logic_vector(11 downto 0)
    );
    end component;

    --=============================================================================================
    -- Signals for state machine control
    --=============================================================================================

    --=============================================================================================
    -- Signals for internal operation
    --=============================================================================================
    --- clock signals ---
    signal sysclk           : std_logic := '0';                                 -- 100MHz clock
    signal pclk             : std_logic := '0';                                 -- 100MHz clock
    --- switch debouncer signals ---
    signal sw_data          : std_logic_vector (7 downto 0) := (others => '0'); -- switch data
    --- pushbutton debouncer signals ---
    signal btn_data         : std_logic_vector (5 downto 0) := (others => '0'); -- pushbuttons
    --- spi port signals ---
    signal spi_ssel         : std_logic;
    signal spi_sck          : std_logic;
    signal spi_mosi         : std_logic;
    signal spi_miso         : std_logic;
    -- debug output signals
    signal leds             : std_logic_vector (7 downto 0) := (others => '0');
    signal dbg              : std_logic_vector (11 downto 0) := (others => '0');
    -- debug ports --
    signal s_do_reg       : std_logic_vector (7 downto 0);
    signal m_do_reg       : std_logic_vector (7 downto 0);
    -- master signals mapped on dbg
    signal wren_m           : std_logic;
    signal wr_ack_m         : std_logic;
    signal di_req_m         : std_logic;
    signal do_valid_m       : std_logic;
    signal master_state     : std_logic_vector (3 downto 0);
    -- slave signals mapped on dbg
    signal wren_s           : std_logic;
    signal wr_ack_s         : std_logic;
    signal di_req_s         : std_logic;
    signal do_valid_s       : std_logic;
    signal slave_state      : std_logic_vector (3 downto 0);
begin

    --=============================================================================================
    -- COMPONENT INSTANTIATIONS FOR THE CORES UNDER TEST
    --=============================================================================================
    -- spi_master_atlys_top:
    --      receives the 100 MHz clock from the board clock oscillator
    --      receives the 8 slide switches and 5 pushbuttons as test stimuli
    --      connects to 4 spi signals
    --      connects to 8 board LEDs
    --      connects to 12 debug pins
    --      set debounce time to 2 us to save simulation time
	Inst_spi_master_atlys_top: spi_master_atlys_top
        port map(
            sclk_i => sysclk,
            pclk_i => pclk,
            spi_ssel_o => spi_ssel,
            spi_sck_o => spi_sck,
            spi_mosi_o => spi_mosi,
            spi_miso_o => spi_miso,
            sw_i => sw_data,
            btn_i => btn_data,
            led_o => leds,
            m_do_o => m_do_reg,
            s_do_o => s_do_reg,
            m_state_o => master_state,
            s_state_o => slave_state,
            dbg_o => dbg
        );

    -- master signals mapped on dbg
    wren_m      <= dbg(11);
    wr_ack_m    <= dbg(10);
    di_req_m    <= dbg(9);
    do_valid_m  <= dbg(8);
    
    -- slave signals mapped on dbg
    wren_s      <= dbg(7);
    wr_ack_s    <= dbg(6);
    di_req_s    <= dbg(5);
    do_valid_s  <= dbg(4);
    

    --=============================================================================================
    -- CLOCK GENERATION
    --=============================================================================================
    sysclk_proc: process is
    begin
        loop
            sysclk <= not sysclk;
            wait for SCLK_PERIOD / 2;
        end loop;
    end process sysclk_proc;

    pclk_proc: process is
    begin
        loop
            pclk <= not pclk;
            wait for PCLK_PERIOD / 2;
        end loop;
    end process pclk_proc;

    --=============================================================================================
    -- TEST BENCH STIMULI
    --=============================================================================================
    tb : process
    begin
        wait for 100 ns; -- wait until global set/reset completes

        btn_data(btUP) <= '1';
        wait for 1 us;
        btn_data(btUP) <= '0';
        sw_data <= X"81";
        wait for 5 us;
        sw_data <= X"65";
        wait for 5 us;
        sw_data <= X"C9";
        wait for 5 us;
        sw_data <= X"55";
        wait for 5 us;
        sw_data <= X"AA";
        wait for 5 us;
        sw_data <= X"1e";
        wait for 5 us;
        sw_data <= X"79";
        wait for 5 us;
        sw_data <= X"40";
        wait for 5 us;
        assert false report "End Simulation" severity failure; -- stop simulation
    end process tb;
    --  End Test Bench 
END;
