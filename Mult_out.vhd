----------------------------------------------------------------------------------
-- Company: 
-- Engineer:       Lazaridis Dimitris
-- 
-- Create Date:    22:57:38 07/25/2012 
-- Design Name: 
-- Module Name:    Mult_out - Behavioral 
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
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Mult_out is
     port (
	        clk : in std_logic;
			  rst,Mult_en : in  STD_LOGIC;
			  Mul_out_c : in STD_LOGIC_VECTOR (1 downto 0);
			  A_in : in STD_LOGIC_VECTOR (31 downto 0);
	        Hi_to_out : in STD_LOGIC_VECTOR (31 downto 0);
			  Lo_to_out : in STD_LOGIC_VECTOR (31 downto 0);
			  Hi_out : out STD_LOGIC_VECTOR (31 downto 0);
			  Lo_out : out STD_LOGIC_VECTOR (31 downto 0)
	   	  );
end Mult_out;

architecture Behavioral of Mult_out is

begin
      
		process(clk,rst,Mult_en,Mul_out_c,A_in,Hi_to_out,Lo_to_out)
		 begin
		      If (RISING_EDGE(clk)) then 
				if rst = '0' then
				    Lo_out <= (others => '0');
					 Hi_out <= (others => '0');
				else
              if Mult_en = '1' then
				  case Mul_out_c is
				    when "00" =>
				    Hi_out <= Hi_to_out;
					 Lo_out <= Lo_to_out;  
                when "01" =>
					 Lo_out <= A_in;
					 when "10" =>
					 Hi_out <= A_in;
					 when others =>
					 Hi_out <= (others => '0');
					 Lo_out <= (others => '0'); 
		          end case;
			  end if;
           END IF;
           end if;			  
		 end process;

end Behavioral;

