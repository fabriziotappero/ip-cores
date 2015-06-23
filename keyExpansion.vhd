library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity keyexpansion is
    port ( reset : in  std_logic;
           clock : in  std_logic;
           loadkey : in  std_logic;
           key : in  std_logic_vector (31 downto 0);
           subkeyenable : out  std_logic;
           subkeyaddress : out  std_logic_vector (3 downto 0);
           subkey : out  std_logic_vector (127 downto 0);
           keyexpansionready : inout  std_logic;
           numberofrounds : out  std_logic_vector (3 downto 0));
end keyexpansion;

architecture Behavioral of keyExpansion is
   signal temp, rotW0, subIn, subRotW0 : std_logic_vector(31 downto 0);
   type wT is array(0 to 7) of std_logic_vector(31 downto 0);
   signal w : wT;
   type RconT is array(0 to 10) of std_logic_vector(7 downto 0);
   constant Rcon : RconT := (x"01",x"02",x"04",x"08",x"10",x"20",x"40",x"80",x"1b",x"36",x"ee");
	signal iModNk, Nk : integer range 0 to 7;
	signal RconCnt : integer range 0 to 10;
	signal roundCounter : std_Logic_vector(5 downto 0);
begin

keyExpansionFSM: process(clock)
begin
   if rising_edge(clock) then
      if reset = '1' then
         Nk <= 0;
         iModNk <= 0;
         RoundCounter <= "000000";
         RconCnt <= 0;
      elsif loadKey = '1' then
         Nk <= Nk + 1;
      elsif keyExpansionReady = '0' then
         roundCounter <= roundCounter + '1';
         if iModNk = Nk then
            iModNk <= 0;
            if RconCnt < 10 then
					RconCnt <= RconCnt + 1;
				end if;
         else
            iModNk <= iModNk + 1;
         end if;
      end if;
   end if;
end process;
--begin keyExpansionFSM asynchron circuitry
keyExpansionReady <= '1' when Nk = 3 and roundCounter = "101000" else --44=32+8+4
                     '1' when Nk = 5 and roundCounter = "110000" else --52=32+16+4
                     '1' when Nk = 7 and roundCounter = "111000" else --60=32+16+8+4
                     '0';
numberOfRounds <= x"a" when Nk = 3 else
                  x"c" when Nk = 5 else
                  x"e" when Nk = 7 else x"0";
--end keyExpansionFSM asynchron circuitry

keyExpansionPipe: process(clock)
begin
   if rising_edge(clock) then
      if loadKey = '1' then
         w <= key & w(0 to 6);
      elsif keyExpansionReady = '0' then
			case Nk is 
				when 3 =>
					w(0 to 3) <= w(1 to 3) & (w(0) xor temp);
 				when 5 =>
					w(0 to 5) <= w(1 to 5) & (w(0) xor temp);
				when others =>
					w(0 to 7) <= w(1 to 7) & (w(0) xor temp);
				end case;
		end if;
   end if;
end process;
--begin keyExpansionPipe asynchron circuitry
rotW0 <= w(Nk)(23 downto 0) & w(Nk)(31 downto 24);
subIn <= rotW0 when iModNk = 0 else
         w(Nk) when Nk = 7 and iModNk = 4 else x"00000000";
subBytesFor: for i in 0 to 3 generate
   type subT is array(0 to 255) of std_logic_vector(7 downto 0);
   constant sub : subT :=
     (x"63", x"7c", x"77", x"7b", x"f2", x"6b", x"6f", x"c5", x"30", x"01", x"67", x"2b", x"fe", x"d7", x"ab", x"76",
      x"ca", x"82", x"c9", x"7d", x"fa", x"59", x"47", x"f0", x"ad", x"d4", x"a2", x"af", x"9c", x"a4", x"72", x"c0",
      x"b7", x"fd", x"93", x"26", x"36", x"3f", x"f7", x"cc", x"34", x"a5", x"e5", x"f1", x"71", x"d8", x"31", x"15",
      x"04", x"c7", x"23", x"c3", x"18", x"96", x"05", x"9a", x"07", x"12", x"80", x"e2", x"eb", x"27", x"b2", x"75",
      x"09", x"83", x"2c", x"1a", x"1b", x"6e", x"5a", x"a0", x"52", x"3b", x"d6", x"b3", x"29", x"e3", x"2f", x"84",
      x"53", x"d1", x"00", x"ed", x"20", x"fc", x"b1", x"5b", x"6a", x"cb", x"be", x"39", x"4a", x"4c", x"58", x"cf",
      x"d0", x"ef", x"aa", x"fb", x"43", x"4d", x"33", x"85", x"45", x"f9", x"02", x"7f", x"50", x"3c", x"9f", x"a8",
      x"51", x"a3", x"40", x"8f", x"92", x"9d", x"38", x"f5", x"bc", x"b6", x"da", x"21", x"10", x"ff", x"f3", x"d2",
      x"cd", x"0c", x"13", x"ec", x"5f", x"97", x"44", x"17", x"c4", x"a7", x"7e", x"3d", x"64", x"5d", x"19", x"73",
      x"60", x"81", x"4f", x"dc", x"22", x"2a", x"90", x"88", x"46", x"ee", x"b8", x"14", x"de", x"5e", x"0b", x"db",
      x"e0", x"32", x"3a", x"0a", x"49", x"06", x"24", x"5c", x"c2", x"d3", x"ac", x"62", x"91", x"95", x"e4", x"79",
      x"e7", x"c8", x"37", x"6d", x"8d", x"d5", x"4e", x"a9", x"6c", x"56", x"f4", x"ea", x"65", x"7a", x"ae", x"08",
      x"ba", x"78", x"25", x"2e", x"1c", x"a6", x"b4", x"c6", x"e8", x"dd", x"74", x"1f", x"4b", x"bd", x"8b", x"8a",
      x"70", x"3e", x"b5", x"66", x"48", x"03", x"f6", x"0e", x"61", x"35", x"57", x"b9", x"86", x"c1", x"1d", x"9e",
      x"e1", x"f8", x"98", x"11", x"69", x"d9", x"8e", x"94", x"9b", x"1e", x"87", x"e9", x"ce", x"55", x"28", x"df",
      x"8c", x"a1", x"89", x"0d", x"bf", x"e6", x"42", x"68", x"41", x"99", x"2d", x"0f", x"b0", x"54", x"bb", x"16");
begin
   subRotW0(8*(i+1)-1 downto 8*i) <= sub(conv_integer(subIn(8*(i+1)-1 downto 8*i)));
end generate;
temp <=  subRotW0 xor (Rcon(RconCnt) & x"000000") when iModNk = 0 else
         subRotW0 when Nk = 7 and iModNk = 4 else
         w(Nk);
--end keyExpansionPipe asynchron circuitry

subKey <= w(0) & w(1) & w(2) & w(3);
subKeyAddress <= roundCounter(5 downto 2);
subKeyEnable <= '1' when roundCounter(1 downto 0) = "00" else '0';
end Behavioral;
