----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:28:06 01/11/2011 
-- Design Name: 
-- Module Name:    CONFIG_CONTROL - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CONFIG_CONTROL is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           config_en : in  STD_LOGIC;
			  nxt_sof : in STD_LOGIC;
			  wren : out  STD_LOGIC;
           addr : out  STD_LOGIC_VECTOR (5 downto 0);
			  ulock_en : in  STD_LOGIC;
			  wren_checksum_1 : out  STD_LOGIC;
			  wren_checksum_2 : out  STD_LOGIC;
			  locked : out  STD_LOGIC
			 );
end CONFIG_CONTROL;

architecture Behavioral of CONFIG_CONTROL is

TYPE state is (rst_state,
					idle_state,
					pre_config_state,
					config_state,
					lock_state
				);
					
signal current_st,next_st: state;

signal rst_count, en_count, stop_s, wren_checksum_1_t: std_logic;
signal counter: std_logic_vector(5 downto 0);




component wraddr_lut_mem is
  port (
    clk : in STD_LOGIC := 'X'; 
    a : in STD_LOGIC_VECTOR ( 5 downto 0 ); 
    qspo : out STD_LOGIC_VECTOR ( 5 downto 0 ) 
  );
end component;

begin

process(clk)
begin
if (rst='1') then
	current_st<= rst_state;
elsif (clk'event and clk='1') then
	current_st <= next_st;
end if;
end process;


process(current_st,config_en,nxt_sof,ulock_en,stop_s)
begin 
case current_st is

when rst_state =>

	rst_count <='1';
	en_count <='0';
	
	wren <='0';
	
	locked<='0';
	
  	next_st<=idle_state;	
	
when idle_state =>

	rst_count <='0';
	en_count <='0';

	wren <='0';
	
	locked<='0';
	
	if config_en='1' then
		next_st <= pre_config_state;
	else
		next_st <= idle_state;
	end if;

when pre_config_state =>	

	rst_count <='0';
	en_count <='0';
	
	wren <='0';
	
	locked<='0';
	
  	if nxt_sof='0' then
		en_count <='1';
		next_st <= config_state;
	else
		en_count <='0';
		next_st <= pre_config_state;
	end if;


when config_state =>	

	rst_count <='0';
	en_count <='1';
	
	wren <='1';
	
	locked<='0';
	
  	if stop_s='1' then
		next_st <= lock_state;
	else
		next_st <= config_state;
	end if;	
	
when lock_state =>	

	rst_count <='1';
	en_count <='0';
	
	wren <='0';
	
	locked<='1';
	
  	if ulock_en='1' then
		next_st <= rst_state;
	else
		next_st <= lock_state;
	end if;

end case;
end process;

process(clk)
begin
if rst_count='1' then
	counter <= "000000";
else
	if clk'event and clk='1' then
		if en_count='1' then
			counter <= counter + "000001";
		end if;
	end if;
end if;
end process;

process(clk)
begin
if clk'event and clk='1' then
	if counter = "100101" then
		stop_s <='1';
	else
		stop_s <='0';
	end if;
end if;
end process;

process(clk)
begin
if clk'event and clk='1' then
	if counter = "010111" then
		wren_checksum_1_t <='1';
	else
		wren_checksum_1_t <='0';
	end if;
end if;
end process;

wren_checksum_1 <= wren_checksum_1_t;

process(clk)
begin
if clk'event and clk='1' then	
	wren_checksum_2 <= wren_checksum_1_t;
end if;
end process;



wraddrlutmem: wraddr_lut_mem Port Map
 (
	clk => clk,
	a=> counter,	
	qspo=> addr);
	
end Behavioral;

