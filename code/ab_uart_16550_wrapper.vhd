-------------------------------------------------------------------------------
--                                                                           --
--                                                                           --
--                                                                           --
--                                                                           --
-------------------------------------------------------------------------------
--
-- unit name: UART_16550_wrapper
--
-- author: 	Andrea Borga (andrea.borga@nikhef.it)
--	        Mauro Predonzani (predmauro@libero.it)
--
-- date: $26/01/2009    $: created
--
-- version: $Rev 0      $:
--
-- description: <file content, behaviour, purpose, special usage notes...>
-- <further description>
--
-- dependencies:	gh_uart_16550
--								register_rx_handler
--								register_tx_handler
--								uart_lbus_slave
--								
--								
--
-- references: <reference one>
-- <reference two> ...
--
-- modified by: $Author:: $:
--
-------------------------------------------------------------------------------
-- changes: 2010-05-06 Mauro Predonzani
--		       set ECHO MODE on/off 		    
--	    2010-06-09 Mauro Predonzani
--		       enable/disable TX address byte	    
--	    2011-08-18 Andrea Borga
--		       added soft FIFO reset release after init
--          2011-08-18 Andrea Borga
--                     renamed entity to a more generic UART_16550_wrapper
--                     (instead of Lantronix_wrapper)
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


--=============================================================================
-- Entity declaration for ada_uart_16550_wrapper
--=============================================================================

entity uart_16550_wrapper is
  port(
  -- general purpose
  sys_clk_i          : in std_logic;  -- system clock
  sys_rst_i          : in std_logic;  -- system reset
  -- TX/RX process command line
  echo_en_i          : in std_logic;  -- Echo enable (byte by byte) enable/disable = 1/0
  tx_addr_wwo_i	     : in std_logic;  -- control of TX process With or WithOut address W/WO=(1/0)
  -- serial I/O side
  uart_din_i              : in std_logic; 	-- Serial data INPUT signal (from the FPGA)
  uart_dout_o             : out std_logic;  	-- Serial data OUTPUT signal (to the FPGA)
  -- parallel I/O side
  s_br_clk_uart_o    : out std_logic;  		-- br_clk clock probe signal
  -- RX part/control
  v_rx_add_o	     : out std_logic_vector(15 downto 0);	-- 16 bits full addr ram input
  v_rx_data_o	     : out std_logic_vector(31 downto 0);	-- 32 bits full data ram input
  s_rx_rdy_o	     : out std_logic;			-- add/data ready to be write into RAM
  s_rx_stb_read_data_i	: in std_logic;			-- strobe signal from RAM ... 
  -- TX part/control
  s_tx_proc_rqst_i   : in std_logic;				-- stream TX process request 1/0 tx enable/disable
  v_tx_add_ram_i     : in std_logic_vector(15 downto 0);		-- 16 bits full addr ram output
  v_tx_data_ram_i	: in std_logic_vector(31 downto 0);		-- 32 bits full data ram output
  s_tx_ram_data_rdy_i	: in std_logic;				-- ram output data ready and stable
  s_tx_stb_ram_data_acq_o	: out std_logic		-- strobe ram data/address output acquired 1/0 acquired/not acquired
		);
end entity;

--=============================================================================
-- architecture declaration
--=============================================================================

