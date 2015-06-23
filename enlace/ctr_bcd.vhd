------------------------------------------------------------------
--  ctr_bcd.vhd -- 
-- BCD counter
------------------------------------------------------------------
-- Luis Jacobo Alvarez Ruiz de Ojeda
-- Dpto. Tecnologia Electronica
-- University of Vigo
-- 24, March, 2006 
------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity ctr_bcd is
    Port ( clk : in std_logic;
           reset : in std_logic;
			  sync_reset : in std_logic;
           gctr : in std_logic;
           qctr : out std_logic_vector(3 downto 0);
           ctr_eq_9 : out std_logic);
end ctr_bcd;

architecture Behavioral of ctr_bcd is

------------------------------------------------------------------
--  Signal Declarations and Constants
------------------------------------------------------------------
signal qctr_aux: std_logic_vector (3 downto 0);

begin

-- Outputs assignment
qctr <= qctr_aux;

process (clk, reset, gctr, qctr_aux)
begin
	if (reset ='1') then
		-- Counter initialization
		qctr_aux <= "0000";
	elsif (clk'event and clk='1') then
		if sync_reset = '1' then 
			qctr_aux <= "0000";
		elsif (gctr='1') then
			if qctr_aux = 9 then
				qctr_aux <= "0000";
			else
				-- Increment counter
				qctr_aux <= qctr_aux + 1;
			end if;
		end if;
	end if;

	if qctr_aux = 9 then
		-- Last state
		ctr_eq_9 <= '1';
	else ctr_eq_9 <='0';
	end if;
end process;

end Behavioral;
