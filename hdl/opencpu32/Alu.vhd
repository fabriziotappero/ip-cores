--! @file
--! @brief Arithmetic logic unit http://en.wikipedia.org/wiki/Arithmetic_logic_unit

--! Use standard library and import the packages (std_logic_1164,std_logic_unsigned,std_logic_arith)
library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--! Use CPU Definitions package
use work.pkgOpenCPU32.all;

--! ALU is a digital circuit that performs arithmetic and logical operations.

--! ALU is a digital circuit that performs arithmetic and logical operations. It's the fundamental part of the CPU
entity Alu is
    generic (n : integer := nBits - 1);						--! Generic value (Used to easily change the size of the Alu on the package)
	 Port ( A : in  STD_LOGIC_VECTOR (n downto 0);			--! Alu Operand 1
           B : in  STD_LOGIC_VECTOR (n downto 0);			--! Alu Operand 2
           S : out  STD_LOGIC_VECTOR (n downto 0);			--! Alu Output
			  flagsOut : out STD_LOGIC_VECTOR(2 downto 0);	--! Flags from current operation
           sel : in  aluOps);										--! Select operation
end Alu;

--! @brief Arithmetic logic unit, refer to this page for more information http://en.wikipedia.org/wiki/Arithmetic_logic_unit
--! @details This circuit will be excited by the control unit to perfom some arithimetic, or logic operation (Depending on the opcode selected)
--! \n You can see some samples on the Internet: http://www.vlsibank.com/sessionspage.asp?titl_id=12222
architecture Behavioral of Alu is

begin
	--! Behavior description of combinational circuit (Can not infer any FF(Flip flop)) of the Alu
	process (A,B,sel) is
	variable mulResult : std_logic_vector(((nBits*2) - 1)downto 0);
	variable FLAG_CARRY, FLAG_ZERO , FLAG_SIGN : STD_LOGIC;
	variable intermediate_S : STD_LOGIC_VECTOR(nBits downto 0);	-- One more bit to detect overflows...
	begin
		case sel is
			when alu_pass =>
				--Pass operation
				intermediate_S := '0' & A;
			
			when alu_passB =>
				--Pass operation
				intermediate_S := '0' & B;
			
			when alu_sum =>
				--Sum operation
				intermediate_S := ('0' & A) + ('0' & B);
			
			when alu_sub =>
				--Subtraction operation
				intermediate_S := ('0' & A) - ('0' & B);
			
			when alu_inc =>
				--Increment operation
				intermediate_S := ('0' & A) + conv_std_logic_vector(1, nBits);
			
			when alu_dec =>
				--Decrement operation
				intermediate_S := ('0' & A) - conv_std_logic_vector(1, nBits);
			
			when alu_mul =>
				--Multiplication operation
				mulResult := A * B;
				intermediate_S := mulResult(nBits downto 0);
				
			when alu_and =>
				--And operation
				intermediate_S := '0' & (A and B);
				
			when alu_or =>
				--Or operation
				intermediate_S := '0' & (A or B);
			
			when alu_xor =>
				--Xor operation
				intermediate_S := '0' & (A xor B);
			
			when alu_not =>
				--Not operation
				intermediate_S := not ('0' & A);
			
			when alu_shfLt =>
				-- Shift left operand A (Get current value bring to left and add a zero to the right)
				intermediate_S := '0' & (A((A'HIGH - 1) downto 0) & '0');	-- "&" is the concatenate operator
			
			when alu_shfRt =>
				-- Shift right operand A (Add a zero to the left and copy the current value to the right)
				intermediate_S := '0' & ('0' & A(A'HIGH downto 1));	-- "&" is the concatenate operator
			
			when alu_roRt =>
				-- Rotate right operand A (Get the lowest bit of A, and concatenate with the others bits, taking out the latest one...)
				intermediate_S := '0' & (A(A'LOW) & A(A'HIGH downto 1)); -- If A is (7 downto 0) A'LOW is 0, and A'HIGH is 7
			
			when alu_roLt =>
				-- Rotate left operand A (Get the the bits from the second highest and concatenate in the end with the highest one...)
				intermediate_S := '0' & (A((A'HIGH - 1) downto 0) & A(A'HIGH)); 
			
			when others =>
				intermediate_S := (others => 'Z');
		end case;
		
		-- Get flags
		if (intermediate_S = 0) then
			FLAG_ZERO := '1';
		else
			FLAG_ZERO := '0';
		end if;
		FLAG_SIGN := intermediate_S(intermediate_S'HIGH - 1);
		FLAG_CARRY := intermediate_S(intermediate_S'HIGH);
		
		-- Pass output
		S <= intermediate_S(S'RANGE); -- S'RANGE == S(31 downto 0);
		flagsOut <= FLAG_SIGN & FLAG_ZERO & FLAG_CARRY;         
	end process;

end Behavioral;

