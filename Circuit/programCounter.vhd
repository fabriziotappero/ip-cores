--##############################################################################
--
--  programCounter
--      Program counter
--
--      Addresses the instruction ROM.
--      Capable of incrementation, jump and function return
--
--------------------------------------------------------------------------------
--
--  Versions / Authors
--      1.0 Francois Corthay    first implementation
--
--  Provided under GNU LGPL licence: <http://www.gnu.org/copyleft/lesser.html>
--
--  by the electronics group of "HES-SO//Valais Wallis", in Switzerland:
--  <http://www.hevs.ch/en/rad-instituts/institut-systemes-industriels/>.
--
--------------------------------------------------------------------------------
--
--  Hierarchy
--      Used by "nanoblaze/nanoProcessor".
--
--##############################################################################

LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.all;

ENTITY programCounter IS
  GENERIC( 
    programCounterBitNb : positive := 10
  );
  PORT( 
    reset             : IN  std_ulogic;
    clock             : IN  std_ulogic;
    instrAddress      : IN  unsigned(programCounterBitNb-1 DOWNTO 0);
    storedProgCounter : IN  unsigned(programCounterBitNb-1 DOWNTO 0);
    incPC             : IN  std_ulogic;
    loadInstrAddress  : IN  std_ulogic;
    loadStoredPC      : IN  std_ulogic;
    progCounter       : OUT unsigned(programCounterBitNb-1 DOWNTO 0)
  );
END programCounter ;

--==============================================================================

ARCHITECTURE RTL OF programCounter IS

  signal pCounter: unsigned(progCounter'range);

BEGIN

  updateProgramCounter: process(reset, clock)
  begin
    if reset = '1' then
      pCounter <= (others => '0');
    elsif rising_edge(clock) then
      if incPC = '1' then
        pCounter <= pCounter + 1;
      elsif loadInstrAddress = '1' then
        pCounter <= instrAddress;
      elsif loadStoredPC = '1' then
        pCounter <= storedProgCounter;
      end if;
    end if;
  end process updateProgramCounter;

  progCounter <= pCounter;

END ARCHITECTURE RTL;
