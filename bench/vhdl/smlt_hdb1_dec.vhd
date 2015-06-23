-- smlttion for HDB1 decoder. 

entity smlt_hdb1_dec is
end smlt_hdb1_dec; 

architecture behaviour of smlt_hdb1_dec is
	--data type: 
	component hdb1_dec
	port ( 
		clr_bar, 
		clk, e0, e1 : in  bit; 
		s           : out bit);
	end component; 
	--binding: 
	for a: hdb1_dec use entity work.hdb1_dec; 

	--declaring the signals present in this architecture: 
	signal CLK, S, E0, E1, clrb: bit;
	signal input0, input1: bit_vector(0 to 24); 

	begin --architecture. 
		a: hdb1_dec port map 
		( clr_bar => clrb, clk=> CLK, e0 => E0, e1 => E1,
		  s => S );

		input0 <=  "0100010110001011001001101";
		input1 <=  "0001001000100100100110010";

	process begin
		clrb <= '1';
                for i in 0 to 24 loop
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
