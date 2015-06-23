library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bin_to_7segment is
    Port(	CLK_I : in std_logic;
			PC    : in std_logic_vector(15 downto 0);
			SEG1  : out std_logic_vector(7 downto 1);
			SEG2  : out std_logic_vector(7 downto 0));
end bin_to_7segment;

architecture Behavioral of bin_to_7segment is

								--					  +-------	middle	upper
								--					  |+-------	right	upper
								--					  ||+------	right	lower
								--					  |||+-----	middle	lower
								--					  ||||+----	left	lower
								--					  |||||+---	left	upper
								--					  ||||||+--	middle	middle
								--					  |||||||
constant LEDV_0		: std_logic_vector(6 downto 0):= "1111110";-- 0
constant LEDV_1		: std_logic_vector(6 downto 0):= "0110000";-- 1
constant LEDV_2		: std_logic_vector(6 downto 0):= "1101101";-- 2
constant LEDV_3		: std_logic_vector(6 downto 0):= "1111001";-- 3
constant LEDV_4		: std_logic_vector(6 downto 0):= "0110011";-- 4
constant LEDV_5		: std_logic_vector(6 downto 0):= "1011011";-- 5
constant LEDV_6		: std_logic_vector(6 downto 0):= "1011111";-- 6
constant LEDV_7		: std_logic_vector(6 downto 0):= "1110000";-- 7
constant LEDV_8		: std_logic_vector(6 downto 0):= "1111111";-- 8
constant LEDV_9		: std_logic_vector(6 downto 0):= "1111011";-- 9
constant LEDV_A		: std_logic_vector(6 downto 0):= "1110111";-- A
constant LEDV_b		: std_logic_vector(6 downto 0):= "0011111";-- b
constant LEDV_C		: std_logic_vector(6 downto 0):= "1001110";-- C
constant LEDV_d		: std_logic_vector(6 downto 0):= "0111101";-- d
constant LEDV_E		: std_logic_vector(6 downto 0):= "1001111";-- E
constant LEDV_F		: std_logic_vector(6 downto 0):= "1000111";-- F

	signal LED_CNT  : std_logic_vector(25 downto 0);
	signal LED_VAL  : std_logic_vector(15 downto 0);

begin

	process(CLK_I)

		variable LED4H, LED4L  : std_logic_vector(3 downto 0);

	begin
		if (rising_edge(CLK_I)) then
			if (LED_CNT(25) = '0')	then
				LED4H := LED_VAL( 7 downto  4);
				LED4L := LED_VAL( 3 downto  0);
			else	
				LED4H := LED_VAL(15 downto 12);
				LED4L := LED_VAL(11 downto  8);
			end if;

			if (LED_CNT = 0) then	LED_VAL <= PC;	end if;
			LED_CNT <= LED_CNT + 1;

			case LED4H is
				when X"0" =>	SEG1 <= LEDV_0;
				when X"1" =>	SEG1 <= LEDV_1;
				when X"2" =>	SEG1 <= LEDV_2;
				when X"3" =>	SEG1 <= LEDV_3;
				when X"4" =>	SEG1 <= LEDV_4;
				when X"5" =>	SEG1 <= LEDV_5;
				when X"6" =>	SEG1 <= LEDV_6;
				when X"7" =>	SEG1 <= LEDV_7;
				when X"8" =>	SEG1 <= LEDV_8;
				when X"9" =>	SEG1 <= LEDV_9;
				when X"A" =>	SEG1 <= LEDV_A;
				when X"B" =>	SEG1 <= LEDV_b;
				when X"C" =>	SEG1 <= LEDV_c;
				when X"D" =>	SEG1 <= LEDV_d;
				when X"E" =>	SEG1 <= LEDV_E;
				when others =>	SEG1 <= LEDV_F;
			end case;

			case LED4L is
				when X"0" =>	SEG2(7 downto 1) <= LEDV_0;
				when X"1" =>	SEG2(7 downto 1) <= LEDV_1;
				when X"2" =>	SEG2(7 downto 1) <= LEDV_2;
				when X"3" =>	SEG2(7 downto 1) <= LEDV_3;
				when X"4" =>	SEG2(7 downto 1) <= LEDV_4;
				when X"5" =>	SEG2(7 downto 1) <= LEDV_5;
				when X"6" =>	SEG2(7 downto 1) <= LEDV_6;
				when X"7" =>	SEG2(7 downto 1) <= LEDV_7;
				when X"8" =>	SEG2(7 downto 1) <= LEDV_8;
				when X"9" =>	SEG2(7 downto 1) <= LEDV_9;
				when X"A" =>	SEG2(7 downto 1) <= LEDV_A;
				when X"B" =>	SEG2(7 downto 1) <= LEDV_b;
				when X"C" =>	SEG2(7 downto 1) <= LEDV_c;
				when X"D" =>	SEG2(7 downto 1) <= LEDV_d;
				when X"E" =>	SEG2(7 downto 1) <= LEDV_E;
				when others =>	SEG2(7 downto 1) <= LEDV_F;
			end case;

			SEG2(0) <= LED_CNT(25);
		end if;
	end process;

end Behavioral;
