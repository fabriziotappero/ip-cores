--Counter with resetn and load enable 
--When load enable is high, it counts. 
--When load enable is low, it stops counting. 
--When a reset is triggered, it resets to zero. 
 
LIBRARY ieee; 
USE ieee.std_logic_1164.ALL; 
USE ieee.std_logic_arith.ALL; 
 
entity counterhle is 
  generic (  
	width: integer :=3
	); 
  port (
	clock : in std_logic; 
	resetn : in std_logic; 
	enable : in std_logic; 
	clear : in std_logic;
	countout : out std_logic_vector(width-1 downto 0)
	
    ); 
end counterhle; 
 
architecture behavior of counterhle is 
signal count : std_logic_vector(width-1 downto 0); 

begin 
process(clock,resetn,enable) 
begin 
 if (resetn='0')then 
     count <= (others => '0'); 
     
  elsif (clock'event and clock='1') then 
      if (enable = '1' ) then 
			if (clear = '1') then
				count <= (others => '0'); 
			else
           count <= unsigned(count) + '1';   
			  end if; 
   end if; 
   
 end if ; 
end process; 
countout <= count; 

end; 
