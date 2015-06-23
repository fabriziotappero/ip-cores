--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:59:34 11/08/2009
-- Design Name:   
-- Module Name:   C:/Users/microcon/bench/tb_bus_register_x16.vhd
-- Project Name:  microcon
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: bus_register_x16
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY tb_bus_register_x16 IS
END tb_bus_register_x16;
 
ARCHITECTURE behavior OF tb_bus_register_x16 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT bus_register_x16
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         re : IN  std_logic;
         we : IN  std_logic;
         dataIn : IN  std_logic_vector(15 downto 0);
         dataOut : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal re : std_logic_vector(1 to 3) := "000";
   signal we : std_logic_vector(1 to 3) := "000";
   signal dataBus : std_logic_vector(15 downto 0) := (others => '0');

   -- Clock period definitions
   constant clk_period : time := 50 us;
   signal dataBusIn : std_logic_vector(15 downto 0) := (others => '0');
	signal wef: std_logic := '0';
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
	uut_force: bus_register_x16 port map (
          clk => clk,
          reset => reset,
          re => '1',
          we => wef,
          dataIn => dataBusIn,
          dataOut => dataBus
        );
		  
   uut1: bus_register_x16 PORT MAP (
          clk => clk,
          reset => reset,
          re => re(1),
          we => we(1),
          dataIn => dataBus,
          dataOut => dataBus
        );
		  
	uut2: bus_register_x16 PORT MAP (
          clk => clk,
          reset => reset,
          re => re(2),
          we => we(2),
          dataIn => dataBus,
          dataOut => dataBus
        );
		  
	uut3: bus_register_x16 PORT MAP (
          clk => clk,
          reset => reset,
          re => re(3),
          we => we(3),
          dataIn => dataBus,
          dataOut => dataBus
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
		reset <= '1';
      -- hold reset state for 100us.
      wait for 100 us;
		reset <= '0';	
		
		dataBusIn <= x"ffee";
		wef <= '1';
		re <= "000";
		we <= "000";
      wait for clk_period;
		
		re <= "010";
		we <= "000";
      wait for clk_period;
		
		dataBusIn <= x"1001";
		wef <= '0';
		re <= "000";
		we <= "000";
      wait for clk_period;
		
		re <= "001";
		we <= "010";
      wait for clk_period;
		
		re <= "100";
		we <= "001";
      wait for clk_period;
		
		dataBusIn <= x"1001";
		wef <= '1';
		re <= "100";
		we <= "000";
      wait for clk_period;
		
		re <= "010";
		we <= "100";
      wait for clk_period;
      wait;
   end process;

END;
