--##############################################################################
--
--  registerFile
--      Microprocessor registers
--
--      The register file has one data input, from the ALU,
--      and two data outputs for the ALU inputs.
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
--      Used by "nanoblaze/nanoProcessor/aluAndRegs".
--
--##############################################################################

LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.all;

ENTITY registerFile IS
  GENERIC( 
    registerAddressBitNb : positive := 4;
    dataBitNb            : positive := 8
  );
  PORT( 
    clock       : IN  std_ulogic;
    reset       : IN  std_ulogic;
    addrA       : IN  unsigned(registerAddressBitNb-1 DOWNTO 0);
    addrB       : IN  unsigned(registerAddressBitNb-1 DOWNTO 0);
    regWrite    : IN  std_ulogic;
    registersIn : IN  signed(dataBitNb-1 DOWNTO 0);
    opA         : OUT signed(dataBitNb-1 DOWNTO 0);
    opB         : OUT signed(dataBitNb-1 DOWNTO 0)
  );
END registerFile ;

--==============================================================================

ARCHITECTURE RTL OF registerFile IS

  subtype registerType is signed(registersIn'range);
  type registerArrayType is array (0 to 2**registerAddressBitNb-1) of registerType;
  signal registerArray : registerArrayType;

BEGIN
  ------------------------------------------------------------------------------
                                                           -- write to registers
  updateRegister: process(reset, clock)
  begin
    if reset = '1' then
      registerArray <= (others => (others => '0'));
    elsif rising_edge(clock) then
      if regWrite = '1' then
        registerArray(to_integer(addrA)) <= registersIn;
      end if;
    end if;
  end process updateRegister;

  ------------------------------------------------------------------------------
                                                          -- read from registers
  opA <= registerArray(to_integer(addrA));
  opB <= registerArray(to_integer(addrB));

END ARCHITECTURE RTL;
