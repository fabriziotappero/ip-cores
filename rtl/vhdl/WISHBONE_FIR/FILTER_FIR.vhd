library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--use work.coeff_pkg.all;

entity FILTER_FIR is 
generic (WordWidth:integer;--width signal of in/out
			N_coef:integer;--coefs 
			M:integer;--width word of coefs
			WordWidth_Q:integer;--width signal of Q
			bit_growth:integer:=8
			);

port(
signal_input: in std_logic_vector(WordWidth-1 downto 0);
signal_output:out std_logic_vector(WordWidth+bit_growth-1 downto 0);
filter_coef: in std_logic_vector(M*N_coef-1 downto 0);
enable,clear,reset,clk: in std_logic;
Q :in std_logic_vector(WordWidth_Q-1 downto 0)

);
end entity;

architecture RTL of FILTER_FIR is

--The cell mult and sum
component cell is 
generic (WordWidth:integer;--width signal of in/out
			M:integer;--width word of coefs
			WordWidth_Q:integer--width signal of Q
			
			);
			
port(

signal_input :in std_logic_vector(WordWidth-1 downto 0);
filter_coef: in std_logic_vector(M-1 downto 0);
reg_input:in std_logic_vector(WordWidth-1 downto 0);
signal_output:out std_logic_vector(WordWidth-1 downto 0);
clk,reset,clear,enable:in std_logic;
Q :in std_logic_vector(WordWidth_Q-1 downto 0)

); 
end component;

type array_aux is array(N_coef downto 0) of std_logic_vector(WordWidth+bit_growth-1 downto 0);
signal cell_aux: array_aux;
signal sext:std_logic_vector(bit_growth-1 downto 0);
begin
sext<=(others=>signal_input(WordWidth-1));
myfilter: 
	for k in N_coef-1 downto 0 generate
filter:cell
		generic map(
						WordWidth=>WordWidth+bit_growth,
						M=>M,
						WordWidth_Q=>WordWidth_Q
						
						)
						
		port map(
					signal_input=>sext&signal_input,
					signal_output=>cell_aux(k),
					filter_coef=>filter_coef((k+1)*M-1 downto k*M),
					reg_input=>cell_aux(k+1),		
					enable=>enable,
					clk=>clk,
					reset=>reset,
					clear=>clear,
					Q=>Q
					
					);
		signal_output<=cell_aux(0)(WordWidth+bit_growth-1 downto 0);
	end generate;
	
end architecture;
