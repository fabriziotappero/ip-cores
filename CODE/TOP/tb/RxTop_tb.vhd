-------------------------------------------------------------------------------
-- Title      :  Top Rx test bench
-- Project    :  HDLC controller
-------------------------------------------------------------------------------
-- File        : Rxtop_tb.vhd
-- Author      : Jamil Khatib  (khatib@ieee.org)
-- Organization: OpenIPCore Project
-- Created     :2001/04/10
-- Last update: 2001/04/12
-- Platform    : 
-- Simulators  : Modelsim 5.3XE/Windows98,NC-SIM/Linux
-- Synthesizers: 
-- Target      : 
-- Dependency  : ieee.std_logic_1164,
--               hdlc.hdlc_components_pkg
-------------------------------------------------------------------------------
-- Description:  Top Rx test bench
-------------------------------------------------------------------------------
-- Copyright (c) 2000 Jamil Khatib
-- 
-- This VHDL design file is an open design; you can redistribute it and/or
-- modify it and/or implement it after contacting the author
-- You can check the draft license at
-- http://www.opencores.org/OIPC/license.shtml

-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   1
-- Version         :   0.1
-- Date            :   10 April 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Created
-- ToOptimize      :
-- Bugs            :
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library hdlc;
use hdlc.hdlc_components_pkg.all;
-------------------------------------------------------------------------------

entity RxTop_ent_tb is

end RxTop_ent_tb;

-------------------------------------------------------------------------------
architecture Rxtop_beh_tb of RxTop_ent_tb is
  constant ADD_WIDTH     : integer   := 7;
  signal   Clk           : std_logic := '0';
  signal   rst_n         : std_logic := '0';
  signal   DataBuff      : std_logic_vector(7 downto 0);
  signal   EOF           : std_logic;
  signal   WrBuff        : std_logic;
  signal   FrameSize     : std_logic_vector(ADD_WIDTH-1 downto 0);
  signal   RxRdy         : std_logic;
  signal   RxDataBuffOut : std_logic_vector(7 downto 0);
  signal   Overflow      : std_logic;
  signal   Rd            : std_logic;


  signal RxD        : std_logic_vector(7 downto 0);
  signal ValidFrame : std_logic := '0';
  signal rdy        : std_logic;
  signal Readbyte   : std_logic;
  signal FCSen      : std_logic := '1';
  signal FCSerr     : std_logic;

begin  -- Rxtop_beh_tb
  Clk   <= not Clk after 50 ns;
  rst_n <= '1'     after 120 ns;

  -- purpose: data generation
  -- type   : sequential
  -- inputs : Clk, rst_n
  -- outputs: 
  process (Clk, rst_n)
  begin  -- PROCESS

    if rst_n = '0' then                 -- asynchronous reset (active low)
      RxD <= (others => '0');
    elsif Clk'event and Clk = '1' then  -- rising clock edge
      RxD <= RxD + 1;
    end if;

  end process;

-- purpose: serial interface EBM
-- type   : combinational
-- inputs : 
-- outputs: 
  process
    variable counter    : integer := 0;
    variable FrameCount : integer := 0;  -- Frame Counter
  begin  -- PROCESS

    rdy <= '0';

    -- Wait three clocks
    wait until Clk = '0';
    wait until Clk = '0';
    wait until Clk = '0';

    ValidFrame <= '1';

    wait until Clk = '0';
    wait until Clk = '0';
    wait until Clk = '0';


    while (true) loop

      wait until clk = '0';
      counter := counter +1;

      if (counter = 8) then
        FrameCount := FrameCount +1;
        rdy        <= '1';
        wait until clk = '0';
      end if;

      if (Readbyte = '1') then
        WAIT UNTIL clk = '1';
        rdy <= '0';
        counter := 0;
      end if;

      if (FrameCount = 15 ) then
        ValidFrame <= '0';
      end if;
    end loop;

  end process;

-- purpose: Backend EBM
-- type   : combinational
-- inputs : 
-- outputs: 
  Backend_EBM        : process
    variable flag    : std_logic := '0';  -- tatus flag
    variable counter : integer   := 0;    -- counter
  begin  -- PROCESS Backend_EBM
    rd                           <= '0';

    wait until RxRdy = '1';

    while counter /= conv_integer(FrameSize) loop

      wait until clk = '0';
      counter := counter +1;
      Rd      <= '1';

    end loop;

    counter := 0;
    Rd      <= '0';

  end process Backend_EBM;

  DUT1 : RxBuff_ent
    generic map (
      FCS_TYPE => 2,
      ADD_WIDTH     => ADD_WIDTH)
    port map (
      Clk           => Clk,
      rst_n         => rst_n,
      DataBuff      => DataBuff,
      EOF           => EOF,
      WrBuff        => WrBuff,
      FrameSize     => FrameSize,
      RxRdy         => RxRdy,
      RxDataBuffOut => RxDataBuffOut,
      Overflow      => Overflow,
      Rd            => Rd);


  DUT2 : RxFCS_ent
    GENERIC MAP (
      FCS_TYPE => 2)
    port map (
      clk        => clk,
      rst_n      => rst_n,
      RxD        => RxD,
      ValidFrame => ValidFrame,
      rdy        => rdy,
      Readbyte   => Readbyte,
      DataBuff   => DataBuff,
      WrBuff     => WrBuff,
      EOF        => EOF,
      FCSen      => FCSen,
      FCSerr     => FCSerr);

end Rxtop_beh_tb;
