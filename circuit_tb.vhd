LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE std.textio.ALL;

ENTITY circuit_tb IS
END circuit_tb;

ARCHITECTURE behavior OF circuit_tb IS 

file vectors: text open read_mode is "fm.txt";


	COMPONENT circuit
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		fmin : IN std_logic_vector(7 downto 0);          
		dmout : OUT std_logic_vector(11 downto 0)
		);
	END COMPONENT;

	SIGNAL clk :  std_logic := '0' ;
	SIGNAL reset    : std_logic := '1';	
	SIGNAL fmin :  std_logic_vector(7 downto 0);
	SIGNAL dmout :  std_logic_vector(11 downto 0);
	constant clkperiod : time := 62.5 ns; -- 16 MHz of frequency

BEGIN

	uut: circuit PORT MAP(
		clk => clk,
		reset => reset,
		fmin => fmin,
		dmout => dmout
	);

    RESET_GEN: process
    begin
        LOOP1: for N in 0 to 3 loop
           wait until falling_edge(CLK);
        end loop LOOP1;
        RESET <= '0' ;
    end process RESET_GEN;

clk <= not clk after clkperiod / 2;

process
variable vectorline : line;
variable fmin_var : bit_vector(7 downto 0);
begin
while not endfile(vectors) loop
	if (reset = '1') then
			fmin <= (others => '0');
	else
			readline(vectors, vectorline);
			read(vectorline, fmin_var);
			fmin <= to_stdlogicvector(fmin_var);
	end if;
		wait for clkperiod;
end loop;
end process; 

END;
