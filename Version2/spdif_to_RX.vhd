
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.std_logic_unsigned.all;


entity spdif_to_RX is
    Port ( iCLK : in  STD_LOGIC;
           optic_in : in  STD_LOGIC;
           RX : out  STD_LOGIC;
			  
			  periodA : in STD_LOGIC_VECTOR(6 downto 0);
			  period10 : in STD_LOGIC_VECTOR(6 downto 0)
			 
	  
			 
			  );
end spdif_to_RX;

architecture Behavioral of spdif_to_RX is



--low pass
signal q1 : STD_LOGIC;
signal q2 : STD_LOGIC;
signal samp : STD_LOGIC;

--RX generator
signal samp2 : STD_LOGIC;
signal cnt : STD_LOGIC_VECTOR(7 downto 0);

signal learn : STD_LOGIC;




signal RX2 : STD_LOGIC;

begin



input_low_pass:process (iCLK)
begin

if (iCLK'event and iCLK= '1') then
	
	q1<=q2;
	q2<=optic_in;
	if(q1=q2)then
		samp<=q1;
	end if;
end if;

end process;

fiber_decoder:process (iCLK)
begin 

if (iCLK'event and iCLK= '1') then

	samp2<=samp;
	if(samp2/=samp and samp=learn) then
		if(cnt>period10+3) then--period10+3
			RX<='0';	--shift 0
			RX2<='0';
		elsif (cnt<=periodA) then
			RX<=RX2;	--shift1
			RX2<='1';
		elsif(cnt<period10-3)then--period10-3
			RX2<='1';	--shift already done, reload diffr. value
		else
			learn<=not learn;
		end if;	
		cnt<=(others=>'0');
	else
		if(cnt=periodA) then
			RX<=RX2;
		end if;
		cnt<=cnt+1;
	end if;

end if;
	
end process;

end Behavioral;

