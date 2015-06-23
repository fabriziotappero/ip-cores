
-- VHDL Test Bench Created from source file bin_ascii.vhd -- 14:56:18 11/03/2010
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY bin_ascii_bin_ascii_TB_vhd_tb IS
END bin_ascii_bin_ascii_TB_vhd_tb;

ARCHITECTURE behavior OF bin_ascii_bin_ascii_TB_vhd_tb IS 

	COMPONENT bin_ascii
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		bin : IN std_logic_vector(7 downto 0);          
		ascii_h : OUT std_logic_vector(7 downto 0);
		ascii_l : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	SIGNAL clk :  std_logic;
	SIGNAL reset :  std_logic;
	SIGNAL bin :  std_logic_vector(7 downto 0);
	SIGNAL ascii_h :  std_logic_vector(7 downto 0);
	SIGNAL ascii_l :  std_logic_vector(7 downto 0);
	   -- Clock period definitions
   constant clk_period : time := 20ns;


BEGIN
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;

	uut: bin_ascii PORT MAP(
		clk => clk,
		reset => reset,
		bin => bin,
		ascii_h => ascii_h,
		ascii_l => ascii_l
	);


-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
   	 reset <= '1';
	 wait for 100ns;
	 reset <= '0';
	 wait for 100ns;
--	 bin <= "11101110"; -- hex 
	 wait; -- will wait forever
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
