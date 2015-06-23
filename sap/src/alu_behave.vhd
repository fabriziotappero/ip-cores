--! @file
--! @brief Arithmetic Logic Unit (ALU)
--! @details It just perform addition and subtraction operation.	\n
--! It is asynchronous block.													\n

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY ALU IS
port (A	: in  std_logic_vector(7 downto 0);		--! ALU A input 8-bit from AC
		B 	: in  std_logic_vector(7 downto 0);		--! ALU B input 8-bit from B-register
      S 	: out std_logic_vector(7 downto 0);		--! ALU output 8-bit to W-bus
		Su	: in  std_logic;								--! Low Add, High Sub
	   Eu	: in  std_logic);								--! Active low enable ALU (tri-state)
END ALU ;

ARCHITECTURE behave OF ALU IS
signal sum,sub : std_logic_vector(7 downto 0);
BEGIN
sum <= (unsigned(A) + unsigned(B));
sub <= (unsigned(A) - unsigned(B));
process (a,b,su,eu)
begin
	if Eu = '0' then
		S <= (s'range => 'Z');
	else
		if Su = '0' then
			S <= sum;
		else
			S <= sub;
		end if;
	end if;
end process;
END behave;

