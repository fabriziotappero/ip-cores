----------------------------------------------------------------------------------
-- Company: 
-- Engineer:        Lazaridis Dimitris
-- 
-- Create Date:    03:17:24 07/23/2012 
-- Design Name: 
-- Module Name:    ALu_control - Behavioral 
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

entity ALu_control is
    
PORT 
(         --clk : IN std_logic;
          instr_15_0 : IN std_logic_vector(15 downto 0);
          ALUOp : IN std_logic_vector(2 downto 0);
			 ALUmux : IN std_logic_vector(1 downto 0);
			 From_i_op : IN std_logic_vector(1 downto 0);
			 From_i_mux : IN std_logic_vector(1 downto 0);
			 sv : out  STD_LOGIC := '0';
			 Mul_out_c : out  STD_LOGIC_VECTOR(1 downto 0);
			 ALUmux_c : OUT std_logic_vector(1 downto 0);
          ALUopcode : OUT std_logic_vector(1 downto 0)
);

  
end ALu_control;

architecture Behavioral of ALu_control is

begin
Alu_Control : PROCESS(instr_15_0, ALUOp,ALUmux,From_i_op,From_i_mux)
CONSTANT ADDr : std_logic_vector(5 downto 0) := "100000";
CONSTANT ADDr_u : std_logic_vector(5 downto 0) := "100001";
CONSTANT SUBr : std_logic_vector(5 downto 0) := "100010";
CONSTANT SUBr_u : std_logic_vector(5 downto 0) := "100011";
CONSTANT ANDr : std_logic_vector(5 downto 0) := "100100"; 
CONSTANT ORr : std_logic_vector(5 downto 0) := "100101"; 
CONSTANT XORr : std_logic_vector(5 downto 0) := "100110"; 
CONSTANT NORr : std_logic_vector(5 downto 0) := "100111";
CONSTANT SLTr : std_logic_vector(5 downto 0) := "101010";
CONSTANT SLTUr : std_logic_vector(5 downto 0) := "101011";
CONSTANT MULTr : std_logic_vector(5 downto 0) := "011000";
CONSTANT Mtlor : std_logic_vector(5 downto 0) := "010011";
CONSTANT Mthir : std_logic_vector(5 downto 0) := "010001";
CONSTANT Mflor : std_logic_vector(5 downto 0) := "010010"; 
CONSTANT Mfhir : std_logic_vector(5 downto 0) := "010000";
CONSTANT Sllr : std_logic_vector(5 downto 0)  := "000000";
CONSTANT SLLVr : std_logic_vector(5 downto 0) := "000100";
CONSTANT SRLr : std_logic_vector(5 downto 0)  := "000010";
CONSTANT SRÁr : std_logic_vector(5 downto 0)  := "000011";
CONSTANT SRLVr : std_logic_vector(5 downto 0) := "000110";  
CONSTANT SRAVr : std_logic_vector(5 downto 0) := "000111";
CONSTANT JRr  : std_logic_vector(5 downto 0)  := "001000"; 
 
BEGIN
  --if FALLING_EDGE(clk) then      
  case ALUOp is
      when "000" => 
		              ALUopcode <= "00";  -- add  I types
						  ALUmux_c <= ALUmux;
      when "001" => ALUopcode <= "01";  -- add unsigned
		              ALUmux_c <= ALUmux;
		when "010" => ALUopcode <= "01";  -- subtract signed
		              ALUmux_c <= ALUmux;
		when "011" => ALUopcode <= "11";  -- subtract unsigned
		              ALUmux_c <= ALUmux;
      when "110" => -- operation depends on function field  r types
                case instr_15_0(5 downto 0) is   -- r types
                when ADDr => ALUopcode <= "00"; -- add signed
					              ALUmux_c <= "10";
					 when ADDr_u => ALUopcode <= "01";  -- add unsigned
					              ALUmux_c <= "10";
                when SUBr => ALUopcode <= "10"; -- subtract
					               ALUmux_c <= "10";
					 when SUBr_u => ALUopcode <= "11"; --subtract unsigned
					                ALUmux_c <= "10";
                when ANDr => ALUopcode <= "00"; -- AND
					                ALUmux_c <= "11";
                when ORr => ALUopcode <= "01"; -- OR
					                ALUmux_c <= "11";
					 when XORr => ALUopcode <= "10"; -- XOR
					                ALUmux_c <= "11";
                when NORr => ALUopcode <=  "11"; -- NOR
                                ALUmux_c <= "11";
                when SLTr => ALUopcode  <=  "10";   -- SLT
                                ALUmux_c <= "01";
                when SLTUr	=> ALUopcode  <=  "11";   -- SLTU
                                ALUmux_c <= "01";									  
                when MULTr => ALUopcode <=  "00"; -- MULT
                                ALUmux_c <= "00";
                             	  Mul_out_c <= "00";
                when Mtlor	=> ALUopcode <=  "00"; -- Mtlo
                                ALUmux_c <= "00";
                                Mul_out_c <= "01";	
                when Mthir	=> ALUopcode <=  "00"; -- Mthi
                                ALUmux_c <= "00";
                                Mul_out_c <= "10";	
                when Mflor	=> ALUopcode <=  "00"; -- Mflo
                                ALUmux_c <= "00";
                            --  Mul_out_c <= "00";
                when Mfhir => ALUopcode <=  "00"; -- Mfhi
                                ALUmux_c <= "00";
                            --  Mul_out_c <= "00";
                when Sllr =>   ALUopcode <= "00";  --sll
                             	 ALUmux_c <= "00";
                               sv <= '0';									 
                when	SRLr =>   ALUopcode <= "10";  --srl
                             	 ALUmux_c <= "00";
										 sv <= '0';
					 when SRÁr =>   ALUopcode <= "11";  --sra
                             	 ALUmux_c <= "00";
										 sv <= '0';
					 when	SLLVr =>  ALUopcode <= "00";  -- sllv
					                ALUmux_c <= "00";
										 sv <= '1';
					 when	SRLVr =>  ALUopcode <= "10";  --srlv
                             	 ALUmux_c <= "00";
										 sv <= '1'; 
					 when SRAVr =>  ALUopcode <= "11";      --srav
                             	 ALUmux_c <= "00";
										 sv <= '1';
                when others => ALUopcode <= "00";
					                ALUmux_c <= "00";
										 Mul_out_c <= "00";
									    sv <= '0';
                end case; 
         when "111" =>   -- I types Aluop from ir
                 	ALUopcode <= From_i_op;
                  ALUmux_c	 <= From_i_mux;	
     when others => ALUopcode <= "00";
  end case;
 -- end if;
END PROCESS;
     
	  
	  
	  
end Behavioral;

