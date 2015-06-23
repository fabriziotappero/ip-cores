--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:16:45 08/22/2009
-- Design Name:   
-- Module Name:   /home/yann/fpga/work/pdp1-3/ptr_test.vhd
-- Project Name:  pdp1-3
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: papertapereader
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
 
ENTITY ptr_test IS
END ptr_test;
 
ARCHITECTURE behavior OF ptr_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT papertapereader
    PORT(
         clk : IN  std_logic;
         dopulse : IN  std_logic;
         done : OUT  std_logic;
         io : OUT  std_logic_vector(0 to 17);
         io_loaded : IN  std_logic;
         ptr_rpa : IN  std_logic;
         ptr_rpb : IN  std_logic;
         ptr_rrb : IN  std_logic;
         rb_loaded : OUT  std_logic;
         RXD : IN  std_logic;
         TXD : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal dopulse : std_logic := '0';
   signal io_loaded : std_logic := '0';
   signal ptr_rpa : std_logic := '0';
   signal ptr_rpb : std_logic := '0';
   signal ptr_rrb : std_logic := '0';
   signal RXD : std_logic := '1';

 	--Outputs
   signal done : std_logic;
   signal io : std_logic_vector(0 to 17);
   signal rb_loaded : std_logic;
   signal TXD : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: papertapereader PORT MAP (
          clk => clk,
          dopulse => dopulse,
          done => done,
          io => io,
          io_loaded => io_loaded,
          ptr_rpa => ptr_rpa,
          ptr_rpb => ptr_rpb,
          ptr_rrb => ptr_rrb,
          rb_loaded => rb_loaded,
          RXD => RXD,
          TXD => TXD
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
		constant bittime : time := 8.680555us;
   begin		
      -- hold reset state for 100ms.
      --wait for 100ms;
		wait for 2*bittime;
		ptr_rpb <= '1'; dopulse <= '1';
		wait for clk_period;
		ptr_rpb <= '0'; dopulse <= '0';

		wait for 16*bittime;
		-- TODO: show reply data
		RXD <= '0'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '1'; wait for bittime;		-- first sixbit 000101
		wait for 16*bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '1'; wait for bittime;				-- this byte is not marked as binary data and should be skipped
		wait for 16*bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '1'; wait for bittime;		-- second sixbit 001100
		wait for 16*bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '1'; wait for bittime;		-- third sixbit 111000

      --wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
