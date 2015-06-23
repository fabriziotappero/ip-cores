-------------------------------------------------------------------------------
-- Title      : ISDN tdm controller
-- Project    : TDM controller
-------------------------------------------------------------------------------
-- File       : ISDN_cont.vhd
-- Author     : Jamil Khatib  <khatib@ieee.org>
-- Organization:  OpenCores.org
-- Created    : 2001/04/30
-- Last update:2001/05/04
-- Platform   : 
-- Simulators  : NC-sim/linux, Modelsim XE/windows98
-- Synthesizers: Leonardo
-- Target      : 
-- Dependency  : ieee.std_logic_1164
-------------------------------------------------------------------------------
-- Description:  ISDN tdm controller that extracts 2B+D channels from 3 time
-- slots of the incoming streem
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
-- Date            :  2001/04/30
-- Modifier        :  Jamil Khatib  <khatib@ieee.org>
-- Desccription    :  Created
-- ToOptimize      :
-- Known Bugs      : The serial interface is not compatible with the ST-Bus
-------------------------------------------------------------------------------
-- $Log: not supported by cvs2svn $
-- Revision 1.1  2001/05/06 17:55:23  jamil
-- Initial Release
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity isdn_cont_ent is

  port (
    rst_n     : in  std_logic;          -- System asynchronous reset
    C2        : in  std_logic;          -- ST-Bus clock
    DSTi      : in  std_logic;          -- ST-Bus input Data
    DSTo      : out std_logic;          -- ST-Bus output Data
    F0_n      : in  std_logic;          -- St-Bus Framing pulse
    F0od_n    : out std_logic;          -- ST-Bus Delayed Framing pulse
    HDLCen1   : out std_logic;          -- HDLC controller 1 enable
    HDLCen2   : out std_logic;          -- HDLC controller 2 enable
    HDLCen3   : out std_logic;          -- HDLC controller 3 enable
    HDLCTxen1 : out std_logic;          -- HDLC controller 1 enable Tx
    HDLCTxen2 : out std_logic;          -- HDLC controller 2 enable Tx
    HDLCTxen3 : out std_logic;          -- HDLC controller 3 enable Tx
    Dout      : out std_logic;          -- Serial Data output
    Din1      : in  std_logic;          -- Serial Data input1
    Din2      : in  std_logic;          -- Serial Data input2
    Din3      : in  std_logic);         -- Serial Data input3

end isdn_cont_ent;

-------------------------------------------------------------------------------

architecture isdn_cont_rtl of isdn_cont_ent is
  type STATES_TYPE is (IDLE_st, PASSB1_st, PASSB2_st, PASSD_st);  -- FSM states

  signal p_state        : STATES_TYPE;                    -- Present state
  signal n_state        : STATES_TYPE;                    -- Next State
  signal counter_Rx_i   : std_logic_vector( 2 downto 0);  -- Internal counter
  signal counter_Rx_reg : std_logic_vector( 2 downto 0);  -- Internal counter

  signal p_state_Tx : STATES_TYPE;      -- Present state
  signal n_state_Tx : STATES_TYPE;      -- Next State

  signal counter_Tx_i   : std_logic_vector( 2 downto 0);  -- Internal counter
  signal counter_Tx_reg : std_logic_vector( 2 downto 0);  -- Internal counter

  signal DSTi_reg : std_logic;          -- DSTi register
  signal F0_n_reg : std_logic;          -- F0_n register

  signal F0od_n_i       : std_logic;    -- Delayed F0output internal
  signal outputData_reg : std_logic_vector(17 downto 0);
                                        -- Output Data register
  signal outputData     : std_logic_vector(17 downto 0);
                                        -- Output Data

begin  -- isdn_cont_rtl

  Dout <= DSTi_reg;

-- purpose: Rising edge F0_n sampling
-- type   : sequential
-- inputs : C2, rst_n
-- outputs: 
  rising_edge_regs : process (C2, rst_n)
  begin  -- process rising_edge
    if rst_n = '0' then                 -- asynchronous reset (active low)
      F0_n_reg       <= '1';
--      F0od_n         <= '1';
      outputData_reg <= (others => '1');
      p_state_tx     <= IDLE_st;
      counter_Tx_reg <= "000";
    elsif C2'event and C2 = '1' then    -- rising clock edge
      F0_n_reg       <= F0_n;
--      F0od_n         <= F0od_n_i;
      outputData_reg <= outputData;
      p_state_tx     <= n_state_tx;
      counter_Tx_reg <= counter_Tx_i;
    end if;
  end process rising_edge_regs;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- purpose: FSM Combinational logic
