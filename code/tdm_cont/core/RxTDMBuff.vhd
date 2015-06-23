-------------------------------------------------------------------------------
-- Title      : TDM controller Rx Buffer
-- Project    : TDM controller
-------------------------------------------------------------------------------
-- File       : RxTDMBuff.vhd
-- Author     : Jamil Khatib  <khatib@ieee.org>
-- Organization:  OpenCores.org
-- Created    : 2001/05/14
-- Last update:2001/05/23
-- Platform   : 
-- Simulators  : NC-sim/linux, Modelsim XE/windows98
-- Synthesizers: Leonardo
-- Target      : 
-- Dependency  : ieee.std_logic_1164
-------------------------------------------------------------------------------
-- Description:  Receive Buffer that uses internal Sram
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
-- Date            :  2001/05/14
-- Modifier        :  Jamil Khatib  <khatib@ieee.org>
-- Desccription    :  Created
-- ToOptimize      :
-- Known Bugs      : 
-------------------------------------------------------------------------------
-- $Log: not supported by cvs2svn $
-- Revision 1.1  2001/05/24 22:48:55  jamil
-- TDM Initial release
--
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

LIBRARY memLib;
USE memLib.mem_pkg.ALL;


ENTITY RxTDMBuff IS

  PORT (
    CLK_I           : IN  STD_LOGIC;
    rst_n           : IN  STD_LOGIC;    -- System reset
    RxD             : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Rx Data
    RxRead          : OUT STD_LOGIC;    -- Rx Read
    RxRdy           : IN  STD_LOGIC;    -- Rx Ready to provide data
    RxValidData     : IN  STD_LOGIC;    -- Valid Data strobe
    BufferDataAvail : OUT STD_LOGIC;    -- Buffer Data Available strobe
    ReadBuff        : IN  STD_LOGIC;    -- Read Byte from Buffer
    RxData          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Rx Byte output from buffer
    RxError  : OUT STD_LOGIC    -- Rx Error (buffer over flow)
    );
END RxTDMBuff;



ARCHITECTURE RxTDMBuff OF RxTDMBuff IS


  TYPE States_type IS (IDLE_st, READ_st, WRITE_st,WAITWRITE_st);  -- Buffer states

  SIGNAL Address : STD_LOGIC_VECTOR(4 DOWNTO 0);  -- memory address

  SIGNAL cs : STD_LOGIC := '1';         -- dummy signal

  SIGNAL wr_i    : STD_LOGIC;                     -- Read/Write signal
  SIGNAL Data_In : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Memory Data in

  SIGNAL Data_Out : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Memory Data out



BEGIN  -- RxTDMBuff
-------------------------------------------------------------------------------
  RxData <= Data_Out;

-------------------------------------------------------------------------------
-- purpose: FSM process
-- type   : sequential
-- inputs : CLK_I, rst_n
-- outputs: 
  fsm : PROCESS (CLK_I, rst_n)

    VARIABLE state   : States_type;                   -- internal state
    VARIABLE counter : STD_LOGIC_VECTOR(4 DOWNTO 0);  -- Internal Counter
    VARIABLE value   : STD_LOGIC_VECTOR(4 DOWNTO 0);  -- Max count value

  BEGIN  -- PROCESS fsm

    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      state           := IDLE_st;
      RxRead          <= '0';
      Counter         := "00000";
      BufferDataAvail <= '0';
      value           := "00000";
      WR_I <= '1';
      RxError <= '0';
      Data_In <= (OTHERS => '1');
      address <= (OTHERS => '0');
      
    ELSIF CLK_I'event AND CLK_I = '1' THEN  -- rising clock edge

      address <= Counter;

      Data_In <= RxD;

      CASE state IS
        WHEN IDLE_st =>

          IF (RxValidData = '1') THEN
            state := WRITE_st;
          END IF;

          wr_i            <= '1';
          RxRead          <= '0';
          Counter         := "00000";
          BufferDataAvail <= '0';
          value           := "00000";
          RxError         <= '0';

        WHEN READ_st =>

          BufferDataAvail <= '1';
          RxRead          <= '0';

          wr_i    <= '1';--ReadBuff;
          RxError <= RxValidData;

          IF (counter = value) OR RxValidData = '1' THEN
            state   := IDLE_st;
            counter := "00000";

          ELSE
            IF (ReadBuff = '1') THEN
              Counter := Counter + 1;
            END IF;

          END if;
          
            WHEN WRITE_st =>
            BufferDataAvail <= '0';

            RxError <= '0';
            RxRead  <= RxRdy;
            wr_i    <= NOT RxRdy;
            
            IF (counter = "11111" OR RxValidData = '0') THEN
              state := READ_st;
              value := counter;

              counter := "00000";

--            wr_i   <= '1';
--            RxRead <= '0';
            ELSE
              IF (RxRdy = '1') THEN
--              wr_i    <= '0';         --write to buffer
                counter := counter + 1;
                state := WAITWRITE_st;
--              RxRead  <= '1';
--            ELSE
--              wr_i    <= '1';
--              RxRead  <= '0';
              END IF;

            END IF;

            WHEN WAITWRITE_st =>
          BufferDataAvail <= '0';
          RxError <= '0';
          RxRead <= '1';
          wr_i <= '0';
          IF (RxRdy = '0') THEN
            state := WRITE_st;
          END IF;
          
            WHEN OTHERS => NULL;
          END CASE;
      END IF;

    END PROCESS fsm;


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


    END RxTDMBuff;
