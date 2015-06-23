--##############################################################################
--
--  aluAndRegs
--      ALU and registers
--
--      This describes the processor ALU, together with the register file.
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

ENTITY aluAndRegs IS
  GENERIC( 
    registerBitNb          : positive := 8;
    registerAddressBitNb   : positive := 4;
    aluCodeBitNb           : positive := 5;
    portAddressBitNb       : positive := 8;
    scratchpadAddressBitNb : natural  := 4
  );
  PORT( 
    reset           : IN  std_ulogic;
    clock           : IN  std_ulogic;
    aluCode         : IN  std_ulogic_vector(aluCodeBitNb-1 DOWNTO 0);
    addrA           : IN  unsigned(registerAddressBitNb-1 DOWNTO 0);
    addrB           : IN  unsigned(registerAddressBitNb-1 DOWNTO 0);
    instrData       : IN  signed(registerBitNb-1 DOWNTO 0);
    registerFileSel : IN  std_ulogic;
    instrDataSel    : IN  std_ulogic;
    portInSel       : IN  std_ulogic;
    scratchpadSel   : IN  std_ulogic;
    regWrite        : IN  std_ulogic;
    cIn             : IN  std_ulogic;
    cOut            : OUT std_ulogic;
    zero            : OUT std_ulogic;
    portAddr        : OUT unsigned(portAddressBitNb-1 DOWNTO 0);
    portOut         : OUT signed(registerBitNb-1 DOWNTO 0);
    portIn          : IN  signed(registerBitNb-1 DOWNTO 0);
    scratchpadAddr  : OUT unsigned(scratchpadAddressBitNb-1 DOWNTO 0);
    spadOut         : OUT signed(registerBitNb-1 DOWNTO 0);
    spadIn          : IN  signed(registerBitNb-1 DOWNTO 0)
  );
END aluAndRegs ;

--==============================================================================

ARCHITECTURE struct OF aluAndRegs IS

  SIGNAL aluOut         : signed(registerBitNb-1 DOWNTO 0);
  SIGNAL opA            : signed(registerBitNb-1 DOWNTO 0);
  SIGNAL opB            : signed(registerBitNb-1 DOWNTO 0);
  SIGNAL registerFileIn : signed(registerBitNb-1 DOWNTO 0);


  COMPONENT alu
    GENERIC (
      aluCodeBitNb : positive := 5;
      dataBitNb    : positive := 8
    );
    PORT (
      aluCode : IN  std_ulogic_vector(aluCodeBitNb-1 DOWNTO 0);
      opA     : IN  signed(dataBitNb-1 DOWNTO 0);
      opB     : IN  signed(dataBitNb-1 DOWNTO 0);
      cIn     : IN  std_ulogic;
      aluOut  : OUT signed(dataBitNb-1 DOWNTO 0);
      cOut    : OUT std_ulogic;
      zero    : OUT std_ulogic
    );
  END COMPONENT;

  COMPONENT aluBOpSelector
    GENERIC (
      registerBitNb : positive := 8
    );
    PORT (
      instrData       : IN  signed(registerBitNb-1 DOWNTO 0);
      instrDataSel    : IN  std_ulogic;
      portIn          : IN  signed(registerBitNb-1 DOWNTO 0);
      portInSel       : IN  std_ulogic;
      registerFileIn  : IN  signed(registerBitNb-1 DOWNTO 0);
      registerFileSel : IN  std_ulogic;
      scratchpadSel   : IN  std_ulogic;
      spadIn          : IN  signed(registerBitNb-1 DOWNTO 0);
      opB             : OUT signed (registerBitNb-1 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT registerFile
    GENERIC (
      registerAddressBitNb : positive := 4;
      dataBitNb            : positive := 8
    );
    PORT (
      clock       : IN  std_ulogic;
      reset       : IN  std_ulogic;
      addrA       : IN  unsigned(registerAddressBitNb-1 DOWNTO 0);
      addrB       : IN  unsigned(registerAddressBitNb-1 DOWNTO 0);
      regWrite    : IN  std_ulogic;
      registersIn : IN  signed(dataBitNb-1 DOWNTO 0);
      opA         : OUT signed(dataBitNb-1 DOWNTO 0);
      opB         : OUT signed(dataBitNb-1 DOWNTO 0)
    );
  END COMPONENT;

BEGIN
  I_ALU : alu
    GENERIC MAP (
      aluCodeBitNb => aluCodeBitNb,
      dataBitNb    => registerBitNb
    )
    PORT MAP (
      aluCode => aluCode,
      opA     => opA,
      opB     => opB,
      cIn     => cIn,
      aluOut  => aluOut,
      cOut    => cOut,
      zero    => zero
    );

  I_bSel : aluBOpSelector
    GENERIC MAP (
      registerBitNb => registerBitNb
    )
    PORT MAP (
      instrData       => instrData,
      instrDataSel    => instrDataSel,
      portIn          => portIn,
      portInSel       => portInSel,
      registerFileIn  => registerFileIn,
      registerFileSel => registerFileSel,
      scratchpadSel   => scratchpadSel,
      spadIn          => spadIn,
      opB             => opB
    );

  I_regs : registerFile
    GENERIC MAP (
      registerAddressBitNb => registerAddressBitNb,
      dataBitNb            => registerBitNb
    )
    PORT MAP (
      clock       => clock,
      reset       => reset,
      addrA       => addrA,
      addrB       => addrB,
      regWrite    => regWrite,
      registersIn => aluOut,
      opA         => opA,
      opB         => registerFileIn
    );

  portAddr <= resize(unsigned(registerFileIn), portAddressBitNb);
  portOut <= opA;
  scratchpadAddr <= resize(unsigned(registerFileIn), scratchpadAddressBitNb);
  spadOut <= opA;

END ARCHITECTURE struct;
