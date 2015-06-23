--! Test baud_generator module
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
 
--! Use Global Definitions package
use work.pkgDefinitions.all;
 
ENTITY testUart_control IS
END testUart_control;
 
ARCHITECTURE behavior OF testUart_control IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT uart_control
    Port ( rst : in  std_logic;														--! Global reset
           clk : in  std_logic;														--! Global clock
			  WE	: in std_logic;														--! Write enable
           reg_addr : in  std_logic_vector (1 downto 0);			  			--! Register address
			  start : in std_logic;														--! Start (Strobe)
			  done : out std_logic;														--! Done (ACK)
           DAT_I : in  std_logic_vector ((nBitsLarge-1) downto 0);		--! Data Input (Wishbone)
           DAT_O : out  std_logic_vector ((nBitsLarge-1) downto 0);		--! Data output (Wishbone)
			  baud_wait : out std_logic_vector ((nBitsLarge-1) downto 0);	--! Signal to control the baud rate frequency
			  data_byte_tx : out std_logic_vector((nBits-1) downto 0);	  	--! 1 Byte to be send to serial_transmitter
			  data_byte_rx : in std_logic_vector((nBits-1) downto 0);     	--! 1 Byte to be received by serial_receiver
           tx_data_sent : in  std_logic;										  	--! Signal comming from serial_transmitter
			  tx_start : out std_logic;												--! Signal to start sending serial data...
			  rst_comm_blocks : out std_logic;										--! Reset Communication blocks
           rx_data_ready : in  std_logic);			
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';																	--! Signal to connect with UUT
   signal clk : std_logic := '0';																	--! Signal to connect with UUT
   signal WE : std_logic := '0';																		--! Signal to connect with UUT
   signal reg_addr : std_logic_vector(1 downto 0) := (others => '0');					--! Signal to connect with UUT
   signal start : std_logic := '0';																	--! Signal to connect with UUT
   signal DAT_I : std_logic_vector((nBitsLarge-1) downto 0) := (others => '0');		--! Signal to connect with UUT
   signal data_byte_rx : std_logic_vector((nBits-1) downto 0) := (others => '0');	--! Signal to connect with UUT
   signal tx_data_sent : std_logic := '0';														--! Signal to connect with UUT
   signal rx_data_ready : std_logic := '0';														--! Signal to connect with UUT

 	--Outputs
   signal done : std_logic;																			--! Signal to connect with UUT
	signal tx_start : std_logic;																		--! Signal to connect with UUT
	signal rst_comm_blocks : std_logic;																--! Signal to connect with UUT
   signal DAT_O : std_logic_vector((nBitsLarge-1) downto 0);								--! Signal to connect with UUT
   signal baud_wait : std_logic_vector((nBitsLarge-1) downto 0);							--! Signal to connect with UUT
   signal data_byte_tx : std_logic_vector((nBits-1) downto 0);								--! Signal to connect with UUT

   -- Clock period definitions
   constant clk_period : time := 20 ns; -- 20ns (50Mhz)
 
BEGIN
 
	--! Instantiate the Unit Under Test (UUT)
   uut: uart_control PORT MAP (
          rst => rst,
          clk => clk,
          WE => WE,
          reg_addr => reg_addr,
          start => start,
          done => done,
          DAT_I => DAT_I,
          DAT_O => DAT_O,
          baud_wait => baud_wait,
          data_byte_tx => data_byte_tx,
          data_byte_rx => data_byte_rx,
          tx_data_sent => tx_data_sent,
			 rst_comm_blocks => rst_comm_blocks,
			 tx_start => tx_start,
          rx_data_ready => rx_data_ready
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      rst <= '1';
		start <= '0';
      wait for clk_period;
		rst <= '0';
      wait for clk_period;

      -- Configure the clock... 
		reg_addr <= "00";
		WE <= '1';
		start <= '1';
		DAT_I <= conv_std_logic_vector(50000000, (nBitsLarge));		
		wait until done = '1';
		WE <= '0';
		start <= '0';
		reg_addr <= (others => 'U');
		wait for clk_period;
		
		-- Configure the Baud... 
		reg_addr <= "01";
		WE <= '1';
		start <= '1';
		DAT_I <= conv_std_logic_vector(115200, (nBitsLarge));		
		wait until done = '1';
		WE <= '0';
		start <= '0';
		reg_addr <= (others => 'U');
		
		-- Wait some time to configure the communication block
		wait for clk_period * 40;	
		
		
		-- Ask to send some data...(0x55)
		reg_addr <= "10";
		WE <= '1';
		start <= '1';
		DAT_I <= x"00000055";		
		wait until done = '1';
		WE <= '0';
		start <= '0';
		reg_addr <= (others => 'U');
		wait for clk_period;
		
		-- Ask to read some data...
		reg_addr <= "11";
		WE <= '0';
		start <= '1';
		wait until done = '1';
		start <= '0';
		wait for clk_period*10;

      -- Stop Simulation
		assert false report "NONE. End of simulation." severity failure;
   end process;

END;
