-------------------------------------------------------------------------------
--                                                                           --
--                                                                           --
--                                                                           --
--                                                                           --
-------------------------------------------------------------------------------
--
-- unit name: uart_lbus (UART Control)
--
-- author: 	Andrea Borga (andrea.borga@nikhef.nl)
--		Mauro Predonzani (predmauro@libero.it)
--
-- date: $26/01/2009    $: created
--
-- version: $Rev 0      $:
--
-- description: <file content, behaviour, purpose, special usage notes...>
-- <further description>
--
-- dependencies:	uart_wrapper
--								gh_uart_16550
--								register_rx_handler
--								register_tx_handler
--
-- references: <reference one>
-- <reference two> ...
--
-- modified by: $Author:: $:
--     18/08/2011   Andrea Borga
--        modified UART_WRITE to improve stability
--
-------------------------------------------------------------------------------
-- last changes: <date> <initials> <log>
-- <extended description>
-------------------------------------------------------------------------------
-- TODO:
--      check the address range (range violation prevention)
-- 
--
-------------------------------------------------------------------------------

--=============================================================================
-- Libraries
--=============================================================================

library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--=============================================================================
-- Entity declaration for ada_uart_lbus
--=============================================================================

entity uart_lbus is
  generic (
    c_bus_width   : natural := 8
    );
  port (
    lbus_clk            : in    std_logic;  -- local bus clock
    lbus_rst            : in    std_logic;  -- local bus reset
    lbus_rst_buffer     : out   std_logic;  -- soft reset for UART fifos
    lbus_txrdy_n        : in    std_logic;  -- Tx data ready
    lbus_rxrdy_n        : in    std_logic;  -- Rx data ready
    lbus_cs             : out   std_logic;  -- Chip Select
    lbus_wr             : out   std_logic;  -- Write/Read (1/0)
    lbus_init           : out   std_logic;  -- Initialization process flag
    lbus_add            : out   std_logic_vector(2 downto 0);  -- local bus address
    lbus_data           : out   std_logic_vector(c_bus_width-1 downto 0);  -- local bus data
    s_tx_proc_rqst_i	: in		std_logic;	-- tx process request from RAM
    v_lbus_state   	: out		std_logic_vector(2 downto 0);	-- flag indicator of lbus_state
    s_cs_rd_c		: out		std_logic;	-- CS signal from caused by read cycle
    s_wr_rd_c		: out		std_logic;	-- WR signal from caused by read cycle
    s_new_byte_rdy	: in 		std_logic;	-- new byte(8bit) is ready and stable to be transmitted
    s_data_tx		: in		std_logic;	-- trasmitting byte of RAM address/data
    reghnd_rd_rdy	: in 		std_logic;	-- 6 byte ready RX but not yet written in RAM (1/0=>data ready/not ready)
    echo_en_i		: in		std_logic		-- echo enable command enable/disable = 1/0

		);    
  end uart_lbus;


--=============================================================================
-- architecture declaration
--=============================================================================

