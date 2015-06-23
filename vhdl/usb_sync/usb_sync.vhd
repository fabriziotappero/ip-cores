
-- FT2232H USB Device Core
-- Operates in FT245 Style Synchronous FIFO Mode for high speed data transfers
-- Designer: Wes Pope
-- License: Public Domain


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity usb_sync is 
	port (
		-- Avalon bus signals
		signal clk : in std_logic;
		signal reset_n : in std_logic;
		signal read_n : in std_logic;
		signal write_n : in std_logic;
		signal irq : out std_logic;
		signal chipselect : in std_logic;
		signal address : in std_logic_vector(1 downto 0);
		signal readdata : out std_logic_vector (31 downto 0);
		signal writedata : in std_logic_vector (31 downto 0);

		-- FT2232 Bus Signals
		signal usb_clock : in std_logic;
		signal usb_data : inout std_logic_vector(7 downto 0);
		signal usb_rd_n : out std_logic;
		signal usb_wr_n : out std_logic;
		signal usb_oe_n : out std_logic;
		signal usb_rxf_n : in std_logic;
		signal usb_txe_n : in std_logic
		);
end entity usb_sync;


architecture rtl of usb_sync is

	signal rd_sig : std_logic;
	signal wr_sig : std_logic;

	signal data_addr_sig : std_logic;
	signal rx_status_addr_sig : std_logic;
	signal tx_status_addr_sig : std_logic;

	signal rx_fifo_rddone : std_logic := '0';	
	
	signal rx_fifo_wrclk : std_logic;
	signal rx_fifo_rdreq : std_logic;
	signal rx_fifo_rdclk : std_logic;
	signal rx_fifo_wrreq : std_logic;
	signal rx_fifo_data : std_logic_vector(7 downto 0);
	signal rx_fifo_rdempty : std_logic;
	signal rx_fifo_wrfull : std_logic;
	signal rx_fifo_q : std_logic_vector(7 downto 0);
	signal rx_fifo_rdusedw : std_logic_vector(11 downto 0);
	
	signal tx_fifo_wrclk : std_logic;
	signal tx_fifo_rdreq : std_logic;
	signal tx_fifo_rdclk : std_logic;
	signal tx_fifo_wrreq : std_logic;
	signal tx_fifo_data : std_logic_vector(7 downto 0);
	signal tx_fifo_rdempty : std_logic;
	signal tx_fifo_wrfull : std_logic;
	signal tx_fifo_q : std_logic_vector(7 downto 0);
	signal tx_fifo_wrusedw : std_logic_vector(11 downto 0);

	signal ft2232_wait : integer range 0 to 1 := 0;
	signal ft2232_bus_oe_mode : integer range 0 to 3 := 0;
	signal ft2232_tx_fifo_read : std_logic;
	signal ft2232_rx_fifo_write : std_logic;
	signal ft2232_tx_please : std_logic;
	signal ft2232_rx_please : std_logic;

	COMPONENT dcfifo
	GENERIC (
		intended_device_family	: STRING;
		lpm_numwords			: NATURAL;
		lpm_showahead			: STRING;
		lpm_type				: STRING;
		lpm_width				: NATURAL;
		lpm_widthu				: NATURAL;
		overflow_checking		: STRING;
		rdsync_delaypipe		: NATURAL;
		underflow_checking		: STRING;
		use_eab					: STRING;
		wrsync_delaypipe		: NATURAL
	);
	PORT (
			wrclk	: IN STD_LOGIC ;
			rdempty	: OUT STD_LOGIC ;
			rdreq	: IN STD_LOGIC ;
			wrfull	: OUT STD_LOGIC ;
			rdclk	: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			wrreq	: IN STD_LOGIC ;
			data	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			rdusedw	: OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
			wrusedw	: OUT STD_LOGIC_VECTOR (11 DOWNTO 0)
	);
	END COMPONENT;

