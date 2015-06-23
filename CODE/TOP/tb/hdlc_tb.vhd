-------------------------------------------------------------------------------
-- Title      :  HDLC core test bench
-- Project    :  HDLC Standalone controller with buffers
-------------------------------------------------------------------------------
-- File        : hdlc_tb.vhd
-- Author      : Jamil Khatib  (khatib@ieee.org)
-- Organization: OpenCores Project
-- Created     :2001/04/22
-- Last update: 2001/04/27
-- Platform    : 
-- Simulators  : Modelsim 5.3XE/Windows98,NC-SIM/Linux
-- Synthesizers: 
-- Target      : 
-- Dependency  : ieee.std_logic_1164
--               hdlc.hdlc_components_pkg
-------------------------------------------------------------------------------
-- Description:  HDLC controller test bench
-------------------------------------------------------------------------------
-- Copyright (c) 2001 Jamil Khatib
-- 
-- This VHDL design file is an open design; you can redistribute it and/or
-- modify it and/or implement it after contacting the author
-- You can check the draft license at
-- http://www.opencores.org/OIPC/license.shtml

-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   1
-- Version         :   0.1
-- Date            :   21 April 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Created
--                     It checkes the received data that is generated automatically
--                     It writes to the Tx buffer and check the Tx data by loop
--                     back to Rx pin that was checked before
-- ToOptimize      :
-- Bugs            :   
-------------------------------------------------------------------------------
-- $Log: not supported by cvs2svn $
-- Revision 1.2  2001/04/27 18:21:59  jamil
-- After Prelimenray simulation
--
-- Revision 1.1  2001/04/22 20:08:48  jamil
-- Initial Release
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library hdlc;
use hdlc.hdlc_components_pkg.all;

-------------------------------------------------------------------------------

entity hdlc_tb is

end hdlc_tb;

-------------------------------------------------------------------------------

architecture hdlc_beh_tb of hdlc_tb is

  type SERIAL_typ is array (0 to 288) of std_logic;  -- Serial Data array

  signal RxSerData : SERIAL_typ;        -- Rx Serial Data


  constant FCS_TYPE  : integer := 2;
  constant ADD_WIDTH : integer := 7;

  signal Txclk  : std_logic := '0';
  signal RxClk  : std_logic := '0';
  signal Tx     : std_logic;
  signal Rx     : std_logic;
  signal TxEN   : std_logic;
  signal RxEN   : std_logic;
  signal RST_I  : std_logic;
  signal CLK_I  : std_logic := '0';
  signal ADR_I  : std_logic_vector(2 downto 0);
  signal DAT_O  : std_logic_vector(31 downto 0);
  signal DAT_I  : std_logic_vector(31 downto 0);
  signal WE_I   : std_logic;
  signal STB_I  : std_logic;
  signal ACK_O  : std_logic;
  signal CYC_I  : std_logic;
  signal RTY_O  : std_logic;
  signal TAG0_O : std_logic;
  signal TAG1_O : std_logic;

begin  -- hdlc_beh_tb

  Txclk <= not Txclk after 250 ns;
  Rxclk <= not Rxclk after 250 ns;
  CLK_I <= not CLK_I after 10 ns;
  RST_I <= '1',
           '0'       after 1 us;

  TxEN <= '1';
  RxEN <= '1';

