----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:18:47 05/21/2012 
-- Design Name: 
-- Module Name:    Or_tree - Behavioral 
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
use IEEE.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Or_tree is
Generic (
         busw : integer := 31
);
Port ( Mux_out : in  STD_LOGIC_VECTOR (busw downto 0);
       Zero : out  STD_LOGIC
	  );
end Or_tree;

architecture Behavioral of Or_tree is

begin
     
	  Zero <= '1' WHEN ( Mux_out (31 DOWNTO 0) = x"00000000") ELSE '0';

end Behavioral;

