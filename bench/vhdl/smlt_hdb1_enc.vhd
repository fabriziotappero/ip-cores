
-- smlttion for HDB1 encoder. 

entity smlt_hdb1_enc is
end smlt_hdb1_enc; 

architecture behaviour of smlt_hdb1_enc is
	--data type: 
	component hdb1_enc
	port ( 
		clr_bar, 
		clk   : in  bit; 
		e     : in  bit;
		s0, s1: out bit);
	end component; 
	--binding: 
	for a: hdb1_enc use entity work.hdb1_enc; 

	--declaring the signals present in this architecture: 
	signal CLK, E, S0, S1, clrb: bit;
	signal inpute: bit_vector(0 to 24); 

	begin --architecture. 
		a: hdb1_enc port map 
		( clr_bar => clrb, clk => CLK, e => E, s0 => S0, 
		   s1 => S1 );

		inpute <= "0101011000101100101000011";

	process begin
		clrb <= '1'; 
                for i in 0 to 24 loop
			E <= inpute(i); 
                        CLK <= '0';
                        wait for 9 ns;
                        CLK <= '1';
                        wait for 1 ns;
                end loop;
                wait;
	end process; 


end behaviour; 
