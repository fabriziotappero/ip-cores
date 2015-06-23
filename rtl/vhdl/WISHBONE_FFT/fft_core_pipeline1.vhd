-- N point FFT 
-- Uses R2^2SDF algorithm 
-- 
-- Generics used: 
-- N - number of points taken - powers of 2 only, ranging f 8 to 1024 points. 
-- input_ width - bit width  of the input vector 
--  twiddle  width - width of the twiddle factors stored in the ROM 
-- add_g - Adder growth - Adders grow 0 or 1 bits each time they are used 
--         Exculdes adders in the complex multiplier (that is handled by mult_g) 
-- mult_g - multiplier growth - 0 to twiddle_width+        1 - Growth during the complex 
--   multiplier stages 
--  
-- Width of output vector is as follows (num_stages=log2(N): 
--    N      width 
--   8,16    input_width + (num_stages * add_g) + mult_g 
--   32,64   input_width + (num_            stages * add_g) + 2*mult_g 
-- 128,256    input_width + (num_stage            s * add_g) + 3*mult_g 
-- 512,1024   input_width + (num_stages            * add_g) + 4*mult_g 
--  
-- Due to the way this system was made parameterizable, there are many signals 
-- that will remain unconnected.  This is normal. 
--  
-- Default generics are for a simple 64 point FFT 

-- Each stage with complex multiplier introduces a 1/2 gain

--Changes made by Alex-Parrado to the original version of Adam Robert Miller

	--Pipeline registers and clock enables, have been added. Clock frequency above of 100 MHz for all FFT sizes
	
	--Synchronous ROMs for proper RAM block inferring. MATLAB scripts have been modified.
	

 
LIBRARY ieee; 
USE ieee.std_logic_1164.ALL; 

USE ieee.numeric_std.ALL; 
--USE ieee.std_logic_arith.ALL; 
use ieee.math_real.all;
use work.fft_pkg .all; 
 
entity fft_core_pipeline1 is 
  generic (  
	input_width : integer :=16; 
   twiddle_width : integer :=16; 
   N : integer :=1024; 
   add_g : integer:=0;--1;  --Either 0 or 1 only. 
   mult_g : integer:=0--9  --Can be any number from 0 to twiddle_width+1 
   ); 
  port (  clock : in std_logic; 
   resetn : in std_logic; 
   enable : in std_logic; 
	clear : in std_logic;
	enable_out: out std_logic;
	frame_ready: out std_logic;
	index : out std_logic_vector(integer(ceil(log2(real((N)))))-1 downto 0);
      xin_r : in std_logic_vector(input_width-1 downto 0); 
      xin_i : in std_logic_vector(input_width-1 downto 0); 
      Xout_r : out std_logic_vector (input_width+((integer(ceil(log2(real((N)))))-1)/2)*mult_g+integer(ceil(log2(real((N)))))*add_g-1 downto 0); 
      Xout_i : out std_logic_vector (input_width+((integer(ceil(log2(real((N)))))-1)/2)*mult_g+integer(ceil(log2(real((N)))))*add_g-1 downto 0) 
   ); 
end fft_core_pipeline1; 
 
architecture structure of fft_core_pipeline1 is 
--Signal declarations 
constant num_stages: integer :=integer(ceil(log2(real((N))))); 
signal control: std_logic_vector(num_stages-1 downto 0); 
signal bit_reverse_index: std_logic_vector(num_stages-1 downto 0); 
type stage_array is array (1 to num_stages-1) of 
 std_logic_vector(input_width+(num_stages*add_g)+(((num_stages-1)/2)*mult_g)-1  downto 0); 
signal stoscon_r: stage_array; 
signal  stoscon_i: stage_array; 
type rom_array is array (1 to (num_stages-1)/2) of std_logic_vector(twiddle_width-1 downto 0); 
signal rtoscon_r: rom_array; 
signal rtoscon_i: rom_array; 

type enables_array is array (0 to num_stages+1) of std_logic_vector(0 downto 0); 
signal enables: enables_array;


type counter_registers_array is array (0 to num_stages+1) of std_logic_vector(num_stages-1 downto 0); 
signal counter_registers: counter_registers_array;

--

signal xin_r_reg :  std_logic_vector(input_width-1 downto 0); 
signal xin_i_reg :  std_logic_vector(input_width-1 downto 0); 

signal t_ff: std_logic_vector(0 downto 0);
signal en_t_ff:std_logic_vector(0 downto 0);
signal clear_t_ff:std_logic;


--component declarations 
component counterhle 
  generic (width : integer); 

  port (   clock : in std_logic; 
   resetn : in std_logic; 
   enable :  in std_logic;
	clear : in std_logic;	
      countout :  out std_logic_vector(width-1 downto 0) 
    ); 
end component; 
 
component rom1 
  generic (
		data_width :  integer; 
		address_width : integer); 
  port (
      clk: in std_logic;
		address: IN     std_logic_vector (address_width-1 DOWNTO 0); 
        datar     : OUT    std_logic_vector (data_width-1 DOWNTO 0); 
        datai     : OUT    std_logic_vector (data_width-1  DOWNTO 0)    
    ); 
end component; 
 
component rom2 
  generic (
	data_width : integer; 
	address_width : integer); 
  port  (
  clk: in std_logic;
	address    : IN     std_logic_vector (address_width-1 DOWNTO 0); 
    datar     : OUT     std_logic_vector (data_width-1 DOWNTO 0); 
    datai     : OUT    std_logic_vector (data_width-1 DOWNTO 0)    
   ); 
end component; 
 
component rom3 
  generic (
	data_width : integer; 
	address_width : integer); 
  port  (
  clk: in std_logic;
	address    : IN     std_logic_vector (address_width-1 DOWNTO 0); 
    datar     : OUT    std_logic_vector (data_width-1 DOWNTO 0); 
    datai     : OUT    std_logic_vector (data_width-1 DOWNTO 0)     
    ); 
end component; 
 
component rom4 
  generic (
	data_width : integer; 
	address_width : integer); 
  port  (
  clk: in std_logic;
	address    : IN     std_logic_vector (address_width-1 DOWNTO 0); 
    datar     : OUT    std_logic_vector (data_width-1 DOWNTO 0); 
    datai     : OUT    std_logic_vector (data_width-1 DOWNTO 0)    
   ); 
end component; 
 
component stage_I 
     generic  (
		data_width : INTEGER; 
		add_g : INTEGER; 
		shift_stages : INTEGER); 
  port  (
		prvs_r :in std_logic_vector(data_width-1-add_g downto 0); 
		prvs_i :in std_logic_vector(data_width-1-add_g downto 0); 
		s :in std_logic; 
		clock : in std_logic; 
		enable: in std_logic; 
		resetn : in std_logic; 
   tonext_r :out std_logic_vector(data_width-1 downto 0);     
   tonext_i :out std_logic_vector(data_width-1 downto 0)); 
end component; 
 
component stage_II 
     generic  (
		data_width : INTEGER; 
		add_g : INTEGER; 
		mult_g : INTEGER; 
		twiddle_width : INTEGER; 
		shift_stages : INTEGER
		); 
  port  (
		prvs_r :in std_logic_vector(data_width-1-add_g downto 0); 
		prvs_i :in std_logic_vector(data_width-1-add_g downto 0) ; 
		t :in std_logic; 
		s :in std_logic; 
		clock : in std_logic; 
		enable: in std_logic; 
		resetn : in std_logic; 
		fromrom_r :in std_logic_vector (twiddle_width-1 downto 0) ; 
		fromrom_i :in std_logic_vector(twiddle_width-1 downto 0); 
		tonext_r :out std_logic_vector(data_width+mult_g-1 downto 0);     
		tonext_i :out std_logic_vector(data_width+mult_g-1 downto 0)); 
end component;
 
component stage_I_last 
  generic  (
		data_width : INTEGER;
		add_g : INTEGER
		); 
  port (
		prvs_r :in std_logic_vector(data_width-1-add_g downto 0);  
		prvs_i :in std_logic_vector(data_width-1-add_g downto 0); 
        s :in std_logic; clock : in std_logic; resetn : in std_logic; 
		  enable: in std_logic; 
		tonext_r :out std_logic_vector(data_width-1 downto 0);    
		tonext_i :out std_logic_vector(data_width-1 downto 0)); 
end component;   
 
component stage_II_last 
  generic  (
		data_width : INTEGER; 
		add_g : INTEGER
		); 
  port  (
		prvs_r :in std_logic_vector(data_width-1-add_g downto 0); 
		prvs_i :in std_logic_vector(data_width-1-add_g downto 0); 
		t :in std_logic; 
		s :in std_logic; 
		clock : in std_logic; 
		enable: in std_logic; 
		resetn :  in std_logic; 
		tonext_r :out std_logic_vector(data_width-1 downto 0);    
		tonext_i :out std_logic_vector(data_width-1 downto 0)); 
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
 
begin 

controller : component counterhle 
     generic map (
		width=>num_stages
) 
  port map (
		clock=>clock,
		resetn=>resetn,
		clear => clear,
		enable=>enable, 
		countout=>control
		); 
		
		
-- Counter, pipeline registers
counter_registers(0)<=control;
forcounterregs: for i in 0 to num_stages generate
counterregi: shiftreg1
generic  map(
		data_width=>num_stages
)
  port map (
		clock=>clock,
		enable=>'1',
		clear => clear,
        read_data=>counter_registers(i+1),
        write_data=>counter_registers(i), 
		resetn=>resetn
		); 
	
end generate;
		
		
--Enable, pipeline registers
enables(0)(0)<=enable;
forenablesregs: for i in 0 to num_stages generate
enableregi: shiftreg1
generic  map(
		data_width=>1
)
  port map (
		clock=>clock,
		enable=>'1',
		clear => clear,
        read_data=>enables(i+1),
        write_data=>enables(i), 
		resetn=>resetn
		); 
	
end generate;
				
		
		
--Input registers
reginputr: shiftreg1
generic  map(
		data_width=>input_width
)
  port map (
		clock=>clock,
		enable=>'1',
		clear => '0',
        read_data=>xin_r_reg,
        write_data=>xin_r, 
		resetn=>resetn
		); 
		
reginputi: shiftreg1
generic  map(
		data_width=>input_width
)
  port map (
		clock=>clock,
		enable=>'1',
		clear => '0',
        read_data=>xin_i_reg,
        write_data=>xin_i, 
		resetn=>resetn
		); 
		
		
stages : for i in 1 to num_stages generate 
--  constan ity : in r :=i rem 2;  t par tege
--  constant shift_stages : integer := 2**(num_stages - i); 
--  consta nt rom_loc : integer :=i/2; 
--  constant data_width : integer :=input_width + (i*add_g) + (((i-1)/2)*mult_g); 
--  constant s: integer :      =(num_stages-i); 
--  constant t    : integer :=(num_stages-i+1); 
     initial_stage: if i=1 generate 
    initial_stage_I :  component stage_I 
      generic map (
		data_width=>input_width + (i*add_g)+(((i-1)/2)*mult_g),  
		add_g=>add_g, 
		shift_stages=>2**(num_stages - i)) 
    port map (
		prvs_r=>xin_r_reg,prvs_i=>xin_i_reg,s=>counter_registers(i)((num_stages-i)),
		clock=>clock,
		enable=>enables(i)(0),
		resetn=>resetn, 
		tonext_r=>stoscon_r(i)(input_width+(i*add_g) + (( (i-1)/2)*mult_g)-1 downto 0), 
        tonext_i=>stoscon_i(i)(input_width+ (i*add_g) + (( (i-1)/2)*mult_g)-1 downto 0)); 
  end generate initial_stage; 
  
  even_stages: if ((i rem 2)=0) and (i/=num_stages) generate 
    inner_stage_II : component stage_II 
      generic map (
		data_width=>input_width + (i*add_g) + (((i-1)/2)*mult_g), 
		add_g=>add_g,mult_g=>mult_g, 
		twiddle_width=>twiddle_width, 
		shift_stages=>2**(num_stages - i)
		) 
    port map ( 
		prvs_r=>stoscon_r(i-1)(input_width + (i*add_g) + (((i -1)/2)*mult_g)-1-add_g downto 0), 
		prvs_i=>stoscon_i(i-1)(input_width + (i*add_g) + (((i-1)/2)*mult_g)-1-add_g downto 0), 
		t=>counter_registers(i)((num_stages-i+1)),
		s=>counter_registers(i)((num_stages-i)),clock=>clock,resetn=>resetn,     
		enable=>enables(i)(0),		
		fromrom_r=>rtoscon_r(i/2),fromrom_i=>rtoscon_i(i/2), 
        tonext_r=>stoscon_r(i)(input_width + (i*add_g) + (((i-1)/2)*mult_g)+mult_g-1 downto 0), 
        tonext_i=>stoscon_i(i)(input_width +  (i*add_g) + (((i-1)/2)*mult_g)+mult_g-1 downto 0)
		); 
        
    first_rom: if (i/2)=1 generate 
    rom_1 : component rom1 

    generic map (
		data_width=>twiddle_width, 
		address_width=>(num_stages-i+1)+1
		) 
      port map ( 
		clk=>clock,
		address=>counter_registers(i-1)((num_stages-i+1) downto 0 ),       
		datar=>rtoscon_r(i/2),datai=>rtoscon_i(i/2)); 
  end   generate first_rom; 
   
       second_rom: if (i/2)=2 generate 
    rom_2 : component rom2 
     generic map (
		data_width=>twiddle_width, 
		address_width=>(num_stages-i+1)+1
		) 
    port map ( 
	 clk=>clock,
		address=>counter_registers(i-1)((num_stages-i+1  ) downto 0),        
		datar=>rtoscon_r(i/2),datai=>rtoscon_i(i/2)
		); 
  end generate second_rom; 
      
    third_rom: if (i/2)=3 generate 
   rom_3 : component rom3 
    generic map (
	 
		data_width  =>twiddle_width, 
		address_width=>(num_stages-i+1)+1
		) 
    port map ( 
	 clk=>clock,
		address=>counter_registers(i-1)((num_stages-i+1) downto 0),        
		datar=>rtoscon_r(i/2),datai=>rtoscon_i(i/2)
		); 
    end generate third_rom;  
     
    fourth_rom: if (i/2)=4 generate 
    rom_4 : component rom4 
     generic map (
		data_width=>twiddle_width, 
		address_width=>(num_stages-i+1)+1
		) 
    port map ( 
	 clk=>clock,
		address=>counter_registers(i-1)((num_stages-i+1) downto 0),       
		datar=>rtoscon_r(i/2),datai=>rtoscon_i(i/2)
		); 
  end generate fourth_rom;  
      
  end generate even_stages; 
  
  
  
  odd_stages: if (((i rem 2)=1) and (i/=num_stages)) and (i/=1)
  generate 
    inner_stage_I : component stage_I 
         generic map (
		data_width=>input_width + (i*add_g) + (((i-1)/2)*mult_g),  
		add_g=>add_g, 
		shift_stages=>2**(num_stages - i)
		) 
   port map ( 
		prvs_r=>stoscon_r(i-1)(input_width + (i*add_g) + (((i-1)/2)*mult_g)-1-add_g downto 0), 
		prvs_i=>stoscon_i(i-1)(input_width + (i*add_g)  + (((i-1)/2)*mult_g)-1-add_g downto 0), 
		s=>counter_registers(i)( (num_stages-i)),
		enable=>enables(i)(0),
		clock=>clock,
		resetn=>resetn, 
		tonext_r=>stoscon_r(i)(input_width+ (i*add_g) + ( ((i -1)/2)*mult_g)-1 downto 0), 
		tonext_i=>stoscon_i(i)(input_width +  (i*add_g) + ( ((i- 1)/2)*mult_g)-1 downto 0)
		); 
  end generate odd_stages; 
  
  end_on_even: if (i=num_stages) and ((i rem 2)=0) generate 
    last_stage_II : component stage_II_last 
      generic map (
		data_width=>input_width + (i*add_g) + (((i-1)/2)*mult_g), 
		add_g=>add_g
		) 
   port map ( 
		prvs_r=>stoscon_r(i-1)(input_width + (i*add_g) + (((i-1)/2)*mult_g)-1-add_g downto 0), 
		prvs_i=>stoscon_i(i-1)(input_width + (i*add_g) + (((i-1)/2)*mult_g)-1-add_g downto 0), 
		t=>counter_registers(i)((num_stages-i+1)),
		s=>counter_registers(i)((num_stages-i)),clock=>clock ,
		resetn=>resetn, 
		enable=>enables(i)(0),
		tonext_r=>Xout_r,
		tonext_i=>Xout_i
		); 
  end generate end_on_even; 
  
  end_on_odd: if (i=num_stages) and ((i rem 2)=1) generate 
    last_stage_I : component stage_I_last 
      generic map (
		data_width=>input_width + (i*add_g) + (((i-1)/2)*mult_g), add_g=>add_g
		) 
   port map ( 
		prvs_r=>stoscon_r(i-1)(input_width + (i*add_g) + (((i-1)/2)*mult_g)-1-add_g downto 0), 
		prvs_i=>stoscon_i(i-1)(input_width + (i*add_g) + (((i-1)/2)*mult_g)-1-add_g downto 0), 
		s=>counter_registers(i)( (num_stages-i)),
		clock=>clock,
		enable=>enables(i)(0),
		resetn=>resetn, 
		tonext_r=>Xout_r,
		tonext_i=>Xout_i
		); 
             
      
  end generate end_on_odd; 
  
end generate stages; 

--Frequency bin with bit reversal
bit_reverse_index<=std_logic_vector(unsigned(counter_registers(num_stages+1))+1);

bit_reverse: for i in 0 to num_stages-1 generate
			index(i)<=bit_reverse_index(num_stages-1-i);

end generate;


--T flip-flop for enable_out generation control

tff: shiftreg1 generic  map(
		data_width=>1
)
  port map (
		clock=>clock,
		enable=>((en_t_ff(0) or clear_t_Ff) and enables(num_stages)(0))  or clear,
		clear => clear or clear_t_ff,
        read_data=>t_ff,
        write_data=>en_t_ff, 
		resetn=>resetn
		); 
	


en_t_ff(0)<= '1' when (unsigned(counter_registers(num_stages+1))=(N-1)) else '0';
clear_t_ff <= '1' when (unsigned(counter_registers(num_stages+1))=(N-1) and t_ff(0)='1') else '0';

--Enable out includes pipeline latency 
enable_out<=enables(num_stages+1)(0) when (t_ff="1")  else '0' ;


--Frame ready, falling edge detector

process(resetn,clock)
      variable detect : std_ulogic_vector (1 downto 0);
   begin
      if resetn ='0' then
         detect := "00";

      elsif rising_edge(clock) then
		
		if (clear ='1') then
		
		frame_ready<='0';
		
		else
		
         detect(1) := detect(0); -- record last value of sync in detect(1)
         detect(0) := t_ff(0) ; --record current sync in detect(0)
         
         if detect = "01" then -- rising_edge
			
			frame_ready<='0';
			
         elsif detect = "10" then --falling_edge
			
frame_ready<='1';		

			
         end if;
			
			end if;

      end if;
end process;




end; 
