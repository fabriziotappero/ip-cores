--! @file
--! @brief Test divisor module

--! Use standard library and import the packages (std_logic_1164,std_logic_unsigned,std_logic_arith)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
 
--! Use Global Definitions package
use work.pkgDefinitions.all;
 
ENTITY testDivisor IS
END testDivisor;
 
--! @brief Test divisor module
--! @details Calculate some divisions and verify if we have the right value
ARCHITECTURE behavior OF testDivisor IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT divisor
    Port ( rst : in  STD_LOGIC;														--! Reset input
           clk : in  STD_LOGIC;			  											--! Clock input
           quotient : out  STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);	--! Division result (32 bits)
			  reminder : out  STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);	--! Reminder result (32 bits)
           numerator : in  STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);	--! Numerator (32 bits)
           divident : in  STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);	--! "Divide by" number (32 bits)
           done : out  STD_LOGIC);
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';																	--! Signal to connect with UUT
   signal clk : std_logic := '0';																	--! Signal to connect with UUT
   signal numerator : std_logic_vector((nBitsLarge-1) downto 0) := (others => '0');	--! Signal to connect with UUT
   signal divident : std_logic_vector((nBitsLarge-1) downto 0) := (others => '0');	--! Signal to connect with UUT

 	--Outputs
   signal quotient : std_logic_vector((nBitsLarge-1) downto 0);							--! Signal to connect with UUT
   signal reminder : std_logic_vector((nBitsLarge-1) downto 0);							--! Signal to connect with UUT
   signal done : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	--! Instantiate the Unit Under Test (UUT)
   uut: divisor PORT MAP (
          rst => rst,
          clk => clk,
          quotient => quotient,
          reminder => reminder,
          numerator => numerator,
          divident => divident,
          done => done
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
      -- hold reset state for 100 ns.
		rst <= '1';
		numerator <= conv_std_logic_vector(50000000, 32);
		divident <= conv_std_logic_vector(115200, 32);
      wait for clk_period;	
		rst <= '0';
		
		wait until done = '1';
		assert quotient = conv_std_logic_vector(434, 32) report "Wrong result... expected 434." severity failure;
      wait for clk_period;
		
		rst <= '1';
		numerator <= conv_std_logic_vector(40, 32);
		divident <= conv_std_logic_vector(5, 32);
      wait for clk_period;
		rst <= '0';
		
		wait until done = '1';
		assert quotient = conv_std_logic_vector(8, 32) report "Wrong result... expected 8." severity failure;
		wait for clk_period;

      -- insert stimulus here 
		assert false report "NONE. End of simulation." severity failure;
      
   end process;

END;
