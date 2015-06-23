--! @file
--! @brief Controller-Sequencer (CU)
--! @details The output is 12-bit form a word controlling the rest of the processor. 	\n
--! It is called the contol bus.																			\n
--! CON = Cp Ep nLm nCE nLi nEi nLa Ea Su Eu nLb nLo												\n
--! The control word determines how the registers will react to the next clock edge.	\n
--! P.S. n for activ low signal

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY CU IS
   PORT( 
      ADD : IN     std_logic;									--! Add instruction 
      CLK : IN     std_logic;									--! Positive edge trigger clock
      CLR : IN     std_logic;									--! Active high asynchronous clear
      LDA : IN     std_logic;									--! Load Accumulator instruction
      O   : IN     std_logic;									--! Out instruction
      SUB : IN     std_logic;									--! Sub instruction
      CON : OUT    std_logic_vector (11 DOWNTO 0)		--! 12-bit control word forming control bus 
																		--!     ~ ~	 ~ ~ ~ ~	     ~ ~
																		--! CpEpLmCE LiEiLaEa SuEuLbLo
																		
   );
END CU ;

ARCHITECTURE fsm OF CU IS

   TYPE STATE_TYPE IS (s0,s1,s2,s3,s4,s5,s6,s8,s9,s10,s11,s12);

   SIGNAL current_state : STATE_TYPE ;
   SIGNAL next_state : STATE_TYPE ;

BEGIN

   clocked : PROCESS(CLK,CLR)

   BEGIN
      IF (CLR = '1') THEN
         current_state <= s0;
         -- Reset Values
      ELSIF (falling_edge(CLK)) THEN
         current_state <= next_state;
         -- Default Assignment To Internals

      END IF;

   END PROCESS clocked;

   nextstate : PROCESS (ADD,CLR,LDA,O,SUB,current_state)

   BEGIN
      -- Default Assignment
      CON <= "001111100011";
      -- Default Assignment To Internals

      -- Combined Actions
      CASE current_state IS
      WHEN s0 => -- Address State
         CON <= "010111100011";
         IF (ADD = '1' OR LDA = '1' OR SUB = '1' OR O = '1') THEN
            next_state <= s1;
         ELSIF (CLR = '1') THEN
            next_state <= s0;
         ELSE
            next_state <= s0;
         END IF;
      WHEN s1 => -- Increment State
         CON<= "101111100011";
         IF (ADD = '1' OR LDA = '1' OR SUB = '1' OR O = '1') THEN
            next_state <= s2;
         ELSE
            next_state <= s1;
         END IF;
      WHEN s2 => -- Memory State
         CON <= "001001100011";
         IF (( LDA = '1' OR ADD = '1' OR SUB = '1' ) AND O = '0') THEN
            next_state <= s3;
         ELSIF (O = '1' AND ADD = '0' AND LDA = '0' AND SUB = '0') THEN
            next_state <= s4;
         ELSE
            next_state <= s2;
         END IF;
      WHEN s3 => -- LDA Routine T4 CpEpLmCE LiEiLax xxxx 
         CON <= "000110100011";
         IF (LDA = '1' AND ADD = '0' AND O = '0' AND SUB = '0') THEN
            next_state <= s5;
         ELSIF ((ADD = '1' OR SUB = '1' ) AND ( LDA = '0' AND O = '0' )) THEN
            next_state <= s6;
         ELSIF (O = '1') THEN
            next_state <= s4;
         ELSE
            next_state <= s3;
         END IF;
      WHEN s4 => -- LDA Routine T6 CpEpLmCE LiEiLax xxxx 
         CON <= "001111110010";
         IF (ADD = '1' AND O = '0' AND SUB = '0' AND LDA = '0') THEN
            next_state <= s3;
         ELSIF (O = '1' AND ADD = '0' AND LDA = '0' AND SUB = '0') THEN
            next_state <= s8;
         ELSE
            next_state <= s3;
         END IF;
      WHEN s5 => -- LDA Routine T5 CpEpLmCE LiEiLax xxxx 
         CON <= "001011000011";
         IF (LDA = '1' AND ADD = '0' AND O = '0' AND SUB = '0') THEN
            next_state <= s12;
         ELSE
            next_state <= s5;
         END IF;
      WHEN s6 => 
         CON <= "001011100001";
         IF (ADD = '1' AND LDA = '0' AND O = '0' AND SUB = '0') THEN
            next_state <= s11;
         ELSIF (SUB = '1' AND ADD = '0' AND LDA = '0' AND O = '0') THEN
            next_state <= s10;
         ELSE
            next_state <= s6;
         END IF;
      WHEN s8 =>
         CON <= "001111100011";
         IF (ADD = '1' AND O = '0' AND SUB = '0' AND LDA = '0') THEN
            next_state <= s3;
         ELSIF (O = '1' AND ADD = '0' AND LDA = '0' AND SUB = '0') THEN
            next_state <= s9;
         ELSE
            next_state <= s8;
         END IF;
      WHEN s9 =>
         CON <= "001111100011";
            next_state <= s0;
      WHEN s10 =>
         CON <= "001111001111";
            next_state <= s0;
      WHEN s11 =>
         CON <= "001111000111";
            next_state <= s0;
      WHEN s12 =>
         CON <= "001111100011";
            next_state <= s0;
      WHEN OTHERS =>
         next_state <= s0;
      END CASE;

   END PROCESS nextstate;

END fsm;
