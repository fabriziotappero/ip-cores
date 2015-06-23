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
    S_RST,
    S_DECODE,
    S_FETCH,
    S_UOP_P1,
    S_UOP_P2,
    S_BOP_P1,
    S_BOP_P2,
    S_LD_RV,
    S_LD_RV_2,
    S_LD_RR,
    S_LD_RR_2,
    S_LD_RM,
    S_LD_RM_2,
    S_LD_MR,
    S_LD_MR_2,
    S_GO_ADR,
    S_GO_ADR_2,
    S_GO_REG,
    S_GO_REG_2,
    S_JZ_P0,
    S_JZ_P1,
    S_JZ_P2,
    S_JNZ_P0,
    S_JNZ_P1,
    S_JNZ_P2,
    S_HALT,
    S_RETI,
    S_RETI_2,
    S_ILL
    );

  SIGNAL NEXT_STATE : uCtrl_state;
  SIGNAL CURR_STATE : uCtrl_state;

  SIGNAL LD_INSTR : STD_LOGIC;
  SIGNAL DECODING : STD_LOGIC;

  SIGNAL OPERATION  : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL REG_ADDR_A : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL REG_ADDR_B : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN  -- ARCHITECTURE Mealy

-- purpose: Next state functionality
-- type   : combinational
-- inputs : IR_IN,ZERO,INT,RST,CURR_STATE
-- outputs: 
  NEXT_ST1 : PROCESS (CURR_STATE, IR_IN, INT, RST, ZERO)
    VARIABLE I_ADDR : uCtrl_state;
  BEGIN  -- PROCESS uCTRL

    IF RST = '1' THEN
      NEXT_STATE <= S_RST;
    ELSE

      CASE IR_IN(15 DOWNTO 12) IS
        WHEN "0000" => I_ADDR := S_HALT;
        WHEN "0001" => I_ADDR := S_GO_ADR;
        WHEN "0010" => I_ADDR := S_GO_REG;
        WHEN "0011" => I_ADDR := S_LD_RV;
        WHEN "0100" => I_ADDR := S_LD_RR;
        WHEN "0101" => I_ADDR := S_LD_RM;
        WHEN "0110" => I_ADDR := S_LD_MR;
        WHEN "0111" => I_ADDR := S_BOP_P1;
        WHEN "1000" => I_ADDR := S_UOP_P1;
        WHEN "1001" => I_ADDR := S_JZ_P0;
        WHEN "1010" => I_ADDR := S_JNZ_P0;
        WHEN "1011" => I_ADDR := S_RETI;
        WHEN "1100" => I_ADDR := S_ILL;
        WHEN "1101" => I_ADDR := S_ILL;
        WHEN "1110" => I_ADDR := S_ILL;
        WHEN "1111" => I_ADDR := S_ILL;
        WHEN OTHERS => I_ADDR := S_ILL;
      END CASE;

      CASE CURR_STATE IS
        WHEN S_RST =>
          NEXT_STATE <= S_FETCH;
        WHEN S_FETCH =>
          NEXT_STATE <= S_DECODE;
        WHEN S_DECODE =>
          NEXT_STATE <= I_ADDR;
        WHEN S_UOP_P1 =>
          NEXT_STATE <= S_UOP_P2;
        WHEN S_UOP_P2 =>
          NEXT_STATE <= I_ADDR;
        WHEN S_BOP_P1 =>
          NEXT_STATE <= S_BOP_P2;
        WHEN S_BOP_P2 =>
          NEXT_STATE <= I_ADDR;
        WHEN S_LD_RV =>
          NEXT_STATE <= S_LD_RV_2;
        WHEN S_LD_RV_2 =>
          NEXT_STATE <= I_ADDR;
        WHEN S_LD_RR =>
          NEXT_STATE <= S_LD_RR_2;
        WHEN S_LD_RR_2 =>
          NEXT_STATE <= I_ADDR;
        WHEN S_LD_RM =>
          NEXT_STATE <= S_LD_RM_2;
        WHEN S_LD_RM_2 =>
          NEXT_STATE <= I_ADDR;
        WHEN S_LD_MR =>
          NEXT_STATE <= S_LD_MR_2;
        WHEN S_LD_MR_2 =>
          NEXT_STATE <= I_ADDR;
        WHEN S_GO_ADR =>
          NEXT_STATE <= S_GO_ADR_2;
        WHEN S_GO_ADR_2 =>
          NEXT_STATE <= I_ADDR;
        WHEN S_GO_REG =>
          NEXT_STATE <= S_GO_REG_2;

        WHEN S_JZ_P0 =>
          NEXT_STATE <= S_JZ_P1;
        WHEN S_JZ_P1 =>
          IF ZERO = '1' THEN
            NEXT_STATE <= S_FETCH;
          ELSE
            NEXT_STATE <= S_JZ_P2;
          END IF;
        WHEN S_JZ_P2 =>
          NEXT_STATE <= I_ADDR;

        WHEN S_JNZ_P0 =>
          NEXT_STATE <= S_JNZ_P1;
        WHEN S_JNZ_P1 =>
          IF ZERO = '1' THEN
            NEXT_STATE <= S_FETCH;
          ELSE
            NEXT_STATE <= S_JNZ_P2;
          END IF;
        WHEN S_JNZ_P2 =>
          NEXT_STATE <= I_ADDR;

        WHEN S_HALT =>
          NEXT_STATE <= S_HALT;
        WHEN S_RETI =>
          NEXT_STATE <= S_RETI_2;
        WHEN S_RETI_2 =>
          NEXT_STATE <= S_DECODE;
        WHEN S_ILL =>
          NEXT_STATE <= S_ILL;
        WHEN OTHERS =>
          NEXT_STATE <= S_DECODE;
      END CASE;
    END IF;
  END PROCESS NEXT_ST1;

  -- State register logic
  STATE_REG1 : PROCESS (CLK, RST)
  BEGIN
    IF rising_edge(CLK) THEN
      IF RST = '1' THEN
        CURR_STATE <= S_RST;
      ELSE
        CURR_STATE <= NEXT_STATE;
      END IF;
    END IF;
  END PROCESS STATE_REG1;

  -- Instruction values
  INSTR_REG1 : PROCESS (CLK, RST)
  BEGIN
    IF rising_edge(CLK) THEN
      IF RST = '1' THEN
        OPERATION  <= "0000";
        REG_ADDR_A <= "0000";
        REG_ADDR_B <= "0000";
      ELSE
        IF LD_INSTR = '1' THEN
          OPERATION  <= IR_IN(11 DOWNTO 8);
          REG_ADDR_A <= IR_IN(7 DOWNTO 4);
          REG_ADDR_B <= IR_IN(3 DOWNTO 0);
        END IF;
      END IF;
    END IF;
  END PROCESS;

  ALU_OP <= OPERATION;
  RFA_A  <= REG_ADDR_A;
  RFA_B  <= REG_ADDR_B;

  -- Mealy output function logic
  OUT1 : PROCESS (CURR_STATE, RST, INT, IR_IN, DECODING, ZERO)
  BEGIN

    -- Make sure that all control signals are initialised
    PC_SRC   <= "011";                  -- Default to PC output
    LD_PC    <= '0';
    LD_IR    <= '0';
    LD_DP    <= '0';
    REG_SRC  <= "101";
    REG_WR   <= '0';
    LD_REG_A <= '0';
    LD_REG_B <= '0';
    LD_MAR   <= '0';
    LD_MDR   <= '0';
    MEM_WR   <= '0';
    LD_INSTR <= '0';
    DECODING <= '0';

    CASE CURR_STATE IS
      WHEN S_RST =>
        IF RST = '0' THEN
          PC_SRC <= "100";
          LD_PC  <= '1';
          LD_IR  <= '0';
        END IF;

      WHEN S_FETCH =>
        PC_SRC   <= "001";
        LD_PC    <= '1';
        LD_IR    <= '1';
        LD_DP    <= '1';
        LD_INSTR <= '1';
        DECODING <= '0';

      WHEN S_DECODE =>
        PC_SRC   <= "001";
        LD_PC    <= '1';
        LD_IR    <= '1';
        LD_DP    <= '1';
        LD_INSTR <= '1';
        DECODING <= '1';

      WHEN S_UOP_P1 =>
        LD_REG_A <= '1';

      WHEN S_UOP_P2 =>
        REG_SRC <= "000";
        REG_WR  <= '1';

        PC_SRC   <= "001";
        LD_PC    <= '1';
        LD_IR    <= '1';
        LD_DP    <= '1';
        LD_INSTR <= '1';
        DECODING <= '1';

      WHEN S_BOP_P1 =>
        LD_REG_A <= '1';
        LD_REG_B <= '1';

      WHEN S_BOP_P2 =>
        REG_SRC <= "000";
        REG_WR  <= '1';

        PC_SRC   <= "001";
        LD_PC    <= '1';
        LD_IR    <= '1';
        LD_DP    <= '1';
        LD_INSTR <= '1';
        DECODING <= '1';

      WHEN S_LD_RR =>
        LD_REG_B <= '1';

      WHEN S_LD_RR_2 =>
        REG_SRC <= "000";
        REG_WR  <= '1';

        PC_SRC   <= "001";
        LD_PC    <= '1';
        LD_IR    <= '1';
        LD_DP    <= '1';
        LD_INSTR <= '1';
        DECODING <= '1';

      WHEN S_LD_RV =>
        PC_SRC <= "001";
        LD_PC  <= '1';
        LD_IR  <= '1';
        LD_DP  <= '0';

      WHEN S_LD_RV_2 =>
        REG_SRC <= "010";
        REG_WR  <= '1';

        PC_SRC   <= "001";
        LD_PC    <= '1';
        LD_IR    <= '1';
        LD_DP    <= '1';
        LD_INSTR <= '1';
        DECODING <= '1';

      -- Write data from reg A to address reg B
      WHEN S_LD_MR =>
        LD_MAR <= '1';
        LD_MDR <= '1';

      WHEN S_LD_MR_2 =>
        MEM_WR <= '1';

        PC_SRC   <= "001";
        LD_PC    <= '1';
        LD_IR    <= '1';
        LD_DP    <= '1';
        LD_INSTR <= '1';
        DECODING <= '1';

      WHEN S_LD_RM =>
        LD_MAR <= '1';

      WHEN S_LD_RM_2 =>
        REG_SRC <= "001";
        REG_WR  <= '1';

        PC_SRC   <= "001";
        LD_PC    <= '1';
        LD_IR    <= '1';
        LD_DP    <= '1';
        LD_INSTR <= '1';
        DECODING <= '1';

      WHEN S_JZ_P0 =>
      WHEN S_JNZ_P0 =>
        NULL;

      WHEN S_JZ_P1 =>
        IF ZERO = '1' THEN
          PC_SRC <= "010";
        ELSE
          PC_SRC <= "001";
        END IF;

        LD_PC <= '1';
        LD_IR <= '1';
        LD_DP <= '0';

      WHEN S_JZ_P2 =>
        PC_SRC   <= "001";
        LD_PC    <= '1';
        LD_IR    <= '1';
        LD_DP    <= '1';
        LD_INSTR <= '1';
        DECODING <= '1';

      WHEN S_JNZ_P1 =>
        IF ZERO = '0' THEN
          PC_SRC <= "010";
        ELSE
          PC_SRC <= "001";
        END IF;

        LD_PC <= '1';
        LD_IR <= '1';
        LD_DP <= '0';

      WHEN S_JNZ_P2 =>
        PC_SRC   <= "001";
        LD_PC    <= '1';
        LD_IR    <= '1';
        LD_DP    <= '1';
        LD_INSTR <= '1';
        DECODING <= '1';
      WHEN S_HALT =>
        NULL;

      WHEN OTHERS =>
        PC_SRC <= "001";
        LD_PC  <= '1';
        LD_IR  <= '1';
        LD_DP  <= '1';

    END CASE;

    CASE IR_IN(15 DOWNTO 12) IS
      WHEN "0001" =>
        IF DECODING = '1' THEN
          PC_SRC <= "111";
          LD_PC  <= '1';
        END IF;

      WHEN "0011" =>
      WHEN "1001" =>
      WHEN "1010" =>
        IF DECODING = '1' THEN
          LD_IR <= '0';
        END IF;

      WHEN OTHERS =>
        NULL;
    END CASE;

  END PROCESS OUT1;

END ARCHITECTURE Mealy;
