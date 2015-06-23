--##############################################################################
--
--  aluBOpSelector
--      ALU B-operand selector
--
--      This multiplexer brings the proper data on the B-input of the ALU.
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

ENTITY aluBOpSelector IS
  GENERIC( 
    registerBitNb : positive := 8
  );
  PORT( 
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
END aluBOpSelector ;

--==============================================================================

ARCHITECTURE RTL OF aluBOpSelector IS
BEGIN

  selectDataSource: process(
    registerFileSel, registerFileIn,
    scratchpadSel,   spadIn,
    portInSel,       portIn,
    instrDataSel,    instrData
  )
  begin
    if registerFileSel = '1' then
      opB <= registerFileIn;
    elsif scratchpadSel = '1' then
      opB <= spadIn;
    elsif portInSel = '1' then
      opB <= portIn;
    elsif instrDataSel = '1' then
      opB <= instrData;
    else
      opB <= (others => '-');
    end if;
  end process selectDataSource;

END ARCHITECTURE RTL;
