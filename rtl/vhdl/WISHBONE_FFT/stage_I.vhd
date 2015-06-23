--Component for Stages using BF2I (first and every odd stage) 
--Doesn't handle last stage 
--Input is a standard logic vector of       data_width-add_g 
--data_width - width of the internal busses 
--add_g - Add growth variable - if 1, data      _width grows by   1, if 0 then 0 
-- t_stages number of shift -shif  register stages 
 
library IEEE; 
use IEEE.std_logic_1164.all; 
use ieee.std_logic_arith.all; 
 
entity stage_I is 
generic  (  
		data_width : INTEGER :=13; 
		add_g : INTEGER := 1; 
		shift_stages : INTEGER := 32 
  ); 
port  (  
		prvs_r :in std_logic_vector(data_width-1-add_g downto 0); 
		prvs_i :in std_logic_vector(data_width-1-add_g downto 0); 
		s :in std_logic; 
		clock : in std_logic; 
		resetn : in std_logic; 
		enable		: in std_logic;	
		tonext_r :out std_logic_vector(data_width-1 downto 0);    
		tonext_i :out std_logic_vector(data_width-1 downto 0)  
  ); 
end stage_I; 
 
architecture structure of stage_I is 

signal toreg_r : std_logic_vector(data_width-1 downto 0); 
signal toreg_i : std_logic_vector(data_width-1 downto 0); 
signal fromreg_r : std_logic_vector(data_width-1 downto 0); 
signal fromreg_i : std_logic_vector(data_width-1 downto 0); 

signal tonext_r_aux : std_logic_vector(data_width-1 downto 0); 
signal tonext_i_aux : std_logic_vector(data_width-1 downto 0); 
 
component shiftregN 
  generic (
		data_width : integer; 
		n : integer
		); 
  port  (
		clock : IN std_logic; 
		enable		: in std_logic;	
          read_data  : OUT    std_logic_vector (data_width-1 DOWNTO 0); 
          write_data : IN     std_logic_vector (data_width-1 DOWNTO 0 ); 
          resetn     : IN     std_logic 
         ); 
end component; 

component shiftreg1 
  generic (
		data_width : integer
); 
  port (
		clock : IN std_logic;  
		enable: in std_logic; 
		clear: in std_logic; 
        read_data  : OUT    std_logic_vector (data_width-1 DOWNTO 0); 
        write_data : IN     std_logic_vector (data_width-1 DOWNTO 0); 
		resetn     : IN     std_logic          
		); 
end component; 
 
 
component BF2I 
  generic (
	data_width : INTEGER; 
	add_g: INTEGER
	); 
  port    (
	fromreg_r :in std_logic_vector(data_width-1 downto 0); 
	fromreg_i :in std_logic_vector(data_width-1 downto 0); 
	prvs_r :in std_logic_vector(data_width-add_g-1 downto 0	); 
	prvs_i :in std_logic_vector(data_width-add_g-1 downto 0); 
    s : in std_logic; 
    toreg_r :out std_logic_vector(data_width-1 downto 0);   
    toreg_i :out std_logic_vector(data_width-1 downto 0);  
	tonext_r :out std_logic_vector(data_width-1 downto 0);    
    tonext_i :out std_logic_vector(data_width-1 downto 0)  
    ); 
end component; 
 
begin 
regr : shiftregN 
  generic map (
	data_width=>data_width, 
	n=>shift_stages
	) 
  port map ( 
clock=>clock, 
enable=>enable,
read_data=>fromreg_r, 
write_data=>toreg_r, 
resetn=>resetn
); 

regi : shiftregN 
  generic map (
	data_width=>data_width, 
	n=>shift_stages
	) 
port map (
	clock=>clock, 
	enable=>enable,
	read_data=>fromreg_i, 
	write_data=>toreg_i, 
	resetn=>resetn
	); 
	
btrfly : BF2I 
  generic map (
	data_width=>data_width, 
	add_g=>add_g
	)    
  port map (
	fromreg_r=>fromreg_r, 
	fromreg_i=>fromreg_i, 
    prvs_r=>prvs_r,  
	prvs_i=>prvs_i, 
    s=>s, 
    toreg_r=>toreg_r, 
	toreg_i=>toreg_i, 
    tonext_r=>tonext_r_aux, 
	tonext_i=>tonext_i_aux
	); 
	

regsegr : shiftreg1
  generic map (
	data_width=>data_width
	
	) 
port map (
	clock=>clock, 
	enable=>'1',
	clear=>'0',
	read_data=>tonext_r, 
	write_data=>tonext_r_aux, 
	resetn=>resetn
	); 
		
regsegi : shiftreg1
  generic map (
	data_width=>data_width
	
	) 
port map (
	clock=>clock, 
	enable=>'1',
	clear=>'0',
	read_data=>tonext_i, 
	write_data=>tonext_i_aux, 
	resetn=>resetn
	); 

		
end; 
 
