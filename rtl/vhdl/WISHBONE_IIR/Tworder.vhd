library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Tworder is 
generic (WordWidth:integer;--:=16;--width signal of in/out
			Bit_growth:integer;--:=8; 
			M:integer;--:=16;--width word of coefs
			Q:integer--:=15--Quantifer
			);
			
port(

signal_input :in std_logic_vector(WordWidth+Bit_growth-1 downto 0);
a0,a1,a2,b0,b1,b2: in std_logic_vector(M-1 downto 0);
signal_output:out std_logic_vector(WordWidth+Bit_growth-1 downto 0);
clk,reset,clear,enable:in std_logic

); 
end entity;

architecture typeII of Tworder is 
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

signal signal_output_aux,signal_input_aux: std_logic_vector(M+Bit_growth+WordWidth-1 downto 0);
signal sum_in,sum_out_aux,sum_out: std_logic_vector((M+WordWidth+Bit_growth)-1 downto 0);
signal RegOut1,RegOut2,RegOut1_aux: std_logic_vector(WordWidth+Bit_growth-1 downto 0);
signal signal1_in,signal2_in,signal3_in,signal1_out,signal2_out,signal3_out : std_logic_vector(M+WordWidth+Bit_growth-1 downto 0);

begin

--EXTENSION DE SIGNO
signal_input_aux(WordWidth+Bit_growth+Q-1 downto Q)<=signal_input;
signal_input_aux(Q-1 downto 0)<=(others=>'0');
signal_input_aux(M+WordWidth+Bit_growth-1 downto WordWidth+Bit_growth+Q)<=(others=>signal_input(WordWidth+Bit_growth-1));



signal1_in<=std_logic_vector(signed(RegOut1)*signed(a1));
signal2_in<=std_logic_vector(signed(RegOut2)*signed(a2));
signal3_in<=signal_input_aux;
signal1_out<=std_logic_vector(signed(RegOut1)*signed(b1));
signal2_out<=std_logic_vector(signed(RegOut2)*signed(b2));
--signal3_out<=std_logic_vector(signed(sum_in_aux((WordWidth+Bit_growth-1)+Q downto Q))*signed(b0));
signal3_out<=std_logic_vector(signed(sum_in((WordWidth+Bit_growth-1)+Q downto Q))*signed(b0));

sum_in<=std_logic_vector(-(signed(signal1_in)) - (signed( signal2_in)) + signed(signal3_in));
sum_out<=std_logic_vector(signed(signal1_out)+ signed( signal2_out) + signed(signal3_out));
REG1:fullregister
generic map(
		N=>WordWidth+Bit_growth
)
	port map (
		clk=>clk,
		reset_n=>reset,
		enable=>enable,
		clear=>clear,
		d=>sum_in(WordWidth+Bit_growth+Q-1 downto Q),
		q=>RegOut1
		);
REG2:fullregister
generic map(
		N=>WordWidth+Bit_growth
)
	port map (
		clk=>clk,
		reset_n=>reset,
		enable=>enable,
		clear=>clear,
		d=>RegOut1,
		q=>RegOut2
		);
		
Reg_seg:fullregister
generic map(
		N=>M+WordWidth+Bit_growth
)
	port map (
		clk=>clk,
		reset_n=>reset,
		enable=>'1',
		clear=>clear,
		d=>sum_out,
		q=>sum_out_aux
		);		

		
signal_output<=sum_out_aux((WordWidth+Bit_growth-1)+Q downto Q);-----OJO

end architecture;


architecture typeIII of Tworder is 
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

signal signal_output_aux,signalV0_aux,signalV1_aux: std_logic_vector(M+Bit_growth+WordWidth-1 downto 0);
signal sum_V0, sum_V1,sum_out_aux,sum_out: std_logic_vector((M+WordWidth+Bit_growth)-1 downto 0);
signal RegOutV0,RegOutV1,signal_input_aux: std_logic_vector(WordWidth+Bit_growth-1 downto 0);
signal signal1_in,signal2_in,signal3_in,signal1_out,signal2_out,signal3_out : std_logic_vector(M+WordWidth+Bit_growth-1 downto 0);

