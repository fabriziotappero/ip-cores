
-- smlttion for AMI encoder. 

entity smlt_ami_enc is
end smlt_ami_enc; 

architecture behaviour of smlt_ami_enc is
	--data type: 
	component ami_enc
	port ( 
		clr_bar, 
		clk   : in  bit; 
		e     : in  bit;
		s0, s1: out bit);
	end component; 
	--binding: 
	for a: ami_enc use entity work.ami_enc; 

	--declaring the signals present in this architecture: 
	signal CLK, E, S0, S1, clrb: bit;
	signal inpute: bit_vector(0 to 26); 

	begin --architecture. 
		a: ami_enc port map 
		( clr_bar => clrb, clk => CLK, e => E, s0 => S0, 
		s1 => S1 );

		inpute <= "000101011000101100101000111";

	process begin
		clrb <= '1'; 
                for i in 0 to 26 loop
			E <= inpute(i); 
                        CLK <= '0';
                        wait for 9 ns;
                        CLK <= '1';
                        wait for 1 ns;
                end loop;
                wait;
	end process; 


end behaviour; 