architecture a of uart_16550_wrapper is

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Components declaration 
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  component gh_uart_16550 is
    port(
      clk     : in std_logic; -- UART clock (toward logic)
      BR_clk  : in std_logic; -- Baudrate generator clock TX and RX 
      rst     : in std_logic; -- Reset
      rst_buffer : in std_logic; -- Reset for FIFO and TX and RX
      CS      : in std_logic; -- Chip select -> 1 Cycle long CS strobe = 1 data transaction (w/r)
      WR      : in std_logic; -- WRITE when HIGH with CS high | READ when LOW with CS high 
      ADD     : in std_logic_vector(2 downto 0); -- ADDRESS BUS
      D       : in std_logic_vector(7 downto 0); -- Input DATA BUS and CONTROL BUS
      
      sRX     : in std_logic; -- uart's INPUT
      CTSn    : in std_logic := '1';
      DSRn    : in std_logic := '1';
      RIn     : in std_logic := '1';
      DCDn    : in std_logic := '1';
      
      sTX     : out std_logic; -- uart's OUTPUT
      DTRn    : out std_logic;
      RTSn    : out std_logic;
      OUT1n   : out std_logic;
      OUT2n   : out std_logic;
      TXRDYn  : out std_logic; -- Tx FIFO not Full      
      RXRDYn  : out std_logic; -- Rx FIFO Data Ready
      
      IRQ     : out std_logic;
      B_CLK   : out std_logic; -- 16x Baudrate clock output
      RD      : out std_logic_vector(7 downto 0) -- Output DATA BUS
      );
  end component;

  component uart_lbus is
  generic (
    c_bus_width   : natural := 8
    );
  port (
    lbus_clk            : in    std_logic;  -- local bus clock
    lbus_rst            : in    std_logic;  -- local bus reset
    lbus_rst_buffer     : out   std_logic; -- Reset for FIFO and TX and RX
    lbus_txrdy_n        : in    std_logic;  -- Tx data ready
    lbus_rxrdy_n        : in    std_logic;  -- Rx data ready
    lbus_cs             : out   std_logic;  -- Chip Select
    lbus_wr             : out   std_logic;  -- Write/Read (1/0)
    lbus_init           : out   std_logic;  -- Initialization process flag
    lbus_add            : out   std_logic_vector(2 downto 0);  -- local bus address
    lbus_data           : out   std_logic_vector(c_bus_width-1 downto 0);  -- local bus data  
    s_tx_proc_rqst_i	: in	std_logic;	-- tx process request from RAM
    v_lbus_state   	: out	std_logic_vector(2 downto 0);	-- flag indicator of lbus_state
    s_cs_rd_c 		: out 	std_logic;	-- CS signal from caused by read cycle
    s_wr_rd_c		: out	std_logic;	-- WR signal from caused by read cycle
    s_new_byte_rdy	: in	std_logic;	-- new byte(8bit)ready and stable to be transmitted
    s_data_tx		: in	std_logic;	-- 6 bytes will be trasmitted
    reghnd_rd_rdy	: in 	std_logic;	-- 6 byte RX ready but not yet written in RAM (1/0=>data ready/not ready)
    echo_en_i		: in	std_logic	-- echo enable command enable/disable = 1/0
		);
  end component;

  component register_rx_handler
    port(
      reghnd_clk 	: in std_logic;		-- system clock
      reghnd_rst 	: in std_logic;		-- system reset
      reghnd_data_in	: in std_logic_vector(7 downto 0);		-- 8 bits fragments 
      reghnd_data_cs_rd : in std_logic;   -- cs strobe of gh16550 during a read process
      reghnd_data_wr_rd	: in std_logic;   -- wr state of gh16550 during a read process
      reghnd_rd_rdy	: out std_logic;			-- Read data ready
      reghnd_full_add 	: out std_logic_vector(15 downto 0);		-- 16 bits RAM address 
      reghnd_full_data 	: out std_logic_vector(31 downto 0);  	-- 32 bits RAM data
      reghnd_full_cs 	: in std_logic		-- strobe data/address acquired (1 acquired - 0 not acquired)
      );
  end component;

  component register_tx_handler
  port(
    reghnd_clk          	: in std_logic;		-- system clock
    reghnd_rst          	: in std_logic;		-- system reset
    reghnd_addr_wwo_i		: in std_logic;		-- control of TX process With or WithOut address W/WO=(1/0)
    reghnd_full_data_ram_i 	: in std_logic_vector(31 downto 0);	-- 32 bits full data
    reghnd_full_add_ram_i	: in std_logic_vector(15 downto 0);	-- 16 bits full addr
    reghnd_stb_data_ram_rdy_i	: in std_logic;		-- strobe ram data ready
    reghnd_data_acq_gh16550_i	: in std_logic;		-- data acquired from gh16550
    reghnd_wr_enable_i		: in std_logic;		-- enable the tx process
    reghnd_txrdy_n_gh16550_i	: in std_logic;		-- gh16550 ready to trasmit
    reghnd_wr_enable_o		: out std_logic;	-- enable the tx process
    reghnd_output_rdy_o		: out std_logic;	-- Read data ready
    reghnd_pdata_o		: out std_logic_vector(7 downto 0);	-- 8 bits parallel
    reghnd_stb_acq_ram_o	: out std_logic		-- strobe data/address acquired (1 acquired - 0 not acquired)
    );
  end component;

  --
  -- Internal signal declaration 
  --

  signal s_rst                  : std_logic;   -- global reset
  signal s_rst_buffer           : std_logic;   -- soft reset for FIFO and TX and RX uart FSM
  signal s_clk                  : std_logic;   -- uart to parallel interface clock
  signal s_clk_n                : std_logic;   -- uart to parallel interface clock
  signal s_br_clk               : std_logic;   -- uart serializer clock
  signal s_open                 : std_logic_vector(32 downto 0) := (others => '0');   -- unused pins

  signal s_cs                   : std_logic;                    -- chip select (data strobe)
  signal s_wr                   : std_logic;                    -- read/write on data bus
  signal lbus_init              : std_logic;                    -- register initialization
  signal lbus_add               : std_logic_vector(2 downto 0); -- local bus arbiter address bus
  signal lbus_data              : std_logic_vector(7 downto 0); -- local bus arbiter data bus

  signal uart_txrdy_n           : std_logic;                    -- tx FIFO Data Ready
  signal uart_rxrdy_n           : std_logic;                    -- rx FIFO Data Ready
  signal uart_add_bus           : std_logic_vector(2 downto 0); -- address bus
  signal uart_data_bus          : std_logic_vector(7 downto 0); -- data bus
  signal uart_rd                : std_logic_vector(7 downto 0); -- UART Rx output data bus
  signal v_write_bus_latch      : std_logic_vector(7 downto 0); -- WRITE data bus latched
  signal v_read_bus_latch       : std_logic_vector(7 downto 0); -- READ data bus latched
  
  --------------------------------------------------------------------------------------------------
  -- v_lcr structure:
  --
  --    0-1     : number of bits
  --                    00 -> 5 | 01 -> 6 | 10 -> 7 | 11 -> 8
  --    2       : number of stop bits
  --                    0 -> 1bit | 1 -> 2bits
  --    3       : parity bit
  --                    0 -> no party | 1 -> parity
  --    4       : parity type
  --                    0 -> odd | 1 -> even
  --    5       : sticky parity (NOT IMPLEMENTED)
  --    6       : set break
  --                    0 -> normal operation
  --                    1 -> serial output is forced to logic 0
  --                         (Spacing State, which will cause a Break interrupt in the receiver)
  --    7       : Divisor Latch (baud rate generator) Access bit
  --                    0 -> set Baud rate divisor
  --                    1 -> access FIFO registers
  --   
  --------------------------------------------------------------------------------------------------

  signal v_lcr          : std_logic_vector(7 downto 0); -- Line Control Register

  --------------------------------------------------------------------------------------------------
  -- v_fcr structure:
  --
  --    0       : FIFO enable 
  --                    X -> FIFOs are always enabled
  --    1       : RECEIVER FIFO reset active HIGH
  --    2       : TRANSMITTER FIFO reset active HIGH
  --    3       : DMA mode
  --                    0 -> Mode 0 (Supports single transfer DMA)
  --                    1 -> Mode 1 (Supports multiple transfers)
  --    4-5     : Reserved bits
  --    6-7     : Receiver FIFO trigger level
  --                    00 -> 1 | 01 -> 4 | 10 -> 8 | 11 -> 14 Bytes
  --   
  --------------------------------------------------------------------------------------------------

  signal v_fcr          : std_logic_vector(7 downto 0); -- FIFO Control Register

  --------------------------------------------------------------------------------------------------
  -- v_lsr structure:
  -- 
  --    0       : Data Ready 
  --                    0 -> Receive FIFO is empty
  --                    1 -> at lest one character is in the receive FIFO
  --    1       : Overrun Error
  --                    0 -> no error
  --                    1 -> Receive FIFO was full, additional character received but was lost
  --    2       : Parity Error
  --                    0 -> no error
  --                    1 -> top character in FIFO received with parity error
  --                            -> Receiver Line Status Interrupt
  --    3       : Framing Error
  --                    0 -> no error
  --                    1 -> top character in FIFO received without a valid stop bit
  --                            -> Receiver Line Status Interrupt
  --    4       : Break Interrupt
  --                    0 -> No Interrupt
  --                    1 -> break condition (uart_srx -> '0' for a character period)
  --                            -> Receiver Line Status Interrupt
  --    5       : Transmitter Holding Register
  --                    0 -> Transmitter FIFO not Empty
  --                    1 -> Transmitter FIFO Empty if enabled
  --                            -> Transmitter Holding Empty Interrupt
  --    6       : Transmitter Empty
  --                    0 -> not 1
  --                    1 -> Transmitter FIFO and Transmitter Shift Register Empty.
  --    7       : Error in receive FIFO
  --                    0 -> not 1
  --                    1 -> at least one error (parity, framing or break) in receive FIFO.
  --                            -> cleared upon reading the register
  --
  --------------------------------------------------------------------------------------------------

  signal v_lsr          : std_logic_vector(7 downto 0); -- Line Status Register

  --------------------------------------------------------------------------------------------------
  -- v_iir structure:
  --
  --    0       : Interrupt pending 
  --                    0 -> Interrupt pending
  --                    1 -> No Interrupt pending
  --    3-1     : 
  --                    010 -> Receiver Data Available ( Rx FIFO trigger level reached)
  --
  --------------------------------------------------------------------------------------------------

  signal v_iir         	: std_logic_vector(7 downto 0); -- Interrupt Identification Register
  
  --------------------------------------------------------------------------------------------------
  -- Baud Rate Generator:
  --    Baud rate division ratio = (s_br_clk /(baudrate x 16))
  --
  --    Baud rate division ratio (16 bits) = c_divisor_msb (8 bits) + c_divisor_lsb (8 bits)
  --
  -- Set useing:  LCR bit 7 -> 1
  --------------------------------------------------------------------------------------------------
  