architecture slave of uart_lbus is

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Components declaration 
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--  component gh_edge_det is
--    port(	
--      clk : in std_logic;
--      rst : in std_logic;
--      d   : in std_logic;
--      re  : out std_logic; -- rising edge (need sync source at d)
--      fe  : out std_logic; -- falling edge (need sync source at d)
--      sre : out std_logic; -- sync'd rising edge
--      sfe : out std_logic  -- sync'd falling edge
--      );
--  end component;

  --
  -- Internal signal declaration 
  --
                             
  signal v_data_gen     : std_logic_vector(7 downto 0);  -- test data generator
  signal s_data_toggle  : std_logic;    -- toggles between two data patterns AA and 55
  signal v_data_num     : std_logic_vector(19 downto 0);    -- number of data to send  
  
  signal s_wr_rd        : std_logic;    -- wr for READ state process
  signal v_add_rd       : std_logic_vector(2 downto 0);
  
  signal s_tx_term      : std_logic;    -- transmission teminating strobe
  signal s_tx_send_data : std_logic;    -- data to send strobe
  signal s_cs_wr        : std_logic;    -- cs for WRITE state process
  signal s_wr_wr        : std_logic;    -- wr for WRITE state process
  signal v_add_wr       : std_logic_vector(2 downto 0);
  
  signal v_add          : std_logic_vector(2 downto 0);
  signal v_data         : std_logic_vector(c_bus_width-1 downto 0);

  signal s_init_done    : std_logic;    -- initialization done flag
  signal s_write_msb    : std_logic;
  signal s_tick_delay   : std_logic;    -- delays termination by 1 cycle (needed for lbus init)
  signal v_tick_delay_1 : std_logic_vector(1 downto 0);    -- delays termination by 1 cycle (needed for RW_lbus) 
  signal s_cs_init      : std_logic;    -- cs for INIT state process
  signal s_wr_init      : std_logic;    -- wr for INIT state process
  signal v_add_init     : std_logic_vector(2 downto 0);
  signal v_data_init    : std_logic_vector(c_bus_width-1 downto 0);
  signal v_fcr_init     : std_logic_vector(7 downto 0);  -- local FIFO Control Register O"2"
  signal v_lcr_init     : std_logic_vector(7 downto 0);  -- local Line Control Register O"3"
  signal v_lsr_init     : std_logic_vector(7 downto 0);  -- local Line Status Register  O"5"
	signal s_cs_rd        : std_logic;
  --
  -- State Machine states 
  --
  
  type t_uart_state is (IDLE, INIT, UART_READ, UART_WRITE);
  signal s_slave_state         : t_uart_state;

  type t_uart_init is (IDLE, WRITE_FCR, WRITE_LCR, WRITE_DIVLTC, ENB_FIFO, ENB_UART);
  signal s_slave_init         : t_uart_init;

--=============================================================================
-- architecture begin
--=============================================================================
  
	
	signal lbus_clk_n       : std_logic;
	
	
