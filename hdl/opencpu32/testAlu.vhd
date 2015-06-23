--! @file
--! @brief Testbench for Alu

--! Use standard library and import the packages (std_logic_1164,std_logic_unsigned,std_logic_arith)
library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--! Use CPU Definitions package
use work.pkgOpenCPU32.all;
 
ENTITY testAlu IS
END testAlu;
 
--! @brief Alu Testbench file
--! @details Exercise each Alu operation to verify if the description work as planned 
--! for more information: http://vhdlguru.blogspot.com/2010/03/how-to-write-testbench.html
ARCHITECTURE behavior OF testAlu IS 
 
    
	 --! Component declaration to instantiate the Alu circuit
    COMPONENT Alu
    generic (n : integer := nBits - 1);						--! Generic value (Used to easily change the size of the Alu on the package)
	 Port ( A : in  STD_LOGIC_VECTOR (n downto 0);			--! Alu Operand 1
           B : in  STD_LOGIC_VECTOR (n downto 0);			--! Alu Operand 2
           S : out  STD_LOGIC_VECTOR (n downto 0);			--! Alu Output
			  flagsOut : out STD_LOGIC_VECTOR(2 downto 0);	--! Flags from current operation
           sel : in  aluOps);										--! Select operation								--! Select operation
    END COMPONENT;
    

   --Inputs
   signal A : std_logic_vector((nBits - 1) downto 0) := (others => '0');	--! Wire to connect Test signal to component
   signal B : std_logic_vector((nBits - 1) downto 0) := (others => '0');	--! Wire to connect Test signal to component
   signal sel : aluOps := alu_sum;														--! Wire to connect Test signal to component

 	--Outputs
   signal S : std_logic_vector((nBits - 1) downto 0);								--! Wire to connect Test signal to component
	signal flagsOut : std_logic_vector(2 downto 0);									--! Wire to connect Test signal to component
   
