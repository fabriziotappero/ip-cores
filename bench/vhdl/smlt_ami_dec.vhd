-- smlttion for AMI decoder. 

entity smlt_ami_dec is
end smlt_ami_dec; 

architecture behaviour of smlt_ami_dec is
	--data type: 
	component ami_dec
	port ( 
	        clr_bar, 
		e0, e1: in  bit; 
		s     : out bit);
	end component; 
	--binding: 
	for a: ami_dec use entity work.ami_dec; 

	--declaring the signals present in this architecture: 
	signal CLK, S, E0, E1, clrb: bit;
	signal input0, input1: bit_vector(0 to 26); 

	begin --architecture. 
		a: ami_dec port map 
		( clr_bar => clrb, e0 => E0, e1 => E1, s => S );

		input0 <= "000100010000100100001000010";
		input1 <= "000001001000001000100000101";

	process begin
		clrb <= '1'; 
                for i in 0 to 26 loop
			E0 <= input0(i); 
			E1 <= input1(i); 
                        CLK <= '0';
                        wait for 9 ns;
                        CLK <= '1';
                        wait for 1 ns;
                end loop;
                wait;
	end process; 


end behaviour; 