begin

  --
  -- Internal signals
  -- 

  lbus_clk_n            <=  not lbus_clk;	
  s_cs_rd_c 						<= s_cs_rd;
  s_wr_rd_c 						<= s_wr_rd;
  lbus_add              <= v_add_init or v_add_wr or v_add_rd;
  lbus_data             <= v_data_init;  			-- or v_data_wr;
  lbus_init             <= not s_init_done;     		-- init signal
  
  lbus_cs               <= s_cs_init or s_cs_wr or s_cs_rd;	--	CS uart signal
  lbus_wr               <= s_wr_init or s_wr_wr or s_wr_rd;	--	R/W control UART signal


		

  --**************************************************************************
  -- UART local bus slave
  -- (state transitions)
  --**************************************************************************
  -- read: lbus_clk
  -- write:
  -- r/w: s_slave_state
	
  p_uart_state: process (lbus_clk_n)   
  begin
    if Rising_edge(lbus_clk_n) then
      if lbus_rst = '1' then                    -- Sync RESET 
        s_slave_state   <= IDLE;
        s_cs_wr         <= '0';
        s_wr_wr         <= '0';
        s_cs_rd         <= '0';
        s_wr_rd         <= '0';
        v_add_wr        <= (others => '0');
        v_add_rd        <= (others => '0');
        v_tick_delay_1  <= "00";
        v_lbus_state		<= "000";
        lbus_rst_buffer <= '1';         -- rest UART FIFO 
      else
        case s_slave_state is
          when IDLE  =>                         -- uart IDLE
            s_cs_rd				<= '0';
            s_wr_rd				<= '0';
            s_cs_wr           <= '0';
            s_wr_wr           <= '0';
            v_tick_delay_1  <= "00";
            if s_init_done = '0' then
              s_slave_state <= INIT;
              v_lbus_state		<= "001";
            else
              lbus_rst_buffer <= '0';   -- release UART FIFO after init
              if s_tx_proc_rqst_i = '1' and lbus_txrdy_n = '0' then -- and reghnd_rd_rdy = '0' then
                v_lbus_state		<= "100";
                s_slave_state <= UART_WRITE;
              elsif s_tx_proc_rqst_i = '0' and lbus_rxrdy_n = '0' and lbus_txrdy_n = '0' and reghnd_rd_rdy = '0' then
                s_slave_state <= UART_READ;
                v_lbus_state		<= "010";
              else
                s_slave_state <= IDLE;
                v_lbus_state <= "000";
              end if;
            end if;
          when INIT =>                          -- uart INIT
            v_lbus_state		<= "001";
            if s_init_done = '0' then
              s_slave_state <= INIT;
            else
              s_slave_state <= IDLE;
            end if;
          when UART_READ =>                     -- uart READ
            v_lbus_state		<= "010";
            s_cs_wr         <= '0';
            s_wr_wr         <= '0';
            if lbus_rxrdy_n = '0'  then 
              if v_tick_delay_1 = "00" then  
                if echo_en_i = '1' then							-- ECHO is enable
                  v_tick_delay_1    <= "01";
                elsif echo_en_i = '0' then					-- ECHO is disable
                  v_tick_delay_1    <= "11";
                end if;
                s_cs_rd           <= '1';
                s_wr_rd           <= '0';
                s_slave_state <= UART_READ;
              elsif v_tick_delay_1 = "01" then			-- will be executed in a READ cycle only if ECHO is enable
                v_tick_delay_1    <= "10";
                v_add_rd          <= O"0";
                s_cs_rd           <= '0';
                s_wr_rd           <= '1';
                s_slave_state <= UART_READ;
              elsif v_tick_delay_1 = "10" then			-- will be executed in a READ cycle only if ECHO is enable
                v_tick_delay_1    <= "11";
                v_add_rd          <= O"0";
                s_cs_rd           <= '1';
                s_wr_rd           <= '1';
                s_slave_state <= UART_READ;
              elsif v_tick_delay_1 = "11" then			-- will be executed in every READ cycle
                v_tick_delay_1    <= "00";
                v_add_rd          <= O"0";
                s_cs_rd           <= '0';
                s_wr_rd           <= '0';
                s_slave_state <= IDLE;
              end if;
            else
              s_cs_rd           <= '0';
              s_wr_rd           <= '0';
              s_slave_state <= IDLE;
            end if;
          when UART_WRITE =>                     -- uart WRITE
            v_lbus_state		<= "100";
            if v_tick_delay_1 = "00" then  
              if s_new_byte_rdy = '1' then	
                v_tick_delay_1    <= "01";
                s_cs_wr           <= '0';
                s_wr_wr           <= '1';
              else 
                v_tick_delay_1    <= "00";
                if s_tx_proc_rqst_i = '0' and s_data_tx = '0' then
                  s_slave_state <= IDLE;
                else
                  s_slave_state <= UART_WRITE;
                end if;
              end if;
            elsif v_tick_delay_1 ="01" then
              v_tick_delay_1     <= "11";
              s_cs_wr           <= '1';
              s_wr_wr           <= '1';
              v_add_wr          <= O"0";
              s_slave_state <= UART_WRITE;
            elsif v_tick_delay_1 ="11" then
              if s_new_byte_rdy = '1' then
                v_tick_delay_1    <= "11";
                s_cs_wr           <= '0';
                s_wr_wr           <= '1';
                v_add_wr          <= O"0";
                s_slave_state <= UART_WRITE;
              else
                v_tick_delay_1    <= "00";
                s_cs_wr           <= '0';
                s_wr_wr           <= '1';
                v_add_wr          <= O"0";
                s_slave_state <= UART_WRITE;
              end if;
            else
              s_cs_rd           <= '0';
              s_wr_rd           <= '0';
              s_slave_state     <= IDLE;
            end if;
          when others =>                        -- uart OTHERS 
            s_slave_state <= IDLE;
        end case;
      end if;
    end if;
  end process p_uart_state;

  --**************************************************************************
  -- UART local bus slave
  -- (initialization)
  --**************************************************************************
  -- read: 
  -- write:
  -- r/w:

  p_init_lbus : process (lbus_clk, lbus_rst)  -- uart initialization process
  begin  -- process
    if lbus_rst = '1' then
      s_slave_init    <= IDLE;
      v_add_init      <= O"7";
      v_data_init     <= (others => '0');
      v_lcr_init      <= (others => '0');
      v_fcr_init      <= (others => '0');
      s_tick_delay    <= '0';
      s_write_msb     <= '0';
      s_cs_init       <= '0';
      s_wr_init       <= '0';
      s_init_done     <= '0';
    elsif Rising_edge(lbus_clk) then
      case s_slave_init is
        when IDLE =>                    -- init IDLE
           if s_init_done = '0' and s_write_msb = '0' then
             s_cs_init          <= '1';
             s_wr_init          <= '1';
             s_slave_init       <= WRITE_FCR;
           else
             s_slave_init       <= IDLE; 
           end if;
        when WRITE_FCR =>               --  init WRITE_FCR
          v_add_init            <= O"2";
          v_fcr_init            <= "00000000";  -- DMA mode 0 init FIFO Control Register
          v_data_init           <= "00000000";  -- DMA mode 0 write FIFO Control Register
