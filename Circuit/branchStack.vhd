--##############################################################################
--
--  branchStack
--      Stack of branch addresses
--
--      This is where the program counter is pushed upon a subroutine call
--      and popped on return.
--
--      The stack is coded in a way to be mapped into a Block RAM.
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

ENTITY branchStack IS
  GENERIC( 
    programCounterBitNb : positive := 10;
    stackPointerBitNb   : positive := 5
  );
  PORT( 
    reset             : IN  std_ulogic;
    clock             : IN  std_ulogic;
    progCounter       : IN  unsigned(programCounterBitNb-1 DOWNTO 0);
    prevPC            : IN  std_ulogic;
    storePC           : IN  std_ulogic;
    storedProgCounter : OUT unsigned(programCounterBitNb-1 DOWNTO 0)
  );
END branchStack ;

--==============================================================================

ARCHITECTURE RTL OF branchStack IS

  subtype progCounterType is unsigned(progCounter'range);
  type progCounterArrayType is array (0 to 2**stackPointerBitNb) of progCounterType;
  signal progCounterArray : progCounterArrayType;

  signal writePointer : unsigned(stackPointerBitNb-1 downto 0);
  signal readPointer  : unsigned(stackPointerBitNb-1 downto 0);

BEGIN
  ------------------------------------------------------------------------------
                                                               -- stack pointers
  updateStackPointer: process(reset, clock)
  begin
    if reset = '1' then
      writePointer <= (others => '0');
    elsif rising_edge(clock) then
      if storePC = '1' then
        writePointer <= writePointer + 1;
      elsif prevPC = '1' then
        writePointer <= writePointer - 1;
      end if;
    end if;
  end process updateStackPointer;

  readPointer <= writePointer - 1;

  ------------------------------------------------------------------------------
                                                       -- program counters stack
  updateStack: process(reset, clock)
  begin
    if rising_edge(clock) then
      if storePc = '1' then
        progCounterArray(to_integer(writePointer)) <= progCounter;
      end if;
      storedProgCounter <= progCounterArray(to_integer(readPointer));
    end if;
  end process updateStack;

END ARCHITECTURE RTL;
