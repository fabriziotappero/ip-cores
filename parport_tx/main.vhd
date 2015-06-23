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
           parallel_in : in  STD_LOGIC_VECTOR (11 downto 0);
           fiber_out : out  STD_LOGIC;
  			  led : out  STD_LOGIC);
end main;

architecture Behavioral of main is


COMPONENT optic_transmitter
	PORT(
		iCLK : IN std_logic;
      s    : IN  STD_LOGIC_VECTOR(11 downto 0);
		OPTIC_OUT : OUT std_logic
		);
	END COMPONENT;
COMPONENT step_sampler
	PORT(
		iCLK : IN std_logic;
      step    : IN  STD_LOGIC;
		dir    : IN  STD_LOGIC;
		step_cnt   : OUT  STD_LOGIC;
		dir_value : OUT std_logic
		);
	END COMPONENT;

signal step_cnt_x:std_logic;
signal dir_value_x:std_logic;
signal step_cnt_y:std_logic;
signal dir_value_y:std_logic;
signal step_cnt_z:std_logic;
signal dir_value_z:std_logic;
signal step_cnt_a:std_logic;
signal dir_value_a:std_logic;
signal s:std_logic_vector(11 downto 0);

signal led_reg:std_logic;
signal led_cnt:std_logic_vector(19 downto 0);


begin
led<=led_reg;
--s<=parallel_in(11 downto 6)&dir_value_z&dir_value_y&dir_value_x&step_cnt_z&step_cnt_y&step_cnt_x;
--s<=parallel_in(11 downto 0);
s<=(
		0=>step_cnt_x,
		1=>dir_value_x,
		2=>step_cnt_a,
		3=>parallel_in(3),
		4=>step_cnt_y,
		5=>dir_value_y,
		6=>parallel_in(6),
		7=>step_cnt_z,
		8=>dir_value_z,
		9=>dir_value_a,
		10=>parallel_in(10),
		11=>parallel_in(11)
		);
		


X_inst:step_sampler
    Port map ( iCLK=> iCLK,
              step => parallel_in(0),
				  dir => parallel_in(1),
				  step_cnt=>step_cnt_x,
				  dir_value => dir_value_x
				  );
Y_inst:step_sampler
    Port map ( iCLK=> iCLK,
              step => parallel_in(4),
				  dir => parallel_in(5),
				  step_cnt=>step_cnt_y,
				  dir_value => dir_value_y
				  );
Z_inst:step_sampler
    Port map ( iCLK=> iCLK,
              step => parallel_in(7),
				  dir => parallel_in(8),
				  step_cnt=>step_cnt_z,
				  dir_value => dir_value_z
				  );				
A_inst:step_sampler
    Port map ( iCLK=> iCLK,
              step => parallel_in(2),
				  dir => parallel_in(9),
				  step_cnt=>step_cnt_a,
				  dir_value => dir_value_a
				  );				


optic_transmitter_inst:optic_transmitter
    Port map ( iCLK=> iCLK,
	           s => s,
              optic_out => fiber_out
				  
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

