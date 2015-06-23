--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:52:32 05/14/2011
-- Design Name:   
-- Module Name:   /home/omar/LineFPGA/Bresenhammer_Sim.vhd
-- Project Name:  LineFPGA
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Bresenhamer
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY Bresenhammer_Sim IS
END Bresenhammer_Sim;
 
ARCHITECTURE behavior OF Bresenhammer_Sim IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Bresenhamer
    PORT(
         WriteEnable : OUT  std_logic;
         X : OUT  std_logic_vector(9 downto 0);
         Y : OUT  std_logic_vector(8 downto 0);
         X1 : IN  std_logic_vector(9 downto 0);
         Y1 : IN  std_logic_vector(8 downto 0);
         X2 : IN  std_logic_vector(9 downto 0);
         Y2 : IN  std_logic_vector(8 downto 0);
         SS : OUT  std_logic_vector(3 downto 0);
         Clk : IN  std_logic;
         StartDraw : IN  std_logic;
			dbg : out  STD_LOGIC_VECTOR (10 downto 0);
         Reset : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal X1 : std_logic_vector(9 downto 0) := (others => '0');
   signal Y1 : std_logic_vector(8 downto 0) := (others => '0');
   signal X2 : std_logic_vector(9 downto 0) := (others => '0');
   signal Y2 : std_logic_vector(8 downto 0) := (others => '0');
   signal Clk : std_logic := '0';
   signal StartDraw : std_logic := '0';
   signal Reset : std_logic := '0';

 	--Outputs
   signal WriteEnable : std_logic;
   signal X : std_logic_vector(9 downto 0);
   signal Y : std_logic_vector(8 downto 0);
   signal SS : std_logic_vector(3 downto 0);
	signal dbg : STD_LOGIC_VECTOR (10 downto 0);

   -- Clock period definitions
   constant Clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Bresenhamer PORT MAP (
          WriteEnable => WriteEnable,
          X => X,
          Y => Y,
          X1 => X1,
          Y1 => Y1,
          X2 => X2,
          Y2 => Y2,
          SS => SS,
          Clk => Clk,
          StartDraw => StartDraw,
			 dbg => dbg,
          Reset => Reset
        );

   -- Clock process definitions
   Clk_process :process
   begin
		Clk <= '0';
		wait for Clk_period/2;
		Clk <= '1';
		wait for Clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      StartDraw <= '1';
		X1 <= "0100000000";
		Y1 <= "010000111";
		X2 <= "0101001100";
		Y2 <= "010000000";
		Reset <= '0';
		wait for Clk_period*2;
		StartDraw <= '0';
      wait;
   end process;

END;