begin


	rx_dcfifo : dcfifo
		GENERIC MAP (
		intended_device_family => "Cyclone II",
		lpm_numwords => 2047,
		lpm_showahead => "ON",
		lpm_type => "dcfifo",
		lpm_width => 8,
		lpm_widthu => 11,
		overflow_checking => "ON",
		rdsync_delaypipe => 4,
		underflow_checking => "ON",
		use_eab => "ON",
		wrsync_delaypipe => 4
	)
	PORT MAP (
		wrclk => rx_fifo_wrclk,
		rdreq => rx_fifo_rdreq,
		rdclk => rx_fifo_rdclk,
		wrreq => rx_fifo_wrreq,
		data => rx_fifo_data,
		rdempty => rx_fifo_rdempty,
		wrfull => rx_fifo_wrfull,
		q => rx_fifo_q,
		rdusedw => rx_fifo_rdusedw
	);
	
	tx_dcfifo : dcfifo
	GENERIC MAP (
		intended_device_family => "Cyclone II",
		lpm_numwords => 4095,
		lpm_showahead => "ON",
		lpm_type => "dcfifo",
		lpm_width => 8,
		lpm_widthu => 12,
		overflow_checking => "ON",
		rdsync_delaypipe => 4,
		underflow_checking => "ON",
		use_eab => "ON",
		wrsync_delaypipe => 4
	)
	PORT MAP (
		wrclk => tx_fifo_wrclk,
		rdreq => tx_fifo_rdreq,
		rdclk => tx_fifo_rdclk,
		wrreq => tx_fifo_wrreq,
		data => tx_fifo_data,
		rdempty => tx_fifo_rdempty,
		wrfull => tx_fifo_wrfull,
		q => tx_fifo_q,
		wrusedw => tx_fifo_wrusedw
	);

	-- USB2232 side
	rx_fifo_wrclk <= usb_clock;
	tx_fifo_rdclk <= usb_clock;
		
	ft2232_tx_please <= '1' when usb_txe_n = '0' and tx_fifo_rdempty = '0' and ft2232_wait = 1 else '0';
	ft2232_rx_please <= '1' when usb_rxf_n = '0' and rx_fifo_wrfull = '0' else '0';
	
	ft2232_tx_fifo_read <= '1' when ft2232_tx_please = '1' else '0';
	ft2232_rx_fifo_write <= '1' when ft2232_bus_oe_mode > 1 and ft2232_rx_please = '1' and ft2232_tx_please = '0' else '0';

	tx_fifo_rdreq <= ft2232_tx_fifo_read;
	rx_fifo_wrreq <= ft2232_rx_fifo_write;
	
	usb_rd_n <= '0' when ft2232_rx_fifo_write = '1' else '1';
	usb_wr_n <= '0' when ft2232_tx_fifo_read = '1' else '1';
	usb_oe_n <= '0' when ft2232_bus_oe_mode > 0 else '1';
	usb_data <= tx_fifo_q when ft2232_bus_oe_mode = 0 else (others => 'Z');
	rx_fifo_data <= usb_data when ft2232_bus_oe_mode > 0 and usb_rxf_n = '0';


	-- Handle FIFOs to USB2232 in synchronous mode
	process (usb_clock)
	begin
	
		if usb_clock'event and usb_clock = '1' then

			-- Bias TX over RX
			if (ft2232_tx_please = '1' or ft2232_rx_please = '0') then

				ft2232_bus_oe_mode <= 0;
				
				if (usb_txe_n = '0' and tx_fifo_rdempty = '0') then
					ft2232_wait <= ft2232_wait + 1;
				else
					ft2232_wait <= 0;
				end if;
				
			elsif (ft2232_rx_please = '1') then
		
				ft2232_wait <= 0;
				
				-- Handle bus turn-around. Negate OE (and for atleast 1 clock)
				if (ft2232_bus_oe_mode < 3) then		
					ft2232_bus_oe_mode <= ft2232_bus_oe_mode + 1;
				end if;

			end if;

		end if;		
	
	end process;
	
		
	-- Avalon Bus side
	rx_fifo_rdclk <= clk;
	tx_fifo_wrclk <= clk;

	wr_sig <= '1' when chipselect = '1' and write_n = '0' else '0';
	rd_sig <= '1' when chipselect = '1' and read_n = '0' else '0';
	
	data_addr_sig <= '1' when address = "00" else '0';
	rx_status_addr_sig <= '1' when address = "01" else '0';
	tx_status_addr_sig <= '1' when address = "10" else '0';
  
	irq <= '0';
  
	-- Handle FIFOs to Avalon Bus
	process (clk, reset_n)
	begin
	
		if reset_n = '0' then
		
			readdata <= (others => '0');
			rx_fifo_rddone <= '0';
			
		elsif clk'event and clk = '1' then			
			
			if (rd_sig = '1' and data_addr_sig = '1') then
				-- read fifo with 2 clocks
				readdata <= "000000000000000000000000" & rx_fifo_q;
				if (rx_fifo_rddone = '0') then
					rx_fifo_rdreq <= '1';
					rx_fifo_rddone <= '1';
				else
					rx_fifo_rdreq <= '0';
					rx_fifo_rddone <= '0';
				end if;
			end if;

			if (wr_sig = '1' and data_addr_sig = '1') then
				-- write fifo
				tx_fifo_wrreq <= '1';
				tx_fifo_data <= writedata(7 downto 0);
			else
				tx_fifo_wrreq <= '0';
			end if;

			if (rd_sig = '1' and rx_status_addr_sig = '1') then
				-- read rx fifo stats
				readdata <= "1000000000000000000" & rx_fifo_rdempty & rx_fifo_rdusedw;
			end if;
			
			if (rd_sig = '1' and tx_status_addr_sig = '1') then
				-- read tx fifo stats
				readdata <= "1000000000000000000" & tx_fifo_wrfull & tx_fifo_wrusedw;
			end if;
			
		end if;
		
	end process;	

end rtl;