begin
--
--/*Implementa una sección de segundo orden usando estructura directa tipo III*/
--delay_t sos_d3(const coeff_t *bk,const coeff_t *ak,delay_t *v,delay_t xn, uint8_t q){
--    acc_t yn;
--
--    /*Calcula salida*/
--    yn=(((acc_t)bk[0])*((acc_t)xn)+(((acc_t)v[0])<<q))>>q;
--
--    /*Actualización de la memoria del filtro*/
--    v[0]=(((acc_t)bk[1])*((acc_t)xn)-(((acc_t)ak[1])*((acc_t)yn))+(((acc_t)v[1])<<q))>>q;
--    v[1]=(((acc_t)bk[2])*((acc_t)xn)-(((acc_t)ak[2])*((acc_t)yn)))>>q;
--
--    /**Retorna salida*/
--    return yn;
--
--
--}

--EXTENSION DE SIGNO
signalV0_aux(WordWidth+Bit_growth+Q-1 downto Q)<=RegOutV0;
signalV0_aux(Q-1 downto 0)<=(others=>'0');
signalV0_aux(M+WordWidth+Bit_growth-1 downto WordWidth+Bit_growth+Q)<=(others=>RegOutV0(WordWidth+Bit_growth-1));

signalV1_aux(WordWidth+Bit_growth+Q-1 downto Q)<=RegOutV1;
signalV1_aux(Q-1 downto 0)<=(others=>'0');
signalV1_aux(M+WordWidth+Bit_growth-1 downto WordWidth+Bit_growth+Q)<=(others=>RegOutV1(WordWidth+Bit_growth-1));







signal1_in<=std_logic_vector(signed(signal_input)*signed(b0));
signal2_in<=std_logic_vector(signed(signal_input_aux)*signed(b1));
signal3_in<=std_logic_vector(signed(signal_input_aux)*signed(b2));




signal2_out<=std_logic_vector(signed(sum_out_aux((WordWidth+Bit_growth-1)+Q downto Q))*signed(a1));
signal3_out<=std_logic_vector(signed(sum_out_aux((WordWidth+Bit_growth-1)+Q downto Q))*signed(a2));

sum_V0<=std_logic_vector(-(signed(signal2_out)) + (signed( signal2_in)) + signed(signalV1_aux));
sum_V1<=std_logic_vector(-(signed(signal3_out)) + (signed( signal3_in)));


sum_out<=std_logic_vector(signed(signal1_in)+ signed( signalV0_aux));


REG1:fullregister
generic map(
		N=>WordWidth+Bit_growth
)
	port map (
		clk=>clk,
		reset_n=>reset,
		enable=>enable,
		clear=>clear,
		d=>sum_V0(WordWidth+Bit_growth+Q-1 downto Q),
		q=>RegOutV0
		);
		
		
REG2:fullregister
generic map(
		N=>WordWidth+Bit_growth
)
	port map (
		clk=>clk,
		reset_n=>reset,
		enable=>enable,
		clear=>clear,
		d=>sum_V1(WordWidth+Bit_growth+Q-1 downto Q),
		q=>RegOutV1
		);
		
Reg_seg1:fullregister
generic map(
		N=>M+WordWidth+Bit_growth
)
	port map (
		clk=>clk,
		reset_n=>reset,
		enable=>'1',
		clear=>clear,
		d=>sum_out,
		q=>sum_out_aux
		);	
	
Reg_seg2:fullregister
generic map(
		N=>WordWidth+Bit_growth
)
	port map (
		clk=>clk,
		reset_n=>reset,
		enable=>'1',
		clear=>clear,
		d=>signal_input,
		q=>signal_input_aux
		);		

		
signal_output<=sum_out_aux((WordWidth+Bit_growth-1)+Q downto Q);-----OJO

end architecture;