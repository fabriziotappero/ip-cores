--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:47:20 05/18/2009
-- Design Name:   
-- Module Name:   /home/erwing/Projects/vhdl/rfid/tb_counterclr.vhd
-- Project Name:  rfid
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: COUNTERCLR
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
 
ENTITY tb_counterclr IS
END tb_counterclr;
 
ARCHITECTURE behavior OF tb_counterclr IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT COUNTERCLR
    PORT(
         clk : IN  std_logic;
         rst_n : IN  std_logic;
         en : IN  std_logic;
         clear : IN  std_logic;
         outcnt : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst_n : std_logic := '0';
   signal en : std_logic := '0';
   signal clear : std_logic := '0';

 	--Outputs
   signal outcnt : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10us;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: COUNTERCLR PORT MAP (
          clk => clk,
          rst_n => rst_n,
          en => en,
          clear => clear,
          outcnt => outcnt
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
      -- hold reset state for 100ms.
      wait for 100ms;	

      wait for clk_period*10;

		rst_n <= '1';
		en <= '1';
		clear <= '0';
		wait for 3ms;
		
		clear <= '1';
		wait for 30us;
		clear <= '0';
		
		wait for 5ms;


      wait;
   end process;

END;
