-------------------------------------------------------------------------------
-- Project: FH-Hagenberg/HSSE: Sandbox X general use IP
-- Author: Copyright 2006 by Markus Pfaff, Linz/Austria/Europe
-------------------------------------------------------------------------------
-- $LastChangedDate: 2007-01-09 08:40:02 +0100 (Di, 09 Jän 2007) $
-- $LastChangedRevision: 415 $
-- $LastChangedBy: pfaff $
-- $HeadURL: file:///C:/pfaff/rpySvn/rpySvnSet5/trunk/Uebung/W06Jg04/Uebung03/unitIcs307Configurator/src/tbIcs307Configurator-Bhv-a.vhd $
-- LoginNames: pfaff - Markus Pfaff, Linz/Austria/Europe
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.Global.all;

--------------------------------------------------------------------------------

architecture Bhv of tbIcs307Configurator is

  -- component generics
  constant cClkFrequency               : natural := 25E6;
  constant cIsLowPercentageOfDutyCycle : natural := 65;
  constant cInResetDuration            : time    := 140 ns;
  constant cStrobeFrequency            : natural := 12E6;

  -- component ports
  signal Clk         : std_ulogic;
  signal nResetAsync : std_ulogic;
  signal Strobe      : std_ulogic;
  signal Sclk        : std_ulogic;
  signal Data        : std_ulogic;


begin  -- architecture Behavioral

  Ics307Configurator_1 : entity work.Ics307Configurator
    --generic map (
    --  gCrystalLoadCapacitance_C   => gCrystalLoadCapacitance_C,
    --  gReferenceDivider_RDW       => gReferenceDivider_RDW,
    --  gVcoDividerWord_VDW         => gVcoDividerWord_VDW,
    --  gOutputDivide_S             => gOutputDivide_S,
    --  gClkFunctionSelect_R        => gClkFunctionSelect_R,
    --  gOutputDutyCycleVoltage_TTL => gOutputDutyCycleVoltage_TTL)
    port map (
      iClk         => Clk,
      inResetAsync => nResetAsync,
      oSclk        => Sclk,
      oData        => Data,
      oStrobe      => Strobe);

  -- reset generation
  PwrOnResetSource : entity work.PwrOnReset
    generic map (
      gInResetDuration => cInResetDuration)
    port map (
      onResetAsync => nResetAsync);

  ICS307_1: entity work.ICS307
    port map (
      iSclk        => Sclk,
      iData        => Data,
      iStrobe      => Strobe,
      oClk1        => Clk);
  
  StopSim : process is
  begin
    wait for 6 ms;
    assert false
      report "MP: Simulation stopped intenionally!"
      severity failure;
    wait;
  end process StopSim;
  
end architecture Bhv;
