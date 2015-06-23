library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity clockcntl is
	port(	reset 				: in	std_logic;
			userResetInternal	: in	std_logic;
			baseClock			: in	std_logic;
			terminationCountRegister	: in std_logic_vector(31 downto 0);
			configurationRegister		: in std_logic_vector(7 downto 0);
			gatedClock			: out	std_logic
			);
end clockcntl;

architecture behavioral of clockcntl is

	signal edgeCounter	: std_logic_vector(31 downto 0);
	signal clockEnable	: std_logic;
	signal gatedClockInt	: std_logic;
	signal startBit		: std_logic;
	signal freeRun			: std_logic;
	
begin

startBit <= configurationRegister(0);
freeRun <= configurationRegister(1);

-------------------------------------------------------------------------------
-- Asynchronously enables, synchronously disables the gated clock.
-------------------------------------------------------------------------------
clockEnableP: process(reset, edgeCounter, baseClock, userResetInternal, freeRun)
 begin
   if (reset = '1') or
      ((edgeCounter = terminationCountRegister) and (baseClock = '0') and (freeRun = '0')) or
      (userResetInternal = '1') then
     clockEnable <= '0';
   elsif baseClock'event and baseClock = '1' then
	  if (edgeCounter /= terminationCountRegister) then
	    clockEnable <= startBit or freeRun;
	  elsif freeRun = '1' then
	    clockEnable <= '1';
	  else
	    clockEnable <= '0';
	  end if;
   end if;
 end process clockEnableP;

 gatedClockInt <= baseClock and clockEnable;

 --gatedDUTClock <= baseClock and DUTClockEnable and clockEnable;

-------------------------------------------------------------------------------
-- The edge counter used by the control state machine.
-------------------------------------------------------------------------------
edgeCounterP: process(gatedClockInt, reset, startBit, userResetInternal)
begin
 if reset = '1' or startBit = '0' or userResetInternal = '1' then
   edgeCounter <= (others => '0');
 elsif gatedClockInt'event and gatedClockInt = '1' then
   edgeCounter <= edgeCounter + '1';
 end if;
end process edgeCounterP;

gatedClock <= gatedClockInt;


end behavioral;

-------------------------------------------------------------------------------
-- A debugging counter that increments on the DUTClock.
-------------------------------------------------------------------------------
--DUTClockCounterP: process(DUTClockInternal, reset, counterReset)
--begin
-- if reset = '1' or counterReset = ENABLED then
--   DUTClockCounter <= (others => '0');
-- elsif DUTClockInternal'event and DUTClockInternal = '1' then
--   DUTClockCounter <= DUTClockCounter + '1';
-- end if;
--end process DUTClockCounterP;