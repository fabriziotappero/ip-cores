---------------------------------------------------------------------
-- vga_main.vhd  Demo VGA configuration module.
---------------------------------------------------------------------
-- 	Author: Barron Barnett
--            Copyright 2004 Digilent, Inc.
---------------------------------------------------------------------
--
-- This project is compatible with Xilinx ISE or Xilinx WebPack tools.
--
-- Inputs: 
--		mclk  - System Clock
-- Outputs:
--		hs		- Horizontal Sync
--		vs		- Vertical Sync
--		red	- Red Output
--		grn	- Green Output
--		blu	- Blue Output
--
-- This module creates a three line pattern on a vga display using a
-- a vertical refresh rate of 60Hz.  This is done by dividing the
-- system clock in half and using that for the pixel clock.  This in
-- turn drives the vertical sync when the horizontal sync has reached
-- its reset point.  All data displayed is done by basic value
-- comparisons.
------------------------------------------------------------------------
-- Revision History:
--	 07/01/2004(BarronB): created
------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity vgaController is
    Port ( mclk : in std_logic;
           hs : out std_logic;
           vs : out std_logic;
           red : out std_logic;
           grn : out std_logic;
           blu : out std_logic);
end vgaController;

architecture Behavioral of vgaController is


	constant hpixels		: std_logic_vector(9 downto 0) := "1100100000";	 --Value of pixels in a horizontal line
	constant vlines		: std_logic_vector(9 downto 0) := "1000001001";	 --Number of horizontal lines in the display
	
	constant hbp			: std_logic_vector(9 downto 0) := "0010010000";	 --Horizontal back porch
	constant hfp			: std_logic_vector(9 downto 0) := "1100010000";	 --Horizontal front porch
	constant	vbp			: std_logic_vector(9 downto 0) := "0000011111";	 --Vertical back porch
	constant vfp			: std_logic_vector(9	downto 0) := "0111111111";	 --Vertical front porch
	
	signal hc, vc			: std_logic_vector(9 downto 0);						 --These are the Horizontal and Vertical counters
	signal clkdiv			: std_logic;												 --Clock divider
	signal vidon			: std_logic;												 --Tells whether or not its ok to display data
	signal vsenable		: std_logic;												 --Enable for the Vertical counter

begin
	--This cuts the 50Mhz clock in half
	process(mclk)
		begin
			if(mclk = '1' and mclk'EVENT) then
				clkdiv <= not clkdiv;
			end if;
		end process;																			

	--Runs the horizontal counter
	process(clkdiv)
		begin
			if(clkdiv = '1' and clkdiv'EVENT) then
				if hc = hpixels then														 --If the counter has reached the end of pixel count
					hc <= "0000000000";													 --reset the counter
					vsenable <= '1';														 --Enable the vertical counter to increment
				else
					hc <= hc + 1;															 --Increment the horizontal counter
					vsenable <= '0';														 --Leave the vsenable off
				end if;
		end if;
	end process;

	hs <= '1' when hc(9 downto 7) = "000" else '0';								 --Horizontal Sync Pulse

	process(clkdiv)
	begin
		if(clkdiv = '1' and clkdiv'EVENT and vsenable = '1') then			 --Increment when enabled
			if vc = vlines then															 --Reset when the number of lines is reached
				vc <= "0000000000";
			else vc <= vc + 1;															 --Increment the vertical counter
			end if;
		end if;
	end process;

	vs <= '1' when vc(9 downto 1) = "000000000" else '0';						 --Vertical Sync Pulse

  	red <= '1' when (hc = "1010101100" and vidon ='1') else '0';			 --Red pixel on at a specific horizontal count
  	grn <= '1' when (hc = "0100000100" and vidon ='1') else '0';			 --Green pixel on at a specific horizontal count
  	blu <= '1' when (vc = "0100100001" and vidon ='1') else '0';			 --Blue pixel on at a specific vertical count

	vidon <= '1' when (((hc < hfp) and (hc > hbp)) or ((vc < vfp) and (vc > vbp))) else '0';	--Enable video out when within the porches

end Behavioral;
