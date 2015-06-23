
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity spdif_to_RX is
    Port ( iCLK : in  STD_LOGIC;
           optic_in : in  STD_LOGIC;
           RX : out  STD_LOGIC;
			  learn_out : out  STD_LOGIC
			  );
end spdif_to_RX;

architecture Behavioral of spdif_to_RX is



--low pass
signal q1 : STD_LOGIC;
signal q2 : STD_LOGIC;
signal samp : STD_LOGIC;

--RX generator
signal samp2 : STD_LOGIC;
signal cnt : natural range 0 to 63;

signal learn : STD_LOGIC;

--constant periode_1_max : natural := (20+7);
--constant periode_0_min : natural := (40-7);


signal RX2 : STD_LOGIC;

begin
learn_out<=learn;


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
		if(cnt>33) then
			RX<='0';	--shift 0
			RX2<='0';
		elsif (cnt<=20) then
			RX<=RX2;	--shift1
			RX2<='1';
		elsif(cnt<27)then
			RX2<='1';	--shift already done, reload diffr. value
		else
			learn<=not learn;
		end if;	
		cnt<=0;
	else
		if(cnt=20) then
			RX<=RX2;
		end if;
		if(cnt<63) then
			cnt<=cnt+1;
		end if;
	end if;

end if;
	
end process;

end Behavioral;

