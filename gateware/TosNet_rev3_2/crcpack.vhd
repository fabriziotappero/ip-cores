----------------------------------------------------------------------------------
-- Company: SDU, Robolab, Denmark
-- Engineer: Simon Falsig
-- 
-- Create Date:    15:49:43 04/01/2008 
-- Design Name: 
-- Module Name:    crcpack - Behavioral 
-- Project Name:	 TosNet Datalink Layer
-- Target Devices: Xilinx Spartan3
-- Tool versions:  ISE 9.2.04i
-- Description: 
--		Adapted from "Parallel CRC Realization", by Guiseppe Campobello, Guiseppe 
--		Patanè and Marco Russo, IEEE Transactions on Computers, Vol.52, No.10, 
--		October 2003.
--		Adjustments have been made to the layout, and the reset has been converted
--		to a synchronous reset instead of the asynchronous reset from the original
--		paper.
--
-- Dependencies:
--		crcgen.vhd			(Contains implementation)
--
-- Revision: 
-- Revision 1.00 - Working!
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package crcpack is
	constant CRC16 		: std_logic_vector(16 downto 0) := "11000000000000101";
	constant CRCXA6		: std_logic_vector(8 downto 0) := "101100101";
	constant CRCDIM		: integer := 8;
	constant CRC 			: std_logic_vector(CRCDIM downto 0) := CRCXA6;
	constant DATA_WIDTH	: integer range 1 to CRCDIM := 8;
	type matrix is array (CRCDIM - 1 downto 0) of std_logic_vector (CRCDIM - 1 downto 0);
end crcpack ;

