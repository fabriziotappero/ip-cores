--Component for Stages using BF2I (if BF2I is the last stage) 
--Input is a standard logic vector of data_width-add_g 
--data_width - width of the internal busses 
--add_g - Add growth variable  - if 1, data_width grows by  1, if 0 then 0 
--Only 1 shift stage 
 
library IEEE; 
use IEEE.std_logic_1164.all; 
use ieee.std_logic_arith.all; 
 
entity stage_I_last  is 
generic  (  
		data_width : INTEGER :=13; 
        add_g :            INTEGER := 1 
   ); 
port  (  
	prvs_r :in std_logic_vector(data_width-1-add_g downto 0); 
    prvs_i :in std_logic_vector(data_width-1-add_g downto 0); 
	s :in std_logic; 
	clock : in  std_logic; 
	enable : in  std_logic; 
	resetn : in std_logic; 
	tonext_r :out std_logic_vector(data_width-1 downto 0);    
    tonext_i :out std_logic_vector(data_width-1 downto 0)  
  ); 
end stage_I_last; 
 
architecture structure of stage_I_last is 
signal toreg_r : std_logic_vector(data_width-1 downto 0); 
signal toreg_i : std_logic_vector(data_width-1 downto 0); 
signal fromreg_r :  std_logic_vector(data_width-1 downto 0); 
signal fromreg_i: std_logic_vector(data_width -1 downto 0); 

signal tonext_r_aux : std_logic_vector(data_width-1 downto 0); 
signal tonext_i_aux : std_logic_vector(data_width-1 downto 0); 
 
component shiftreg1 
  generic (
		data_width : integer
); 
  port (
		clock : IN std_logic;  
		enable : in  std_logic; 
		clear : in  std_logic; 
        read_data  : OUT    std_logic_vector (data_width-1 DOWNTO 0); 
        write_data : IN     std_logic_vector (data_width-1 DOWNTO 0); 
		resetn     : IN     std_logic          
		); 
end component; 
 
component BF2I 
  generic      (
	data_width : INTEGER; 
    add_g: INTEGER
); 
  port    (
		fromreg_r :in std_logic_vector(data_width-1 downto 0); 
		fromreg_i :in std_logic_vector(data_width -1 downto 0); 
		prvs_r :in std_logic_vector(data_width-add_g-1 downto 0) ; 
		prvs_i :in std_logic_vector(data_width-add_g-1   downto 0) ; 
		s : in std_logic; 
		toreg_r :out std_logic_vector(data_width-1 downto 0);   
        toreg_i :out std_logic_vector(data_width-1 downto 0);  
		tonext_r :out std_logic_vector(data_width-1 downto 0);    
		tonext_i :out std_logic_vector( data_width-1 downto 0)  
   ); 
end component; 
 
begin 
regr : shiftreg1 
  generic map (
	data_width=>data_width           
	) 
  port map (
	clock=>clock, 
	enable=>enable,
	clear =>'0',
	read_data=>fromreg_r, 
	write_data=>toreg_r, 
	resetn=>resetn
	); 
regi : shiftreg1 
  generic map (
	data_width=>data_width
	) 
  port map (
	clock=>clock,
	enable=>enable,
	clear =>'0',
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
    toreg_r=>toreg_r, toreg_i=>toreg_i, 
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
