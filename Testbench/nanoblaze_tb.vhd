--##############################################################################
--
--  nanoblaze_tb
--      Testbench for the NanoBlaze processor
--
--      Instanciates the processor and a stimulus generator.
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
--  Usage
--      Set the proper values for all generics.
--
--      For the processor ROM, use the assembler file "nanoTest.asm".
--
--##############################################################################

LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.all;

ENTITY nanoBlaze_tb IS
END nanoBlaze_tb ;

--==============================================================================

ARCHITECTURE struct OF nanoBlaze_tb IS

  -- Values for the generic parameters
  constant addressBitNb: positive := 8;
  constant dataBitNb: positive := 8;
  constant programCounterBitNb: positive := 10;
  constant stackPointerBitNb: positive := 5;
  constant registerAddressBitNb: positive := 4;
  constant portAddressBitNb: positive := 8;
  constant scratchpadAddressBitNb: positive := 4;

  SIGNAL reset       : std_ulogic;
  SIGNAL clock       : std_ulogic;
  SIGNAL en          : std_ulogic;
  SIGNAL dataAddress : unsigned( addressBitNb-1 DOWNTO 0 );
  SIGNAL dataOut     : std_ulogic_vector(dataBitNb-1 DOWNTO 0);
  SIGNAL dataIn      : std_ulogic_vector(dataBitNb-1 DOWNTO 0);
  SIGNAL readStrobe  : std_uLogic;
  SIGNAL writeStrobe : std_uLogic;
  SIGNAL int         : std_uLogic;
  SIGNAL intAck      : std_ulogic;

  COMPONENT nanoBlaze
    GENERIC (
      addressBitNb           : positive := 8;
      registerBitNb          : positive := 8;
      programCounterBitNb    : positive := 10;
      stackPointerBitNb      : positive := 5;
      registerAddressBitNb   : positive := 4;
      scratchpadAddressBitNb : natural  := 6
    );
    PORT (
      reset       : IN  std_ulogic;
      clock       : IN  std_ulogic;
      en          : IN  std_ulogic;
      dataAddress : OUT unsigned(addressBitNb-1 DOWNTO 0);
      dataOut     : OUT std_ulogic_vector(registerBitNb-1 DOWNTO 0);
      dataIn      : IN  std_ulogic_vector(registerBitNb-1 DOWNTO 0);
      readStrobe  : OUT std_uLogic;
      writeStrobe : OUT std_uLogic;
      int         : IN  std_uLogic;
      intAck      : OUT std_ulogic
    );
  END COMPONENT;

  COMPONENT nanoBlaze_tester
    GENERIC (
      addressBitNb : positive := 8;
      dataBitNb    : positive := 8
    );
    PORT (
      reset       : OUT std_ulogic 
      clock       : OUT std_uLogic;
      en          : OUT std_uLogic;
      dataAddress : IN  unsigned(addressBitNb-1 DOWNTO 0);
      dataOut     : IN  std_ulogic_vector(dataBitNb-1 DOWNTO 0);
      dataIn      : OUT std_ulogic_vector(dataBitNb-1 DOWNTO 0);
      readStrobe  : IN  std_uLogic;
      writeStrobe : IN  std_uLogic;
      int         : OUT std_uLogic;
      intAck      : IN  std_uLogic;
    );
  END COMPONENT;

BEGIN

  I_DUT : nanoBlaze
    GENERIC MAP (
      addressBitNb           => addressBitNb,
      registerBitNb          => dataBitNb,
      programCounterBitNb    => programCounterBitNb,
      stackPointerBitNb      => stackPointerBitNb,
      registerAddressBitNb   => registerAddressBitNb,
      scratchpadAddressBitNb => scratchpadAddressBitNb
    )
    PORT MAP (
      clock       => clock,
      dataIn      => dataIn,
      en          => en,
      int         => int,
      reset       => reset,
      dataAddress => dataAddress,
      dataOut     => dataOut,
      intAck      => intAck,
      readStrobe  => readStrobe,
      writeStrobe => writeStrobe
    );

  I_tb : nanoBlaze_tester
    GENERIC MAP (
      addressBitNb => addressBitNb,
      dataBitNb    => dataBitNb
    )
    PORT MAP (
      dataAddress => dataAddress,
      dataOut     => dataOut,
      intAck      => intAck,
      readStrobe  => readStrobe,
      writeStrobe => writeStrobe,
      clock       => clock,
      dataIn      => dataIn,
      en          => en,
      int         => int,
      reset       => reset
    );

END ARCHITECTURE struct;
