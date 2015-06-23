library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.STD_LOGIC_ARITH.ALL;
entity FrameBuffer is
    Port ( inX : in  STD_LOGIC_VECTOR (9 downto 0);
           inY : in  STD_LOGIC_VECTOR (8 downto 0);
           outX : in  STD_LOGIC_VECTOR (9 downto 0);
           outY : in  STD_LOGIC_VECTOR (8 downto 0);
           outColor : out  STD_LOGIC_VECTOR (2 downto 0);
           inColor : in  STD_LOGIC_VECTOR (2 downto 0);
           BufferWrite : in  STD_LOGIC;
           Clk : in  STD_LOGIC);
end FrameBuffer;
architecture Behavioral of FrameBuffer is
type FBuffer is array (0 to 524288/16-1) of std_logic_vector (2 downto 0);
impure function initFB return FBuffer is
variable temp : FBuffer;
variable i : integer;
begin
	for i in 0 to 524288/16-1 loop
		temp(i) := "000";
	end loop;
	return temp;
end initFB;
signal mybuffer : FBuffer := initFB;
signal addressWrite,addressRead : STD_LOGIC_VECTOR (14 downto 0);
signal temp : STD_LOGIC_VECTOR (2 downto 0);
begin
addressWrite <= inX(9 downto 2) & inY(8 downto 2);
addressRead <= outX(9 downto 2) & outY(8 downto 2);
outColor <= temp;
process (clk) begin
	if (rising_edge(Clk)) then
		if (BufferWrite = '1') then
			mybuffer(conv_integer(addressWrite)) <= inColor;
		end if;
		temp <= mybuffer(conv_integer(addressRead));
	end if;
end process;
end Behavioral;