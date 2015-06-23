-----------------------------------------------------------------------------
-- Wishbone UART ------------------------------------------------------------
-- (c) 2007 Joerg Bornschein (jb@capsec.org)
--
-- All files under GPLv2 -- please contact me if you use this component
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-----------------------------------------------------------------------------
-- Wishbone UART ------------------------------------------------------------
entity wb_uart is
	port (
		clk        : in  std_logic;
		reset      : in  std_logic;
		-- Wishbone slave
		wb_adr_i   : in  std_logic_vector(31 downto 0);
		wb_dat_i   : in  std_logic_vector(31 downto 0);
		wb_dat_o   : out std_logic_vector(31 downto 0);
		wb_sel_i   : in  std_logic_vector( 3 downto 0);
		wb_cyc_i   : in  std_logic;
		wb_stb_i   : in  std_logic;
		wb_ack_o   : out std_logic;
		wb_we_i    : in  std_logic;
		wb_rxirq_o : out std_logic;
		wb_txirq_o : out std_logic;
		-- Serial I/O ports
		uart_rx    : in  std_logic;
		uart_tx    : out std_logic );
end wb_uart;

-----------------------------------------------------------------------------
-- 0x00 Status Register
-- 0x04 Divisor Register
-- 0x08 RX / TX Data
--
-- Status Register:
-- 
--       +-------------+----------+----------+---------+---------+
--       |  ... 0 ...  | TX_IRQEN | RX_IRQEN | TX_BUSY | RX_FULL |
--       +-------------+----------+----------+---------+---------+
--
-- Divisor Register:
--   Example: 115200 Baud with clk beeing 50MHz:   50MHz/115200 = 434
--
-----------------------------------------------------------------------------
-- Implementation -----------------------------------------------------------
architecture rtl of wb_uart is

-----------------------------------------------------------------------------
-- Components ---------------------------------------------------------------
component myuart is
	port (
		clk       : in  std_logic;
		reset     : in  std_logic;
		--
		divisor   : in  std_logic_vector(15 downto 0);
		txdata    : in  std_logic_vector( 7 downto 0);
		rxdata    : out std_logic_vector( 7 downto 0);
		wr        : in  std_logic;
		rd        : in  std_logic;
		tx_avail  : out std_logic;
		tx_busy   : out std_logic;
		rx_avail  : out std_logic;
		rx_full   : out std_logic;
		rx_error  : out std_logic;
		-- 
		uart_rxd  : in  std_logic;
		uart_txd  : out std_logic );
end component;


-----------------------------------------------------------------------------
-- Local Signals ------------------------------------------------------------

constant ZEROS  : std_logic_vector(31 downto 0) := (others => '0');

signal active     : std_logic;
signal activeLast : std_logic;
signal ack        : std_logic;

signal wr         : std_logic;
signal rd         : std_logic;
signal rx_avail   : std_logic;
signal tx_avail   : std_logic;
signal rxdata     : std_logic_vector(7 downto 0);
signal txdata     : std_logic_vector(7 downto 0);

signal status_reg : std_logic_vector(31 downto 0);
signal data_reg   : std_logic_vector(31 downto 0);
signal div_reg    : std_logic_vector(31 downto 0);

signal tx_irqen   : std_logic;
signal rx_irqen   : std_logic;
signal divisor    : std_logic_vector(15 downto 0);

begin

-- Instantiate actual UART engine
uart0: myuart
	port map (
		clk       => clk,
		reset     => reset,
        -- Sync Interface
		divisor   => divisor,
		txdata    => txdata,
		rxdata    => rxdata,
		wr        => wr,
		rd        => rd,
		tx_avail  => tx_avail,
		tx_busy   => open,
		rx_avail  => rx_avail,
		rx_full   => open,
		rx_error  => open,
		-- Async Interface
		uart_txd  => uart_tx,
		uart_rxd  => uart_rx );


-- Status & divisor register + Wishbine glue logic
status_reg <= ZEROS(31 downto  4) & tx_irqen & rx_irqen & not tx_avail & rx_avail;
data_reg   <= ZEROS(31 downto  8) & rxdata;
div_reg    <= ZEROS(31 downto 16) & divisor;

-- Bus cycle?
active <= wb_stb_i and wb_cyc_i;

wb_dat_o <= status_reg when wb_we_i='0' and (active='1' or ack='1') and wb_adr_i(3 downto 0)=x"0" else
            div_reg    when wb_we_i='0' and (active='1' or ack='1') and wb_adr_i(3 downto 0)=x"4" else
            data_reg   when wb_we_i='0' and (active='1' or ack='1') and wb_adr_i(3 downto 0)=x"8" else
            (others => '0');

rd <= '1' when (active='1' or ack='1') and wb_adr_i(3 downto 0)=x"8" and wb_we_i='0' else
      '0';

wr <= '1' when (active='1' or ack='1') and wb_adr_i(3 downto 0)=x"8" and wb_we_i='1' else
      '0';

txdata   <= wb_dat_i(7 downto 0);
wb_ack_o <= ack;

-- Handle Wishbone write request (and reset condition)
proc: process(reset, clk) is
begin
	if clk'event and clk='1' then
		if reset='1' then
			tx_irqen <= '0';
			rx_irqen <= '0';
			divisor  <= (others => '1');
		else 
		
		if active='1' then
			if	activeLast='0' then
				activeLast <= '1';
				ack        <= '0';
			else 
				activeLast <= '0';
				ack        <= '1';
			end if;
		else 
			ack        <= '0';
			activeLast <= '0';	
		end if;
		
		if active='1' and wb_we_i='1' then    
			if wb_adr_i(3 downto 0)=x"0" then     -- write to status register
				tx_irqen <= wb_dat_i(3);
				rx_irqen <= wb_dat_i(2);
			elsif wb_adr_i(3 downto 0)=x"4" then  -- write to divisor register
				divisor  <= wb_dat_i(15 downto 0);
			end if;
		end if;
		end if;
	end if;
end process;

-- Generate interrupts when enabled
wb_rxirq_o <= rx_avail and rx_irqen;
wb_txirq_o <= tx_avail and tx_irqen;

end rtl;
