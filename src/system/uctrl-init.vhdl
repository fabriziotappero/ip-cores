-- Copyright 2015, Jürgen Defurne
--
-- This file is part of the Experimental Unstable CPU System.
--
-- The Experimental Unstable CPU System Is free software: you can redistribute
-- it and/or modify it under the terms of the GNU Lesser General Public License
-- as published by the Free Software Foundation, either version 3 of the
-- License, or (at your option) any later version.
--
-- The Experimental Unstable CPU System is distributed in the hope that it will
-- be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
-- General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with Experimental Unstable CPU System. If not, see
-- http://www.gnu.org/licenses/lgpl.txt.


ARCHITECTURE Mealy OF uctrl IS

  TYPE uCtrl_state IS (
    S_0,
    S_1,
    S_2,
    S_3,
    S_4,
    S_5,
    S_6
    );

  SIGNAL NEXT_STATE : uCtrl_state;
  SIGNAL CURR_STATE : uCtrl_state;

BEGIN  -- ARCHITECTURE Mealy

-- purpose: Next state functionality
-- type   : combinational
-- inputs : IR_IN,ZERO,INT,RST,CURR_STATE
-- outputs: 
  NEXT_ST1 : PROCESS (CURR_STATE, IR_IN, INT, RST)
  BEGIN  -- PROCESS uCTRL

    IF RST = '1' THEN
      NEXT_STATE <= S_0;
    ELSE

      CASE CURR_STATE IS
        WHEN S_0 =>
          NEXT_STATE <= S_1;
        WHEN S_1 =>
          NEXT_STATE <= S_2;
        WHEN S_2 =>
          NEXT_STATE <= S_3;
        WHEN S_3 =>
          NEXT_STATE <= S_4;
        WHEN S_4 =>
          NEXT_STATE <= S_5;
        WHEN S_5 =>
          NEXT_STATE <= S_6;
        WHEN S_6 =>
          NEXT_STATE <= S_6;

      END CASE;
    END IF;
  END PROCESS NEXT_ST1;

  -- State register logic
  STATE_REG1 : PROCESS (CLK, RST)
  BEGIN
    IF rising_edge(CLK) THEN
      IF RST = '1' THEN
        CURR_STATE <= S_0;
      ELSE
        CURR_STATE <= NEXT_STATE;
      END IF;
    END IF;
  END PROCESS STATE_REG1;

  -- Mealy output function logic
  OUT1 : PROCESS (CURR_STATE, RST, IR_IN, INT)
  BEGIN
    -- Make sure that all control signals are initialised
    PC_SRC   <= "011";
    LD_PC    <= '0';
    LD_IR    <= '0';
    LD_DP    <= '0';
    REG_SRC  <= "000";
    RFA_A    <= "0000";
    RFA_B    <= "0000";
    REG_WR   <= '0';
    LD_REG_A <= '0';
    LD_REG_B <= '0';
    LD_MAR   <= '0';
    LD_MDR   <= '0';
    MEM_WR   <= '0';
    ALU_OP   <= "0000";

    CASE CURR_STATE IS
      WHEN S_0 =>
        IF RST = '0' THEN
          PC_SRC <= "100";
          LD_PC  <= '1';
          LD_IR  <= '0';
        END IF;
      WHEN S_1 =>
        PC_SRC <= "001";
        LD_PC  <= '1';
        LD_IR  <= '1';
      WHEN S_2 =>
        LD_IR  <= '0';
      WHEN S_3 =>
        NULL;
      WHEN S_4 =>
        PC_SRC <= "001";
        LD_PC  <= '1';
        LD_IR  <= '1';        
      WHEN S_5 =>
        NULL;
      WHEN S_6 =>
        NULL;
    END CASE;

  END PROCESS OUT1;

END ARCHITECTURE Mealy;
