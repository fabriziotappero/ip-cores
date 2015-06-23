library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity FFT_WB is 
generic (WB_Width:integer:=32;--Filter width signals of in/out
			Adress_wordwidth:integer:=32 ;
			N:integer:=1024;--width word of coefs
			reg_control:integer:=0;
			reg_data:integer:=4;
			reg_status:integer:=8;
			reg_memory:integer:=12
			
			);

port(
DAT_I: in std_logic_vector(WB_Width-1 downto 0);
DAT_O:out std_logic_vector(WB_Width-1 downto 0);
ADR_I :in std_logic_vector(Adress_wordwidth-1 downto 0);
STB_I,RST_I,CLK_I,WE_I: in std_logic;
ACK_O: out   std_logic
);
end entity;


architecture RTL of FFT_WB is 


component fft_core_pipeline1 is 
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
end component;

component interface_slave_fft is 
generic(
N: integer;
data_wordwidth: integer;
adress_wordwidth: integer;
reg_control:integer;
reg_data:integer;
reg_status:integer;
reg_memory:integer


);
port(
 
 
 ACK_O: out   std_logic;--to MASTER
 ADR_I: in    std_logic_vector( adress_wordwidth-1 downto 0 );
 ADR_FFT: in    std_logic_vector( integer(ceil(log2(real(N))))-1 downto 0 );
 DAT_I: in    std_logic_vector( data_wordwidth-1 downto 0 );--from MASTER
 sDAT_I: in    std_logic_vector( data_wordwidth-1 downto 0 );--from SLAVE
 DAT_O: out   std_logic_vector( data_wordwidth-1 downto 0 );--to MASTER
 sDAT_O: out   std_logic_vector( data_wordwidth-1 downto 0 );--to SLAVE
 STB_I: in    std_logic;--from MASTER
 WE_I: in    std_logic;--from MASTER
 FFT_finish_in: in    std_logic;--from SLAVE	
 FFT_enable: out    std_logic;--to SLAVE	
 enable_in: in    std_logic;--from SLAVE	
 clear_out: out    std_logic;--to SLAVE
 clk: in std_logic
 );
end component;

signal index_aux: std_logic_vector(integer(ceil(log2(real(N))))-1 downto 0);
signal frame_ready_aux,enable_out_aux,FFT_enable_aux,clear_aux:std_logic;
signal Data1_aux,Data2_aux: std_logic_vector(WB_Width-1 downto 0);
begin

--Instancia del FFT-Core
FFT: fft_core_pipeline1  
  generic map(  
	input_width=>WB_Width/2, 
   twiddle_width=>WB_Width/2,
   N=>N,
   add_g=>0,
   mult_g=>0
   )
  port map(  
   clock=>CLK_I,
   resetn=>RST_I,
   enable=>FFT_enable_aux,
	clear=>clear_aux,
	enable_out=>enable_out_aux,
	frame_ready=>frame_ready_aux,
	index=>index_aux,
   xin_r=>Data1_aux(WB_Width-1 downto WB_Width/2),
   xin_i=>Data1_aux((WB_Width/2)-1 downto 0),
   Xout_r=>Data2_aux(WB_Width-1 downto WB_Width/2),
   Xout_i=>Data2_aux((WB_Width/2)-1 downto 0)
   ); 

	--Instancia de interfaz con arbitro Wishbone 
	Interface: interface_slave_fft  
generic map(
N=>N,
data_wordwidth=>WB_Width,
adress_wordwidth=>Adress_wordwidth,
reg_control=>reg_control,
reg_data=>reg_data,
reg_status=>reg_status,
reg_memory=>reg_memory
)
port map(
 ACK_O=>ACK_O,
 ADR_I=>ADR_I,
 ADR_FFT=>index_aux,
 DAT_I=>DAT_I,
 sDAT_I=>Data2_aux,
 DAT_O=>DAT_O,
 sDAT_O=>Data1_aux,
 STB_I=>STB_I,
 WE_I=>WE_I,
 FFT_finish_in=>frame_ready_aux,
 FFT_enable=>FFT_enable_aux,
 enable_in=>enable_out_aux,
 clear_out=>clear_aux,
 clk=>CLK_I
 );

 end architecture;