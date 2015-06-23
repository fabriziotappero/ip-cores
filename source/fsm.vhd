----------------------------------------------------------------------------------
-- Company: 
-- Engineer:     Lazaridis Dimitris
-- 
-- Create Date:    00:18:09 06/13/2012 
-- Design Name: 
-- Module Name:    fsm - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fsm is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
			  RegDst, RegWrite, ALUSrcA, MemRead, MemWrite, Mult_en, IorD, IRWrite, PCWrite,
           EqNq,ALUsw : out std_logic;
           instr_31_26,immed_addr : in std_logic_vector(5 downto 0);
           ALUOp, ALUSrcB, PCSource,ALUmux : OUT std_logic_vector(1 downto 0);
			  ALUop_sw,RFmux : out std_logic_vector(2 downto 0)
			);
end fsm;

architecture Behavioral of fsm is
     TYPE state_type IS ( InstDec, MemAddComp, MemAccL, MemReadCompl, MemAccS, MultWrite, Exec, MultComlFlo, MultComlFhi,
      RCompl, BranchCompare, BranchCompl, BranchComplNe, I_typeExe, I_typeComplt, JrCompl, JalrCompl, ErrState, InstFetch );
     SIGNAL state, next_state : state_type;
begin
     
	  
-- State process
state_reg : PROCESS(clk, rst)
            BEGIN
            IF rst = '0' THEN
				  	state <= InstFetch;
				ELSIF RISING_EDGE(clk) THEN
            state <= next_state;
            END IF;
            END PROCESS;
	  
	  
	  -------------------------------------------------------------------------------
-- Logic Process
logic_process : PROCESS(state,instr_31_26,immed_addr)  

-- ALUOp ALUSrcB PCSource ALUmux
--4x2bit
     VARIABLE control_signals : std_logic_vector(21 downto 0);
	  VARIABLE ALUop_3_sw : std_logic_vector(2 downto 0);
-- Defintion of Constants 
     Constant LOADWORD : std_logic_vector(5 Downto 0) := "100011";
	  Constant LOADBYTE : std_logic_vector(5 Downto 0) := "010100";
     Constant STOREWORD : std_logic_vector(5 Downto 0) := "101011";
     Constant RTYPE : std_logic_vector(5 Downto 0) := "000000";
     Constant BEQ : std_logic_vector(5 Downto 0) := "000100";
	  Constant BNE : std_logic_vector(5 Downto 0) := "000101";
	  Constant ADDI: std_logic_vector(5 Downto 0) := "001000";
	  Constant ADDIU : std_logic_vector(5 Downto 0) := "001001"; 
	  Constant ANDI : std_logic_vector(5 Downto 0) := "001100";
	  Constant ORI : std_logic_vector(5 Downto 0) := "001101";
	  Constant XORI : std_logic_vector(5 Downto 0) := "001110";
	  Constant LUI : std_logic_vector(5 Downto 0) := "001111";
	  Constant SLTI : std_logic_vector(5 Downto 0) := "001010";
	  Constant SLTIU : std_logic_vector(5 Downto 0) := "001011";
     Constant JR : std_logic_vector(5 Downto 0) := "001000";
	  Constant JALR : std_logic_vector(5 Downto 0) := "001001";  
	  BEGIN
	       CASE state IS
-- Instruction Fetch
          WHEN InstFetch =>
          control_signals := "0000000011000100000000";  --checked  lw
			 next_state <= InstDec;         
-- Instruction Decode and Register Fetch
          WHEN InstDec =>
          control_signals := "0000000010000000000000";   --checked  lw "000000000000000001100";
               IF instr_31_26 = LOADWORD OR instr_31_26 = LOADBYTE OR instr_31_26 = STOREWORD THEN
               next_state <= MemAddComp;
               ELSIF immed_addr = JR AND instr_31_26 = RTYPE THEN
					next_state <= JrCompl;
					ELSIF immed_addr = JALR AND instr_31_26 = RTYPE THEN
					next_state <= JalrCompl;
					ELSIF (instr_31_26 = RTYPE and immed_addr = "010001") OR     --Mthi
			      (instr_31_26 = RTYPE and immed_addr = "010011") OR           --Mtlo 
				   (instr_31_26 = RTYPE and immed_addr = "011000") THEN         --Mult   
              	next_state <= MultWrite;				
					ELSIF instr_31_26 = RTYPE THEN
               next_state <= Exec;
               ELSIF instr_31_26 = BEQ OR instr_31_26 = BNE THEN
               next_state <= BranchCompare;
					ELSIF instr_31_26 = ADDI OR instr_31_26 = ADDIU OR instr_31_26 = ANDI 
					OR instr_31_26 = ORI OR instr_31_26 = XORI OR instr_31_26 = LUI OR instr_31_26 = SLTI 
					OR instr_31_26 = SLTIU  THEN
					next_state <= I_typeExe;
					ELSE
               next_state <= ErrState;
               END IF;
