library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bin_ascii is
	port(
		clk		:in std_logic;
		reset	:in std_logic;
		bin		:in std_logic_vector(7 downto 0);
		ascii_h	:out std_logic_vector(7 downto 0);
		ascii_l	:out std_logic_vector(7 downto 0));
end bin_ascii;

architecture Behavioral of bin_ascii is

signal	Sa_L				:std_logic;
signal	Sb_L				:std_logic;
signal	Sc_L				:std_logic;
signal	Sd_L				:std_logic;
signal 	Sconvinacional_L	:std_logic;
signal 	Ssuma_L			:std_logic_vector(7 downto 0);

signal	Sa_H				:std_logic;
signal	Sb_H				:std_logic;
signal	Sc_H				:std_logic;
signal	Sd_H				:std_logic;
signal 	Sconvinacional_H	:std_logic;
signal 	Ssuma_H			:std_logic_vector(7 downto 0);

begin


--**************************************************************
-- Obtención código ascii de la parte baja
--**************************************************************
mayor_cero_L:process(clk)
begin
   if (clk'event and clk ='1') then   
      if ( bin(3 downto 0) >= "0000" ) then --si es mayor que 0 binario
         Sa_L <= '1';
      else 
         Sa_L <= '0';
      end if;
   end if; 
end process;

menor_nueve_L:process(clk)
begin
   if (clk'event and clk ='1') then   
      if ( bin(3 downto 0) <= "1001" ) then --si es menor que 9  binario
         Sb_L <= '1';
      else 
         Sb_L <= '0';
      end if;
   end if; 
end process;

mayor_10_L:process(clk)
begin
   if (clk'event and clk ='1') then   
      if ( bin(3 downto 0) >= "1010" ) then --si es mayor que 10 binario
         Sc_L <= '1';
      else 
         Sc_L <= '0';
      end if;
   end if; 
end process;

menor_F_L:process(clk)
begin
   if (clk'event and clk ='1') then   
      if ( bin(3 downto 0) <= "1111" ) then --si es menor que 15 binario
         Sd_L <= '1';
      else 
         Sd_L <= '0';
      end if;
   end if; 
end process;

--**************************************************************
-- Obtención código ascii de la parte alta
--**************************************************************
mayor_cero_H:process(clk)
begin
   if (clk'event and clk ='1') then   
      if ( bin(7 downto 4) >= "0000" ) then --si es mayor que 0 binario
         Sa_H <= '1';
      else 
         Sa_H <= '0';
      end if;
   end if; 
end process;

menor_nueve_H:process(clk)
begin
   if (clk'event and clk ='1') then   
      if ( bin(7 downto 4) <= "1001" ) then --si es menor que 9  binario
         Sb_H <= '1';
      else 
         Sb_H <= '0';
      end if;
   end if; 
end process;

mayor_10_H:process(clk)
begin
   if (clk'event and clk ='1') then   
      if ( bin(7 downto 4) >= "1010" ) then --si es mayor que 10 binario
         Sc_H <= '1';
      else 
         Sc_H <= '0';
      end if;
   end if; 
end process;

menor_15_H:process(clk)
begin
   if (clk'event and clk ='1') then   
      if ( bin(7 downto 4) <= "1111" ) then --si es menor que 15 binario
         Sd_H <= '1';
      else 
         Sd_H <= '0';
      end if;
   end if; 
end process;


--**************************************************************
-- Logica convinacional para la obtención del código ascii bajo
--**************************************************************
Sconvinacional_L<= (not(Sa_L and not Sb_L and Sc_L and Sd_L)) or (Sa_L and Sb_L and not Sc_L and Sd_L); --controla cual es el sustraendo (0 o A-10)

Ssuma_L <= "00110000" WHEN Sconvinacional_L ='1' ELSE --es el mutiplexor controlado por Sconvinacional para definir lo sumado
	     "00110111";  -- valor equivalente a el ascii 'A'

ascii_L <= bin(3 downto 0) + Ssuma_L;

--**************************************************************
-- Logica convinacional para la obtención del código ascii alto
--**************************************************************
Sconvinacional_H<= (not(Sa_H and not Sb_H and Sc_H and Sd_H)) or (Sa_H and Sb_H and not Sc_H and Sd_H); --controla cual es el sustraendo (0 o A-10)

Ssuma_H <= "00110000" WHEN Sconvinacional_H ='1' ELSE --es el mutiplexor controlado por Sconvinacional para definir lo sumado
	     "00110111";  -- valor equivalente a el ascii 'A'

ascii_H <= bin(7 downto 4) + Ssuma_H;








end Behavioral;
