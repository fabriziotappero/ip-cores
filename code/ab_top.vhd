--
-- unit name: ab_top (Register map access)
--
-- author: 	Andrea Borga (andrea.borga@nikhef.nl)
--		
--
-- date: $26/08/2011    $: created
--
-- version: $Rev 0      $:
--
-- description:
--    NOTE: look through the code for this
--
--         -- #####################
--         -- #####################
--
--   to spot where the code needs customization
--
-- dependencies:	
--			gh_uart_16550
--                      ab_uart_lbus_slave
--                      ab_uart_16550_wrapper
--			ab_register_rx_handler
--			ab_register_tx_handler
--
-- references: <reference one>
-- <reference two> ...
--
-- modified by: $Author:: $:
--     
--        
--
-------------------------------------------------------------------------------
-- last changes: <date> <initials> <log>
-- <extended description>
-------------------------------------------------------------------------------
-- TODO:
--      
-- 
--
-------------------------------------------------------------------------------

--=============================================================================
-- Libraries
--=============================================================================

library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--=============================================================================
-- Entity declaration for ab_top
--=============================================================================

entity ab_top is
   port(
     clk_uart_29MHz_i   : in     std_logic;
     uart_rst_i         : in     std_logic;
     uart_leds_o        : out    std_logic_vector(7 downto 0);
     clk_uart_monitor_o : out    std_logic;
     -- #####################
     -- ADD your registers toward the rest of the logic here
     -- #####################
     uart_dout_o        : out    std_logic;
     uart_din_i         : in     std_logic);

end ab_top;


--=============================================================================
-- architecture declaration
--=============================================================================
  
architecture a0 of ab_top is
  
  component uart_16550_wrapper
    port(
    -- general purpose 
	sys_clk_i	        : in std_logic;		-- system clock 
        sys_rst_i               : in std_logic;  	-- system reset
	-- TX/RX process command line
	echo_en_i		: in std_logic;		-- Echo enable (byte by byte) enable/disable = 1/0
	tx_addr_wwo_i	        : in std_logic;		-- control of TX process With or WithOut address W/WO=(1/0)
	-- serial I/O side
        uart_din_i              : in std_logic; 	-- Serial data INPUT signal (from the FPGA)
	uart_dout_o             : out std_logic;  	-- Serial data OUTPUT signal (to the FPGA)
        -- parallel I/O side
	s_br_clk_uart_o         : out std_logic;  	-- br_clk clock probe signal
	-- RX part/control
	v_rx_add_o		: out std_logic_vector(15 downto 0);	-- 16 bits full addr ram input
	v_rx_data_o		: out std_logic_vector(31 downto 0);	-- 32 bits full data ram input
	s_rx_rdy_o		: out std_logic;	-- add/data ready to be write into RAM
	s_rx_stb_read_data_i	: in std_logic;	-- strobe signal from RAM ... 
	-- TX part/control
	s_tx_proc_rqst_i	: in std_logic;		-- stream TX process request 1/0 tx enable/disable
	v_tx_add_ram_i		: in std_logic_vector(15 downto 0);		-- 16 bits full addr ram output
	v_tx_data_ram_i		: in std_logic_vector(31 downto 0);		-- 32 bits full data ram output
	s_tx_ram_data_rdy_i	: in std_logic;		-- ram output data ready and stable
	s_tx_stb_ram_data_acq_o	: out std_logic	-- strobe ram data/address output acquired 1/0 acquired/not acquired
	);
  end component;
  
  --
  -- Internal signal declaration 
  --

  -- generic signals
  signal s_rst			: std_logic; -- main reset
  signal s_clk_uart		: std_logic; -- slow (29 MHz) clock
  
  -- uart control signals
  signal s_uart_br_clk   			: std_logic; -- unused clock monitor
  signal s_uart_rx_add          	: std_logic_vector (15 downto 0);
  signal s_uart_rx_data          	: std_logic_vector (31 downto 0);
  signal s_uart_rx_rdy            	: std_logic;
  signal s_uart_rx_stb_read_data	: std_logic;
  signal s_update               	: std_logic;
  signal s_uart_tx_add            	: std_logic_vector (15 downto 0);
  signal s_uart_tx_data            	: std_logic_vector (31 downto 0);
  signal s_uart_tx_data_rdy           	: std_logic;
  signal s_uart_tx_req           	: std_logic;
  signal s_uart_tx_stb_acq           	: std_logic;
  signal s_tx_complete           	: std_logic;
  

  -- address decoder signals

  signal r_config_addr_uart         : std_logic_vector (1 downto 0);
  signal r_open                  	: std_logic_vector (31 downto 0);  
  signal r_leds                    	: std_logic_vector (7 downto 0);
  signal r_test_reg01                 	: std_logic_vector (31 downto 0);
  signal r_test_reg02                  	: std_logic_vector (31 downto 0);
  signal r_test_reg03                  	: std_logic_vector (31 downto 0);
  signal r_test_reg04                  	: std_logic_vector (31 downto 0);
  signal r_test_reg05                  	: std_logic_vector (31 downto 0);
  -- #####################
  -- declare your registers here
  -- #####################
  
  --
  -- State Machine states 
  --
  
  type t_tx_reg_map is (IDLE, WAIT_A_BYTE, LATCH, TRANSMIT);
  signal s_tx_fsm         : t_tx_reg_map;
  