-- Memory Address Computation
          WHEN MemAddComp =>
          control_signals := "0000100010000000001000"; --checked lw  have to add alusrca
               if instr_31_26 = LOADWORD OR instr_31_26 = LOADBYTE THEN
               next_state <= MemAccL;
               ELSIF instr_31_26 = STOREWORD THEN
               next_state <= MemAccS;
               ELSE
               next_state <= ErrState;
               END IF;

-- Memory Access Load Word
          WHEN MemAccL =>
          control_signals := "0000100011001000001000";  --checked lw    iii
          next_state <= MemReadCompl;
-- Memory Read Completion
          WHEN MemReadCompl =>
          control_signals := "0110000110000010001000";  --checked lw "000000110010000001000"
          next_state <= InstFetch;
-- Memory Access Store Word
          WHEN MemAccS =>
          control_signals := "0000000011101010001000";    --sw
          next_state <= InstFetch;
-- Multi exe write			 
			 WHEN MultWrite =>
			 control_signals := "1000100010010010100000";
			 next_state <= InstFetch;
			 
			 
-- Execution
          WHEN Exec =>
			 control_signals := "1000100010000000100000";
--Mult Completion	
			 IF (immed_addr = "010010" and instr_31_26 = RTYPE) THEN --Mflo 
			 next_state <= MultComlFlo;
--Mflo 
			 ELSIF (immed_addr = "010000" and instr_31_26 = RTYPE) THEN --Mfhi
			 next_state <= MultComlFhi;
--Mfhi 			 
			 ELSIF (instr_31_26 = RTYPE) THEN
			 next_state <= RCompl;
			 ELSE
			 next_state <= ErrState;
			 END IF;
--Mflo Completion			 
			 WHEN MultComlFlo =>
			 control_signals := "1010001110000010100000";  --Mult_Mflo
			 next_state <= InstFetch;
--Mfhi Completion			 
			 WHEN MultComlFhi =>
			 control_signals := "1000001110000010100000";  --Mult_Mfhi
			 next_state <= InstFetch;
-- R-type Completion
          WHEN RCompl =>
          control_signals := "1100001110000010100000";  --add
          next_state <= InstFetch;
-- Branch Compare			 
			 WHEN BranchCompare =>
			 control_signals := "0000100010000000110001";
			 IF instr_31_26 = BEQ THEN
			 next_state <= BranchCompl;
			 ELSIF instr_31_26 = BNE THEN
			 next_state <= BranchComplNe;
			 ELSE
			 next_state <= ErrState;
			 END IF;
-- Branch Completion
          WHEN BranchCompl =>
          control_signals := "0000100010000010110001";   --beq
          next_state <= InstFetch;
-- Branch no equal Completion			 
			 WHEN BranchComplNe =>
			 control_signals := "0000100010000011110001";   --bne
			 next_state <= InstFetch;
--I types execution		 
			 WHEN I_typeExe =>
			 control_signals := "1000100010000000111000";   -- I type  
			 next_state <= I_typeComplt;
--I types Completion			 
			 WHEN I_typeComplt =>
			 control_signals := "0100100110000010001000"; 
			 next_state <= InstFetch;
-- Jump Completion
          WHEN JrCompl =>
          control_signals := "0000000000000010000010";
          next_state <= InstFetch;
			 WHEN JalrCompl =>
          control_signals := "0001001100000010000010";
          next_state <= InstFetch; 
			 --WHEN ErrState =>
			 --control_signals := "0000000000000000000000";  -- i have to built soft reset
			 --next_state <= InstFetch;
          WHEN OTHERS =>
          control_signals := (others => 'X');
          next_state <= ErrState;
       END case;
		 
	 
ALUsw <= control_signals(21);             -- for r types
RFmux <= control_signals(20 downto 18); 
ALUmux <= control_signals(17 downto 16);	 
RegDst <= control_signals(15);
RegWrite <= control_signals(14);
ALUSrcA <= control_signals(13);
MemRead <= control_signals(12);
MemWrite <= control_signals(11);
Mult_en <= control_signals(10);
IorD <= control_signals(9);
IRWrite <= control_signals(8);
PCWrite <= control_signals(7);
EqNq <= control_signals(6);
ALUOp <= control_signals(5 downto 4);
ALUSrcB <= control_signals(3 downto 2);
PCSource <= control_signals(1 downto 0);

ALUop_3_sw(1 downto 0) := control_signals(5 downto 4); 
ALUop_3_sw(2 downto 2) := control_signals(21 downto 21);
ALUop_sw <= ALUop_3_sw;

END process;


end Behavioral;

