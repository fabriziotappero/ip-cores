----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    05:31:10 12/11/2013 
-- Design Name: 
-- Module Name:    optic_receiver - Behavioral 
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

entity optic_receiver is
    Port ( iCLK : in  STD_LOGIC;
           optic_in : in  STD_LOGIC;
           s : out  STD_LOGIC_VECTOR (11 downto 0);
			  s_prev : out  STD_LOGIC_VECTOR (11 downto 0);
			  step_sync : out  STD_LOGIC);
end optic_receiver;

architecture Behavioral of optic_receiver is


signal q1 : STD_LOGIC;
signal q2 : STD_LOGIC;
signal samp2 : STD_LOGIC;

signal samp : STD_LOGIC;
signal cnt : STD_LOGIC_VECTOR(4 downto 0);
signal s_reg : STD_LOGIC_VECTOR(11 downto 0);
signal N1 : STD_LOGIC;
--signal s_prev : STD_LOGIC_VECTOR(2 downto 0);
signal s_recv : STD_LOGIC_VECTOR(11 downto 0);
signal bit_count: STD_LOGIC_VECTOR(3 downto 0);


begin

step_sync<='1' when (bit_count>=4 and bit_count<8) else '0';
s<=s_recv;

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
	

	--samp<=optic_in;
	--if(samp/=optic_in and samp='0') then
	samp2<=samp;
	if(samp2/=samp and samp='1') then

		if(cnt>11) then		--12 = 3/4 of a 16 period (ideally 7 or 15)
			if(N1='1')then
				--s<=s_reg(11 downto 3)&(s_reg(2 downto 0) xor s_prev);
				--s<=s_reg(11 downto 0);
				--s_prev<=s_reg(2 downto 0);
				s_prev<=s_recv;
				s_recv<=s_reg;
				bit_count<=(others=>'0');
			else
				s_reg<=s_reg(10 downto 0)&'0';
				bit_count<=bit_count+1;
			end if;
			N1<='0';
		else
			if(N1='1')then
				s_reg<=s_reg(10 downto 0)&'1';--shift 1
				bit_count<=bit_count+1;
			end if;
			N1<= not N1;
		end if;
	
		cnt<=(others=>'0');
	else
		cnt<=cnt+1;
	end if;

end if;
	
end process;

end Behavioral;

