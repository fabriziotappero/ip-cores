
-- VHDL Test Bench Created from source file filt_test_system.vhd -- 13:41:17 03/25/2005
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

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT filt_test_system
	PORT(
		clock : IN std_logic;
		reset : IN std_logic;
		adaption_enable : IN std_logic;          
		error_led_out : OUT std_logic_vector(7 downto 0);
		seg_select : OUT std_logic_vector(3 downto 0);
		error_freq_out : OUT std_logic;
          reset_clk : in std_logic;
		filt_data_out : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	SIGNAL clock :  std_logic;
	SIGNAL error_led_out :  std_logic_vector(7 downto 0);
	SIGNAL seg_select :  std_logic_vector(3 downto 0);
	SIGNAL error_freq_out :  std_logic;
	SIGNAL filt_data_out :  std_logic_vector(7 downto 0);
	SIGNAL reset :  std_logic;
     signal reset_clk : std_logic;
	SIGNAL adaption_enable :  std_logic;

	CONSTANT clk_high   : time := 10 ns;
	CONSTANT clk_low    : time := 10 ns;
	CONSTANT clk_period : time := 20 ns;
	CONSTANT clk_hold   : time := 4 ns;




BEGIN

	uut: filt_test_system PORT MAP(
		clock => clock,
		error_led_out => error_led_out,
		seg_select => seg_select,
		error_freq_out => error_freq_out,
		filt_data_out => filt_data_out,
		reset => reset,
		reset_clk => reset_clk,
		adaption_enable => adaption_enable
	);


-- *** Test Bench - User Defined Section ***
   clk_gen: PROCESS
   BEGIN
	    clock <= '1';
	    WAIT FOR clk_high;
	    clock <= '0';
	    WAIT FOR clk_low;

   END PROCESS clk_gen;

   reset_gen: process
   begin
   		reset <= '0';
		reset_clk <= '0';
		wait for clk_period*2;
 		reset_clk <= '1';
		adaption_enable <= '1';
		wait for clk_period*10;
		reset <= '1';

   wait;
   end process reset_gen;
-- *** End Test Bench - User Defined Section ***

END;
