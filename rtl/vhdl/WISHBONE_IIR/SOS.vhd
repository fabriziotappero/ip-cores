library ieee;
--library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--Structure SOS
entity SOS is 
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

); 
end entity;

architecture RTL of SOS is 
--Filter Tworder component
component Tworder is 
generic (WordWidth:integer;--:=16;--width signal of in/out
			Bit_growth:integer;
			M:integer;--:=16;--width word of coefs
			Q:integer--:=15--Quantifer
			);
			
port(

signal_input :in std_logic_vector(WordWidth+Bit_growth-1 downto 0);
a0,a1,a2,b0,b1,b2: in std_logic_vector(M-1 downto 0);
signal_output:out std_logic_vector(WordWidth+Bit_growth-1 downto 0);
clk,reset,clear,enable:in std_logic

); 
end component;

--The fullregister component
component fullregister is

	generic
	(
		N: integer
	);

	port
	(
		clk		  : in std_logic;
		reset_n	  : in std_logic;
		enable	  : in std_logic;
		clear		  : in std_logic;
		d		  : in std_logic_vector(N-1 downto 0);
		q		  : out std_logic_vector(N-1 downto 0)
		
	);
end component;
--
type output_aux is array(NSECT downto 0) of std_logic_vector(WordWidth+Bit_growth-1 downto 0);
signal output,out_reg: output_aux;

type gain_out_t is array(NSECT downto 0) of std_logic_vector(M+WordWidth+Bit_growth-1 downto 0);

signal gain_out: gain_out_t;


constant Nh: integer :=(NSECT*M*6);

signal filter_coef:std_logic_vector(Nh-1 downto 0);
signal signal_output_aux:std_logic_vector(WordWidth+Bit_growth-1 downto 0);
--type aux_enable is array (0 to NSECT) of std_logic_vector(0 downto 0); 
type aux_enable is array (0 to 2*NSECT) of std_logic_vector(0 downto 0); 
signal enable_aux:aux_enable;
begin

filter_coef<=h0;
myfilter: 
	for k in NSECT-1 downto 0 generate
	
filter: entity work.Tworder(typeIII)
		generic map(
						WordWidth=>WordWidth,
						Bit_growth=>Bit_growth,
						M=>M,
						Q=>Q
						)
						
		port map(
					signal_input => out_reg(k),
					a2=>filter_coef((1*(M)+(k*(M)*6))-1 downto (k*(M)*6)),
					a1=>filter_coef((2*(M)+(k*(M)*6))-1 downto (1*(M)+(k*(M)*6))),
					a0=>filter_coef((3*(M)+(k*(M)*6))-1 downto (2*(M)+(k*(M)*6))),
					b2=>filter_coef((4*(M)+(k*(M)*6))-1 downto (3*(M)+(k*(M)*6))),	
					b1=>filter_coef((5*(M)+(k*(M)*6))-1 downto (4*(M)+(k*(M)*6))),
					b0=>filter_coef((6*(M)+(k*(M)*6))-1 downto (5*(M)+(k*(M)*6))),
					signal_output => output(k),
					clk=>clk,
					reset=>reset,
					clear=>clear,
					enable=>enable_aux(k*2)(0)
					);
	
gain_out(k)<=std_logic_vector(signed(gain)*signed(output(k)));
						
	Reg_seg:fullregister
							generic map(
											N=>WordWidth+Bit_growth
											)
							port map (
											clk=>clk,
											reset_n=>reset,
											enable=>'1',
											clear=>clear,
											d=>gain_out(k)(WordWidth+Bit_growth-1+Q downto Q),
											q=>out_reg(k+1)
											);					

											
	end generate;
	
	myenables: 
	for k in 0 to 2*NSECT-1 generate
	
					
	Reg_enables:fullregister
							generic map(
											N=>1
											)
							port map (
											clk=>clk,
											reset_n=>reset,
											enable=>'1',
											clear=>clear,
											d=>enable_aux(k),
											q=>enable_aux(k+1)
											);
											
	end generate;

	out_reg(0)<=signal_input;
	enable_aux(0)(0)<=enable;
	enable_out<=enable_aux(to_integer((2*(unsigned(en_out))+2)))(0);
	
	
	
	signal_output_aux <=  gain_out(to_integer(unsigned(en_out)))(WordWidth+Bit_growth-1+Q downto Q);  
	
	Reg_out:fullregister
							generic map(
											N=>WordWidth+Bit_growth
											)
							port map (
											clk=>clk,
											reset_n=>reset,
											enable=>'1',
											clear=>clear,
											d=>signal_output_aux,
											q=>signal_output
											);
end architecture;