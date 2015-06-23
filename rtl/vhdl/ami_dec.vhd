
-- implementation of the AMI decoder. 

entity ami_dec is
	port (
	clr_bar, 
	e0, e1      : in    bit; -- inputs.
	s           : out   bit  -- output.
	);
end ami_dec; 

architecture behaviour of ami_dec is
begin
     process (e0, e1, clr_bar) begin
     		if (clr_bar = '0')then
			s <= '0'; 
		end if; 
		s <=  e0 or e1; 
     end process; 
end behaviour; 
