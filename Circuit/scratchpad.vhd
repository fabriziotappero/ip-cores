--##############################################################################
--
--  scratchpad
--      The scratchpad as defined in version 3
--
--      This corresponds to a simple RAM.
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

ENTITY scratchpad IS
  GENERIC( 
    registerBitNb    : positive := 8;
    spadAddressBitNb : natural  := 4
  );
  PORT( 
    reset   : IN  std_ulogic;
    clock   : IN  std_ulogic;
    addr    : IN  unsigned(spadAddressBitNb-1 DOWNTO 0);
    write   : IN  std_ulogic;
    dataIn  : IN  signed(registerBitNb-1 DOWNTO 0);
    dataOut : OUT signed(registerBitNb-1 DOWNTO 0 )
  );
END scratchpad ;

--==============================================================================

ARCHITECTURE RTL OF scratchpad IS

  subtype memoryWordType is signed(dataOut'range);
  type memoryArrayType is array (0 to 2**addr'length-1) of memoryWordType;

  signal memoryArray : memoryArrayType;

BEGIN

  process (clock)
  begin
    if rising_edge(clock) then
      if write = '1' then
        memoryArray(to_integer(addr)) <= dataIn;
      end if;
    end if;
  end process;

  dataOut <= memoryArray(to_integer(addr));

END ARCHITECTURE RTL;
