library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--The cell mult and sum
entity cell is 
generic (WordWidth:integer:=24;--width signal of in/out
			M:integer:=16;--width word of coefs
			WordWidth_Q:integer:=4--width signal of Q
			);
			
port(

signal_input :in std_logic_vector(WordWidth-1 downto 0);
filter_coef: in std_logic_vector(M-1 downto 0);
reg_input:in std_logic_vector(WordWidth-1 downto 0);
signal_output:out std_logic_vector(WordWidth-1 downto 0);
clk,reset,clear,enable:in std_logic;
Q :in std_logic_vector(WordWidth_Q-1 downto 0)

); 
end entity;

architecture RTL of cell is 
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

component Barrel_Shifter is 

generic (

	WordWidth_in:integer;--width signal of in
	WordWidth_out:integer;--width signal of out
	WordWidth_Q:integer--width signal of Q
); 
port(
signal_input :in std_logic_vector(WordWidth_in-1 downto 0);
signal_out :out std_logic_vector(WordWidth_out-1 downto 0);
Q :in std_logic_vector(WordWidth_Q-1 downto 0)
);
end component;

component Barrel_Shifter_left is 

generic (

	WordWidth_in:integer;--width signal of in
	WordWidth_out:integer;--width signal of out
	WordWidth_Q:integer--width signal of Q
); 
port(
signal_input :in std_logic_vector(WordWidth_in-1 downto 0);
signal_out :out std_logic_vector(WordWidth_out-1 downto 0);
Q :in std_logic_vector(WordWidth_Q-1 downto 0)
);
end component;

signal signal_output_aux: std_logic_vector(WordWidth-1 downto 0);
signal sum_mult: std_logic_vector(M+WordWidth-1 downto 0);
signal reg_input_aux,reg_output_aux:std_logic_vector(M+WordWidth-1 downto 0);
--signal sext:std_logic_vector(WordWidth-Q downto 0);
begin

--reg_input_aux(Q-1 downto 0)<= (others =>'0');
--sext<=(others=>reg_input(WordWidth-1));
--reg_input_aux(2*wordwidth downto Q)<=sext & reg_input; 

Barrel_Shifter2:Barrel_Shifter_left

generic map(

	WordWidth_in=>WordWidth,
	WordWidth_out=>WordWidth+M,
	WordWidth_Q=>WordWidth_Q
) 
port map(
signal_input=>reg_input,
signal_out=>reg_input_aux,
Q=>Q
);



sum_mult<=std_logic_vector((signed(filter_coef)*signed(signal_input)) + signed(reg_input_aux));

mycell:fullregister
generic map(
		N=>M+WordWidth
)
	port map (
		clk=>clk,
		reset_n=>reset,
		enable=>enable,
		clear=>clear,
		d=>sum_mult,
		q=>reg_output_aux
		);
		
Barrel_Shifter1:Barrel_Shifter 

generic map(

	WordWidth_in=>WordWidth+M,
	WordWidth_out=>WordWidth,
	WordWidth_Q=>WordWidth_Q
) 
port map(
signal_input=>reg_output_aux,
signal_out=>signal_output_aux,
Q=>Q
);
		

signal_output<=signal_output_aux;
	
end architecture;