begin

  s_rst <= not uart_rst_i;

  uart_leds_o <= r_leds;                -- Let there be light ...
  
  -- UART simple register map
  register_map : process (s_rst, s_clk_uart)
    begin
      if s_rst = '1' then -- reset all registers here  
        s_uart_rx_stb_read_data        <=  '0';
        s_update                       <= '0';
        r_leds                         <= (others => '0');
        r_config_addr_uart             <= "10";
        r_test_reg01                   <= (others => '0');
        r_test_reg02                   <= (others => '0');
        r_test_reg03                   <= (others => '0');
        r_test_reg04                   <= (others => '0');
        r_test_reg05                   <= (others => '0');
        -- #####################
        -- reset your registers here
        -- #####################
      elsif rising_edge(s_clk_uart) then
        if s_uart_rx_rdy = '1' then
          case (s_uart_rx_add) is
            when X"0020" =>  r_leds            <=  s_uart_rx_data(7 downto 0);
            -- #####################
            -- declare more registers here to WRITE
            -- #####################
            when X"0030" =>  r_test_reg03      <=  s_uart_rx_data;
            when X"0031" =>  r_test_reg04      <=  s_uart_rx_data;
            when X"0032" =>  r_test_reg05      <=  s_uart_rx_data;
            when X"0040" =>  r_test_reg01      <=  s_uart_rx_data;
            when X"0050" =>  r_test_reg02      <=  s_uart_rx_data;
            when X"8000" =>  s_update         <=  '1';  -- register update self clearing
            when others =>  r_open            <= s_uart_rx_data;  
          end case;
          s_uart_rx_stb_read_data <= '1';
        else
          s_uart_rx_stb_read_data <= '0';
          s_update <= '0';
        end if;
      end if;
    end process;

  register_update : process (s_rst, s_clk_uart)
    variable v_uart_tx_add  : unsigned (15 downto 0);
    variable v_count        : unsigned (15 downto 0);
  begin  
      if s_rst = '1' then -- reset all registers here  
        s_uart_tx_data_rdy   <= '0';
        s_uart_tx_req        <= '0';
        v_uart_tx_add        := (others => '0');
        v_count              := (others => '0');
        s_uart_tx_data       <= (others => '0');
        s_uart_tx_add        <= (others => '0');
        -- #####################
        -- reset your registers here
        -- #####################
        s_tx_fsm             <= IDLE;
      elsif rising_edge(s_clk_uart) then
        case s_tx_fsm is
          when IDLE =>
            if s_update = '1' then
              s_tx_fsm <= WAIT_A_BYTE;
            else
              s_tx_fsm <= IDLE;
              s_uart_tx_data_rdy   <= '0';
              s_uart_tx_req        <= '0';
              v_uart_tx_add        := (others => '0');
              v_count              := (others => '0');
              s_uart_tx_data       <= (others => '0');
              s_uart_tx_add        <= (others => '0');
            end if;
          when WAIT_A_BYTE =>
            s_uart_tx_data_rdy   <= '0';
            v_count := v_count + 1;
            if v_count = X"0900" then
              v_uart_tx_add := v_uart_tx_add + 1;
              s_tx_fsm <= LATCH;
            else
              s_tx_fsm <= WAIT_A_BYTE;               
            end if;
          when LATCH =>
            if s_uart_tx_stb_acq = '0' then
              s_uart_tx_req <= '1';
              s_uart_tx_add <= std_logic_vector (v_uart_tx_add);
              case v_uart_tx_add is
                when X"0001" => s_uart_tx_data               <= (others => '0'); -- reserved synch register
                                s_tx_fsm <= TRANSMIT;
                -- #####################
                -- declare more registers here to READ
                -- #####################
                when X"0010" => s_uart_tx_data               <= (others => '0'); 
                                s_tx_fsm <= TRANSMIT;
                when X"0011" => s_uart_tx_data               <= (others => '0'); 
                                s_tx_fsm <= TRANSMIT;
                when X"0020" => s_uart_tx_data (7 downto 0)  <= r_leds;
                                s_tx_fsm <= TRANSMIT;
                when X"0030" => s_uart_tx_data               <= r_test_reg03;
                                s_tx_fsm <= TRANSMIT;
                when X"0031" => s_uart_tx_data               <= r_test_reg04;
                                s_tx_fsm <= TRANSMIT;
                when X"0032" => s_uart_tx_data               <= r_test_reg05;
                                s_tx_fsm <= TRANSMIT;                
                when X"0040" => s_uart_tx_data               <= r_test_reg01;
                                s_tx_fsm <= TRANSMIT;
                when X"0050" => s_uart_tx_data               <= r_test_reg02;
                                s_tx_fsm <= TRANSMIT;
                -- End Of Transmission register = last register + 1
                when X"0051" => s_tx_fsm <= IDLE;  -- end of transmission
                when others => s_uart_tx_data <=  (others => '0');
                               v_uart_tx_add := v_uart_tx_add + 1;
                               s_uart_tx_data_rdy   <= '0';
                               s_tx_fsm <= LATCH;
              end case;
            else
              v_count  := (others => '0');
              s_tx_fsm <=  WAIT_A_BYTE;
            end if;
          when TRANSMIT =>
            s_uart_tx_data_rdy   <= '1';
            v_count              := (others => '0');
            s_tx_fsm <= WAIT_A_BYTE;
          when others =>
            s_tx_fsm <= IDLE;
        end case;
      end if;
    end process;
 

  s_clk_uart <= clk_uart_29MHz_i;              -- UART system clock 29.4912 MHz
  clk_uart_monitor_o <= s_uart_br_clk;
    
  uart_wrapper : uart_16550_wrapper 
    port map(
      sys_clk_i		      => s_clk_uart,
      sys_rst_i               => s_rst,
      echo_en_i		      => r_config_addr_uart(0), 
      tx_addr_wwo_i	      => r_config_addr_uart(1), 
      uart_din_i              => uart_din_i,
      uart_dout_o             => uart_dout_o, 
      s_br_clk_uart_o         => s_uart_br_clk,
      v_rx_add_o	      => s_uart_rx_add,          
      v_rx_data_o	      => s_uart_rx_data,               
      s_rx_rdy_o	      => s_uart_rx_rdy,                 
      s_rx_stb_read_data_i    => s_uart_rx_stb_read_data,
      s_tx_proc_rqst_i	      => s_uart_tx_req,         
      v_tx_add_ram_i	      => s_uart_tx_add,           
      v_tx_data_ram_i	      => s_uart_tx_data,          
      s_tx_ram_data_rdy_i     => s_uart_tx_data_rdy,      
      s_tx_stb_ram_data_acq_o => s_uart_tx_stb_acq  
      );	
    
end architecture a0 ; -- of UART_control

