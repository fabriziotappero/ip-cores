-------------------------------------------------------------------------------
-- Title      :  Rx Channel test bench
-- Project    :  HDLC controller
-------------------------------------------------------------------------------
-- File        : Rx_tb.vhd
-- Author      : Jamil Khatib  (khatib@ieee.org)
-- Organization: OpenIPCore Project
-- Created     : 2000/12/30
-- Last update: 2001/01/12
-- Platform    : 
-- Simulators  : Modelsim 5.3XE/Windows98
-- Synthesizers: 
-- Target      : 
-- Dependency  : ieee.std_logic_1164
--
-------------------------------------------------------------------------------
-- Description:  receive Channel test bench
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
-- Date            :   30 Dec 2000
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Created
-- ToOptimize      :   Add an input procedure to insert data pattern
-- Bugs            :  
-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   2
-- Version         :   0.2
-- Date            :   12 Jan 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Rx Enable and delayed Read tests are added
-- ToOptimize      :   Add an input procedure to insert data pattern
-- Bugs            :  
-------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use work.hdlc_components_pkg.all;

entity rx_tb_ent is

end rx_tb_ent;

architecture rx_tb_beh of rx_tb_ent is
  constant DataStreem : std_logic_vector(88 downto 0) := "11111111011111100100110011011111010001010011111101111000111101001101001011011011001111110";

-- "1_11111110_11111100_10011001_10111110_10001010_01111110_11110001_11101001_10100101_10110110_01111110"

  signal Rxclk_i : std_logic := '0';    -- system clock
  signal rst_i   : std_logic := '0';    -- system reset
  signal Rx_i    : std_logic;           -- internal Rx serial data

  signal RxData_i      : std_logic_vector(7 downto 0);  -- backend data bus
  signal ValidFrame_i  : std_logic;     -- backedn Valid frame signal
  signal AbortSignal_i : std_logic;     -- backend abort signal
  signal Readbyte_i    : std_logic;     -- backend read byte
  signal rdy_i         : std_logic;     -- backend ready signal
  signal RxEn_i        : std_logic;     -- receive enable
  signal FrameError_i  : std_logic;     -- Frame Error
begin  -- rx_tb_beh
-------------------------------------------------------------------------------

  Rxclk_i <= not Rxclk_i after 20 ns;

  rst_i <= '0',
           '1' after 30 ns;

  RxEn_i <= '1',
            '0' after 960 ns,
            '1' after 1280 ns;
-------------------------------------------------------------------------------

  -- purpose: Serial interface stimulus
  -- type   : sequential
  -- inputs : 
  -- outputs: 
  serial_proc      : process
    variable count : integer := 0;      -- Counter
  begin  -- process backend_proc


    wait until Rxclk_i = '0';

    rx_i <= DataStreem(count);

    if count = DataStreem'length-1 then
      count := 0;
    else
      count := count +1;
    end if;

  end process serial_proc;
-------------------------------------------------------------------------------
  -- purpose: Backend stimulus
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  backend_proc       : process(rdy_i)
    variable counter : integer := 0;    -- Counter
  begin  -- process backend_proc
    if rdy_i = '1' then
      -- Counter is used to generate Readbyte signal at different delays
      if not((counter > 20) and (counter < 40)) then
        Readbyte_i             <= '1' after 60 ns;
      elsif(counter mod 2 = 0) then
        -- data bits will be lost in this case
        Readbyte_i             <= '1' after 350 ns;
      else
        Readbyte_i             <= '1' after 60 ns;
      end if;
      counter                  := counter+1;
    else
      Readbyte_i               <= '0';
    end if;



  end process backend_proc;

-------------------------------------------------------------------------------

  uut : RxChannel_ent
    port map (
      Rxclk       => Rxclk_i,
      rst         => rst_i,
      Rx          => Rx_i,
      RxData      => RxData_i,
      ValidFrame  => ValidFrame_i,
      FrameError  => FrameError_i,
      AbortSignal => AbortSignal_i,
      Readbyte    => Readbyte_i,
      rdy         => rdy_i,
      RxEn        => RxEn_i);


end rx_tb_beh;
