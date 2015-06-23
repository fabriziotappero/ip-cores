-------------------------------------------------------------------------------
-- Title      : HPI MEMORY
-- Project    : LEON3MINI
-------------------------------------------------------------------------------
-- $Id: $
-------------------------------------------------------------------------------
-- Author     : Thomas Ameseder
-- Company    : Gleichmann Electronics
-- Created    : 2005-08-19
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description:
--
-- This module is for testing the AHB2HPI(2) core. It is a memory that
-- can be connected to the HPI interface. Also features HPI timing
-- checks.
-------------------------------------------------------------------------------
-- Copyright (c) 2005 
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;

entity hpi_ram is
  generic (abits : integer := 9; dbits : integer := 16);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector(1 downto 0);
    datain  : in  std_logic_vector(dbits-1 downto 0);
    dataout : out std_logic_vector(dbits-1 downto 0);
    writen  : in  std_ulogic;
    readn   : in  std_ulogic;
    csn     : in  std_ulogic
    ); 
end;

architecture behavioral of hpi_ram is

  constant Tcyc : time := 40000 ps;        -- cycle time

  type mem is array(0 to (2**abits -1))
    of std_logic_vector((dbits -1) downto 0);
  signal memarr : mem;

  signal
    data_reg,                           -- "00"
    mailbox_reg,                        -- "01"
    address_reg,                        -- "10"
    status_reg                          -- "11"
 : std_logic_vector(dbits-1 downto 0);

begin

  write : process(clk)
  begin
    if rising_edge(clk) then
      if csn = '0' then
        if writen = '0' then
          case address(1 downto 0) is
            when "00"   => memarr(conv_integer(address_reg(abits-1 downto 1))) <= datain;
            when "01"   => mailbox_reg                                         <= datain;
            when "10"   => address_reg                                         <= datain;
            when "11"   => status_reg                                          <= datain;
            when others => null;
          end case;
        end if;
      end if;
    end if;
  end process;

  read : process(address, address_reg, csn, mailbox_reg, memarr, readn,
                 status_reg)
    constant Tacc : time := Tcyc;       -- data access time
  begin
    if (readn = '0' and csn = '0') then
      case address(1 downto 0) is
        when "00"   => dataout <= memarr(conv_integer(address_reg(abits-1 downto 1))) after Tacc;
        when "01"   => dataout <= mailbox_reg                                         after Tacc;
        when "10"   => dataout <= address_reg                                         after Tacc;
        when "11"   => dataout <= status_reg                                          after Tacc;
        when others => null;
      end case;
    else
      -- the rest of the time, invalid data shall be driven
      -- (note: makes an 'X' when being resolved on a high-impedance bus)
      dataout <= (others => 'Z');
    end if;
  end process;

  -- pragma translate_off

  ---------------------------------------------------------------------------------------
  -- HPI TIMING CHECKS
  ---------------------------------------------------------------------------------------

  cycle_timing_check : process(datain, readn, writen)
    constant Tcycmin    : time := 6 * Tcyc;  -- minimum write/read cycle time
    constant Tpulsemin  : time := 2 * Tcyc;  -- minimum write/read pulse time
    constant Twdatasu   : time := 6 ns;      -- write data setup time
    constant Twdatahold : time := 2 ns;      -- write data hold time

    variable wrlastev, rdlastev       : time := 0 ps;
    variable wrlowlastev, rdlowlastev : time := 0 ps;
    variable wdatalastev              : time := 0 ps;  -- write data last event
    variable wrhighlastev             : time := 0 ps;
  begin

    -- write data hold check
    if datain'event then
      assert (now = 0 ps) or (now - wrhighlastev >= Twdatahold)
        report "Write data hold violation!" severity error;
      wdatalastev := now;
    end if;

    -- exclusive read or write check
    assert writen = '1' or readn = '1'
      report "Both read and write are signals are low!" severity error;

    -- write cycle time and write pulse width checks
    if writen'event then
      if writen = '0' then
        assert (now = 0 ps) or (now - wrlowlastev >= Tcycmin)
          report "Write cycle time violation!" severity error;
        wrlowlastev := now;
        wrlastev    := now;
      elsif writen = '1' then
        assert (now = 0 ps) or (now - wrlastev >= Tpulsemin)
          report "Write pulse width violation!" severity error;
        assert (now = 0 ps) or (now - wdatalastev >= Twdatasu)
          report "Write data setup violation!" severity error;
        wrhighlastev := now;
        wrlastev     := now;
      end if;
    end if;

    -- read cycle time and read pulse width checks
    if readn'event then
      if readn = '0' then
        assert (now = 0 ps) or (now - rdlowlastev >= Tcycmin)
          report "Read cycle time violation!" severity error;
        rdlowlastev := now;
        rdlastev    := now;
      elsif readn = '1' then
        assert (now = 0 ps) or (now - rdlastev >= Tpulsemin)
          report "Read pulse width violation!" severity error;
        rdlastev := now;
      end if;
    end if;

  end process cycle_timing_check;

  -- pragma translate_on

end architecture;

