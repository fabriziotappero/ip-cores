library ieee;
library work;
--use work.coeff_pkg.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity FIR_WB is 
generic (Filter_Width:integer:=16;--Filter width signals of in/out
			WB_Width:integer:=32;--WishBone width signal of in/out
			N_coef:integer:=50;--coefs 
			M:integer:=16;--width word of coefs
			WordWidth_Q:integer:=4;--width signal of Q
			bit_growth:integer:=8;
			adress_wordwidth:integer:=32 ;
			Adr_bas:integer:=8;
			reg_control:integer:=4;
			reg_data:integer:=8;
			reg_status:integer:=12;
			reg_Q:integer:=16;
			reg_coef:integer:=20
			
			);

port(
DAT_I: in std_logic_vector(WB_Width-1 downto 0);
DAT_O:out std_logic_vector(WB_Width-1 downto 0);
ADR_I :in std_logic_vector(adress_wordwidth-1 downto 0);
STB_I,RST_I,CLK_I,WE_I,clear: in std_logic;
ACK_O: out   std_logic
);
end entity;


architecture RTL of FIR_WB is 

component FILTER_FIR is 
generic (WordWidth:integer;--width signal of in/out
			N_coef:integer;--coefs 
			M:integer;--width word of coefs
			WordWidth_Q:integer;--width signal of Q
			bit_growth:integer

			
			);

port(
signal_input: in std_logic_vector(WordWidth-1 downto 0);
signal_output:out std_logic_vector(WordWidth+bit_growth-1 downto 0);
filter_coef: in std_logic_vector(M*N_coef-1 downto 0);
enable,clear,reset,clk: in std_logic;
Q :in std_logic_vector(WordWidth_Q-1 downto 0)

);
end component;

component interface_slave_fir is 
generic(

data_wordwidth: integer;
adress_wordwidth: integer;
Adr_bas:integer;
reg_control:integer;
reg_data:integer;
reg_status:integer;
reg_Q:integer;
reg_coef:integer;
N_coef:integer;
M:integer;
WordWidth_Q:integer
);
port(
 
 
 ACK_O: out   std_logic;--to MASTER
 ADR_I: in    std_logic_vector( adress_wordwidth-1 downto 0 );
 DAT_I: in    std_logic_vector( data_wordwidth-1 downto 0 );--from MASTER
 sDAT_I: in    std_logic_vector( data_wordwidth-1 downto 0 );--from SLAVE
 DAT_O: out   std_logic_vector( data_wordwidth-1 downto 0 );--to MASTER
 sDAT_O: out   std_logic_vector( data_wordwidth-1 downto 0 );--to SLAVE
 STB_I: in    std_logic;--from MASTER
 WE_I: in    std_logic;--from MASTER
 Start: out    std_logic;--to SLAVE	
 h0: out std_logic_vector( (N_coef*M)-1 downto 0 );
 Q: out std_logic_vector( WordWidth_Q-1 downto 0 );
 clear,reset,clk: in std_logic
 );
end component;

signal h0_aux:std_logic_vector(M*N_coef-1 downto 0);
signal fir_data_in:std_logic_vector(WB_Width-1 downto 0);
signal fir_data_out:std_logic_vector(Filter_Width+bit_growth-1 downto 0);
signal Q_aux:std_logic_vector(WordWidth_Q-1 downto 0);
signal Start_aux, WE_O_aux:std_logic;
signal sext:std_logic_vector(bit_growth-1 downto 0);
begin 

sext<=(others=>fir_data_out(Filter_Width+bit_growth-1));

myFilter:FILTER_FIR
generic map(
			WordWidth=>Filter_Width,
			N_coef=>N_coef, 
			M=>M,
			WordWidth_Q=>WordWidth_Q,
			bit_growth=>bit_growth
)
	port map (
		signal_input=>fir_data_in(Filter_Width-1 downto 0),
		signal_output=>fir_data_out,
		filter_coef=>h0_aux,
		enable=>Start_aux,
		clear=>clear,
		reset=>RST_I,
		clk=>CLK_I,
		Q=>Q_aux
		);

wb_interface:interface_slave_fir
generic map(

data_wordwidth=>WB_Width,
adress_wordwidth=>adress_wordwidth,
Adr_bas=>Adr_bas,
reg_control=>reg_control,
reg_data=>reg_data,
reg_status=>reg_status,
reg_Q=>reg_Q,
reg_coef=>reg_coef,
N_coef=>N_coef,
M=>M,
WordWidth_Q=>WordWidth_Q

)
port map(
 
 
 ACK_O=>ACK_O,
 ADR_I=>ADR_I,
 DAT_I=>DAT_I,
 sDAT_I=>sext&fir_data_out,
 DAT_O=>DAT_O,
 sDAT_O=>fir_data_in,
 STB_I=>STB_I,
 WE_I=>WE_I,
 Start=>Start_aux,
 h0=>h0_aux,
 Q=>Q_aux,
 clear=>clear,
 reset=>RST_I,
 clk=>CLK_I
 );
		 
end architecture;