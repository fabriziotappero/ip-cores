------------------------------------------------------------------------------
-- Title      : HDLC Rx Buffer
-- Project    : HDLC controller
-------------------------------------------------------------------------------
-- File       : RxBuff.vhd
-- Author     : Jamil Khatib  <khatib@ieee.org>
-- Organization: OpenIPCore Project 
-- Created    : 2001/04/06
-- Last update: 2001/04/25
-- Platform   : 
-- Simulators  : Modelsim/Windows98, NC-sim/Linux
-- Synthesizers: 
-- Target      : 
-- Dependency  : ieee.std_logic_1164
--                memLib.mem_pkg
-------------------------------------------------------------------------------
-- Description:  HDLC Receive Buffer
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
-- Date            :  2001/04/06
-- Modifier        :  Jamil Khatib  <khatib@ieee.org>
-- Desccription    :  Created
-- ToOptimize      :
-- Known Bugs      :
-------------------------------------------------------------------------------
-- $Log: not supported by cvs2svn $
-- Revision 1.3  2001/04/27 18:21:59  jamil
-- After Prelimenray simulation
--
-- Revision 1.2  2001/04/22 20:08:16  jamil
-- Top level simulation
--
-- Revision 1.1  2001/04/14 15:02:25  jamil
-- Initial Release
--
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

LIBRARY memLib;
USE memLib.mem_Pkg.ALL;

ENTITY RxBuff_ent IS

  GENERIC (
    FCS_TYPE  : INTEGER := 2;           -- 2 = FCS 16
                                        -- 4 = FCS 32
                                        -- 0 = FCS disabled
    ADD_WIDTH : INTEGER := 7);          -- Internal Address width

  PORT (
    Clk           : IN  STD_LOGIC;      -- System Clock
    rst_n         : IN  STD_LOGIC;      -- System reset
    DataBuff      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Rx Data
    EOF           : IN  STD_LOGIC;      -- End of Frame pulse
    WrBuff        : IN  STD_LOGIC;      -- Write buffer
    FrameSize     : OUT STD_LOGIC_VECTOR(ADD_WIDTH-1 DOWNTO 0);  -- Frame Length
    RxRdy         : OUT STD_LOGIC;      -- Rx Ready
    RxDataBuffOut : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Output Rx Buffer
    Overflow      : OUT STD_LOGIC;      -- Buffer Overflow
    Rd            : IN  STD_LOGIC);     -- Read buffer

END RxBuff_ent;


ARCHITECTURE RxBuff_rtl OF RxBuff_ent IS

  SIGNAL load_FrSize : STD_LOGIC;       -- Load Frame Size
  SIGNAL en_Count    : STD_LOGIC;       -- Enable Counter

  SIGNAL   Data_In_i   : STD_LOGIC_VECTOR(7 DOWNTO 0);
                                        -- Internal Data in
  SIGNAL   Data_Out_i  : STD_LOGIC_VECTOR(7 DOWNTO 0);
                                        -- Internal Data out
  CONSTANT MAX_ADDRESS : STD_LOGIC_VECTOR(ADD_WIDTH-1 DOWNTO 0) := (OTHERS => '1');
                                        -- MAX Address

  SIGNAL Count     : STD_LOGIC_VECTOR(ADD_WIDTH-1 DOWNTO 0);  -- Counter
  SIGNAL rst_count : STD_LOGIC;                               -- Reset Counter

  SIGNAL cs : STD_LOGIC := '1';         -- dummy signal

  SIGNAL WR_i        : STD_LOGIC;       -- Internal Read/Write signal
  SIGNAL Address     : STD_LOGIC_VECTOR(ADD_WIDTH-1 DOWNTO 0);
                                        -- Internal Address bus
  SIGNAL FrameSize_i : STD_LOGIC_VECTOR(ADD_WIDTH-1 DOWNTO 0);
                                        -- Internal Frame Size
  SIGNAL Overflow_i  : STD_LOGIC;       -- Internal Overflow
  SIGNAL RxRdy_i     : STD_LOGIC;       -- Internal RxRdy

  TYPE states_typ IS (IDLE_st, WRITE_st, READ_st);  -- states types

  SIGNAL p_state : states_typ;          -- Present state
  SIGNAL n_state : states_typ;          -- Next State


BEGIN  -- RxBuff_rtl
-------------------------------------------------------------------------------

  Data_In_i     <= DataBuff;
  RxDataBuffOut <= Data_Out_i;

-------------------------------------------------------------------------------
--  Full    <= '1' WHEN Address = MAX_ADDRESS ELSE '0';
  Address <= Count;

