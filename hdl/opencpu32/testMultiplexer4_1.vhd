--! @file
--! @brief Testbench for Multiplexer4_1

--! Use standard library and import the packages (std_logic_1164,std_logic_unsigned,std_logic_arith)
LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
 
--! Use CPU Definitions package
use work.pkgOpenCPU32.all;
 
ENTITY testMultiplexer4_1 IS
END testMultiplexer4_1;
 
--! @brief Multiplexer4_1 Testbench file
--! @details Test multiplexer operations changing the selection signal
--! for more information: http://en.wikipedia.org/wiki/Multiplexer
ARCHITECTURE behavior OF testMultiplexer4_1 IS 
 
    --! Component declaration to instantiate the Multiplexer circuit
    COMPONENT Multiplexer4_1
    generic (n : integer := nBits - 1);					--! Generic value (Used to easily change the size of the Alu on the package)
	 Port ( A   : in  STD_LOGIC_VECTOR (n downto 0);	--! First Input
           B   : in  STD_LOGIC_VECTOR (n downto 0);	--! Second Input
			  C   : in  STD_LOGIC_VECTOR (n downto 0);	--! Third Input
			  D   : in  STD_LOGIC_VECTOR (n downto 0);	--! Forth Input
			  E   : in  STD_LOGIC_VECTOR (n downto 0);	--! Fifth Input
           sel : in  dpMuxInputs;							--! Select inputs (1, 2, 3, 4, 5)
           S   : out  STD_LOGIC_VECTOR (n downto 0));	--! Mux Output
    END COMPONENT;
    

   --Inputs
   signal A : std_logic_vector((nBits - 1) downto 0) := (others => '0');	--! Wire to connect Test signal to component
   signal B : std_logic_vector((nBits - 1) downto 0) := (others => '0');	--! Wire to connect Test signal to component
	signal C : std_logic_vector((nBits - 1) downto 0) := (others => '0');	--! Wire to connect Test signal to component
	signal D : std_logic_vector((nBits - 1) downto 0) := (others => '0');	--! Wire to connect Test signal to component
	signal E : std_logic_vector((nBits - 1) downto 0) := (others => '0');	--! Wire to connect Test signal to component
   signal sel : dpMuxInputs := fromMemory;											--! Wire to connect Test signal to component

 	--Outputs
   signal S : std_logic_vector((nBits - 1) downto 0);   							--! Wire to connect Test signal to component
 
BEGIN
 
	--!Instantiate the Unit Under Test (Multiplexer4_1) (Doxygen bug if it's not commented!)
   uut: Multiplexer4_1 PORT MAP (
          A => A,
          B => B,
			 C => C,
			 D => D,
			 E => E,
          sel => sel,
          S => S
        );
   
   --! Process that will change sel signal and verify the Mux outputs
   stim_proc: process
   begin		
      -- Sel 0 ---------------------------------------------------------------------------
		wait for 1 ps;
		REPORT "Select first channel" SEVERITY NOTE;
		sel <= fromMemory;
		A <= conv_std_logic_vector(0, nBits);
		B <= conv_std_logic_vector(1000, nBits);		
		C <= conv_std_logic_vector(2000, nBits);		
		D <= conv_std_logic_vector(3000, nBits);		
		E <= conv_std_logic_vector(4000, nBits);		
		wait for 1 ns;  -- Wait to stabilize the response
		assert S = (A) report "Could not select first channel" severity FAILURE;		
		
		-- Sel 1 ---------------------------------------------------------------------------
		wait for 1 ns;
		REPORT "Select second channel" SEVERITY NOTE;
		sel <= fromImediate;
		A <= conv_std_logic_vector(0, nBits);
		B <= conv_std_logic_vector(1000, nBits);		
		C <= conv_std_logic_vector(2000, nBits);		
		D <= conv_std_logic_vector(3000, nBits);		
		E <= conv_std_logic_vector(4000, nBits);		
		wait for 1 ns;  -- Wait to stabilize the response
		assert S = (B) report "Could not select second channel" severity FAILURE;
		
		-- Sel 2 ---------------------------------------------------------------------------
		wait for 1 ns;
		REPORT "Select third channel" SEVERITY NOTE;
		sel <= fromRegFileA;
		A <= conv_std_logic_vector(0, nBits);
		B <= conv_std_logic_vector(1000, nBits);		
		C <= conv_std_logic_vector(2000, nBits);		
		D <= conv_std_logic_vector(3000, nBits);	
		E <= conv_std_logic_vector(4000, nBits);				
		wait for 1 ns;  -- Wait to stabilize the response
		assert S = (C) report "Could not select third channel" severity FAILURE;
		
		-- Sel 3 ---------------------------------------------------------------------------
		wait for 1 ns;
		REPORT "Select forth channel" SEVERITY NOTE;
		sel <= fromRegFileB;
		A <= conv_std_logic_vector(0, nBits);
		B <= conv_std_logic_vector(1000, nBits);		
		C <= conv_std_logic_vector(2000, nBits);		
		D <= conv_std_logic_vector(3000, nBits);		
		E <= conv_std_logic_vector(4000, nBits);		
		wait for 1 ns;  -- Wait to stabilize the response
		assert S = (D) report "Could not select forth channel" severity FAILURE;
		
		-- Sel 4 ---------------------------------------------------------------------------
		wait for 1 ns;
		REPORT "Select fifth channel" SEVERITY NOTE;
		sel <= fromAlu;
		A <= conv_std_logic_vector(0, nBits);
		B <= conv_std_logic_vector(1000, nBits);		
		C <= conv_std_logic_vector(2000, nBits);		
		D <= conv_std_logic_vector(3000, nBits);		
		E <= conv_std_logic_vector(4000, nBits);		
		wait for 1 ns;  -- Wait to stabilize the response
		assert S = (E) report "Could not select fifth channel" severity FAILURE;
		
		-- Finish simulation
		assert false report "NONE. End of simulation." severity failure;
   end process;

END;
