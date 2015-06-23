----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:01:23 07/26/2009 
-- Design Name: 
-- Module Name:    my_mux - Behavioral 
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
--library gaisler;
--use gaisler.libiu.all; 
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity my_mux is
    Port ( a : in  STD_LOGIC_VECTOR (31 downto 0);
           b : in  STD_LOGIC_VECTOR (31 downto 0);
           c : in  STD_LOGIC_VECTOR (31 downto 0);
           d : in  STD_LOGIC_VECTOR (31 downto 0);
           sel : in  STD_LOGIC_VECTOR (1 downto 0);
           res : out  STD_LOGIC_VECTOR (31 downto 0));
end my_mux;

architecture RTL of my_mux is
begin
 SEL_PROCESS:process (a,b,c,d,sel)
 begin
	case sel is 
		when "00" => res<=a;
		when "01" => res<=b;
		when "10" => res<=c;
		when others => res<=d;
	end case; 
end process SEL_PROCESS;
end RTL;	
