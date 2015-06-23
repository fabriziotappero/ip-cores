-------------------------------------------------------------------------------
-- Title      : Programmer for ICS307
-- Project    : General IP
-------------------------------------------------------------------------------
-- Author     : Copyright 2006: Markus Pfaff, Linz
-- Standard   : Using VHDL'93
-------------------------------------------------------------------------------
-- Description: Configures an ICS Serially Programmable Clock
-- Synthesizer immediately after FPGA configuration.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.global.all;

entity Ics307Configurator is
  generic(
    -- Default settings for 25 MHz input clk and 48 MHz on clk1
    -- Parameters in the order implied by the block diagramm on title
    -- page of data sheet. The data word given by online calculator
    -- (see data sheet page 3) is "001001000000100000000011". This
    -- data word contains the following parameters:
    -- Set for lowest crystal load capacitance,
    gCrystalLoadCapacitance_C   : std_ulogic_vector(1 downto 0) := "00";
    -- divide by (3+2),
    gReferenceDivider_RDW       : std_ulogic_vector(6 downto 0) := "0000011";
    -- multiply by (16+8),
    gVcoDividerWord_VDW         : std_ulogic_vector(8 downto 0) := "000010000";
    -- divide by 5,
    gOutputDivide_S             : std_ulogic_vector(2 downto 0) := "100";
    -- set source of Clk2 to REF clk (i.e. input clk),
    gClkFunctionSelect_R        : std_ulogic_vector(1 downto 0) := "00";
    -- CMOS voltage levels for 3.3V.
    gOutputDutyCycleVoltage_TTL : std_ulogic                    := '1'
    );

  port(
    iClk         : in std_ulogic;
    inResetAsync : in std_ulogic;

    -- 3 wire SPI interface for configuration
    oSclk   : out std_ulogic;
    oData   : out std_ulogic;
    oStrobe : out std_ulogic
    );
end entity Ics307Configurator;
