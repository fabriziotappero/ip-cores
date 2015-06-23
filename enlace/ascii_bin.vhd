----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:17:44 03/31/2010 
-- Design Name: 
-- Module Name:    ascii_bin - Behavioral 
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

entity ascii_bin is
	port(
			clk			:in std_logic;
			reset		:in std_logic;
			ascii		:in std_logic_vector(7 downto 0);
			new_data		:in std_logic;
			Nnew_data		:out std_logic;			
			bin			:out std_logic_vector(7 downto 0));
end ascii_bin;

architecture Behavioral of ascii_bin is
signal	Sa	:std_logic:='0';
signal	Sb	:std_logic:='0';
signal	Sc	:std_logic:='0';
signal	Sd	:std_logic:='0';
signal	Ssustraendo:std_logic_vector(7 downto 0):=(others => '0');
signal	Sconvinacional:std_logic:='0';
signal	Q1	:std_logic:='0';

begin

mayor_cero:process(clk)
begin
   if (clk'event and clk ='1') then   
      if ( ascii >= "00110000" ) then --si es mayor que 0 (ASCII)
         Sa <= '1';
      else 
         Sa <= '0';
      end if;
   end if; 
end process;

menor_nueve:process(clk)
begin
   if (clk'event and clk ='1') then   
      if ( ascii <= "00111001" ) then --si es menor que 9 (ASCII)
         Sb <= '1';
      else 
         Sb <= '0';
      end if;
   end if; 
end process;

mayor_A:process(clk)
begin
   if (clk'event and clk ='1') then   
      if ( ascii >= "01000001" ) then --si es mayor que A (ASCII)
         Sc <= '1';
      else 
         Sc <= '0';
      end if;
   end if; 
end process;

menor_F:process(clk)
begin
   if (clk'event and clk ='1') then   
      if ( ascii <= "01000110" ) then --si es menor que 9 (ASCII)
         Sd <= '1';
      else 
         Sd <= '0';
      end if;
   end if; 
end process;

Sconvinacional<= (not(Sa and not Sb and Sc and Sd)) or (Sa and Sb and not Sc and Sd); --controla cual es el sustraendo (0 o A-10)

Ssustraendo<= "00110000" WHEN Sconvinacional ='1' ELSE --es el mutiplexor controlado por Sconvinacional para definir el sustraendo en la resta
			"00110111";
bin <= ascii - Ssustraendo;

process(clk, reset)
begin
  if (reset = '1') then
    Q1 <= '0';
  elsif (clk'event and clk = '1') then
    Q1 <= new_data;
    Nnew_data <= Q1;
  end if;
end process;

end Behavioral;

