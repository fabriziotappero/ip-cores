library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ClocksPorts is
    port ( 	
	 			Xtal :  in std_logic; --main system oscillator
				LRClk : out std_logic; --LR clock for analog serial bus
				SClk : out std_logic; --Serial Bit clock for analog serial bus
				MClk : out std_logic--; --Master clock for analog serial bus (runs DeltaSig hardware in converters)
		);
end ClocksPorts;

architecture Clocks of ClocksPorts is

	signal XtalDiv : std_logic_vector(3 downto 0);
	signal div256 : std_logic_vector(8 downto 0);
	
begin

	MClk <= div256(0); --run at mclk (XtalDiv/2)
	SClk <= div256(2); --divide MCLK by 4 to Get SCLK (64*Fs)	    	
	LRClk <= div256(8); --divide MCLK by 256 to Get LRCLK (1*Fs)

	process (Xtal)

		begin

		if (Xtal'event and Xtal = '1') then

			--the following divider calculations assume a Xtal input of 25MHz:
			XtalDiv <= XtalDiv + "0001";
			--if (XtalDiv = "1001") then --9: divide by 10 -> fs=4.833kHz
			if (XtalDiv = "0101") then --5: divide by 6 -> fs=8.137kHz
			--if (XtalDiv = "0100") then --4: divide by 5 -> fs=9.766kHz
			--if (XtalDiv = "0011") then --3: divide by 4 -> fs=12kHz
			--if (XtalDiv = "0010") then --2: divide by 3 -> fs=16kHz
			--if (XtalDiv = "0001") then --1: divide by 2 -> fs=32kHz
			--if 'this divider removed 		: divide by 1 -> fs=48kHz						

				--reset master divide counter
				XtalDiv <= "0000";
								
				--drive other dividers...
				div256 <= div256 + "000000001";

			end if; -- if (XtalDiv = ...

		end if; --if (Xtal'event ...

	end process;

end Clocks;