-------------------------------------------------------------------------------
  -- purpose: Initialization
  -- type   : combinational
  -- inputs : RST_I
  -- outputs: 
  INIT               : process (RST_I)
    variable counter : std_logic_vector(7 downto 0) := "00000000";  -- Internal Counter
  begin  -- PROCESS INIT

    if (RST_I = '1') then

      RxSerData(0)  <= '1';
      RxSerData(1)  <= '1';
      RxSerData(2)  <= '1';
      RxSerData(3)  <= '1';
      RxSerData(4)  <= '1';
      RxSerData(5)  <= '1';
      RxSerData(6)  <= '1';
      RxSerData(7)  <= '1';
      RxSerData(8)  <= '1';
      -- Idle
      RxSerData(9)  <= '0';
      RxSerData(10) <= '1';
      RxSerData(11) <= '1';
      RxSerData(12) <= '1';
      RxSerData(13) <= '1';
      RxSerData(14) <= '1';
      RxSerData(15) <= '1';
      RxSerData(16) <= '0';
      -- Opening Flag

      -- Data pattern
      for i in 0 to 31 loop
        RxSerData(16+8*i+1) <= Counter(0);
        RxSerData(16+8*i+2) <= Counter(1);
        RxSerData(16+8*i+3) <= Counter(2);
        RxSerData(16+8*i+4) <= Counter(3);
        RxSerData(16+8*i+5) <= Counter(4);
        RxSerData(16+8*i+6) <= Counter(5);
        RxSerData(16+8*i+7) <= Counter(6);
        RxSerData(16+8*i+8) <= Counter(7);

        Counter := Counter +1;
      end loop;  -- i

      RxSerData(273) <= '0';
      RxSerData(274) <= '1';
      RxSerData(275) <= '1';
      RxSerData(276) <= '1';
      RxSerData(277) <= '1';
      RxSerData(278) <= '1';
      RxSerData(279) <= '1';
      RxSerData(280) <= '0';
      -- closing flag

      RxSerData(281) <= '1';
      RxSerData(282) <= '1';
      RxSerData(283) <= '1';
      RxSerData(284) <= '1';
      RxSerData(285) <= '1';
      RxSerData(286) <= '1';
      RxSerData(287) <= '1';
      RxSerData(288) <= '1';
      -- Idle 

    end if;


  end process INIT;
-------------------------------------------------------------------------------
  Host_IF                : process
    variable FrameLength : std_logic_vector(7 downto 0);  -- Frame Length
    variable counter     : std_logic_vector(7 downto 0) := "00000000";  -- Internal counter
  begin  -- PROCESS Host_IF
    WE_I                                                <= '0';  -- Read

    STB_I <= '0';
    CYC_I <= '0';
    ADR_I <= "000";

    wait until TAG1_O = '1';            -- wait for RxRdy
    STB_I <= '1';
    CYC_I <= '1';
    ADR_I <= "100";                     -- Rx_Fr_siz

    wait until ACK_O = '1';
    wait until CLK_I = '0';
    FrameLength := DAT_O(7 downto 0);
    STB_I       <= '0';
    CYC_I       <= '0';

--    wait until CLK_I = '0';
    wait until CLK_I = '1';
    wait until CLK_I = '0';
    STB_I <= '1';
    CYC_I <= '1';
    ADR_I <= "010";                     -- Rx_SC

    wait until ACK_O = '1';
    wait until CLK_I = '0';
    STB_I <= '0';
    CYC_I <= '0';

    ADR_I <= "011";                     -- Rx_Buff

--    wait until CLK_I = '0';
    wait until CLK_I = '1';
    wait until CLK_I = '0';

    STB_I <= '1';
    CYC_I <= '1';

    while (FrameLength /= "00000000") loop

      wait until ACK_O = '1';

      assert (DAT_O(7 downto 0) = counter)
        report "Data byte 1 missmatch"
        severity warning;

      FrameLength := FrameLength - 1;
      if FrameLength = "00000000" then
        exit;
      end if;

      counter := counter +1;
      assert (DAT_O(15 downto 8) = counter)
        report "Data byte 2 missmatch"
        severity warning;

      FrameLength := FrameLength - 1;
      if FrameLength = "00000000" then
        exit;
      end if;

      counter := counter +1;
      assert (DAT_O(23 downto 16) = counter)
        report "Data byte 3 missmatch"
        severity warning;

      FrameLength := FrameLength - 1;
      if FrameLength = "00000000" then
        exit;
      end if;

      counter := counter +1;
      assert (DAT_O(31 downto 24) = counter)
        report "Data byte 4 missmatch"
        severity warning;

      FrameLength := FrameLength - 1;
      if FrameLength = "00000000" then
        exit;
      end if;

      counter := counter +1;
--      wait until ACK_O = '1';

    end loop;

    wait until CLK_I = '0';

    STB_I <= '0';
    CYC_I <= '0';
    ADR_I <= "000";

    -- Transmit
    if TAG0_O = '0' then
      wait until TAG0_O = '1';
    end if;

    wait until CLK_I = '0';
    counter := (others => '0');

    STB_I <= '1';
    CYC_I <= '1';
    ADR_I <= "001";                     -- Tx_Buff
    WE_I  <= '1';                       -- Write

    for i in 0 to 7 loop

      DAT_I(7 downto 0)   <= counter;
      counter             := counter +1;
      DAT_I(15 downto 8)  <= counter;
      counter             := counter +1;
      DAT_I(23 downto 16) <= counter;
      counter             := counter +1;
      DAT_I(31 downto 24) <= counter;
      counter             := counter +1;

      wait until ACK_O = '1';

      wait until CLK_I = '0';

    end loop;  -- i

