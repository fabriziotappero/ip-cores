----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:20:52 03/03/2009 
-- Design Name: 
-- Module Name:    display - Behavioral 
-- Project Name: 
-- Target Devices: Spartan-3A starter kit SPI DAC
-- Tool versions: 
-- Description:    Oscilloscope output module for PDP-1.
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity display is
    Port ( X : in  STD_LOGIC_VECTOR (0 to 9);
           Y : in  STD_LOGIC_VECTOR (0 to 9);
           CLK : in  STD_LOGIC;
           TRIG, DOPULSE : in  STD_LOGIC;
           DONE : out  STD_LOGIC := '0';
			  
			  SPI_MOSI, DAC_CS, SPI_SCK, DAC_CLR : out STD_LOGIC);
end display;

architecture Behavioral of display is
	signal command : std_logic_vector(23 downto 6) := (others=>'1');
	shared variable Xin, Yin : std_logic_vector(0 to 9) := (others=>'0');
	shared variable newval, dodone : boolean := false;
begin
	DAC_CLR <= '1';
	SPI_SCK <= not CLK;
	SPI_MOSI <= command(command'left);
	
	process(CLK)
		constant exposure : integer := 50*50;	-- 50MHz clock, 50µs exposure
		variable Xidle, Yidle : std_logic_vector(0 to 9) := (others=>'0');
		variable count : integer range 0 to exposure := 0;
		type direction is (left, up, right, down);
		variable dir : direction := right;
	begin
		if rising_edge(CLK) then
			if TRIG='1' then
				if X(0)='1' then
                                  Xin(1 to Xin'right) := X(1 to X'right)+1;
                                else
                                  Xin(1 to Xin'right) := X(1 to X'right);
				end if;
				Xin(0) := not X(0);
				if Y(0)='1' then
                                  Yin(1 to Yin'right) := Y(1 to Y'right)+1;
                                else
                                  Yin(1 to Yin'right) := Y(1 to Y'right);
				end if;
				Yin(0) := not Y(0);
				newval := true;
				count := 0;
				dodone := DOPULSE='1';
			end if;
			case count is
				when 0=>
					DONE <= '0';
					DAC_CS <= '0';
					if newval then	-- channel 3 does X, set without update
						command <= x"03" & Xin;
					else
						case dir is
							when right =>
								Xidle := Xidle+1;
								if Xidle="1111111111" then
									dir:=up;
								end if;
							when up =>
								Yidle := Yidle+1;
								if Yidle="1111111111" then
									dir:=left;
								end if;
							when left =>
								Xidle := Xidle-1;
								if Xidle="0000000000" then
									dir:=down;
								end if;
							when down =>
								Yidle := Yidle-1;
								if Yidle="0000000000" then
									dir:=right;
								end if;
						end case;
						command <= x"03" & Xidle;
					end if;
					count:=count+1;
				when 24=>
					DAC_CS <= '1';
					count:=count+1;
				when 25=>
					if newval then		-- channel 2 is Y, update all DACs
						command <= x"22" & Yin;
					else
						command <= x"22" & Yidle;
					end if;
					DAC_CS <= '0';
					count:=count+1;
				when 25+24=>
					DAC_CS <= '1';
					if newval then
						count:=count+1;
					else
						count := 0;
					end if;
				when exposure =>
					if dodone then
						DONE <= '1';
					end if;
					newval := false;
					count := 0;
				when others =>		-- shift out command bits
					command <= command(command'left-1 downto command'right)&'1';
					count := count+1;
			end case;
		end if;
	end process;
end Behavioral;
