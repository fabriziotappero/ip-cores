--##############################################################################
--
--  InstructionDecoder
--      Instriction decoder
--
--      Provides different parts of the instruction word to differnent blocks.
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

ENTITY instructionDecoder IS
  GENERIC( 
    registerBitNb        : positive := 8;
    registerAddressBitNb : positive := 4;
    aluCodeBitNb         : positive := 5;
    instructionBitNb     : positive := 18;
    programCounterBitNb  : positive := 10;
    opCodeBitNb          : positive := 5;
    branchCondBitNb      : positive := 3;
    intCodeBitNb         : positive := 5;
    spadAddressBitNb     : natural  := 4;
    portAddressBitNb     : positive := 8
  );
  PORT( 
    instruction    : IN  std_ulogic_vector(instructionBitNb-1 DOWNTO 0);
    aluCode        : OUT std_ulogic_vector(aluCodeBitNb-1 DOWNTO 0);
    addrA          : OUT unsigned(registerAddressBitNb-1 DOWNTO 0);
    addrB          : OUT unsigned(registerAddressBitNb-1 DOWNTO 0);
    instrData      : OUT signed(registerBitNb-1 DOWNTO 0);
    instrAddress   : OUT unsigned(programCounterBitNb-1 DOWNTO 0);
    opCode         : OUT std_ulogic_vector(opCodeBitNb-1 DOWNTO 0);
    twoRegInstr    : OUT std_ulogic;
    branchCond     : OUT std_ulogic_vector(branchCondBitNb-1 DOWNTO 0);
    intCode        : OUT std_ulogic_vector(intCodeBitNb-1 DOWNTO 0);
    portIndexedSel : OUT std_ulogic;
    portAddress    : OUT unsigned(portAddressBitNb-1 DOWNTO 0);
    spadIndexedSel : OUT std_ulogic;
    spadAddress    : OUT unsigned(spadAddressBitNb-1 DOWNTO 0)
  );
END instructionDecoder ;

--==============================================================================

ARCHITECTURE RTL OF instructionDecoder IS

  constant opCodeIndexH         : integer := instruction'high;
  constant opCodeIndexL         : integer := opCodeIndexH - opCodeBitNb + 1;

  constant twoRegInstrIndex     : integer := opCodeIndexL - 1;
  constant ioAddrIndexed        : integer := twoRegInstrIndex;

  constant addrAIndexH          : integer := twoRegInstrIndex - 1;
  constant addrAIndexL          : integer := addrAIndexH - registerAddressBitNb + 1;

  constant immediateDataIndexH  : integer := registerBitNb-1;
  constant immediateDataIndexL  : integer := 0;
  constant addrBIndexH          : integer := addrAIndexL - 1;
  constant addrBIndexL          : integer := addrBIndexH - registerAddressBitNb + 1;

  constant aluCodeIndexH        : integer := opCodeIndexH;
  constant aluCodeIndexL        : integer := aluCodeIndexH - aluCodeBitNb + 1;

  constant portAddressH         : integer := registerBitNb-1;
  constant portAddressL         : integer := portAddressH-portAddressBitNb+1;
  constant spadAddressH         : integer := registerBitNb-1;
  constant spadAddressL         : integer := spadAddressH-spadAddressBitNb+1;

  constant branchCondH          : integer := opCodeIndexL-1;
  constant branchCondL          : integer := branchCondH-branchCondBitNb+1;

BEGIN
  ------------------------------------------------------------------------------
                                                                  -- ALU control
  aluCode <=
    instruction(aluCodeIndexH downto aluCodeIndexL)
      when instruction(aluCodeIndexH) = '0' else
    '1' & instruction(aluCodeBitNb-2 downto 0);
  opCode <= instruction(opCodeIndexH downto opCodeIndexL);
  twoRegInstr <= instruction(twoRegInstrIndex);
  addrA <= unsigned(instruction(addrAIndexH downto addrAIndexL));
  addrB <= unsigned(instruction(addrBIndexH downto addrBIndexL));
  instrData <= signed(instruction(immediateDataIndexH downto immediateDataIndexL));

  ------------------------------------------------------------------------------
                                                                  -- I/O control
  portIndexedSel <= instruction(ioAddrIndexed);
  portAddress <= unsigned(instruction(portAddressH downto portAddressL));

  ------------------------------------------------------------------------------
                                                           -- scratchpad control
  spadIndexedSel <= instruction(ioAddrIndexed);
  spadAddress <= unsigned(instruction(spadAddressH downto spadAddressL));

  ------------------------------------------------------------------------------
                                                               -- branch control
  branchCond <= instruction(branchCondH downto branchCondL);
  instrAddress <= unsigned(instruction(instrAddress'range));

END ARCHITECTURE RTL;