--  signal c_divisor_lsb  : std_logic_vector(7 downto 0); -- Divisor Latch LSB (Baud Rate Generator)
--  signal c_divisor_msb  : std_logic_vector(7 downto 0); -- Divisor Latch MSB (Baud Rate Generator)
  
  signal v_unused_write 		: std_logic_vector(7 downto 0); -- Unused registers
  signal v_unused_read 	 		: std_logic_vector(7 downto 0); -- Unused registers
	
	signal v_lbus_state				: std_logic_vector(2 downto 0);
	signal s_reading_proc			: std_logic;
	signal s_cs_rd_c					: std_logic;
	signal s_wr_rd_c					:	std_logic;
	signal s_writing_proc			: std_logic;
	signal v_data8_ram				: std_logic_vector (7 downto 0);
	signal s_data8_ram_rdy		: std_logic;
	signal s_wr_enable_o			: std_logic;
	signal s_not_ready				: std_logic;
	
--=============================================================================
-- architecture begin
--=============================================================================
	
begin

  s_clk                 <= sys_clk_i;    -- 29,xxx MHz main clock single ended buffer

  s_clk_n               <=  not s_clk;
  s_rst                 <= sys_rst_i;
  s_br_clk              <= s_clk;               

	s_reading_proc <= v_lbus_state(1);
	s_writing_proc <= v_lbus_state(2);	

	s_rx_rdy_o <= s_not_ready;
	
  --**************************************************************************
  -- UART read/write bus access
  -- 
  --**************************************************************************
  -- read: 
  -- write:
  -- r/w:

  p_uart_RW_bus : process(s_rst, s_clk)    
  begin  
    if s_rst = '1' then
      uart_data_bus     <= (others => '0');
      uart_add_bus      <= (others => '0');
      v_unused_write    <= (others => '0');
      v_unused_read     <= (others => '0');
      v_fcr             <= (others => '0');
      v_lcr             <= (others => '0');
      v_lsr             <= (others => '0');
    elsif Rising_edge(s_clk) then
      uart_add_bus          <= lbus_add;
      case v_lbus_state is
        when "001" =>           -- init
          case uart_add_bus (2 downto 0) is
            when O"0"         => uart_data_bus           <= lbus_data;         -- init Divisor latch lsb
            when O"1"         => uart_data_bus           <= lbus_data;         -- init Divisor latch msb
            when O"2"         => uart_data_bus           <= lbus_data;
                                 v_fcr                   <= lbus_data;         -- FIFO Control Register
            when O"3"         => uart_data_bus           <= lbus_data;
                                 v_lcr                   <= lbus_data;         -- Line Control Register
            when others => null;
          end case;
        when "100" =>        -- write           
          case uart_add_bus (2 downto 0) is
            when O"0"         => uart_data_bus           <= v_write_bus_latch; -- write TRANSMITTER FIFO
            when O"1"         => uart_data_bus           <= lbus_data;         -- Interrupt Enable Register
            when O"2"         => uart_data_bus           <= lbus_data;
                                 v_fcr                   <= lbus_data;         -- FIFO Control Register
            when O"3"         => uart_data_bus           <= lbus_data;
                                 v_lcr                   <= lbus_data;         -- Line Control Register
            when O"4"         => uart_data_bus           <= v_unused_write;    -- Modem Control Register
            when O"7"         => uart_data_bus           <= v_unused_write;    -- Scretch Register
            when others       => null; 
          end case;
        when "010" =>        -- read
          case uart_add_bus (2 downto 0) is  
            when O"0"         => uart_data_bus          <= v_read_bus_latch; --uart_rd;        -- read RECEIVER FIFO
            when O"1"         => v_unused_read          <= uart_data_bus;  -- Interrupt Enable Register
            when O"2"         => v_iir                  <= uart_data_bus;  -- Interrupt Identification Register
            when O"3"         => v_unused_read          <= uart_data_bus;  -- Line Control Register
            when O"4"         => v_unused_read          <= uart_data_bus;  -- Modem Control Register
            when O"5"         => v_lsr                  <= uart_data_bus;  -- Line Status Register
            when O"6"         => v_unused_read          <= uart_data_bus;  -- Modem Status Register
            when O"7"         => v_unused_read          <= uart_data_bus;  -- Scratch Register
            when others       => null;              
          end case;
        when others =>        -- idle 
          case uart_add_bus (2 downto 0) is  
            when O"0"         => uart_data_bus          <= (others => '0');  --uart_rd;        -- read RECEIVER FIFO
            when O"1"         => v_unused_read          <= uart_data_bus;  -- Interrupt Enable Register
            when O"2"         => v_iir                  <= uart_data_bus;  -- Interrupt Identification Register
            when O"3"         => v_unused_read          <= uart_data_bus;  -- Line Control Register
            when O"4"         => v_unused_read          <= uart_data_bus;  -- Modem Control Register
            when O"5"         => v_lsr                  <= uart_data_bus;  -- Line Status Register
            when O"6"         => v_unused_read          <= uart_data_bus;  -- Modem Status Register
            when O"7"         => v_unused_read          <= uart_data_bus;  -- Scratch Register
            when others       => null;                
          end case;
      end case;
    end if;
  end process p_uart_RW_bus;

  --**************************************************************************
  -- UART register latch update
  --**************************************************************************
  -- read: 
  -- write:
  -- r/w:

  p_uart_read_latch : process(s_rst, s_reading_proc)
  begin
    if s_rst = '1' then
      v_read_bus_latch          <= (others => '0');
		elsif rising_edge (s_reading_proc) then
      if s_cs = '0' and s_wr = '0' then
        v_read_bus_latch        <= uart_rd;
      end if;
		end if;
  end process p_uart_read_latch;

  p_uart_write_latch : process(s_rst, s_data8_ram_rdy)
  begin
    if s_rst = '1' then
      v_write_bus_latch          <= (others => '0');
    elsif rising_edge (s_data8_ram_rdy) then
      if s_cs = '0' and s_wr = '1'then
        v_write_bus_latch	<= v_data8_ram;
      end if;
    end if;
  end process p_uart_write_latch;
  
