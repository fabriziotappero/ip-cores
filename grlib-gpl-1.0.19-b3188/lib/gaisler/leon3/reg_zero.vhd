library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity reg_zero is 
Port(
      address:in std_logic_vector(4 downto 0);
      we_o:   in std_logic;
      address_o:  out std_logic_vector(4 downto 0);
      we_o1:  out std_logic
) ;
end reg_zero;

architecture behavioural of reg_zero is
signal addr1:std_logic_vector(4 downto 0);

begin
addr1<=address;   
process (addr1)
    variable i:integer:=0;
    
    begin   
      if (((addr1(0) = '0') and (addr1(1)='0') and (addr1(2) = '0') and(addr1(3) = '0') and (addr1(4) = '0'))and(i=0)) then
        we_o1<='1' after 0ns,'0' after 200ns;
         i:=1;

      elsif  ((addr1(0) = '0') and (addr1(1)='0') and (addr1(2) = '0') and(addr1(3) = '0') and (addr1(4) = '0'))  then 
         we_o1<='0';
      else
         we_o1 <= we_o;
end if;
end process;
address_o<=address;
end behavioural;