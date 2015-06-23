----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:00:20 06/19/2012 
-- Design Name: 
-- Module Name:    Ext_sz - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Ext_sz is
port (
      clk : in  STD_LOGIC;
	   rst : in  STD_LOGIC;
      immed_addr : in std_logic_vector(15 downto 0);
		Ext_sz_c   : in std_logic;
      Ext_sz     : out std_logic_vector(31 downto 0)


);          
end Ext_sz;

architecture Behavioral of Ext_sz is
shared variable Ext_internal : std_logic_vector(31 downto 0);

begin
       process(Ext_sz_c,immed_addr)
		 variable sign_c : std_logic_vector(15 downto 0) := "0000000000000000";	
        variable sign_exit : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";			 
		 begin
		       case Ext_sz_c is
             when '0' => 
                     sign_c(0 downto 0) := immed_addr(15 downto 15);
							for I in 1 to 15 loop
							sign_c(I) := sign_c(0);
							end loop;
							sign_exit(31 downto 16) := sign_c(15 downto 0);
                     sign_exit(15 downto 0) := immed_addr(15 downto 0);
				 when '1' =>
				         sign_exit(31 downto 16) := "0000000000000000";
							sign_exit(15 downto 0) := immed_addr(15 downto 0);

             when others => sign_exit := (others =>'0');							
             end case;				 
		       
		       Ext_internal := sign_exit;
		 end process;
		 
		 process(clk,rst)
		 begin
		       if rst = '0' then 
				           Ext_sz  <= (others => '0');
				 elsif (RISING_EDGE(Clk))then
				         Ext_sz <= Ext_internal;
             end if;							
		 end process;
       

end Behavioral;

