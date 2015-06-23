--! @file
--! @brief Test serial_receiver module module

--! Use standard library and import the packages (std_logic_1164,std_logic_unsigned,std_logic_arith)
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
--! Use CPU Definitions package
use work.pkgDefinitions.all;
 
ENTITY testSerial_receiver IS
END testSerial_receiver;
 
--! @brief Test serial_receiver module module
--! @details Receive some simulated byte stream and verify received values
ARCHITECTURE behavior OF testSerial_receiver IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT serial_receiver
   Port ( 
			  rst : in STD_LOGIC;													--! Reset input		  
			  baudOverSampleClk : in  STD_LOGIC;								--! Baud oversampled 8x (Best way to detect start bit)
           serial_in : in  STD_LOGIC;											--! Uart serial input
           data_ready : out  STD_LOGIC;										--! Data received and ready to be read
           data_byte : out  STD_LOGIC_VECTOR ((nBits-1) downto 0));	--! Data byte received
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';					--! Signal to connect with UUT
   signal baudClk : std_logic := '0';				--! Signal to connect with UUT
   signal baudOverSampleClk : std_logic := '0';	--! Signal to connect with UUT
   signal serial_in : std_logic := '0';			--! Signal to connect with UUT

 	--Outputs
   signal data_ready : std_logic;									--! Signal to connect with UUT
   signal data_byte : std_logic_vector((nBits-1) downto 0);	--! Signal to connect with UUT

   -- Clock period definitions
   constant baudClk_period : time := 8.6805 us;
   constant baudOverSampleClk_period : time :=1.085 us;
 
BEGIN
 
	--! Instantiate the Unit Under Test (UUT)
   uut: serial_receiver PORT MAP (
          rst => rst,          
          baudOverSampleClk => baudOverSampleClk,
          serial_in => serial_in,
          data_ready => data_ready,
          data_byte => data_byte
        );

   -- Clock process definitions
   baudClk_process :process
   begin
		baudClk <= '0';
		wait for baudClk_period/2;
		baudClk <= '1';
		wait for baudClk_period/2;
   end process;
 
   baudOverSampleClk_process :process
   begin
		baudOverSampleClk <= '0';
		wait for baudOverSampleClk_period/2;
		baudOverSampleClk <= '1';
		wait for baudOverSampleClk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      rst <= '1';
		serial_in <= '1';	-- Idle
      wait for 3 us;	
		rst <= '0';
		wait for baudClk_period * 3;
		
		-- Receive 0xC4 value (11000100)
		-- Start bit here
		serial_in <= '0';
		wait for baudClk_period;
		
		serial_in <= '0';
      wait for baudClk_period;
		serial_in <= '0';
      wait for baudClk_period;
		serial_in <= '1';
      wait for baudClk_period;
		serial_in <= '0';
      wait for baudClk_period;
		serial_in <= '0';
      wait for baudClk_period;
		serial_in <= '0';
      wait for baudClk_period;
		serial_in <= '1';
      wait for baudClk_period;
		serial_in <= '1';
      wait for baudClk_period;
		
		-- Stop bit here
		serial_in <= '1';		
		---wait until data_ready = '1';
		assert data_byte = X"C4" report "Wrong result... expected 0xC4" severity failure;
		wait for baudClk_period * 8;
		
		-- Receive 0x55 value (01010101)
		-- Start bit here
		serial_in <= '0';
		wait for baudClk_period;
		
		serial_in <= '1';
      wait for baudClk_period;
		serial_in <= '0';
      wait for baudClk_period;
		serial_in <= '1';
      wait for baudClk_period;
		serial_in <= '0';
      wait for baudClk_period;
		serial_in <= '1';
      wait for baudClk_period;
		serial_in <= '0';
      wait for baudClk_period;
		serial_in <= '1';
      wait for baudClk_period;
		serial_in <= '0';
      wait for baudClk_period;
		
		-- Stop bit here
		serial_in <= '1';
		wait for baudClk_period * 1;
		---wait until data_ready = '1';
		assert data_byte = X"55" report "Wrong result... expected 0x55" severity failure;

      -- Stop Simulation
		assert false report "NONE. End of simulation." severity failure;

      wait;
   end process;

END;
