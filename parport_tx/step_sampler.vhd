----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    07:58:18 12/11/2013 
-- Design Name: 
-- Module Name:    step_sampler - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity step_sampler is
    Port ( iCLK : in  STD_LOGIC;
           step : in  STD_LOGIC;
           dir : in  STD_LOGIC;
           step_cnt : out  STD_LOGIC;
           dir_value : out  STD_LOGIC);
end step_sampler;

architecture Behavioral of step_sampler is

signal q:std_logic;
signal step_cnt_reg:std_logic;


begin

step_cnt<=step_cnt_reg;

step_sampler:process (iCLK)
begin 

	if (iCLK'event and iCLK= '1') then
		q<=step;
		if(q/=step and step='1')then
			dir_value<=dir;
			step_cnt_reg<=not step_cnt_reg;
		end if;
	end if;
end process;


end Behavioral;

