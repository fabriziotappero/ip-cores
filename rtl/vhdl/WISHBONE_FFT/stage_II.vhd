
--Component for  Stages using BF2II (second and every even stage) 
--Doesn 't handle last stage 
--Input is a stand ard logic vector of data_width-add_g 
--data_width - width of the internal busses 
--  Add growth variable - if 1, data_width gro add_g -   ws by 1,   if 0 then 0 
--mult_g - mult g  rowth variable - can r ange from 0 to twiddle_width+1 
--twiddle_width - width of the twiddle factor input 
--shift_stages - number of shift register stages 
library IEEE; 
use IEEE.std_logic_1164.all; 
use ieee.std_logic_arith.all; 
 
entity stage_II is 
generic  (  
	data_width : INTEGER :=14; 
    add_g : INTEGER := 1; 
	mult_g : INTEGER :=9; 
	twiddle_width : INTEGER :=10; 
    shift_stages : INTEGER := 16 
  );  
   
port  (  
	prvs_r :in std_logic_vector(data_width-1-add_g downto 0); 
	prvs_i :in std_logic_vector(data_width -1-add_g downto 0); 
	t :in std_logic; 
	s :in std_logic; 
    clock : in std_logic; 
	 enable : in std_logic; 
    resetn : in std_logic; 
	fromrom_r :in std_logic_vector(twiddle_width-1 downto 0); 
    fromrom_i :in  std_logic_vector(twiddle_width-1 downto 0); 
   tonext_r :out std_logic_vector(data_width+mult_g-1 downto 0) ; 
   tonext_i :out std_logic_vector(data_width+mult_g-1 downto 0 ) 
  ); 
end stage_II; 
 
architecture structure of stage_II is 
signal toreg_r : std_logic_vector(data_width-1        downto 0); 
signal toreg_i : std_logic_vector(data_width-1 downto 0); 
signal fromreg_r : std_logic_vector(data_width-1 downto 0); 
signal fromreg_i : std_logic_vector(data_width-1 downto 0); 
signal tomult_r : std_logic_vector(data_width-1 downto 0); 
signal tomult_i :  std_logic_vector(data_width-1 downto 0); 

signal tonext_r_aux : std_logic_vector(data_width+mult_g-1 downto 0); 
signal tonext_i_aux : std_logic_vector(data_width+mult_g-1 downto 0); 
 
component shiftregN 
  generic (
		data_width : integer; 
		n : integer
); 
  port  (
		clock : IN std_logic; 
		enable : in std_logic; 
		read_data  : OUT    std_logic_vector (data_width-1 DOWNTO 0); 
        write_data : IN     std_logic_vector (data_width-1 DOWNTO 0); 
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
 
 
component BF2II 
  generic (
	data_width : INTEGER; 
	add_g: INTEGER
	); 
  port    (
	fromreg_r :in std_logic_vector(data_width-1 downto 0); 
    fromreg_i :in std_logic_vector(data_width-1 downto 0); 
	prvs_r :in std_logic_vector(data_width-add_g-1 downto 0); 
	prvs_i :in std_logic_vector(data_width-add_g-1 downto  0); 
	t : in std_logic; 
	s : in std_logic; 
    toreg_r :out std_logic_vector(data_width-1 downto 0);    
    toreg_i :out std_logic_vector(data_width-1 downto 0);  
    tonext_r :out std_logic_vector(data_width-1 downto 0);    
    tonext_i :out std_logic_vector(data_width-1 downto 0)  
    ); 
end component;
 
component  twiddle_mult 
  generic (
	mult_width : INTEGER; 
    twiddle_width               : INTEGER; 
    output_width : INTEGER
); 
     port  (
		data_r :in std_logic_vector(mult_width-1 downto 0); 
        data_i :in std_logic_vector(mult_width-1 downto 0); 
		twdl_r :in std_logic_vector(twiddle_width-1 downto 0) ; 
		twdl_i :in std_logic_vector(twiddle_width-1 downto 0); 
        out_r :out std_logic_vector(output_width-1 downto 0);   
		out_i :out std_logic_vector(output_width-1 downto 0) 
   ); 
end component; 
 
begin 
regr : shiftregN 
  generic map (
	data_width=>data_width, n=>shift_stages
) 
  port map (
	clock=>clock,
	enable=>enable,
	read_data=>fromreg_r, 
	write_data=>toreg_r, 
	resetn=>resetn
	); 
	
regi :  shiftregN 
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
		
btrfly : BF2II 
  generic map (
		data_width=>data_width, 
		add_g=>add_g
		)                
  port map (  
		fromreg_r=>fromreg_r, 
		fromreg_i=>fromreg_i, 
		prvs_r=>prvs_r, prvs_i=>prvs_i, 
		t=>t, 
		s=>s, 
		toreg_r=>toreg_r, 
		toreg_i=>toreg_i, 
		tonext_r=>tomult_r, 
		tonext_i =>tomult_i
		); 
		
twiddle : twiddle_mult 
  generic map (
		mult_width=>data_width, 
		twiddle_width=>twiddle_width,  
		output_width=> data_width+mult_g
		) 
  port map (  
		data_r=>tomult_r, 
		data_i=>tomult_i, 
		twdl_r=>fromrom_r, 
		twdl_i=>fromrom_i, 
		out_r=>tonext_r_aux, 
		out_i=>tonext_i_aux
		); 
		

regsegr : shiftreg1
  generic map (
	data_width=>data_width+mult_g
	
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
	data_width=>data_width+mult_g
	
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
