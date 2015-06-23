library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity RAM_Memory is 
generic(

Add_WordWidth: integer:=10;
Data_WordWidth: integer:=32
);
port(
 DATi: in   std_logic_vector( Data_WordWidth-1 downto 0 );
 DATo: out   std_logic_vector( Data_WordWidth-1 downto 0 );
 ADR_WB: in    std_logic_vector( Add_WordWidth-1 downto 0 );
 ADR_FFT: in    std_logic_vector( Add_WordWidth-1 downto 0 );
 W_R: in    std_logic;
 clk: in std_logic
 );
end entity;

architecture RTL of RAM_Memory is

type array_aux is array((2**Add_WordWidth)-1 downto 0) of std_logic_vector(Data_WordWidth-1 downto 0);
signal mem:array_aux;
signal  reg0: std_logic_vector(Data_WordWidth-1 downto 0);
begin
process(clk)
begin
	if rising_edge(clk) then 
			
			if ( W_R='1') then
					mem(to_integer(unsigned(ADR_FFT)))<=DATi   ;  
			end if;	
			
				
				--DATo<=reg0;
	DATo <=  mem(to_integer(unsigned(ADR_WB)));  			
		
	end if;
	
	
	
	
end process;
end architecture;