--  p_uart_read_latch : process(s_rst, s_clk_n)
--  begin
--    if s_rst = '1' then
--      v_read_bus_latch          <= (others => '0');
--    elsif rising_edge (s_clk_n) then
--      if s_reading_proc = '1' and s_cs = '0' and s_wr = '0' then
--        v_read_bus_latch        <= uart_rd;
--      else
--        v_read_bus_latch        <= uart_rd;
--      end if;
--		end if;
--  end process p_uart_read_latch;

--  p_uart_write_latch : process(s_rst, s_clk_n)
--  begin
--    if s_rst = '1' then
--      v_write_bus_latch          <= (others => '0');
--    elsif rising_edge (s_clk_n) then
--      if s_data8_ram_rdy = '1' and s_cs = '0' and s_wr = '1' then
--        v_write_bus_latch	<= v_data8_ram;
--      else
--        v_write_bus_latch          <= (others => '0');    
--      end if;
--    end if;
--  end process p_uart_write_latch;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Components mapping
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  cmp_uart : gh_uart_16550 
    port map (
      clk       => s_clk,			-- uart clock
      BR_clk    => s_br_clk,	-- Baudrate generator clock TX and RX 
      rst       => s_rst,			-- Reset
      rst_buffer => s_rst_buffer,       -- soft fifo release reset after init
      CS        => s_cs, -- Chip select -> 1 Cycle long CS strobe = 1 data transaction (w/r)
      WR        => s_wr, -- WRITE when HIGH with CS high | READ when LOW with CS high
      ADD       => uart_add_bus,	-- ADDRESS BUS
      D         => uart_data_bus,	-- Input DATA BUS and CONTROL BUS
      sRX       => uart_din_i, 		 -- uart' INPUT
      CTSn      => '1',                    -- not used 
      DSRn      => '1',                    -- not used
      RIn       => '1',                    -- not used
      DCDn      => '1',                    -- not used
      
      sTX       => uart_dout_o, 		 -- uart's OUTPUT
      DTRn      => open,                   -- not used 
      RTSn      => open,                   -- not used 
      OUT1n     => open,                   -- not used 
      OUT2n     => open,                   -- not used 
      TXRDYn    => uart_txrdy_n,           -- Tx FIFO not Fully      
      RXRDYn    => uart_rxrdy_n,           -- Rx FIFO Data Ready       
      
      IRQ       => open,                 -- not used 
      B_CLK     => s_br_clk_uart_o,	 -- br_clk clock probe signal
      RD        => uart_rd		 -- read data
    );

  cmp_uart_lbus : uart_lbus
    port map (
      lbus_clk          => s_clk,      -- uart clock      
      lbus_rst          => s_rst,			 -- system reset
      lbus_rst_buffer   => s_rst_buffer,    -- soft UART FIFO reset
      lbus_txrdy_n      => uart_txrdy_n,	-- Tx data ready
      lbus_rxrdy_n      => uart_rxrdy_n,	-- Rx data ready
      lbus_cs           => s_cs,      	-- Chip Select gh16550
      lbus_wr           => s_wr, 				-- Write/Read (1/0) gh16550
      lbus_init         => lbus_init, 	-- Initialization process flag
      lbus_add          => lbus_add, 		-- local bus address
      lbus_data         => lbus_data,		-- local bus data  
      s_tx_proc_rqst_i	=> s_tx_proc_rqst_i, -- tx process request from RAM
      v_lbus_state      => v_lbus_state,	-- flag indicator of lbus_state
      s_cs_rd_c 	=> s_cs_rd_c,		-- CS signal from caused by read cycle
      s_wr_rd_c		=> s_wr_rd_c,		-- WR signal from caused by read cycle
      s_new_byte_rdy	=> s_data8_ram_rdy,	-- new byte(8bit)ready and stable to be transmitted
      s_data_tx		=> s_wr_enable_o,		-- 6 bytes will be trasmitted
      reghnd_rd_rdy	=> s_not_ready,			-- 6 byte ready but not yet written in RAM (1/0=>data ready/not ready)
      echo_en_i		=> echo_en_i				-- echo enable command enable/disable = 1/0 
		);

  cmp_register_rx_handler: register_rx_handler
    port map(
      reghnd_clk => s_clk,			-- system clock
      reghnd_rst => s_rst,			-- system reset
      reghnd_data_in => v_read_bus_latch,	-- 8 bits handler input from gh16550 RD through latch
      reghnd_data_cs_rd => s_cs_rd_c,		-- cs strobe of gh16550 during a read process
      reghnd_data_wr_rd	=> s_wr_rd_c,		-- wr state of gh16550 during a read process
      reghnd_rd_rdy => s_not_ready,		-- data and address ready and stable at handler output
      reghnd_full_add => v_rx_add_o,		-- 16 bits full addr ram input
      reghnd_full_data => v_rx_data_o,		-- 32 bits full data ram input
      reghnd_full_cs => s_rx_stb_read_data_i	-- strobe data/address acquired (1 acquired - 0 not acquired)
      );

  cmp_register_tx_handler: register_tx_handler 
    port map(
      reghnd_clk => s_clk,				-- system clock
      reghnd_rst => s_rst,				-- system reset
      reghnd_addr_wwo_i => tx_addr_wwo_i,		-- control of TX process With or WithOut address W/WO=(1/0)
      reghnd_full_data_ram_i => v_tx_data_ram_i,	-- 32 bits full data ram output
      reghnd_full_add_ram_i => v_tx_add_ram_i,		-- 16 bits full addr ram output
      reghnd_stb_data_ram_rdy_i => s_tx_ram_data_rdy_i,	-- strobe ram output data ready and stable
      reghnd_data_acq_gh16550_i => s_cs,		-- data acquired from gh16550
      reghnd_wr_enable_i => s_writing_proc,		-- enable the tx process
      reghnd_txrdy_n_gh16550_i => uart_txrdy_n,	-- gh16550 ready to trasmit
      reghnd_wr_enable_o => s_wr_enable_o,		-- enable the tx process
      reghnd_output_rdy_o => s_data8_ram_rdy,		-- output data(8) ready
      reghnd_pdata_o => v_data8_ram,			-- 8 bits parallel
      reghnd_stb_acq_ram_o => s_tx_stb_ram_data_acq_o	-- strobe data/address acquired (1 acquired - 0 not acquired)	
      );

end a;

--=============================================================================
-- architecture end
--=============================================================================
