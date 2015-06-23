
--Twiddle multiplier 
--7/17/02  
--Uses a both inputs same width complex multiplier 
--Won't sign extend output, but will truncate it down 
--(mult_width + twiddle_width >= output_width) 
-- 
--Twiddle factors are limited to -1 < twdl < 1. 
--(twiddle factor can't be 0b1000000000) 
 
library IEEE; 
use IEEE.std_logic_1164.all; 
 
entity twiddle_mult is 
 
generic (    
    mult_width : INTEGER := 7; 
    twiddle_width : INTEGER :=3; 
        output_width : INTEGER :=9 
        ); 
 
port    (   data_r :in std_logic_vector(mult_width-1 downto 0); 
                     data_i :in std_logic_vector(mult_width-1 downto 0); 
   twdl_r :in std_logic_vector(twiddle_width-1 downto 0); 
   twdl_i :in std_logic_vector(twiddle_width-1 downto 0); 
                     out_r :out std_logic_vector(output_width-1 downto 0); 
   
      out_i :out std_logic_vector(output_width-1 downto 0)   
  ); 
 
end twiddle_mult; 
 
architecture behavior of  twiddle_mult is 
signal  mult_out_r : std_logic_vector(twiddle_width + mult_width downto 0); 
signal mult_out_i : std_logic_vector(twiddle_width + mult_width downto 0); 
 
component comp_mult 
 generic ( inst_width1:integer; 
   inst_width2:integer );   
  port  ( Re1  : in std_logic_vector(inst_width1-1 downto 0); 
          Im1        : in std_logic_vector(inst_width1-1 downto 0);  
          Re2  :        in std_logic_vector(inst_width2-1 downto 0);  
          Im2  : in std_logic_vector(inst_width2-1 downto 0); 
          Re   : out std_logic_vector(inst_width1 + inst_width2 
downto 0); 
          Im   : out std_logic_vector(inst_width1 + inst_width2 
downto 0)  
 
  ) ; 
    
end component; 
 
begin 
 
  U1 : comp_mult 
 generic map( 
    inst_width1 => mult_width, inst_width2 => twiddle_width) 
  port map (Re1=>data_r, Im1=>data_i, Re2=>twdl_r, Im2=>twdl_i, 
Re=>mult_out_r, Im=>mult_out_i); 
 
 process(mult_out_r,mult_out_i) 
  begin 
       out_r <= mult_out_r((twiddle_width+mult_width-1) downto (twiddle_width+mult_width-output_width)); 
       out_i <= mult_out_i((twiddle_width+mult_width-1) downto (twiddle_width+mult_width-output_width)); 
 
  end process; 
end; 
