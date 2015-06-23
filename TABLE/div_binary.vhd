library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 


entity div_binary is 
Port ( 

ina : in std_logic_vector (11 downto 0);
inb: in std_logic_vector (11 downto 0);
quot: out std_logic_vector (11 downto 0)
);

end div_binary; 

architecture Behavioral of div_binary is 

signal a,b: integer range 0 to 65535; 
begin 

a <= CONV_INTEGER(ina); 
b <= CONV_INTEGER(inb); 
process (a,b) 

variable temp1,temp2: integer range 0 to 65535; 
variable y : std_logic_vector (11 downto 0); 
begin 
temp1:=a; 
temp2:=b; 
for i in 11 downto 0 loop 
if (temp1>temp2 * 2**i) then 
y(i):= '1'; 
temp1:= temp1- temp2 * 2**i; 
else y(i):= '0'; 
end if; 
end loop; 
quot<= y; 
--quot<= conv_integer (y); 
end process; 


end Behavioral;