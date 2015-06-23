-------------------------------------------------------------------------------
-- Title      : TDM controller wishbone interface
-- Project    : TDM controller
-------------------------------------------------------------------------------
-- File       : tdm_wb_if.vhd
-- Author     : Jamil Khatib  <khatib@ieee.org>
-- Organization:  OpenCores.org
-- Created    : 2001/05/18
-- Last update:2001/05/24
-- Platform   : 
-- Simulators  : NC-sim/linux, Modelsim XE/windows98
-- Synthesizers: Leonardo
-- Target      : 
-- Dependency  : ieee.std_logic_1164,ieee.std_logic_unsigned
-------------------------------------------------------------------------------
-- Description:  tdm controller Wishbone Bus interface
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
-- Date            :  2001/05/18
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

ENTITY tdm_wb_if_ent IS

  PORT (
    -- WB Bus ports
    CLK_I  : IN  STD_LOGIC;                      -- System Clock
    RST_I  : IN  STD_LOGIC;                      -- System Reset
    ACK_O  : OUT STD_LOGIC;                      -- acknowledge
    ADR_I  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);   -- address
    CYC_I  : IN  STD_LOGIC;                      -- Bus cycle
    DAT_I  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);  -- Input data
    DAT_O  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);  -- Output data
    RTY_O  : OUT STD_LOGIC;                      -- retry
    STB_I  : IN  STD_LOGIC;                      -- strobe
    WE_I   : IN  STD_LOGIC;                      -- Write
    TAG0_O : OUT STD_LOGIC;                      -- TAG0 (TxDone)
    TAG1_O : OUT STD_LOGIC;                      -- TAG1_O (RxRdy)

-- Internal ports
    -- Tx
    TxDone      : IN  STD_LOGIC;        -- Transmission Done (Read Frame completed)
    WrBuff      : OUT STD_LOGIC;        -- Write to buffer
    TxData      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Tx Byte output from buffer
    TxOverflow  : IN  STD_LOGIC;        -- Tx buffer overflow
    TxUnderflow : IN  STD_LOGIC;        -- Tx Buffer under flow
    -- Rx
    RxRdy       : IN  STD_LOGIC;        -- Rx Ready    
    ReadBuff    : OUT STD_LOGIC;        -- Read Byte from Buffer
    RxData      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Rx Byte output from buffer
    RxOverflow  : IN  STD_LOGIC;        -- Rx Buffer Overflow
    RxLineOverflow : IN STD_LOGIC;          -- Rx Line conversion error
    HDLCen       : OUT STD_LOGIC;       -- Enable HDLC
    NoChannels   : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);  -- No of channels
    DropChannels : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)  -- No of channels to be dropped
    );
END tdm_wb_if_ent;


ARCHITECTURE WB_IF_rtl OF tdm_WB_IF_ent IS
  SIGNAL ack_0 : STD_LOGIC;             -- ack Reg 0
  SIGNAL ack_1 : STD_LOGIC;             -- ack Reg 1
  SIGNAL ack_2 : STD_LOGIC;             -- ack Reg 2
  SIGNAL ack_3 : STD_LOGIC;             -- ack Reg 3
  SIGNAL ack_4 : STD_LOGIC;             -- ack Reg 4

  SIGNAL DATO_0 : STD_LOGIC_VECTOR(31 DOWNTO 0);  -- data out 0
  SIGNAL DATO_1 : STD_LOGIC_VECTOR(31 DOWNTO 0);  -- data out 1
  SIGNAL DATO_2 : STD_LOGIC_VECTOR(31 DOWNTO 0);  -- data out 2
  SIGNAL DATO_3 : STD_LOGIC_VECTOR(31 DOWNTO 0);  -- data out 3
  SIGNAL DATO_4 : STD_LOGIC_VECTOR(31 DOWNTO 0);  -- data out 4

  SIGNAL en_0 : STD_LOGIC;              -- Enable reg 0
  SIGNAL en_1 : STD_LOGIC;              -- Enable reg 1
  SIGNAL en_2 : STD_LOGIC;              -- Enable reg 2
  SIGNAL en_3 : STD_LOGIC;              -- Enable reg 3
  SIGNAL en_4 : STD_LOGIC;              -- Enable reg 4

  SIGNAL counter   : INTEGER RANGE 0 TO 8;  -- System counter
  SIGNAL rst_count : STD_LOGIC;             -- Reset counter

