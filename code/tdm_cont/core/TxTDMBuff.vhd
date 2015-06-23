-------------------------------------------------------------------------------
-- Title      : TDM controller Tx Buffer
-- Project    : TDM controller
-------------------------------------------------------------------------------
-- File       : TxTDMBuff.vhd
-- Author     : Jamil Khatib  <khatib@ieee.org>
-- Organization:  OpenCores.org
-- Created    : 2001/05/14
-- Last update:2001/05/22
-- Platform   : 
-- Simulators  : NC-sim/linux, Modelsim XE/windows98
-- Synthesizers: Leonardo
-- Target      : 
-- Dependency  : ieee.std_logic_1164,ieee.std_logic_unsigned
--               memLib.mem_pkg
-------------------------------------------------------------------------------
-- Description:  Transmit Buffer that uses internal Sram
-------------------------------------------------------------------------------
-- Copyright (c) 2001  Jamil Khatib
-- 
-- This VHDL design file is an open design; you can redistribute it and/or
-- modify it and/or implement it after contacting the author
-- You can check the draft license at
-- http://www.opencores.org/OIPC/license.shtml
-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   1
-- Version         :   0.1
-- Date            :  2001/05/15
-- Modifier        :  Jamil Khatib  <khatib@ieee.org>
-- Desccription    :  Created
-- ToOptimize      :
-- Known Bugs      : 
-------------------------------------------------------------------------------
-- $Log: not supported by cvs2svn $
-- Revision 1.1  2001/05/24 22:48:56  jamil
-- TDM Initial release
--
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

LIBRARY memLib;
USE memLib.mem_pkg.ALL;

ENTITY TxTDMBuff IS

  PORT (
    CLK_I       : IN  STD_LOGIC;                     -- System Clock
    rst_n       : IN  STD_LOGIC;                     -- System reset
    TxD         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Tx output data
    TxValidData : OUT STD_LOGIC;                     -- Tx Valid Data
    TxWrite     : OUT STD_LOGIC;                     -- Write byte
    TxRdy       : IN  STD_LOGIC;                     -- Ready to send data

    WrBuff       : IN  STD_LOGIC;       -- Write to buffer
    TxData       : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Tx Byte output from buffer
    NoChannels   : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);  -- No of channels
    DropChannels : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);  -- No of channels to be dropped
    TxDone       : OUT STD_LOGIC;       -- Transmission completed
    TxOverflow   : OUT STD_LOGIC        -- Tx buffer overflow

    );

END TxTDMBuff;

ARCHITECTURE TxTDMBuff_rtl OF TxTDMBuff IS

  TYPE States_type IS (IDLE_st, READ_st, WAITREAD_st, WRITE_st);  -- Buffer states

  SIGNAL Address : STD_LOGIC_VECTOR(4 DOWNTO 0);  -- memory address

  SIGNAL cs : STD_LOGIC := '1';         -- dummy signal

  SIGNAL wr_i    : STD_LOGIC;                     -- Read/Write signal
  SIGNAL Data_In : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Memory Data in

  SIGNAL Data_Out : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Memory Data out

  SIGNAL TotalChannels : STD_LOGIC_VECTOR(4 DOWNTO 0);  -- Totoal Channels

BEGIN  -- TxTDMBuff_rtl

-------------------------------------------------------------------------------
  TxD           <= Data_Out;
  TotalChannels <= NoChannels - DropChannels;

-------------------------------------------------------------------------------
-- purpose: FSM process
-- type   : sequential
-- inputs : CLK_I, rst_n
-- outputs: 
  fsm : PROCESS (CLK_I, rst_n)

    VARIABLE state   : States_type;                   -- internal state
    VARIABLE counter : STD_LOGIC_VECTOR(4 DOWNTO 0);  -- Internal Counter
--    VARIABLE TxwriteDelayed : STD_LOGIC;            -- Delayed TxWrite

  BEGIN  -- PROCESS fsm

    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      state       := IDLE_st;
      TxWrite     <= '0';
      Counter     := "00000";
      TxValidData <= '0';

      TxOverflow <= '0';

      address <= (OTHERS => '0');
      Data_In <= (OTHERS => '0');

      TxDone <= '0';
      wr_i   <= '1';

    ELSIF CLK_I'event AND CLK_I = '1' THEN  -- rising clock edge


      CASE state IS
        WHEN IDLE_st =>
          TxValidData <= '0';
          TxOverflow  <= '0';

          Counter := "00000";
          address <= Counter;
          Data_In <= TxData;

          Txwrite <= '0';
          TxDone  <= '1';

          IF (WrBuff = '1') THEN

            state   := WRITE_st;
            Counter := Counter +1;

          END IF;

          wr_i <= NOT WrBuff;

          TxOverflow <= '0';

        WHEN READ_st =>
          TxValidData <= '1';
          TxDone      <= '0';
          TxOverflow  <= '0';

          wr_i    <= '1';
          Txwrite <= '0';

          address <= Counter;

          IF (TxRdy = '1') THEN

            state := WAITREAD_st;

          END IF;

        WHEN WAITREAD_st =>
          TxDone      <= '0';
          TxValidData <= '1';
          Txwrite     <= '1';
          TxOverflow  <= '0';

          address <= counter;

          wr_i <= '1';

          IF (TxRdy = '0') THEN
            IF (counter = TotalChannels) THEN             
              
              counter := (OTHERS => '0');
              state := IDLE_st;
              
              else
                counter := counter +1;
                state := READ_st;
            END IF;
            
          END IF;

        WHEN WRITE_st =>
          TxDone <= '0';

          TxValidData <= '0';

          TxOverflow <= '0';

          Txwrite <= '0';

          wr_i <= NOT WrBuff;

          address <= Counter;
          Data_In <= TxData;

          IF (counter = TotalChannels) THEN

            counter := "00000";
            state   := READ_st;

          ELSIF (WrBuff = '1') THEN
            counter := counter + 1;
          END IF;


        WHEN OTHERS => NULL;
      END CASE;
    END IF;

  END PROCESS fsm;
------------------------------------------------------------------------------

  Buff : Spmem_ent
    GENERIC MAP (
      USE_RESET   => FALSE,
      USE_CS      => FALSE,
      DEFAULT_OUT => '1',
      OPTION      => 0,
      ADD_WIDTH   => 5,
      WIDTH       => 8)
    PORT MAP (
      cs          => cs,
      clk         => clk_I,
      reset       => rst_n,
      add         => Address,
      Data_In     => Data_In,
      Data_Out    => Data_Out,
      WR          => WR_i);

END TxTDMBuff_rtl;