--          v_fcr_init            <= "00001000";  -- DMA mode 1 init FIFO Control Register
--          v_data_init           <= "00001000";  -- DMA mode 1 write FIFO Control Register
          s_slave_init          <= WRITE_LCR;
        when WRITE_LCR =>               -- init WRITE_LCR
          v_add_init            <= O"3";
          v_lcr_init            <= "10000011";  -- init FIFO Control Register
          v_data_init           <= "10000011";  -- write FIFO Control Register
          s_slave_init          <= WRITE_DIVLTC;
        when WRITE_DIVLTC =>            -- init WRITE_DIVLTC
          if s_write_msb = '0' then
            v_add_init          <= O"0";         -- init Divisor Latch lsb
            v_data_init         <= "00000010";   -- DEC 2 Baudrate = 921600 bps @ 29,4912 MHz 
            s_write_msb         <= '1';
            s_slave_init        <= WRITE_DIVLTC;
          else
            v_add_init          <= O"1";         -- init Divisor Latch msb
            v_data_init         <= "00000000";  
            s_slave_init        <= ENB_FIFO;
          end if;
        when ENB_FIFO =>                -- init ENB_FIFO
          if s_tick_delay = '0' then
            s_tick_delay        <= '1';
            v_add_init          <= O"3";
            v_lcr_init          <= "00000011";         -- Enable FIFO access
            v_data_init         <= "00000011";
          else
            v_add_init          <= (others => '0');
            v_data_init         <= (others => '0');
            s_tick_delay        <= '0';
            s_slave_init        <= ENB_UART;
          end if;
        when ENB_UART =>                -- init ENB_UART
          if s_tick_delay = '0' then
            s_tick_delay        <= '1';
            s_init_done         <= '1';         -- terminate init
            s_cs_init           <= '0';
            s_wr_init           <= '0';
            v_data_init         <= "00000000";
          else
            s_tick_delay        <= '0';
            s_init_done         <= '1';
            s_slave_init          <= IDLE;
          end if;
        when others =>
          s_slave_init          <= IDLE; 
      end case;
    end if;
  end process;




  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Components mapping
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--  cmp_cs_rd_edge : gh_edge_det 
--    port map (
--      clk => lbus_clk,
--      rst => lbus_rst,
--      d   => s_cs_rd,
--      sre => s_cs_rd_edge);

--  cmp_wr_rd_edge : gh_edge_det 
--    port map (
--      clk => lbus_clk,
--      rst => lbus_rst,
--      d   => s_wr_rd,
--      sre => s_wr_rd_edge);
  
--  cmp_cs_wr_edge : gh_edge_det 
--    port map (
--      clk => lbus_clk,
--      rst => lbus_rst,
--      d   => s_cs_wr,
--      sre => s_cs_wr_edge);
--
--  cmp_wr_wr_edge : gh_edge_det 
--    port map (
--      clk => lbus_clk,
--      rst => lbus_rst,
--      d   => s_wr_wr,
--      sre => s_wr_wr_edge);
  
end slave;

--=============================================================================
-- architecture end
--=============================================================================


