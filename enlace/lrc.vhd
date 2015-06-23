----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:41:27 03/30/2010 
-- Design Name: 
-- Module Name:    lrc - Behavioral 
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

entity lrc is
	port(
			clk		:in std_logic;
			reset	:in std_logic;
			trama	:in std_logic;
			dato_ok	:in std_logic;
			dato		:in std_logic_vector(7 downto 0);
			lrc_ok	:out std_logic);
end lrc;

architecture Behavioral of lrc is

signal acumulador : std_logic_vector(7 downto 0);
begin
	
SUMADOR:process (clk,reset) 
begin
   if reset='1' then 
	 acumulador <= (others=>'0');
   elsif clk ='1' and clk'event then
   		if trama = '1' then
	 		if dato_ok='1'then --tener presente que data_ok debe permanecer SOLO 1 clk
         			acumulador <= acumulador + dato;
   			end if;
		elsif acumulador = "00000000" then
	 		lrc_ok <= '1';
		else
			lrc_ok <= '0';
		end if;
   end if;
end process SUMADOR;
		
end Behavioral;

