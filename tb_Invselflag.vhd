--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:58:53 05/18/2009
-- Design Name:   
-- Module Name:   /home/erwing/Projects/vhdl/rfid/tb_Invselflag.vhd
-- Project Name:  rfid
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: InvSelFlag
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
 
ENTITY tb_Invselflag IS
END tb_Invselflag;
 
ARCHITECTURE behavior OF tb_Invselflag IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT InvSelFlag
    PORT(
         S1i : IN  std_logic;
         S2i : IN  std_logic;
         S3i : IN  std_logic;
         SLi : IN  std_logic;
         S1o : OUT  std_logic;
         S2o : OUT  std_logic;
         S3o : OUT  std_logic;
         SLo : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal S1i : std_logic := '0';
   signal S2i : std_logic := '0';
   signal S3i : std_logic := '0';
   signal SLi : std_logic := '0';

 	--Outputs
   signal S1o : std_logic;
   signal S2o : std_logic;
   signal S3o : std_logic;
   signal SLo : std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: InvSelFlag PORT MAP (
          S1i => S1i,
          S2i => S2i,
          S3i => S3i,
          SLi => SLi,
          S1o => S1o,
          S2o => S2o,
          S3o => S3o,
          SLo => SLo
        );
 
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   constant <clock>_period := 1ns;
 
   <clock>_process :process
   begin
		<clock> <= '0';
		wait for <clock>_period/2;
		<clock> <= '1';
		wait for <clock>_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100ms.
      wait for 100ms;	

      wait for <clock>_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
