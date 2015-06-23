library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
entity Synchronizer is
    Port ( R : out  STD_LOGIC;
           G : out  STD_LOGIC;
           B : out  STD_LOGIC;
           HS : out  STD_LOGIC;
           VS : out  STD_LOGIC;
           Clk : in  STD_LOGIC;
			  dataIn : in  STD_LOGIC_VECTOR (2 downto 0);
			  AddressX : out  STD_LOGIC_VECTOR (9 downto 0);
			  AddressY : out  STD_LOGIC_VECTOR (8 downto 0));
end Synchronizer;
architecture Behavioral of Synchronizer is
signal X,nX : STD_LOGIC_VECTOR (10 downto 0) := (others=>'0');
signal Y,nY : STD_LOGIC_VECTOR (20 downto 0) := (others=>'0');
constant TPW : STD_LOGIC_VECTOR (1 downto 0) := "00";
constant TBP : STD_LOGIC_VECTOR (1 downto 0) := "01";
constant TDP : STD_LOGIC_VECTOR (1 downto 0) := "10";
constant TFP : STD_LOGIC_VECTOR (1 downto 0) := "11";
signal XState : STD_LOGIC_VECTOR (1 downto 0) := TPW;
signal YState : STD_LOGIC_VECTOR (1 downto 0) := TPW;
signal EnableDisplay : STD_LOGIC;
signal AddressOfY,nAddressOfY : STD_LOGIC_VECTOR (8 downto 0);
begin
nX <= X+1;
nY <= Y+1;
nAddressOfY <= AddressOfY+1;
HS <= '0' when XState=TPW else '1';
VS <= '0' when YState=TPW else '1';
EnableDisplay <= '1' when XState=TDP and YState=TDP else '0';
R <= dataIn(0) when EnableDisplay='1' else '0';
B <= dataIn(1) when EnableDisplay='1' else '0';
G <= dataIn(2) when EnableDisplay='1' else '0';
AddressX <= X(10 downto 1);
AddressY <= AddressOfY-30;
process (Clk) begin
	if (rising_edge(Clk)) then
		if (XState=TPW and X(7 downto 1)="1100000") then
			X <= (others=>'0');
			XState <= TBP;
		elsif (XState=TBP and X(6 downto 1)="110000") then
			X <= (others=>'0');
			XState <= TDP;
		elsif (XState=TDP and X(10 downto 1)="1010000000") then
			X <= (others=>'0');
			XState <= TFP;
		elsif (XState=TFP and X(5 downto 1)="10000") then
			X <= (others=>'0');
			XState <= TPW;
			AddressOfY <= nAddressOfY;
		else
			X <= nX;
		end if;
		if (YState=TPW and Y(12 downto 1)="11001000000") then
			Y <= (others=>'0');
			YState <= TBP;
		elsif (YState=TBP and Y(16 downto 1)="101101010100000") then
			Y <= (others=>'0');
			YState <= TDP;
		elsif (YState=TDP and Y(20 downto 1)="1011101110000000000") then
			Y <= (others=>'0');
			YState <= TFP;
		elsif (YState=TFP and Y(14 downto 1)="1111101000000") then
			Y <= (others=>'0');
			X <= (others=>'0');
			YState <= TPW;
			XState <= TPW;
			AddressOfY <= (others=>'0');
		else
			Y <= nY;
		end if;
	end if;
end process;
end Behavioral;