BEGIN  -- WB_IF_rtl

-- purpose: WB fsm
-- type   : sequential
-- inputs : CLK_I, RST_I
-- outputs: 
  WB_fsm : PROCESS (CLK_I, RST_I)

  BEGIN  -- PROCESS WB_fsm
    IF (CLK_I'event AND CLK_I = '1') THEN
      RTY_O <= '0';

      IF (RST_I = '1') THEN             -- synchronous reset

        ACK_O  <= '0';
        DAT_O  <= (OTHERS => '0');
        RTY_O  <= '0';
        TAG0_O <= '0';
        TAG1_O <= '0';

        en_0      <= '0';
        en_1      <= '0';
        en_2      <= '0';
        en_3      <= '0';
        en_4      <= '0';
        rst_count <= '1';

      ELSE
        TAG0_O <= TxDone;
        TAG1_O <= RxRdy;

        IF (CYC_I = '1' AND STB_I = '1') THEN

          CASE ADR_I IS
            WHEN "000" =>               -- Tx_SC
              ACK_O <= ack_0;
              DAT_O <= DATO_0;

              en_0      <= '1';
              en_1      <= '0';
              en_2      <= '0';
              en_3      <= '0';
              en_4      <= '0';
              rst_count <= '1';

            WHEN "001" =>               -- Tx_Buff
              ACK_O <= ack_1;
              DAT_O <= DATO_1;

              en_0 <= '0';
              en_1 <= '1' AND NOT ack_1;
              en_2 <= '0';
              en_3 <= '0';
              en_4 <= '0';

              IF counter = 4 THEN
                rst_count <= '1';
              ELSE
                rst_count <= '0';
              END IF;

            WHEN "010" =>               -- Rx_SC
              ACK_O <= ack_2;
              DAT_O <= DATO_2;

              en_0 <= '0';
              en_1 <= '0';
              en_2 <= '1';
              en_3 <= '0';
              en_4 <= '0';

            WHEN "011" =>               -- Rx_Buff
              ACK_O <= ack_3;
              DAT_O <= DATO_3;

              en_0 <= '0';
              en_1 <= '0';
              en_2 <= '0';
              en_3 <= '1' AND NOT ack_3;
              en_4 <= '0';

              IF (ack_3 = '1') THEN
                rst_count <= '1';
                else
                  rst_count <= '0';
              END IF;
--              IF counter = 6 THEN
--                rst_count <= '1';
--              ELSE
--                rst_count <= '0';
--              END IF;

            WHEN "100" =>               -- Channels configuration
              ACK_O <= ack_4;
              DAT_O <= DATO_4;

              en_0 <= '0';
              en_1 <= '0';
              en_2 <= '0';
              en_3 <= '0';
              en_4 <= '1';

            WHEN OTHERS        =>
              DAT_O <= (OTHERS => '0');
              ACK_O <= '1';

              en_0 <= '0';
              en_1 <= '0';
              en_2 <= '0';
              en_3 <= '0';
              en_4 <= '0';

          END CASE;

        ELSE

          DAT_O <= (OTHERS => '0');
          ACK_O <= '0';

          en_0 <= '0';
          en_1 <= '0';
          en_2 <= '0';
          en_3 <= '0';
          en_4 <= '0';

        END IF;  -- cycle

      END IF;  --clock

    END IF;  -- reset

  END PROCESS WB_fsm;

-------------------------------------------------------------------------------
  -- purpose: Register0
  -- type   : sequential
  -- inputs : CLK_I, RST_I
  -- outputs: 
  reg0 : PROCESS (CLK_I, RST_I)

    VARIABLE HDLCen_var      : STD_LOGIC;  -- Internal HDLc enable
    VARIABLE TxOverflow_var  : STD_LOGIC;  -- Internal Overflow reg
    VARIABLE TxUnderflow_var : STD_LOGIC;  -- Internal underflow re 

  BEGIN  -- PROCESS reg0
    IF (CLK_I'event AND CLK_I = '1') THEN

      IF (RST_I = '1') THEN
        ack_0           <= '0';
        DATO_0          <= (OTHERS => '0');
        HDLCen          <= '0';
        HDLCen_var      := '0';
        TxOverflow_var  := '0';
        TxUnderflow_var := '0';

      ELSE

        DATO_0 <= "000000000000000000000000"&
                  "0000" & HDLCen_var & TxUnderflow_var & TxOverflow_var & TxDone;
        ack_0  <= en_0;

        IF (TxOverflow = '1') THEN
          TxOverflow_var := '1';
        ELSIF (en_0 = '1') THEN
          TxOverflow_var := '0';
        END IF;

        IF (TxUnderflow = '1') THEN
          TxUnderflow_var := '1';
        ELSIF (en_0 = '1') THEN
          TxUnderflow_var := '0';
        END IF;


        IF (en_0 = '1' AND WE_I = '1') THEN

          HDLCen_var := DAT_I(3);

        END IF;  -- Write and en_0

        HDLCen <= HDLCen_var;

      END IF;  -- rst
    END IF;  -- clk

  END PROCESS reg0;
-------------------------------------------------------------------------------
  -- purpose: Register1
  -- type   : sequential
  -- inputs : CLK_I, RST_I
  -- outputs: 
  reg1 : PROCESS (CLK_I, RST_I)

  BEGIN  -- PROCESS reg1
    IF (CLK_I'event AND CLK_I = '1') THEN

      IF (RST_I = '1') THEN
        ack_1  <= '0';
        DATO_1 <= (OTHERS => '0');

      ELSE                              -- reset
        DATO_1 <= (OTHERS => '0');

        IF (WE_I = '1' AND en_1 = '1') THEN

          CASE counter IS
            WHEN 0 =>
              WrBuff <= '1';
              TxData <= DAT_I(7 DOWNTO 0);
              ack_1  <= '0';

            WHEN 1 =>
              WrBuff <= '1';
              TxData <= DAT_I(15 DOWNTO 8);
              ack_1  <= '0';

            WHEN 2 =>
              WrBuff <= '1';
              TxData <= DAT_I(23 DOWNTO 16);
              ack_1  <= '0';

            WHEN 3 =>
              WrBuff <= '1';
              TxData <= DAT_I(31 DOWNTO 24);
              ack_1  <= '1';

            WHEN OTHERS         =>
              WrBuff <= '0';
              TxData <= (OTHERS => '0');
              ack_1  <= '0';
          END CASE;

        ELSE                            -- WE_I

          TxData <= (OTHERS => '0');
          WrBuff <= '0';
          ack_1  <= '0';
        END IF;  -- WE_I and en_1

      END IF;  -- rst
    END IF;  -- clk

  END PROCESS reg1;

-------------------------------------------------------------------------------
  -- purpose: Register2
  -- type   : sequential
  -- inputs : CLK_I, RST_I
  -- outputs: 
  reg2                      : PROCESS (CLK_I, RST_I)
    VARIABLE RxOverflow_var : STD_LOGIC;  -- RxOverflow internal register
    VARIABLE RxLineOverflow_var : STD_LOGIC;  -- Rx Line Over flow (cased by line
                                          -- serial to parallel conversion error)
  BEGIN  -- PROCESS reg3
    IF (CLK_I'event AND CLK_I = '1') THEN

      IF (RST_I = '1') THEN
        ack_2  <= '0';
        DATO_2 <= (OTHERS => '0');
        RxLineOverflow_var := '0';
        RxOverflow_var := '0';
      ELSE
        DATO_2 <= "000000000000000000000000"&
                  "00000" & RxOverflow_var & RxLineOverflow_var & RxRdy;
        ack_2  <= en_2;

        IF (RxOverflow = '1') THEN
          RxOverflow_var := '1';
        ELSIF (en_2 = '1') THEN
          RxOverflow_var := '0';
        END IF;

        IF (RxLineOverflow = '1') THEN
          RxLineOverflow_var := '1';
        ELSIF (en_2 = '1') THEN
          RxLineOverflow_var := '0';
        END IF;

      END IF;  -- rst
    END IF;  -- clk

  END PROCESS reg2;
-------------------------------------------------------------------------------
  -- purpose: Register3
  -- type   : sequential
  -- inputs : CLK_I, RST_I
  -- outputs: 
  reg3 : PROCESS (CLK_I, RST_I)

  BEGIN  -- PROCESS reg3
    IF (CLK_I'event AND CLK_I = '1') THEN

      IF (RST_I = '1') THEN
        ack_3  <= '0';
        DATO_3 <= (OTHERS => '0');

      ELSE

        IF (en_3 = '1' AND WE_I = '0') THEN

          CASE counter IS
            WHEN 0                =>
              ReadBuff <= '1';
              DATO_3   <= (OTHERS => '0');
              ack_3    <= '0';

            WHEN 1 =>
              ReadBuff <= '1';

              DATO_3 <= RxData & DATO_3(31 DOWNTO 8);

              ack_3 <= '0';

            WHEN 2 =>
              ReadBuff <= '1';
              DATO_3   <= RxData & DATO_3(31 DOWNTO 8);
              ack_3    <= '0';

            WHEN 3 =>
              ReadBuff <= '1';

              DATO_3 <= RxData & DATO_3(31 DOWNTO 8);
              ack_3  <= '0';

            WHEN 4 =>
              ReadBuff <= '0';

              DATO_3 <= RxData & DATO_3(31 DOWNTO 8);
              ack_3  <= '0';

            WHEN 5 =>
              ReadBuff <= '0';

              DATO_3 <= RxData & DATO_3(31 DOWNTO 8);
              ack_3  <= '0';

             WHEN 6 =>
              ReadBuff <= '0';

              DATO_3 <= RxData & DATO_3(31 DOWNTO 8);
              ack_3  <= '1';  

            WHEN OTHERS =>
              ReadBuff <= '0';

              DATO_3 <= (OTHERS => '0');
              ack_3  <= '0';
          END CASE;

        ELSE
          DATO_3 <= (OTHERS => '0');

          ReadBuff <= '0';
          ack_3    <= '0';

        END IF;  -- en

      END IF;  -- rst
    END IF;  -- clk

  END PROCESS reg3;

  -----------------------------------------------------------------------------
  -- purpose: Register4
  -- type   : sequential
  -- inputs : CLK_I, RST_I
  -- outputs: 
  reg4 : PROCESS (CLK_I, RST_I)
variable NoChannels_var : STD_LOGIC_VECTOR(4 downto 0);  -- Internal register
variable DropChannels_var : STD_LOGIC_VECTOR(4 downto 0);  -- Internal register

  BEGIN  -- PROCESS reg4
    IF (CLK_I'event AND CLK_I = '1') THEN

      IF (RST_I = '1') THEN
        ack_4  <= '0';
        DATO_4 <= (OTHERS => '0');

        NoChannels_var := (OTHERS => '0');
        DropChannels_var := (OTHERS => '0');
        
      ELSE
        DATO_4 <= "0000000000000000" & "000" & DropChannels_var& "000" & NoChannels_var;

        if( WE_I = '1' and en_4 = '1')then
           NoChannels_var   := DAT_I(4 DOWNTO 0);
           DropChannels_var := DAT_I(12 DOWNTO 8);
           NoChannels   <= DAT_I(4 DOWNTO 0);
           DropChannels <= DAT_I(12 DOWNTO 8);
        end if;
        
        ack_4 <= en_4;
    
      END IF;  -- rst
    END IF;  -- clk

  END PROCESS reg4;
  -----------------------------------------------------------------------------

-- purpose: system counter
-- type   : sequential
-- inputs : CLK_I
-- outputs: 
  sys_counter : PROCESS (CLK_I)
  BEGIN  -- process sys_counter

    IF CLK_I'event AND CLK_I = '1' THEN  -- rising clock edge

      IF rst_count = '1' THEN

        counter <= 0;

      ELSIF en_1 = '1' OR en_3 = '1' THEN

        counter <= counter +1;

      ELSE
        counter <= 0;
      END IF;
    END IF;
  END PROCESS sys_counter;
-----------------------------------------------------------------------------

END WB_IF_rtl;
