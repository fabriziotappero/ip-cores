library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
entity Pointer is
	 Generic (initX : STD_LOGIC_VECTOR (9 downto 0);
				 initY : STD_LOGIC_VECTOR (8 downto 0));
    Port ( MoveUp : in  STD_LOGIC;
           MoveDown : in  STD_LOGIC;
			  MoveLeft : in  STD_LOGIC;
			  MoveRight : in  STD_LOGIC;
           Move : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
           Here : out  STD_LOGIC;
			  X : out  STD_LOGIC_VECTOR (9 downto 0);
			  Y : out  STD_LOGIC_VECTOR (8 downto 0);
           syncX : in  STD_LOGIC_VECTOR (9 downto 0);
           syncY : in  STD_LOGIC_VECTOR (8 downto 0));
end Pointer;
architecture Behavioral of Pointer is
signal rX : STD_LOGIC_VECTOR (9 downto 0) := initX;
signal rY : STD_LOGIC_VECTOR (8 downto 0) := initY;
begin
Here <= '1' when syncX(9 downto 3)=rX(9 downto 3) and
					  syncY(8 downto 3)=rY(8 downto 3) else '0';
X <= rX;
Y <= rY;
process (Clk) begin
	if (rising_edge(Clk)) then
		if (Move = '1') then
			if (MoveLeft = '1' and MoveRight = '0') then
				if not (rX = "0000000000") then
					rX <= rX - 1;
				end if;
			elsif (MoveLeft = '0' and MoveRight = '1') then
				if not (rX = "1001111111") then
					rX <= rX + 1;
				end if;
			end if;
			if (MoveUp = '1' and MoveDown = '0') then
				if not (rY = "000000000") then
					rY <= rY - 1;
				end if;
			elsif (MoveUp = '0' and MoveDown = '1') then
				if not (rY = "111011111") then
					rY <= rY + 1;
				end if;
			end if;
		end if;
	end if;
end process;
end Behavioral;