library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity startup_timer is
    Port ( clk : in std_logic;
           rst : in std_logic;
			  startup : out std_logic);
end startup_timer;

architecture startup_timer of startup_timer is

   signal timer: integer range 0 to 3;
begin

process (clk, rst)
begin
   if rst = '1' then
	   timer <= 0;
		startup <= '1';
	elsif clk'event and clk='1' then
	   if timer /= 3 then
	      timer <= timer +1;
      else
		   startup <='0';
			timer <= timer;
		end if;
	end if;
end process;

end startup_timer;
