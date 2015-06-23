library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Barrel_Shifter_left is 

generic (

	WordWidth_in:integer:=20;--width signal of in
	WordWidth_out:integer:=32;--width signal of out
	WordWidth_Q:integer:=4--width signal of Q
); 
port(
signal_input :in std_logic_vector(WordWidth_in-1 downto 0);
signal_out :out std_logic_vector(WordWidth_out-1 downto 0);
Q :in std_logic_vector(WordWidth_Q-1 downto 0)
);
end entity;

architecture RTL of Barrel_Shifter_left is 
signal signal_aux: std_logic_vector(WordWidth_out-1 downto 0);
signal signal_aux_input: std_logic_vector(WordWidth_out-1 downto 0);
signal sext: std_logic_vector(WordWidth_out-WordWidth_in-1 downto 0);
begin 

sext<= (others=>signal_input(WordWidth_in-1));
signal_aux_input<= sext & signal_input;

--signal_aux<=std_logic_vector(signed(signal_input)*to_signed(2**(to_integer(-signed(Q))),24));
signal_aux<=to_stdlogicvector(to_bitvector(signal_aux_input) sll to_integer(unsigned(Q)));
--signal_aux<=std_logic_vector(signed(signal_input) ror (to_integer(unsigned(Q))));
signal_out<=signal_aux;
end architecture;