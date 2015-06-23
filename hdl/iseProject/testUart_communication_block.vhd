--! @file
--! @brief Test communication block

--! Use standard library and import the packages (std_logic_1164,std_logic_unsigned,std_logic_arith)
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
 
--! Use Global Definitions package
use work.pkgDefinitions.all;
 
ENTITY testUart_communication_block IS
END testUart_communication_block;
 
--! @brief Test communication block
--! @details This will include all blocks used in uart (transmiter, receiver, baud generator)
ARCHITECTURE behavior OF testUart_communication_block IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT uart_communication_blocks
    Port ( rst : in  STD_LOGIC;															--! Global reset
           clk : in  STD_LOGIC;															--! Global clock
			  cycle_wait_baud : in std_logic_vector((nBitsLarge-1) downto 0);	--! Number of cycles to wait in order to generate desired baud
           byte_tx : in  STD_LOGIC_VECTOR ((nBits-1) downto 0);				--! Byte to transmit
           byte_rx : out  STD_LOGIC_VECTOR ((nBits-1) downto 0);				--! Byte to receive
           data_sent_tx : out  STD_LOGIC;												--! Indicate that byte has been sent
           data_received_rx : out  STD_LOGIC;										--! Indicate that we got a byte
			  serial_out : out std_logic;													--! Uart serial out
			  serial_in : in std_logic;													--! Uart serial in
           start_tx : in  STD_LOGIC);													--! Initiate transmission
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';																			--! Signal to connect with UUT
   signal clk : std_logic := '0';																			--! Signal to connect with UUT
   signal cycle_wait_baud : std_logic_vector((nBitsLarge-1) downto 0) := (others => '0');	--! Signal to connect with UUT
   signal byte_tx : std_logic_vector((nBits-1) downto 0) := (others => '0');					--! Signal to connect with UUT
   signal serial_in : std_logic := '0';																	--! Signal to connect with UUT
   signal start_tx : std_logic := '0';																		--! Signal to connect with UUT

 	--Outputs
   signal byte_rx : std_logic_vector((nBits-1) downto 0);											--! Signal to connect with UUT
   signal data_sent_tx : std_logic;																			--! Signal to connect with UUT
   signal data_received_rx : std_logic;																	--! Signal to connect with UUT
   signal serial_out : std_logic;																			--! Signal to connect with UUT

   -- Clock period definitions   
	constant clk_period : time := 20 ns; -- 0.543us (1.8432Mhz) 20ns (50Mhz)
 
BEGIN
 
	--! Instantiate the Unit Under Test (UUT)
   uut: uart_communication_blocks PORT MAP (
          rst => rst,
          clk => clk,
          cycle_wait_baud => cycle_wait_baud,
          byte_tx => byte_tx,
          byte_rx => byte_rx,
          data_sent_tx => data_sent_tx,
          data_received_rx => data_received_rx,
          serial_out => serial_out,
          serial_in => serial_in,
          start_tx => start_tx
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
      -- Setup communication blocks
		rst <= '1';
		serial_in <= '1'; -- Idle..
		cycle_wait_baud <= conv_std_logic_vector(434, (nBitsLarge));
		start_tx <= '0';
      wait for 2 ns;	
		rst <= '0';
		
		-- Send data..
		start_tx <= '1';
		byte_tx <= "01010101";
		wait until data_sent_tx = '1';		

      wait for clk_period*3;
		start_tx <= '0';
		wait for clk_period*3;
		
		start_tx <= '1';
		byte_tx <= "11000100";
		wait until data_sent_tx = '1';
		
		wait for clk_period*3;
		start_tx <= '0';
		wait for clk_period*3;
		
		-- Receive data...
		-- Receive 0x55 value (01010101)
		serial_in <= '0'; -- Start bit
		wait for 8.68 us;
		
		serial_in <= '1';
      wait for 8.68 us;
		serial_in <= '0';
      wait for 8.68 us;
		serial_in <= '1';
      wait for 8.68 us;
		serial_in <= '0';
      wait for 8.68 us;
		serial_in <= '1';
      wait for 8.68 us;
		serial_in <= '0';
      wait for 8.68 us;
		serial_in <= '1';
      wait for 8.68 us;
		serial_in <= '0';
      wait for 8.68 us;
		
		-- Stop bit here
		serial_in <= '1';
		wait for clk_period*200;
		
		-- Receive 0xC4 value (11000100)
		serial_in <= '0'; -- Start bit
		wait for 8.68 us;
		
		serial_in <= '0';
      wait for 8.68 us;
		serial_in <= '0';
      wait for 8.68 us;
		serial_in <= '1';
      wait for 8.68 us;
		serial_in <= '0';
      wait for 8.68 us;
		serial_in <= '0';
      wait for 8.68 us;
		serial_in <= '0';
      wait for 8.68 us;
		serial_in <= '1';
      wait for 8.68 us;
		serial_in <= '1';
      wait for 8.68 us;
		
		-- Stop bit here
		serial_in <= '1';
		wait for clk_period*200;
		
				

      -- Stop Simulation
		assert false report "NONE. End of simulation." severity failure;
		
   end process;

END;
