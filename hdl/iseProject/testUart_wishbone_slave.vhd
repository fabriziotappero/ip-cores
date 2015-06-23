--! Test uart_wishbone_slave (Main test module)
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
 
--! Use Global Definitions package
use work.pkgDefinitions.all;
 
ENTITY testUart_wishbone_slave IS
END testUart_wishbone_slave;
 
ARCHITECTURE behavior OF testUart_wishbone_slave IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT uart_wishbone_slave
    Port ( RST_I : in  STD_LOGIC;								--! Reset Input
           CLK_I : in  STD_LOGIC;								--! Clock Input
           ADR_I0 : in  STD_LOGIC_VECTOR (1 downto 0);	--! Address input
           DAT_I0 : in  STD_LOGIC_VECTOR (31 downto 0);	--! Data Input 0
           DAT_O0 : out  STD_LOGIC_VECTOR (31 downto 0);	--! Data Output 0
           WE_I : in  STD_LOGIC;									--! Write enable input
           STB_I : in  STD_LOGIC;								--! Strobe input (Works like a chip select)
           ACK_O : out  STD_LOGIC;								--! Ack output
			  
			  -- NON-WISHBONE Signals
			  serial_in : in std_logic;							--! Uart serial input
			  data_Avaible : out std_logic;						--! Flag to indicate data avaible					
			  serial_out : out std_logic
			  );
    END COMPONENT;
    

   --Inputs
   signal RST_I : std_logic := '0';												--! Signal to connect with UUT
   signal CLK_I : std_logic := '0';												--! Signal to connect with UUT
   signal ADR_I0 : std_logic_vector(1 downto 0) := (others => '0');	--! Signal to connect with UUT
   signal DAT_I0 : std_logic_vector(31 downto 0) := (others => '0');	--! Signal to connect with UUT
   signal WE_I : std_logic := '0';
   signal STB_I : std_logic := '0';
   signal serial_in : std_logic := '0';

 	--Outputs
   signal DAT_O0 : std_logic_vector(31 downto 0);							--! Signal to connect with UUT
   signal ACK_O : std_logic;														--! Signal to connect with UUT
   signal serial_out : std_logic;												--! Signal to connect with UUT
	signal data_Avaible : std_logic;												--! Signal to connect with UUT

   -- Clock period definitions (1.8432MHz)
   constant CLK_I_period : time := 20 ns; -- 0.543us (1.8432Mhz) 2ns (50Mhz)
 
BEGIN
 
	--! Instantiate the Unit Under Test (UUT)
   uut: uart_wishbone_slave PORT MAP (
          RST_I => RST_I,
          CLK_I => CLK_I,
          ADR_I0 => ADR_I0,
          DAT_I0 => DAT_I0,
          DAT_O0 => DAT_O0,
          WE_I => WE_I,
          STB_I => STB_I,
          ACK_O => ACK_O,
          serial_in => serial_in,
			 data_Avaible => data_Avaible,
          serial_out => serial_out
        );

   -- Clock process definitions
   CLK_I_process :process
   begin
		CLK_I <= '0';
		wait for CLK_I_period/2;
		CLK_I <= '1';
		wait for CLK_I_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- Reset the slave
		RST_I <= '1';
		serial_in <= '1';
      wait for CLK_I_period;
		RST_I <= '0';
		wait for CLK_I_period;

      -- Configure the clock... 
		ADR_I0 <= "00";
		WE_I <= '1';
		STB_I <= '1';
		DAT_I0 <= conv_std_logic_vector(50000000, (nBitsLarge));		
		wait until ACK_O = '1';
		WE_I <= '0';
		STB_I <= '0';
		ADR_I0 <= (others => 'U');
		wait for CLK_I_period;
		
		-- Configure the Baud... 
		ADR_I0 <= "01";
		WE_I <= '1';
		STB_I <= '1';
		DAT_I0 <= conv_std_logic_vector(115200, (nBitsLarge));		
		wait until ACK_O = '1';
		WE_I <= '0';
		STB_I <= '0';
		ADR_I0 <= (others => 'U');
		wait for CLK_I_period*40;
		
		-- Ask to send some data...(0xC4)
		ADR_I0 <= "10";
		WE_I <= '1';
		STB_I <= '1';
		DAT_I0 <= x"000000C4";		
		wait until ACK_O = '1';
		WE_I <= '0';
		STB_I <= '0';
		ADR_I0 <= (others => 'U');
		wait for CLK_I_period*5000;
		
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
		wait for CLK_I_period*5000;
		
		-- Check content by reading the register (Should be 0x55)
		ADR_I0 <= "11";
		WE_I <= '0';
		STB_I <= '1';		
		wait until ACK_O = '1';
		STB_I <= '0';		
		ADR_I0 <= (others => 'U');
		wait for CLK_I_period*5000;
		
		-- Ask to send some data...(0x55)
		ADR_I0 <= "10";
		WE_I <= '1';
		STB_I <= '1';
		DAT_I0 <= x"00000055";		
		wait until ACK_O = '1';
		WE_I <= '0';
		STB_I <= '0';
		ADR_I0 <= (others => 'U');
		wait for CLK_I_period*5000;
		
		

      -- Stop Simulation
		assert false report "NONE. End of simulation." severity failure;
   end process;

END;
