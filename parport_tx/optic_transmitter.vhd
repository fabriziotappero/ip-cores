----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    04:53:24 12/11/2013 
-- Design Name: 
-- Module Name:    optic_transmitter - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.std_logic_unsigned.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


--each frame of 12bit take 12x4 period + 4 + 2 period  * 4; speed@50Mhz 230Khz

entity optic_transmitter is
    Port (
	 iCLK : in  STD_LOGIC;
	 s : in  STD_LOGIC_VECTOR (11 downto 0);
    optic_out : out  STD_LOGIC);
end optic_transmitter;

architecture Behavioral of optic_transmitter is

--output flip-flop
signal optic_flop:STD_LOGIC;
signal s_reg:STD_LOGIC_VECTOR(13 downto 0);
signal optic_cnt:STD_LOGIC_VECTOR(5 downto 0);
signal optic_sub_cnt:STD_LOGIC_VECTOR(1 downto 0);



begin

optic_out<=optic_flop;	--output (fiber optic)

optic_stage:process (iCLK)
begin 
	if (iCLK'event and iCLK = '1') then
		optic_sub_cnt<=optic_sub_cnt+1;
		if(optic_sub_cnt=0) then
			if(optic_cnt=0)then 
				s_reg<=(13=>'0')&s(11 downto 0)&(0=>'1');	--0xxxxxxxx1 where the last 1 is halved
			elsif(optic_cnt(1 downto 0)="00")then
				s_reg<=s_reg(12 downto 0)&'0';
			end if;

			if(optic_cnt(0)=optic_cnt(1)) then	--00 and 11
				optic_flop<=not optic_cnt(0);
			else											--01 and 10
				optic_flop<=optic_cnt(0) xor s_reg(13);
			end if;
		
			if(optic_cnt=('1','1','0','1','0','1'))then	--53 because 13x4+2 value
				optic_cnt<=(others=>'0');
			else
				optic_cnt<=optic_cnt+1;
			end if;
		end if;--optic_sub_cnt divide iCLK
	end if;--iCLK event

end process;

end Behavioral;

