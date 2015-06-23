----------------------------------------------------------------------------------
-- Company: SDU, Robolab, Denmark
-- Engineer: Simon Falsig
-- 
-- Create Date:    15:49:43 04/01/2008 
-- Design Name: 
-- Module Name:    commandpack - Behavioral 
-- Project Name:	 TosNet Datalink Layer
-- Target Devices: Xilinx Spartan3
-- Tool versions:  ISE 9.2.04i
-- Description: 
--		Contains the commands used for the network.
--
-- Dependencies:
--
-- Revision: 
-- Revision 1.00 - Working!
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

package commandpack is
	constant CMD_IDLE			: STD_LOGIC_VECTOR(3 downto 0) := "0000";
	constant CMD_MASTER_DSC	: STD_LOGIC_VECTOR(3 downto 0) := "0010";
	constant CMD_MASTER_SET	: STD_LOGIC_VECTOR(3 downto 0) := "0011";
	constant CMD_NET_DSC		: STD_LOGIC_VECTOR(3 downto 0) := "0100";
	constant CMD_NET_SET		: STD_LOGIC_VECTOR(3 downto 0) := "0101";
	constant CMD_REG_DSC		: STD_LOGIC_VECTOR(3 downto 0) := "0110";
	constant CMD_REG_SET		: STD_LOGIC_VECTOR(3 downto 0) := "0111";
	constant	CMD_SYNC_DSC	: STD_LOGIC_VECTOR(3 downto 0) := "1000";
	constant	CMD_SYNC_SET	: STD_LOGIC_VECTOR(3 downto 0) := "1001";
	constant	CMD_DATA			: STD_LOGIC_VECTOR(3 downto 0) := "1010";
	constant CMD_HALT			: STD_LOGIC_VECTOR(3 downto 0) := "1111";
end commandpack;

