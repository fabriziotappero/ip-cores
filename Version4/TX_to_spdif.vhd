library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.std_logic_unsigned.all;
--use IEEE.NUMERIC_STD.ALL;


entity TX_to_spdif is
    Port ( iCLK : in  STD_LOGIC;
           TX : in  STD_LOGIC;
           optic_out : out  STD_LOGIC;
			  period01 : in STD_LOGIC_VECTOR(6 downto 0);
			  periodA : in STD_LOGIC_VECTOR(6 downto 0);
			  period10 : in STD_LOGIC_VECTOR(6 downto 0);
			  period : in STD_LOGIC_VECTOR(6 downto 0);
			  baud_div : in STD_LOGIC_VECTOR(6 downto 0);
			  direct_mode : in STD_LOGIC
			  );
end TX_to_spdif;

architecture Behavioral of TX_to_spdif is


--output flip-flop
signal optic_flop:STD_LOGIC:='0';
--optic stage 
signal optic_cnt : STD_LOGIC_VECTOR(6 downto 0):=(0=>'1',others=>'0');	--count 1 to Fosc/fiber bitrate
signal optic_bit:STD_LOGIC;
--input stage
signal tx_cnt : STD_LOGIC_VECTOR(6 downto 0);		--count 1 to Fosc/fiber bitrate
signal tx_bit:STD_LOGIC:='1';								--bit received on TX
signal start_detected : STD_LOGIC:='0';
signal bit_position : STD_LOGIC_VECTOR(3 downto 0);--value 0-9 (bit position from start to stop)
--baud division
signal baud_div_cnt : STD_LOGIC_VECTOR(6 downto 0);--fiber bitrate / TX bitrate


begin

optic_out<=optic_flop;	--output (fiber optic)

--generate signal on fiber optic
optic_stage:process (iCLK)

begin 

if (iCLK'event and iCLK = '1') then

	if(optic_cnt = period) then
		optic_cnt<=(0=>'1',others=>'0');
	else
		optic_cnt<=optic_cnt+1;
	end if;

	if((optic_cnt=periodA) or
	((optic_cnt=period10 or optic_cnt=period01) and optic_bit='1')) then
		optic_flop<=not optic_flop;--other edge
	end if;
	
	if(optic_cnt=period)then
		optic_flop<='1';				--rising edge
	end if;
	
	if(optic_cnt=period) then
			optic_bit<=tx_bit;		--reload input at fiber baud rate
	end if;

	
end if;
	
end process;

--Synchronize input (TX pin) with local clock
input_stage: process (iCLK,TX)
begin  
if (iCLK'event and iCLK = '1') then
   if(direct_mode='1')then
		tx_bit<=TX;
	elsif(start_detected='0') then
		if(TX='0') then
			start_detected<='1';
			tx_cnt<=(0=>'1',others=>'0');
			bit_position<=(others=>'0');
			baud_div_cnt<=(0=>'1',others=>'0');
		end if;	
	else											--start detected=1
		if(baud_div_cnt=baud_div)then		--multiply with baud div
			if(tx_cnt=periodA)then
				tx_bit<=TX;						--sample every bit time (n+0.5 bit time from start)
			elsif(tx_cnt=period10)then
				if(tx_bit='1' and bit_position=9 and baud_div>2)then
					start_detected<='0';		--resync early stop length >=3/4 period
				end if;				
			elsif(tx_cnt=period)then
				if(bit_position/=9)then
					bit_position<=bit_position+1;
				end if;
				if(bit_position=9 and tx_bit='1') then --stop bit
					bit_position<=(others=>'0');
					if(TX='1')then
						start_detected<='0';	--resync
					end if;
				end if;
			end if;
			if(tx_cnt=period)then
				tx_cnt<=(0=>'1',others=>'0');
			else
				tx_cnt<=tx_cnt+1;
			end if;
			baud_div_cnt<=(0=>'1',others=>'0');
		else
			baud_div_cnt<=baud_div_cnt+1;
		end if;--baud_div
	end if;--start detected
end if;--clk event			
	
end process;
end Behavioral;

