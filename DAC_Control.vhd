-----------------------------------------------------------------------------------------
-- Engineer: Tomas Daujotas (mailsoc@gmail.com www.scrts.net)
-- 
-- Create Date: 2010-07-21 
-- Design Name: Control of LTC2624 Quad 12 bit DAC on Spartan-3E Starter Kit (32bit mode)
-----------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DAC_Control is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  DAC_DATA : in STD_LOGIC_VECTOR(31 downto 0);
           DAC_MOSI : out  STD_LOGIC;
           DAC_SCK : out  STD_LOGIC;
           DAC_CS : out  STD_LOGIC;
           RDY : out  STD_LOGIC);
end DAC_Control;

architecture DAC_Control of DAC_Control is

type state_type is (idle,ready,send,dummy,check);
signal state : state_type;
signal DAC_SEND : std_logic_vector(31 downto 0);

begin
	process(DAC_DATA)
	begin
		for i in 31 downto 0 loop
			DAC_SEND(i) <= DAC_DATA(31 - i); -- The data must be MSB first
		end loop;
	end process;
	
	process(CLK,RST)	
	
	variable index : integer range 0 to 32 := 0;
	
	begin
		if (RST = '1') then
			index := 0;
		elsif rising_edge(CLK) then	
			case state is
				when idle =>
					DAC_SCK <= '0';
					DAC_CS <= '1';
					index := 0;
					DAC_MOSI <= '0';
					RDY <= '1';
					state <= ready;
				when ready =>
					RDY <= '0';
					DAC_CS <= '0';
					DAC_SCK <= '0';
					DAC_MOSI <= DAC_SEND(index);
					state <= dummy;
				when dummy =>
					state <= send;
				when send =>
					DAC_SCK <= '1';
					state <= check;
					index := index + 1;
				when check =>
					DAC_SCK <= '1';
					if (index = 32) then
						state <= idle;
					else
						state <= ready;
					end if;
			end case;	
		end if;	
	end process;

end DAC_Control;

