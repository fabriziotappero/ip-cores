--! @file
--! @brief Test baud_generator module

--! Use standard library and import the packages (std_logic_1164,std_logic_unsigned,std_logic_arith)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--! Use Global Definitions package
use work.pkgDefinitions.all;
 
ENTITY testBaud_generator IS
END testBaud_generator;
 
--! @brief Test baud_generator module
--! @details Exercise the baud generator with 50Mhz clock and dividing by 434, finally checking for period of 8.68 us
ARCHITECTURE behavior OF testBaud_generator IS 
      
    COMPONENT baud_generator
    Port ( rst : in STD_LOGIC;														--! Reset Input
			  clk : in  STD_LOGIC;														--! Clock input
           cycle_wait : in  STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);	--! Number of cycles to wait for baud generation
			  baud_oversample : out std_logic;										--! Oversample(8x) version of baud (Used on serial_receiver)
           baud : out  STD_LOGIC);													--! Baud generation output (Used on serial_transmitter)
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';																		--! Signal to connect with UUT
   signal clk : std_logic := '0';																		--! Signal to connect with UUT
   signal cycle_wait : std_logic_vector((nBitsLarge-1) downto 0) := (others => '0');	--! Signal to connect with UUT

 	--Outputs
   signal baud : std_logic;					--! Signal to connect with UUT
	signal baud_oversample : std_logic;		--! Signal to connect with UUT

   -- Clock period definitions (1.8432MHz)
   constant clk_period : time := 20 ns; -- 0.543us (1.8432Mhz) 20ns (50Mhz)
 
BEGIN
 
	--! Instantiate the Unit Under Test (UUT)
   uut: baud_generator PORT MAP (
          rst => rst,
          clk => clk,
          cycle_wait => cycle_wait,
			 baud_oversample => baud_oversample,
          baud => baud
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
   variable t1 : time;
	variable t2 : time;
	variable period : time; -- 1/115200 = 8.68 us
	begin		
      -- Test the baud generator waiting for 434 clock cycles from 50MHz clock
		rst <= '1';
		cycle_wait <= conv_std_logic_vector(434, (nBitsLarge)); -- 50000000/115200
      wait for clk_period;
		rst <= '0';

      wait until baud = '1';
		t1 := now;	-- Get current simulation time
		wait until baud = '0';
		wait until baud = '1';
		t2 := now;	-- Get current simulation time
		wait until baud = '0';
		wait until baud = '1';
		report "Current sim time=" & time'image(now);
		period := t2 - t1;
		
		-- Verify if we have the right period 1/115200 = 8.68 us
		assert period = 8.68 us report "Wrong period expecter 8.68 us. got: "& time'image(period) severity failure;
      
		-- Stop Simulation
		assert false report "NONE. End of simulation." severity failure;

      wait;
   end process;

END;
