----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Léo Germond
-- 
-- Create Date:    19:21:58 11/04/2009 
-- Design Name: 
-- Module Name:    rdecal_x16 - Behavioral 
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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rdecal_x16 is
    Port ( data : in  STD_LOGIC_VECTOR (15 downto 0);
           decal_lvl : in  STD_LOGIC_VECTOR (3 downto 0);
           decal : out  STD_LOGIC_VECTOR (15 downto 0));
end rdecal_x16;


architecture BarrelShifter of rdecal_x16 is
	
	signal din: STD_LOGIC_VECTOR (15 downto 0);
	signal dout: STD_LOGIC_VECTOR (15 downto 0);
	
	signal dec1: STD_LOGIC_VECTOR (15 downto 0);
	signal dec2: STD_LOGIC_VECTOR (15 downto 0);
	signal dec3: STD_LOGIC_VECTOR (15 downto 0);
	
	component generic_const_rdecal_x16
		generic ( BIT_DECAL : natural range 0 to 15 );
		Port ( data : in  STD_LOGIC_VECTOR (15 downto 0);
           en : in  STD_LOGIC;
           decal : out  STD_LOGIC_VECTOR (15 downto 0));	
	end component;
begin
	d1 : generic_const_rdecal_x16 
		generic map(BIT_DECAL => 1) 
		port map( data => din, en => decal_lvl(0), decal => dec1);
	
	d2 : generic_const_rdecal_x16 
		generic map(BIT_DECAL => 2)  
		port map( data => dec1, en => decal_lvl(1), decal => dec2);
	
	d3 : generic_const_rdecal_x16 
		generic map(BIT_DECAL => 4) 
		port map( data => dec2, en => decal_lvl(2), decal => dec3);
	
	d4 : generic_const_rdecal_x16 
		generic map(BIT_DECAL => 8) 
		port map( data => dec3, en => decal_lvl(3), decal => dout);
		
		din <= data;
		decal <= dout;
end BarrelShifter;
