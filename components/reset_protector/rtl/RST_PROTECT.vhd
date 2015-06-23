-- ######################################################
-- #          < STORM SoC by Stephan Nolting >          #
-- # ************************************************** #
-- #                -- RESET Protector --               #
-- # ************************************************** #
-- #  Valid system reset after pushing the RST button   #
-- #  for at least 3 seconds.                           #
-- # ************************************************** #
-- # Last modified: 21.04.2012                          #
-- ######################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RST_PROTECT is
	generic	(
				TRIGGER_VAL   : natural := 50000000; -- trigger in sys clocks
				LOW_ACT_RST   : boolean := TRUE      -- valid reset level
			);
	port	(
				-- Interface --
				MAIN_CLK_I    : in  STD_LOGIC; -- system master clock
				EXT_RST_I     : in  STD_LOGIC; -- external reset input
				SYS_RST_O     : out STD_LOGIC  -- system master reset
			);
end RST_PROTECT;

architecture Behavioral of RST_PROTECT is

	--- Counter ---
	signal RST_CNT   : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	signal RST_STATE : STD_LOGIC := '0';

begin

	-- Reset Counter ---------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		RESET_COUNTER: process(MAIN_CLK_I)
		begin
			if rising_edge(MAIN_CLK_I) then
				if (RST_STATE = '0') then -- wait for reset
					SYS_RST_O <= '0';
					if ((EXT_RST_I = '0') and (LOW_ACT_RST = TRUE)) or ((EXT_RST_I = '1') and (LOW_ACT_RST = FALSE)) then
						if (to_integer(unsigned(RST_CNT)) < TRIGGER_VAL) then -- wait 3 seconds
							RST_CNT   <= Std_Logic_Vector(unsigned(RST_CNT) + 1);
							RST_STATE <= '0';
						else
							RST_CNT   <= (others => '0');
							RST_STATE <= '1';
						end if;
					else
						RST_CNT   <= (others => '0');
						RST_STATE <= '0';
					end if;
				else -- do reset
					if (to_integer(unsigned(RST_CNT)) < TRIGGER_VAL/100000) then -- hold reset
						SYS_RST_O <= '1';
						RST_CNT   <= Std_Logic_Vector(unsigned(RST_CNT) + 1);
						RST_STATE <= '1';
					elsif ((EXT_RST_I = '0') and (LOW_ACT_RST = TRUE)) or ((EXT_RST_I = '1') and (LOW_ACT_RST = FALSE)) then -- ext reset still active?
						SYS_RST_O <= '1';
						RST_STATE <= '1';
					else
						SYS_RST_O <= '0';
						RST_CNT   <= (others => '0');
						RST_STATE <= '0';
					end if;
				end if;
			end if;
		end process RESET_COUNTER;



end Behavioral;