--##############################################################################
--
--  nanoblaze
--      Top view of the NanoBlaze processor
--
--      The processor is compatible with the Xilinx PicoBlaze
--      <http://www.picoblaze.info>, but different bit widths can be adapted
--      in order to have a larger processor.
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
--      Edit an assembler file and compile it as the architecture of "programRom".
--
--      The "reset" signal is active high.
--
--------------------------------------------------------------------------------
--
--  Synthesis results
--      A circuit compatible with the PicoBlaze sizes gives the following
--      synthesis result on a Xilinx Spartan3-1000:
--          Number of Slice Flip Flops:           157 out of  15,360    1%
--          Number of 4 input LUTs:               446 out of  15,360    2%
--          Number of BRAMs:                        1 out of      24    4%
--
--##############################################################################

LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.all;

ENTITY nanoBlaze IS
  GENERIC( 
    addressBitNb           : positive := 8;
    registerBitNb          : positive := 8;
    programCounterBitNb    : positive := 10;
    stackPointerBitNb      : positive := 5;
    registerAddressBitNb   : positive := 4;
    scratchpadAddressBitNb : natural  := 6
  );
  PORT( 
    reset       : IN     std_ulogic;
    clock       : IN     std_ulogic;
    en          : IN     std_ulogic;
    dataAddress : OUT    unsigned(addressBitNb-1 DOWNTO 0);
    dataOut     : OUT    std_ulogic_vector(registerBitNb-1 DOWNTO 0);
    dataIn      : IN     std_ulogic_vector(registerBitNb-1 DOWNTO 0);
    readStrobe  : OUT    std_uLogic;
    writeStrobe : OUT    std_uLogic;
    int         : IN     std_uLogic;
    intAck      : OUT    std_ulogic
  );
END nanoBlaze ;

--==============================================================================

ARCHITECTURE struct OF nanoBlaze IS

  constant instructionBitNb: positive := 18;
  SIGNAL instruction    : std_ulogic_vector(instructionBitNb-1 DOWNTO 0);
  SIGNAL logic1         : std_ulogic;
  SIGNAL programCounter : unsigned(programCounterBitNb-1 DOWNTO 0);

  COMPONENT nanoProcessor
    GENERIC (
      addressBitNb           : positive := 8;
      registerBitNb          : positive := 8;
      registerAddressBitNb   : positive := 4;
      programCounterBitNb    : positive := 10;
      stackPointerBitNb      : positive := 5;
      instructionBitNb       : positive := 18;
      scratchpadAddressBitNb : natural  := 4
    );
    PORT (
      reset       : IN  std_uLogic;
      clock       : IN  std_uLogic;
      en          : IN  std_uLogic;
      progCounter : OUT unsigned(programCounterBitNb-1 DOWNTO 0);
      instruction : IN  std_ulogic_vector(instructionBitNb-1 DOWNTO 0);
      dataAddress : OUT unsigned(addressBitNb-1 DOWNTO 0);
      dataOut     : OUT std_ulogic_vector(registerBitNb-1 DOWNTO 0);
      dataIn      : IN  std_ulogic_vector(registerBitNb-1 DOWNTO 0);
      readStrobe  : OUT std_uLogic;
      writeStrobe : OUT std_uLogic;
      int         : IN  std_uLogic;
      intAck      : OUT std_ulogic
    );
  END COMPONENT;

  COMPONENT programRom
    GENERIC (
      addressBitNb : positive := 8;
      dataBitNb    : positive := 8
    );
    PORT (
      reset   : IN  std_uLogic;
      clock   : IN  std_uLogic;
      en      : IN  std_uLogic;
      address : IN  unsigned(addressBitNb-1 DOWNTO 0);
      dataOut : OUT std_ulogic_vector(dataBitNb-1 DOWNTO 0)
    );
  END COMPONENT;

BEGIN
  logic1 <= '1';

  I_up : nanoProcessor
    GENERIC MAP (
      addressBitNb           => addressBitNb,
      registerBitNb          => registerBitNb,
      registerAddressBitNb   => registerAddressBitNb,
      programCounterBitNb    => programCounterBitNb,
      stackPointerBitNb      => stackPointerBitNb,
      instructionBitNb       => instructionBitNb,
      scratchpadAddressBitNb => scratchpadAddressBitNb
    )
    PORT MAP (
      reset       => reset,
      clock       => clock,
      en          => en,
      progCounter => programCounter,
      instruction => instruction,
      dataAddress => dataAddress,
      dataOut     => dataOut,
      dataIn      => dataIn,
      readStrobe  => readStrobe,
      writeStrobe => writeStrobe,
      int         => int,
      intAck      => intAck
    );

  I_rom : programRom
    GENERIC MAP (
      addressBitNb => programCounterBitNb,
      dataBitNb    => instructionBitNb
    )
    PORT MAP (
      reset   => reset,
      clock   => clock,
      en      => logic1,
      address => programCounter,
      dataOut => instruction
    );

END ARCHITECTURE struct;
