----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    04:52:11 12/11/2013 
-- Design Name: 
-- Module Name:    main - Behavioral 
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

entity main is
    Port ( iCLK : in  STD_LOGIC;
           parallel_out : out  STD_LOGIC_VECTOR (11 downto 0);
           fiber_in : in  STD_LOGIC;
			  led : out  STD_LOGIC
			  );
       
end main;

architecture Behavioral of main is


COMPONENT optic_receiver
	PORT(
		iCLK : IN std_logic;          	
		OPTIC_IN : IN std_logic;
		s : OUT STD_LOGIC_VECTOR(11 downto 0);
		s_prev : OUT STD_LOGIC_VECTOR(11 downto 0);
		step_sync : OUT STD_LOGIC
		);
	END COMPONENT;

signal s:std_logic_vector(11 downto 0);
signal s_prev:std_logic_vector(11 downto 0);
signal step_sync:std_logic;
signal led_reg:std_logic;
signal led_cnt:std_logic_vector(19 downto 0);
begin



--parallel_out<=s(11 downto 3)&((s(2) xor s_prev(2)) and step_sync)&((s(1) xor s_prev(1)) and step_sync)&((s(0) xor s_prev(0)) and step_sync);
--parallel_out<=s(11 downto 0);

parallel_out<=(
				0=>(s(0) xor s_prev(0)) and step_sync,--step x
				1=>s(1),
				2=>(s(2) xor s_prev(2)) and step_sync,--step a
				3=>s(3),
				4=>(s(4) xor s_prev(4)) and step_sync,--step y
				5=>s(5),
				6=>s(6),
				7=>(s(7) xor s_prev(7)) and step_sync,--step z
				8=>s(8),
				9=>s(9),
				10=>s(10),
				11=>s(11));



led<=led_reg;

optic_receiver_inst:optic_receiver
    Port map ( iCLK=> iCLK,
              optic_in => fiber_in,
				  s => s,
				  s_prev => s_prev,
				  step_sync => step_sync
				  );
			
led_proc:process (iCLK)
begin
	if (iCLK'event and iCLK= '1') then
		if(led_cnt=0)then
			led_reg<=not led_reg;
		end if;
		led_cnt<=led_cnt+1;
	end if;
end process;

end Behavioral;

