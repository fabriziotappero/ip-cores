LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY MP_struct_TB IS
END MP_struct_TB;
 
ARCHITECTURE behavior OF MP_struct_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT MP
    PORT(
         clk : IN  std_logic;
         clr : IN  std_logic;
         hlt : OUT  std_logic;
         q3 : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal clr : std_logic := '0';

 	--Outputs
   signal hlt : std_logic;
   signal q3 : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 500 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: MP PORT MAP (
          clk => clk,
          clr => clr,
          hlt => hlt,
          q3 => q3
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
		clr <= '1';
      wait for 2430 ns;	
		clr <= '0';
      wait for clk_period*20;

      -- insert stimulus here 

      wait;
   end process;

END;
