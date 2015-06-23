----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:44:27 02/19/2007 
-- Design Name: 
-- Module Name:    regfile - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.types.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity regfile is
    Port ( addr1 : in  STD_LOGIC_VECTOR (4 downto 0);
           addr2 : in  STD_LOGIC_VECTOR (4 downto 0);
           dout1 : out  STD_LOGIC_VECTOR (31 downto 0);
           dout2 : out  STD_LOGIC_VECTOR (31 downto 0);
           addrw : in  STD_LOGIC_VECTOR (4 downto 0);
           din : in  STD_LOGIC_VECTOR (31 downto 0);
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC);
end regfile;

architecture Behavioral of regfile is

component dist_mem
	port (
	a: IN std_logic_VECTOR(4 downto 0);
	d: IN std_logic_VECTOR(31 downto 0);
	dpra: IN std_logic_VECTOR(4 downto 0);
	clk: IN std_logic;
	we: IN std_logic;
	spo: OUT std_logic_VECTOR(31 downto 0);
	dpo: OUT std_logic_VECTOR(31 downto 0));
end component;

signal out1: std_logic_VECTOR(31 downto 0);
signal out2: std_logic_VECTOR(31 downto 0);

--signal qin: std_logic_VECTOR(31 downto 0);


begin

	reg1: dist_mem
	port map (
	a => addrw,
	d => din,
	dpra => addr1,
	clk => clk,
	we => '1',
--	spo: OUT std_logic_VECTOR(31 downto 0);
	dpo => out1);

	reg2: dist_mem
	port map (
	a => addrw,
	d => din,
	dpra => addr2,
	clk => clk,
	we => '1',
--	spo: OUT std_logic_VECTOR(31 downto 0);
	dpo => out2);

	
--	reg2: regmem
--	port map (
--	addra => addr2,
--	addrb => addrw,
--	clka => clk,
--	clkb => clk,
--	dinb => din,
--	douta => out2,
--	web => '1');

	dout1 <= din when addr1 = addrw else out1;
	dout2 <= din when addr2 = addrw else out2;
	
end Behavioral;