-- type   : combinational
-- inputs : F0_n, p_state_tx, counter_tx_reg, outputData_reg, Din1, Din2, Din3
-- outputs: 
  comb_tx : process (F0_n, p_state_tx, counter_tx_reg, outputData_reg, Din1, Din2, Din3)

  begin  -- PROCESS comb

    case p_state_tx is

      when IDLE_st =>
        HDLCTxen1 <= '0';
        HDLCTxen2 <= '0';
        HDLCTxen3 <= '0';

        counter_Tx_i <= "000";

        DSTo       <= 'Z';
        outputData <= outputData_reg;

        if (F0_n = '0') then
          n_state_tx <= PASSB1_st;
        else
          n_state_tx <= IDLE_st;
        end if;

      when PASSB1_st =>

        HDLCTxen1 <= '1';
        HDLCTxen2 <= '0';
        HDLCTxen3 <= '0';

        counter_Tx_i <= counter_Tx_reg + 1;

        if (counter_tx_reg = "110" ) then
          n_state_tx <= PASSB2_st;
        else
          n_state_tx <= PASSB1_st;
        end if;
        DSTo         <= outputData_reg(0);
        outputData   <= Din1 & outputData_reg(17 downto 1);

      when PASSB2_st =>
        counter_Tx_i <= counter_Tx_reg +1;

        HDLCTxen1 <= '0';
        HDLCTxen2 <= '1';
        HDLCTxen3 <= '0';

        if (counter_tx_reg = "110" ) then
          n_state_tx <= PASSD_st;
        else
          n_state_tx <= PASSB2_st;
        end if;
        DSTo         <= outputData_reg(0);
        outputData   <= Din2 & outputData_reg(17 downto 1);

      when PASSD_st =>
        counter_Tx_i <= counter_Tx_reg + 1;

        HDLCTxen1 <= '0';
        HDLCTxen2 <= '0';
        HDLCTxen3 <= '1';

        if (counter_tx_reg = "001" ) then
          n_state_tx <= IDLE_st;
        else
          n_state_tx <= PASSD_st;
        end if;
        DSTo         <= outputData_reg(0);
        outputData   <= Din3 & outputData_reg(17 downto 1);

    end case;

  end process comb_tx;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- purpose: FSM registers
-- type   : sequential
-- inputs : C2, rst_n
-- outputs: 
  fsm : process (C2, rst_n)
  begin  -- PROCESS fsm

    if rst_n = '0' then                 -- asynchronous reset (active low)
      p_state        <= IDLE_st;
      DSTi_reg       <= '0';
      F0od_n         <= '1';
      counter_Rx_reg <= "000";
    elsif C2'event and C2 = '0' then    -- falling clock edge
      p_state        <= n_state;
      DSTi_reg       <= DSTi;
      F0od_n         <= F0od_n_i;
      counter_Rx_reg <= counter_Rx_i;
    end if;

  end process fsm;

-------------------------------------------------------------------------------
-- purpose: FSM Combinational logic
-- type   : combinational
-- inputs : F0_n,Din,p_state
-- outputs: 
  comb : process (F0_n_reg, p_state, counter_Rx_reg, outputData_reg, Din1, Din2, Din3)

  begin  -- PROCESS comb

    case p_state is

      when IDLE_st =>
        HDLCen1 <= '0';
        HDLCen2 <= '0';
        HDLCen3 <= '0';

        counter_Rx_i <= "000";

        F0od_n_i <= '1';

        if (F0_n_reg = '0') then
          n_state <= PASSB1_st;
        else
          n_state <= IDLE_st;
        end if;

      when PASSB1_st =>

        HDLCen1 <= '1';
        HDLCen2 <= '0';
        HDLCen3 <= '0';

        counter_Rx_i <= counter_Rx_reg + 1;

        F0od_n_i <= '1';

        if (counter_Rx_reg = "111" ) then
          n_state <= PASSB2_st;
        else
          n_state <= PASSB1_st;
        end if;

      when PASSB2_st =>
        HDLCen1      <= '0';
        HDLCen2      <= '1';
        HDLCen3      <= '0';
        counter_Rx_i <= counter_Rx_reg + 1;
        F0od_n_i     <= '1';

        if (counter_Rx_reg = "111" ) then
          n_state    <= PASSD_st;
        else
          n_state    <= PASSB2_st;
        end if;

      when PASSD_st =>
        HDLCen1      <= '0';
        HDLCen2      <= '0';
        HDLCen3      <= '1';
        counter_Rx_i <= counter_Rx_reg + 1;

        if (counter_Rx_reg = "001" ) then
          n_state  <= IDLE_st;
          F0od_n_i <= '0';
        else
          n_state  <= PASSD_st;
          F0od_n_i <= '1';
        end if;

    end case;
  end process comb;

-------------------------------------------------------------------------------
end isdn_cont_rtl;
