
-- implementation of the HDB1 encoder. 

entity hdb1_enc is
	port (
	clr_bar, 
	clk         : in    bit; -- clock input.
	e           : in    bit; -- input.
	s0, s1      : out   bit  -- output.
	);
end hdb1_enc; 

architecture behaviour of hdb1_enc is
	signal q0, q1, q2    : bit;      -- 3 flipflops for 6 states. 
begin
     process (clk, clr_bar) begin
        if clr_bar = '0' then 
		q0 <= '0'; 
		q1 <= '0'; 
		q2 <= '0'; 
		s0 <= '0'; 
		s1 <= '0'; 
	elsif clk'event and clk = '1' then

		q0 <= (e and (not q1))
		      or ((not e) and (not q0) and  q1 and q2 )
		      or ((not e) and q0 and  q1 and (not q2) ); 
		      
		q1 <= (e and (not q1))
		      or ((not q1) and q2)
		      or ((not e) and q1 and (not q2));

		q2 <= (not e) and (not q2); 

		s0 <= ((not q1) and (not q2))
		      or ((not e)and q1 and q2); 

		s1 <= (q1 and (not q2)) 
		      or ((not e) and (not q1) and q2);
		    
	end if;
     end process; 
end behaviour; 
