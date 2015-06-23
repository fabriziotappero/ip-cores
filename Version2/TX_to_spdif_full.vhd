library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.std_logic_unsigned.all;
--use IEEE.NUMERIC_STD.ALL;


entity TX_to_spdif_full is
    Port ( iCLK : in  STD_LOGIC;
           TX : in  STD_LOGIC;
           optic_out : out  STD_LOGIC;
			  period01 : in STD_LOGIC_VECTOR(6 downto 0);
			  periodA : in STD_LOGIC_VECTOR(6 downto 0);
			  period10 : in STD_LOGIC_VECTOR(6 downto 0);
			  period : in STD_LOGIC_VECTOR(6 downto 0);
			  baud_div : in STD_LOGIC_VECTOR(6 downto 0)
			  );
end TX_to_spdif_full;

architecture Behavioral of TX_to_spdif_full is


--output flip-flop
signal optic_flop:STD_LOGIC:='0';
--optic stage 
signal optic_cnt : STD_LOGIC_VECTOR(6 downto 0):=(0=>'1',others=>'0');	--value 0 to 9 (divide 50Mhz/10=5Mhz)
signal optic_bit:STD_LOGIC;
--input stage
signal tx_cnt : STD_LOGIC_VECTOR(6 downto 0);		--value 0-19 (divide 50Mhz/20=2.5Mhz)
signal tx_bit:STD_LOGIC:='1';
signal start_detected : STD_LOGIC:='0';
signal tx_half : STD_LOGIC;								--1/2 bit
signal bit_position : STD_LOGIC_VECTOR(3 downto 0);--value 0-9 (bit position from start to stop)
--baud division
signal baud_div_cnt : STD_LOGIC_VECTOR(6 downto 0);


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

	
	if((optic_cnt=period or optic_cnt=periodA) or
	((optic_cnt=period10 or optic_cnt=period01) and optic_bit='1')) then
		optic_flop<=not optic_flop;		--2.5Mhz / 1.25Mhz signal  for 1 / 0
	end if;
	
	if(optic_cnt=period) then
			optic_bit<=tx_bit;	--reload input at baud rate
	end if;

	
end if;
	
end process;

--Synchronize input (TX pin) with local clock
input_stage: process (iCLK,TX)
begin  
if (iCLK'event and iCLK = '1') then
	if(start_detected='0') then
		if(TX='0') then
			start_detected<='1';
			tx_cnt<=(0=>'1',others=>'0');
			bit_position<=(others=>'0');
			tx_half<='0';
			baud_div_cnt<=(0=>'1',others=>'0');
		end if;	
	else											--start detected=1
		if(baud_div_cnt=baud_div)then		--multiply with baud div
			if(tx_cnt=periodA or tx_cnt=period) then		--0.5 bit time
				if(tx_half='0')then
					tx_bit<=TX;						--sample every bit time (n+0.5 bit time from start)
					if(TX='1' and bit_position=9 and baud_div/=1)then
						start_detected<='0';--resync early if 2 x baudrate <= optic rate (in this case baudrate could be an approximation)
					end if;
				elsif(tx_half='1')then
					if(bit_position/=9)then
						bit_position<=bit_position+1;
					end if;
					if(bit_position=9 and tx_bit='1') then --stop bit
						bit_position<=(others=>'0');
						if(TX='1')then
							start_detected<='0';--resync
						end if;
					end if;
				end if;
				tx_half<=not tx_half;			--next 1/2 bit
			end if;--tx_cnt
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

