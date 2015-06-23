--! @file
--! @brief Testbench for TriStateBuffer

--! Use standard library and import the packages (std_logic_1164,std_logic_unsigned,std_logic_arith)
LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
 
--! Use CPU Definitions package
use work.pkgOpenCPU32.all;
 
ENTITY testTriStateBuffer IS
END testTriStateBuffer;
 
--! @brief TriStateBuffer Testbench file
--! @details Test TriStateBuffer by enabling/disabling the sel signal
ARCHITECTURE behavior OF testTriStateBuffer IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT TriStateBuffer
    generic (n : integer := nBits - 1);				--! Generic value (Used to easily change the size of the Alu on the package)
	 PORT(         
			A : IN  std_logic_vector(n downto 0);		--! Buffer Input
         sel : IN  typeEnDis;								--! Enable or Disable the output
         S : OUT  std_logic_vector(n downto 0)		--! Enable or Disable the output
        );
    END COMPONENT;
    

   --Inputs
   signal A : std_logic_vector((nBits - 1) downto 0) := (others => '0');	--! Wire to connect Test signal to component
   signal sel : typeEnDis := disable;													--! Wire to connect Test signal to component

 	--Outputs
   signal S : std_logic_vector((nBits - 1) downto 0);								--! Wire to connect Test signal to component
   
BEGIN 	
	--!Instantiate the Unit Under Test (Multiplexer2_1) (Doxygen bug if it's not commented!)
   uut: TriStateBuffer PORT MAP (
          A => A,
          sel => sel,
          S => S
        );
    
   --! Process that will change sel signal and verify the Mux outputs
   stim_proc: process
	variable allZ : std_logic_vector((nBits - 1) downto 0) := (others => 'Z');
   begin		
      -- Sel disable ---------------------------------------------------------------------------
		wait for 1 ps;
		REPORT "Test tristate on disable mode" SEVERITY NOTE;
		sel <= disable;
		A <= conv_std_logic_vector(10, nBits);		
		wait for 1 ns;  -- Wait to stabilize the response
		assert S = allZ report "Output should be high impedance..." severity FAILURE;		
      
		-- Sel disable ---------------------------------------------------------------------------
		wait for 1 ps;
		REPORT "Test tristate on enable mode" SEVERITY NOTE;
		sel <= enable;
		A <= conv_std_logic_vector(10, nBits);		
		wait for 1 ns;  -- Wait to stabilize the response
		assert S = (conv_std_logic_vector(10, nBits)) report "Output should be high impedance..." severity FAILURE;		     

      -- Finish simulation
		assert false report "NONE. End of simulation." severity failure;
   end process;

END;