BEGIN
 
	--! Instantiate the Unit Under Test (Alu) (Doxygen bug if it's not commented!)
   uut: Alu PORT MAP (
          A => A,
          B => B,
          S => S,
			 flagsOut => flagsOut,
          sel => sel
        );

   --! Process that will stimulate all of the Alu operations
   stim_proc: process
	variable mulResult : std_logic_vector(((nBits*2) - 1)downto 0);
   begin		      
      -- Pass ---------------------------------------------------------------------------
		wait for 1 ps;
		REPORT "Pass input A to output" SEVERITY NOTE;
		sel <= alu_pass;
		A <= conv_std_logic_vector(22, nBits);
		wait for 1 ns;  -- Wait to stabilize the response
		assert S = (A ) report "Invalid Pass output" severity FAILURE;	

		-- Sum ---------------------------------------------------------------------------
		wait for 1 ps;
		REPORT "Sum without carry 12 AND 13" SEVERITY NOTE;
		sel <= alu_sum;
		A <= conv_std_logic_vector(12, nBits);
		B <= conv_std_logic_vector(13, nBits);		
		wait for 1 ns;  -- Wait to stabilize the response	
		assert S = (A + B) report "Invalid Sum output" severity FAILURE;

		-- Sub ---------------------------------------------------------------------------
		wait for 1 ps;
		REPORT "Sub without carry 34 AND 30" SEVERITY NOTE;
		sel <= alu_sub;
		A <= conv_std_logic_vector(34, nBits);
		B <= conv_std_logic_vector(30, nBits);		
		wait for 1 ns;  -- Wait to stabilize the response
		assert S = (A - B) report "Invalid Sum Sub" severity FAILURE;		
		
		-- Inc ---------------------------------------------------------------------------
		wait for 1 ps;
		REPORT "Inc without carry 1" SEVERITY NOTE;
		sel <= alu_inc;
		A <= conv_std_logic_vector(1, nBits);
		wait for 1 ns;  -- Wait to stabilize the response
		assert S = (A + 1) report "Invalid Sum Sub" severity FAILURE;

		-- Dec ---------------------------------------------------------------------------
		wait for 1 ps;
		REPORT "Dec without carry 1" SEVERITY NOTE;
		sel <= alu_dec;
		A <= conv_std_logic_vector(1, nBits);
		wait for 1 ns;  -- Wait to stabilize the response
		assert S = (A - 1) report "Invalid Sum Sub" severity FAILURE;		
		
		-- Mul ---------------------------------------------------------------------------
		wait for 1 ps;
		REPORT "Sub without carry 34 AND 30" SEVERITY NOTE;
		sel <= alu_mul;
		A <= conv_std_logic_vector(3, nBits);
		B <= conv_std_logic_vector(5, nBits);		
		wait for 1 ns;  -- Wait to stabilize the response
		mulResult := (A * B);
		assert S = (mulResult((nBits - 1) downto 0)) report "Invalid Sum Sub" severity FAILURE;		
		
		-- AND ---------------------------------------------------------------------------
		wait for 1 ps;
		REPORT "AND without carry 2(10) AND 3(11)" SEVERITY NOTE;
		sel <= alu_and;
		A <= conv_std_logic_vector(2, nBits);
		B <= conv_std_logic_vector(3, nBits);		
		wait for 1 ns;  -- Wait to stabilize the response
		assert S = (A and B) report "Invalid AND output" severity FAILURE;		
		
		-- OR ---------------------------------------------------------------------------
		wait for 1 ns;
		REPORT "OR without carry 5 OR 7" SEVERITY NOTE;
		sel <= alu_or;
		A <= conv_std_logic_vector(5, nBits);
		B <= conv_std_logic_vector(7, nBits);		
		wait for 1 ns;  -- Wait to stabilize the response
		assert S = (A or B) report "Invalid OR output" severity FAILURE;

		-- XOR ---------------------------------------------------------------------------
		wait for 1 ns;
		REPORT "OR without carry 11 XOR 9" SEVERITY NOTE;
		sel <= alu_xor;
		A <= conv_std_logic_vector(11, nBits);
		B <= conv_std_logic_vector(9, nBits);		
		wait for 1 ns;  -- Wait to stabilize the response
		assert S = (A xor B) report "Invalid XOR output" severity FAILURE;
		
		-- NOT ---------------------------------------------------------------------------
		wait for 1 ns;
		REPORT "NOT 10" SEVERITY NOTE;
		sel <= alu_not;
		A <= conv_std_logic_vector(10, nBits);
		B <= (others => 'X');		
		wait for 1 ns;  -- Wait to stabilize the response
		assert S = (not A) report "Invalid NOT output" severity FAILURE;
		
		-- Shift left---------------------------------------------------------------------
		wait for 1 ns;
		REPORT "Shift left 2" SEVERITY NOTE;
		sel <= alu_shfLt;
		A <= conv_std_logic_vector(2, nBits);
		B <= (others => 'X');		
		wait for 1 ns;  -- Wait to stabilize the response
		assert S = conv_std_logic_vector(4, nBits) report "Invalid shift left output expected " severity FAILURE;
		
		-- Shift right---------------------------------------------------------------------
		wait for 1 ns;
		REPORT "Shift right 4" SEVERITY NOTE;
		sel <= alu_shfRt;
		A <= conv_std_logic_vector(4, nBits);
		B <= (others => 'X');		
		wait for 1 ns;  -- Wait to stabilize the response
		assert S = conv_std_logic_vector(2, nBits) report "Invalid shift left output expected " severity FAILURE;
		
		-- Test flag zero ------------------------------------------------------------------
		wait for 1 ps;
		REPORT "Test zero flag 10 sub 10" SEVERITY NOTE;
		sel <= alu_sub;
		A <= conv_std_logic_vector(10, nBits);
		B <= conv_std_logic_vector(10, nBits);		
		wait for 1 ns;  -- Wait to stabilize the response
		assert flagsOut(flag_zero) = '1' report "Invalid zero flag" severity FAILURE;
		
		-- Test flag carry ------------------------------------------------------------------
		wait for 1 ps;
		REPORT "Test carry flag 4294967056 sum 4294967056" SEVERITY NOTE;
		sel <= alu_sum;
		A <= "11111111111111111111111100010000";
		B <= "11111111111111111111111100010000";
		wait for 1 ns;  -- Wait to stabilize the response
		assert flagsOut(flag_carry) = '1' report "Invalid carry flag" severity FAILURE;
		
		-- Test flag sign ------------------------------------------------------------------
		wait for 1 ps;
		REPORT "Test sign flag -4 sub 4" SEVERITY NOTE;
		sel <= alu_sub;
		A <= conv_std_logic_vector(-4, nBits);
		B <= conv_std_logic_vector(4, nBits);		
		wait for 1 ns;  -- Wait to stabilize the response
		assert flagsOut(flag_sign) = '1' report "Invalid sign flag" severity FAILURE;
		assert S = conv_std_logic_vector(-8, nBits) report "Invalid Sub" severity FAILURE;

      -- Finish simulation
		assert false report "NONE. End of simulation." severity failure;
   end process;

END;
