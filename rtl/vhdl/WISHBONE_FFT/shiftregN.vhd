-- hds  header_start 
-- age shift registe -n st                    r, data_width bits wide. 
 
LIBRARY    ieee   ;
USE ieee.std_logic_1164.ALL; 
USE ieee.std_logic_arith.ALL; 
 
 
ENTITY shiftregN IS 
   GENERIC(  
      data_width : integer := 25; 
      n   : integer := 254 
   ); 
   PORT(  
      clock      : IN     std_logic; 
		enable		: in std_logic;		
      read_data  : OUT    std_logic_vector (data_width-1 DOWNTO 0); 
      write_data : IN     std_logic_vector (data_width-1 DOWNTO 0); 
      resetn     : IN     std_logic 
   ); 
 
-- Declarations 
 
END shiftregN ; 
 
-- hds interface_end 
ARCHITECTURE behavior OF shiftregN IS   

type regArray is array (0 to n) of std_logic_vector(data_width-1 downto 0);  
 
signal registerFile  : regArray; 

component shiftreg1 IS 
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
 
END component;
BEGIN  

registerFile(0)<=write_data;
read_data<=registerFile(n);

registers: for i in 0 to n-1 generate

regi: shiftreg1 generic map(
data_width=>data_width

)
port map(
clock=>clock,
		enable=>enable,
		clear=>'0',
      read_data=>registerFile(i+1),
      write_data=>registerFile(i),
      resetn=>resetn

);

end generate;
 
END behavior; 
