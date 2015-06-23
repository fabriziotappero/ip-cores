----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:34:34 06/21/2012 
-- Design Name: 
-- Module Name:    Alu_out - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Alu_out is
port (
      clk : in  STD_LOGIC;
	   rst : in  STD_LOGIC;
		I  : in std_logic_vector(31 downto 0);
		N  : in std_logic_vector(31 downto 0);
		Alu_all_in : in std_logic_vector(31 downto 0);
		M : out std_logic_vector(31 downto 0);
		Alu_out : out std_logic_vector(31 downto 0)

);

end Alu_out;

architecture Behavioral of Alu_out is

begin
      process(clk,rst,Alu_all_in)
		begin
		              if rst = '0' then 
		                       Alu_out <= (others => '0');
							elsif (RISING_EDGE(Clk))then		  
		                      Alu_out <= Alu_all_in;
									 
						  end if;
      end process;
		
		process(clk,I,N,rst)
		variable M_var,N_var,I_var : signed(31 downto 0);
		variable shift_temp : std_logic_vector(31 downto 0); 
		begin
		     N_var := signed(N);
			  shift_temp :=  to_stdlogicvector(to_bitvector(I) sla 2);
			  I_var := signed(shift_temp);
			  M_var := N_var + I_var; 
			  
			  if rst = '0' then 
		             M <= (others => '0');
			  elsif (RISING_EDGE(Clk))then		  
		             M <= std_logic_vector(M_var);
			  end if;
		end process;

end Behavioral;

