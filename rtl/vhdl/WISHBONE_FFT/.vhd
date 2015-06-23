
-- hds header_start 
--1 stage shift register, data_width bits wide. 
 
LIBRARY ieee; 
USE ieee.std_logic_1164.ALL; 
USE ieee.std_logic_arith.ALL; 
 
 
ENTITY shiftreg1 IS 
   GENERIC(  
   data_width : integer := 25      
   ); 
    PORT(  
      clock      : IN     std_logic; 
		enable		: in std_logic;
		clear       : in std_logic;
      read_data  : OUT    std_logic_vector (data_width-1 DOWNTO 0); 
      write_data : IN     std_logic_vector (data_width-1 DOWNTO 0); 
      resetn     : IN     std_logic 
   ); 
 
-- Declarations 
 
END shiftreg1 ; 
 
-- hds interface_end 
ARCHITECTURE behavior OF shiftreg1 IS 
--signal reg00 : std_logic_vector(data_width-1 downto 0); 
BEGIN 
process(Clock,resetn) 
begin
if (resetn='0') then 
--      for                i in data_width-1 downto 0 loop 
--    r eg00(i)<='0'; 
     read_data <= (others => '0'); 
--     end loop;  
  elsif (Clock'event and Clock='1') then 
     
	  if (enable='1') then

		if(clear ='1') then
--    reg00<=write_data; 
--   read _data<=reg00; 
   read_data <= (others => '0'); 
	
	else 
	read_data  <= write_data;     
	  
	
  end if;
  end if;
  end if; 
end process; 
END behavior; 
