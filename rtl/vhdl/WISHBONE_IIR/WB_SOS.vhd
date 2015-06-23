library ieee;
--library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WB_SOS is 
generic (Filter_Width:integer:=16;--Filter width signals of in/out
			WB_Width:integer:=32;--WishBone width signal of in/out
			Bit_Growth:integer:=8;
			NSECT:integer:=6;--Cant of sections
			M:integer:=16;--width word of coefs
			Q:integer:=13;--Q--Quantifer
			Adress_wordwidth:integer:=32 ;
			Adr_bas:integer:=9;
			Reg_control:integer:=0;
			Reg_data:integer:=4;
			Reg_status:integer:=8;
			Reg_Nsec:integer:=12;
			Reg_gain: integer:=16;
			Reg_coef:integer:=20
		
			--Reg_coef:integer:=20
			--N_coef:integer:=42
			
			);
			
port(

DAT_I: in std_logic_vector(WB_Width-1 downto 0);
DAT_O:out std_logic_vector(WB_Width-1 downto 0);
ADR_I :in std_logic_vector(Adress_wordwidth-1 downto 0);
STB_I,RST_I,CLK_I,WE_I: in std_logic;
ACK_O: out   std_logic;
clear:in std_logic 
);
end entity;

architecture RTL of WB_SOS is 
--Structure SOS
component SOS is 
generic (WordWidth:integer;--width signal of in/out
			Bit_growth:integer;	
			NSECT:integer;--Cant of sections
			M:integer;--width word of coefs
			Q:integer--Q--Quantifer
			
			);
			
port(

signal_input :in std_logic_vector(WordWidth+Bit_growth-1 downto 0);
h0: in std_logic_vector((NSECT*M*6)-1 downto 0);
gain: in std_logic_vector(M-1 downto 0);
signal_output:out std_logic_vector(WordWidth+Bit_growth-1 downto 0);
en_out : in std_logic_vector(3 downto 0);
enable_out:out std_logic;
clk,reset,clear,enable:in std_logic

);  end component;

--
component interface_slave_iir is 
generic(

Data_wordwidth: integer;
Adress_wordwidth: integer;
Adr_bas:integer;
Reg_control:integer;
Reg_data:integer;
Reg_status:integer;
Reg_coef:integer;
Reg_gain:integer;
Reg_Nsec:integer;
NSECT:integer;
--Offset_coef:integer;
M:integer

);
port(
 
 
 ACK_O: out   std_logic;--to MASTER
 ADR_I: in    std_logic_vector( Adress_wordwidth-1 downto 0 );
 DAT_I: in    std_logic_vector( Data_wordwidth-1 downto 0 );--from MASTER
 sDAT_I: in    std_logic_vector( Data_wordwidth-1 downto 0 );--from SLAVE
 DAT_O: out   std_logic_vector( Data_wordwidth-1 downto 0 );--to MASTER
 sDAT_O: out   std_logic_vector( Data_wordwidth-1 downto 0 );--to SLAVE
 en_out: out   std_logic_vector( 3 downto 0 );--to slave
 STB_I: in    std_logic;--from MASTER
 WE_I: in    std_logic;--from MASTER
 Start: out    std_logic;--to SLAVE	
 h0: out std_logic_vector( (NSECT*M*6)-1 downto 0 );--to SLAVE
 gain: out std_logic_vector(M-1 downto 0);
 enable_in: in std_logic;
 clear,reset,clk: in std_logic
 );
end component;
signal h0_aux:std_logic_vector((NSECT*M*6)-1 downto 0);
signal gain_aux:std_logic_vector(M-1 downto 0);
signal iir_data_in, iir_data_out:std_logic_vector(Filter_Width+Bit_Growth-1 downto 0);
signal en_out_aux:std_logic_vector(3 downto 0);
signal Start_aux, WE_O_aux,enable_aux:std_logic;
signal sext:std_logic_vector(WB_Width-Filter_Width-bit_growth-1 downto 0);
begin
sext<=(others=>iir_data_out(Filter_Width-1));

sos_1:SOS 
generic map(WordWidth=>Filter_Width,--width signal of in/out
			Bit_growth=>Bit_Growth,	
			NSECT=>NSECT,--Cant of sections
			M=>M,--width word of coefs
			Q=>Q--Quantifer
			
			)
			
port map(

signal_input=>iir_data_in((Filter_Width+Bit_Growth)-1 downto 0),
--signal_input((WordWidth-(8*2))-1 downto 0)<=(others=>'0'),
h0=>h0_aux,
gain=>gain_aux,
signal_output=>iir_data_out,
en_out=>en_out_aux,
enable_out=>enable_aux,
clk=>CLK_I,
reset=>RST_I,
clear=>clear,
enable=>start_aux

); 

inteface:interface_slave_iir  
generic map(

Data_wordwidth=>WB_Width,
Adress_wordwidth=>Adress_wordwidth,
Adr_bas=>Adr_bas,
Reg_control=>Reg_control,
Reg_data=>Reg_data,
Reg_status=>Reg_status,
Reg_coef=>Reg_coef,
Reg_gain=>Reg_gain,
Reg_Nsec=>Reg_Nsec,
NSECT=>NSECT,
--Offset_coef=>Offset_coef,
M=>M

)
port map(
 
 
 ACK_O=>ACK_O,
 ADR_I=>ADR_I,
 DAT_I=>DAT_I,
 sDAT_I=>sext&iir_data_out,
 DAT_O=>DAT_O,
 sDAT_O((Filter_Width+Bit_Growth)-1 downto 0)=>iir_data_in,
 en_out=>en_out_aux,
 enable_in=>enable_aux,
 STB_I=>STB_I,
 WE_I=>WE_I,
 Start=>Start_aux,
 h0=>h0_aux,
 gain=>gain_aux,
 clear=>clear,
 reset=>RST_I,
 clk=>CLK_I
 );

	
end architecture;