--! @file
--! @brief Instruction Register Decoder (IRDec)
--! @details It is equivelent to a ring counter driving the CU.

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY IRDec IS
 port (q_c     : IN     std_logic_vector (3 DOWNTO 0);
       LDA     : OUT    std_logic;
       ADD     : OUT    std_logic;
       SUB     : OUT    std_logic;
       OUTPUT  : OUT    std_logic;
	  -- jmp     : OUT    std_logic;
       HLT     : OUT    std_logic);
END IRDec ;

ARCHITECTURE behave OF IRDec IS
signal instruction : std_logic_vector(5 downto 0);
BEGIN
process (q_c)
begin
	if  q_c = "0000" then 
		instruction <=  "000001" ;
	elsif  q_c = "0001" then
		instruction <= "000010"   ;
	elsif q_c = "0010" then 
		instruction <= "000100"   ;
	elsif q_c = "1110" then 
		instruction <= "001000"   ;
	elsif q_c = "1111" then
		instruction <= "100000";
	end if;
end process;

LDA    <= instruction(0);
ADD    <= instruction(1);
SUB    <= instruction(2);
OUTPUT <= instruction(3);
--jmp    <= instruction(4);
HLT    <= instruction(5);
END behave;