-------------------------------------------------------------------------------
-- purpose: Byte counter
-- type   : sequential
-- inputs : Clk, rst_n
-- outputs: 
  counter_proc  : PROCESS (Clk, rst_n)
  BEGIN  -- process counter_proc
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      count         <= (OTHERS => '0');
    ELSIF Clk'event AND Clk = '1' THEN  -- rising clock edge
      IF rst_count = '1' THEN           -- Synchronouse Reset (active high)
        count       <= (OTHERS => '0');
      ELSIF en_Count = '1' THEN
        count       <= count +1;
      END IF;
    END IF;
  END PROCESS counter_proc;
-------------------------------------------------------------------------------
-- purpose: Frame Size register
-- type   : sequential
-- inputs : Clk, rst_n
-- outputs: 
  FrameSize_reg : PROCESS (Clk, rst_n)
  BEGIN  -- process FrameSize_reg
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      FrameSize     <= (OTHERS => '0');
      FrameSize_i   <= (OTHERS => '0');
    ELSIF Clk'event AND Clk = '1' THEN  -- rising clock edge
      IF load_FrSize = '1' THEN
        FrameSize   <= address - FCS_TYPE;
        FrameSize_i <= address - FCS_TYPE;
      END IF;
    END IF;
  END PROCESS FrameSize_reg;
-------------------------------------------------------------------------------

  -- purpose: fsm process
  -- type   : sequential
  -- inputs : Clk, rst_n
  -- outputs: 
  fsm_proc  : PROCESS (Clk, rst_n)
  BEGIN  -- process fsm_proc
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      p_state  <= IDLE_st;
      Overflow <= '0';
      RxRdy    <= '0';
    ELSIF Clk'event AND Clk = '1' THEN  -- rising clock edge
      p_state  <= n_state;
      Overflow <= Overflow_i;
      RxRdy    <= RxRdy_i;
    END IF;
  END PROCESS fsm_proc;
-------------------------------------------------------------------------------
  -- purpose: FSM Combinational logic
  -- type   : combinational
  -- inputs : p_state,WrBuff,Rd
  -- outputs: 
  ReadWrite : PROCESS (p_state, WrBuff, Rd, EOF, FrameSize_i, address)

  BEGIN  -- PROCESS ReadWrite

    CASE p_state IS

      WHEN IDLE_st =>
        RxRdy_i     <= '0';
        load_FrSize <= '0';
        wr_i        <= NOT WrBuff;
        Overflow_i  <= '0';
        IF WrBuff = '1' THEN
          n_state   <= WRITE_st;
          en_Count  <= '1';
          rst_count <= '0';
        ELSE
          n_state   <= IDLE_st;
          en_Count  <= '0';
          rst_count <= '1';
        END IF;

      WHEN WRITE_st =>
        IF (Address = MAX_ADDRESS) THEN
          Overflow_i <= '1';
        ELSE
          Overflow_i <= '0';
        END IF;


--        RxRdy_i  <= '0';
        wr_i     <= NOT WrBuff;
        en_Count <= WrBuff;

        IF (EOF = '1') OR (address = MAX_ADDRESS) THEN
          RxRdy_i     <= '1';
          n_state     <= READ_st;
          load_FrSize <= '1';
          rst_count   <= '1';
        ELSE
          RxRdy_i     <= '0';
          n_state     <= WRITE_st;
          load_FrSize <= '0';
          rst_count   <= '0';
        END IF;

      WHEN READ_st =>

        wr_i        <= '1';
        en_Count    <= Rd;
        load_FrSize <= '0';

        IF address = FrameSize_i THEN
          Overflow_i   <= '0';
          RxRdy_i      <= '0';
          n_state      <= IDLE_st;
          rst_count    <= '1';
        ELSE
          IF (WrBuff = '1') THEN
            Overflow_i <= '1';
            n_state    <= WRITE_st;
            rst_count  <= '1';
          ELSE
            Overflow_i <= '0';
            n_state    <= READ_st;
            rst_count  <= '0';
          END IF;
          RxRdy_i      <= '1';

        END IF;

    END CASE;

  END PROCESS ReadWrite;


  Buff : Spmem_ent
    GENERIC MAP (
      USE_RESET   => FALSE,
      USE_CS      => FALSE,
      DEFAULT_OUT => '1',
      OPTION      => 0,
      ADD_WIDTH   => ADD_WIDTH,
      WIDTH       => 8)
    PORT MAP (
      cs          => cs,
      clk         => clk,
      reset       => rst_n,
      add         => Address,
      Data_In     => Data_In_i,
      Data_Out    => Data_Out_i,
      WR          => WR_i);

END RxBuff_rtl;