--    wait until CLK_I = '0';
    STB_I <= '0';
    CYC_I <= '0';
    WE_I  <= '0';

    wait until CLK_I = '1';
    wait until CLK_I = '0';
    STB_I              <= '1';
    CYC_I              <= '1';
    WE_I               <= '1';
    ADR_I              <= "000";        -- Tx_Sc
    DAT_I(31 downto 8) <= (others => '0');
    DAT_I(7 downto 0)  <= "00100010";

    wait until ACK_O = '1';
    wait until CLK_I = '0';

    STB_I <= '0';
    CYC_I <= '0';
    WE_I  <= '0';

    -- Check looped back Data
    wait until TAG1_O = '1';
    STB_I <= '1';
    CYC_I <= '1';
    ADR_I <= "100";                     -- Rx_Fr_siz

    wait until ACK_O = '1';
    FrameLength := DAT_O(7 downto 0);
    STB_I       <= '0';
    CYC_I       <= '0';

    wait until CLK_I = '0';
    wait until CLK_I = '1';
    wait until CLK_I = '0';
    STB_I <= '1';
    CYC_I <= '1';
    ADR_I <= "010";                     -- Rx_SC

    wait until ACK_O = '1';
    STB_I <= '0';
    CYC_I <= '0';

    ADR_I <= "011";                     -- Rx_Buff

    wait until CLK_I = '0';
    wait until CLK_I = '1';
    wait until CLK_I = '0';

    STB_I <= '1';
    CYC_I <= '1';
    counter := (others => '0');
    
    while (FrameLength /= "00000000") loop

      wait until ACK_O = '1';

      assert (DAT_O(7 downto 0) = counter)
        report "Data byte 1 missmatch"
        severity warning;

      FrameLength := FrameLength - 1;
      if FrameLength = "00000000" then
        exit;
      end if;

      counter := counter +1;
      assert (DAT_O(15 downto 8) = counter)
        report "Data byte 2 missmatch"
        severity warning;

      FrameLength := FrameLength - 1;
      if FrameLength = "00000000" then
        exit;
      end if;

      counter := counter +1;
      assert (DAT_O(23 downto 16) = counter)
        report "Data byte 3 missmatch"
        severity warning;

      FrameLength := FrameLength - 1;
      if FrameLength = "00000000" then
        exit;
      end if;

      counter := counter +1;
      assert (DAT_O(31 downto 24) = counter)
        report "Data byte 4 missmatch"
        severity warning;

      FrameLength := FrameLength - 1;
      if FrameLength = "00000000" then
        exit;
      end if;

      counter := counter +1;
      -- FrameLength := FrameLength - 4;

    end loop;


    STB_I <= '0';
    CYC_I <= '0';
    ADR_I <= "000";

    wait;

  end process Host_IF;

-------------------------------------------------------------------------------

  Rx_gen          : process
    variable flag : std_logic := '0';   -- internal flag
  begin  -- PROCESS Rx_gen

    for counter in 0 to RxSerData'length-1 loop
      wait until Rxclk = '0';

      Rx <= RxSerData(counter);

    end loop;  -- counter

    while flag = '0' loop
      wait until RxClk = '0';
      Rx <= Tx;
    end loop;

  end process Rx_gen;

-------------------------------------------------------------------------------
  DUT : hdlc_ent
    generic map (
      FCS_TYPE  => FCS_TYPE,
      ADD_WIDTH => ADD_WIDTH)
    port map (
      Txclk     => Txclk,
      RxClk     => RxClk,
      Tx        => Tx,
      Rx        => Rx,
      TxEN      => TxEN,
      RxEn      => RxEn,
      RST_I     => RST_I,
      CLK_I     => CLK_I,
      ADR_I     => ADR_I,
      DAT_O     => DAT_O,
      DAT_I     => DAT_I,
      WE_I      => WE_I,
      STB_I     => STB_I,
      ACK_O     => ACK_O,
      CYC_I     => CYC_I,
      RTY_O     => RTY_O,
      TAG0_O    => TAG0_O,
      TAG1_O    => TAG1_O);



end hdlc_beh_tb;

-------------------------------------------------------------------------------

