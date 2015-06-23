
-- implementation of the HDB1 decoder. 

entity hdb1_dec is
	port (
	clr_bar, 
	clk, e0, e1 : in    bit; -- inputs.
	s           : out   bit  -- output.
	);
end hdb1_dec; 

architecture behaviour of hdb1_dec is
     signal q0, q1: bit;  -- two flipflops.
begin
     process (clk, clr_bar) begin
     		if clr_bar = '0' then
			q0 <= '0'; 
			q1 <= '0'; 
			s  <= '0'; 
		elsif clk'event and clk = '1' then
			s  <= ( q0 and (not e0) ) or ( q1 and (not e1) ); 
			q0 <= (not q0) and e0;   
			q1 <= (not q1) and e1;   
		end if; 
     end process; 
end behaviour; 
