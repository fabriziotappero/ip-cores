
-- implementation of the AMI encoder. 

entity ami_enc is
	port (
	clr_bar, 
	clk         : in    bit; -- clock input.
	e           : in    bit; -- input.
	s0, s1      : out   bit  -- output.
	);
end ami_enc; 

architecture behaviour of ami_enc is
	signal q    : bit;      -- 1 flipflops for 2 states. 
begin
     process (clk, clr_bar) begin
        if clr_bar = '0' then 
		q  <= '0'; 
		s1 <= '0'; 
		s0 <= '0'; 
	elsif clk'event and clk = '1' then
		q  <= q xor e; 
		s1 <= q and e; 
		s0 <= e and (not q); 
	end if;
     end process; 
end behaviour; 
