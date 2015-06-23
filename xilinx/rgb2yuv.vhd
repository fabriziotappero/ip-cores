-------------------------------------------------------------------------------
--	MiniGA
--  Author: Thomas Pototschnig (thomas.pototschnig@gmx.de)
--
--  License: Creative Commons Attribution-NonCommercial-ShareAlike 2.0 License
--           http://creativecommons.org/licenses/by-nc-sa/2.0/de/
--
--  If you want to use MiniGA for commercial purposes please contact the author
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity rgb2yuv is
    Port ( clk : in std_logic;
           reset : in std_logic;
			  in_r, in_g, in_b : in std_logic_vector (4 downto 0); -- signed
			  out_y, out_u, out_v : out std_logic_vector (11 downto 0)); -- unsigned
end rgb2yuv;

architecture Behavioral of rgb2yuv is
begin
	process (clk, reset)
		variable multu : signed (11 downto 0) := conv_signed (517,12);
		variable multv : signed (11 downto 0) := conv_signed (929,12);
		variable var_y : signed (11 downto 0);
		variable in_rs : signed (11 downto 0);
		variable in_gs : signed (11 downto 0);
		variable in_bs : signed (11 downto 0);

		variable worku24 : signed (23 downto 0);
		variable workv24 : signed (23 downto 0);

		variable rsigned : signed (11 downto 0) := conv_signed(0,12);
		variable bsigned : signed (11 downto 0) := conv_signed(0,12);

	begin
		if reset='0' then
			out_u <= (others => '0');
			out_v <= (others => '0');
			out_y <= (others => '0');
		elsif clk='1' and clk'event then
			case in_r is
				when "00000" => in_rs := "000000000000"; -- 0.0000
				when "00001" => in_rs := "000000001001"; -- 0.0094
				when "00010" => in_rs := "000000010011"; -- 0.0187
				when "00011" => in_rs := "000000011100"; -- 0.0281
				when "00100" => in_rs := "000000100110"; -- 0.0375
				when "00101" => in_rs := "000000110000"; -- 0.0469
				when "00110" => in_rs := "000000111001"; -- 0.0562
				when "00111" => in_rs := "000001000011"; -- 0.0656
				when "01000" => in_rs := "000001001100"; -- 0.0750
				when "01001" => in_rs := "000001010110"; -- 0.0844
				when "01010" => in_rs := "000001100000"; -- 0.0938
				when "01011" => in_rs := "000001101001"; -- 0.1031
				when "01100" => in_rs := "000001110011"; -- 0.1125
				when "01101" => in_rs := "000001111100"; -- 0.1219
				when "01110" => in_rs := "000010000110"; -- 0.1313
				when "01111" => in_rs := "000010010000"; -- 0.1406
				when "10000" => in_rs := "000010011001"; -- 0.1500
				when "10001" => in_rs := "000010100011"; -- 0.1594
				when "10010" => in_rs := "000010101100"; -- 0.1687
				when "10011" => in_rs := "000010110110"; -- 0.1781
				when "10100" => in_rs := "000011000000"; -- 0.1875
				when "10101" => in_rs := "000011001001"; -- 0.1969
				when "10110" => in_rs := "000011010011"; -- 0.2062
				when "10111" => in_rs := "000011011100"; -- 0.2156
				when "11000" => in_rs := "000011100110"; -- 0.2250
				when "11001" => in_rs := "000011110000"; -- 0.2344
				when "11010" => in_rs := "000011111001"; -- 0.2437
				when "11011" => in_rs := "000100000011"; -- 0.2531
				when "11100" => in_rs := "000100001100"; -- 0.2625
				when "11101" => in_rs := "000100010110"; -- 0.2719
				when "11110" => in_rs := "000100100000"; -- 0.2813
				when "11111" => in_rs := "000100101001"; -- 0.2906
				when others => in_rs := (others => '0');
			end case;

			case in_g is
				when "00000" => in_gs := "000000000000"; -- 0.0000
				when "00001" => in_gs := "000000010010"; -- 0.0184
				when "00010" => in_gs := "000000100101"; -- 0.0369
				when "00011" => in_gs := "000000111000"; -- 0.0553
				when "00100" => in_gs := "000001001011"; -- 0.0737
				when "00101" => in_gs := "000001011110"; -- 0.0922
				when "00110" => in_gs := "000001110001"; -- 0.1106
				when "00111" => in_gs := "000010000100"; -- 0.1291
				when "01000" => in_gs := "000010010111"; -- 0.1475
				when "01001" => in_gs := "000010101001"; -- 0.1659
				when "01010" => in_gs := "000010111100"; -- 0.1844
				when "01011" => in_gs := "000011001111"; -- 0.2028
				when "01100" => in_gs := "000011100010"; -- 0.2213
				when "01101" => in_gs := "000011110101"; -- 0.2397
				when "01110" => in_gs := "000100001000"; -- 0.2581
				when "01111" => in_gs := "000100011011"; -- 0.2766
				when "10000" => in_gs := "000100101110"; -- 0.2950
				when "10001" => in_gs := "000101000000"; -- 0.3134
				when "10010" => in_gs := "000101010011"; -- 0.3319
				when "10011" => in_gs := "000101100110"; -- 0.3503
				when "10100" => in_gs := "000101111001"; -- 0.3687
				when "10101" => in_gs := "000110001100"; -- 0.3872
				when "10110" => in_gs := "000110011111"; -- 0.4056
				when "10111" => in_gs := "000110110010"; -- 0.4241
				when "11000" => in_gs := "000111000101"; -- 0.4425
				when "11001" => in_gs := "000111011000"; -- 0.4609
				when "11010" => in_gs := "000111101010"; -- 0.4794
				when "11011" => in_gs := "000111111101"; -- 0.4978
				when "11100" => in_gs := "001000010000"; -- 0.5162
				when "11101" => in_gs := "001000100011"; -- 0.5347
				when "11110" => in_gs := "001000110110"; -- 0.5531
				when "11111" => in_gs := "001001001001"; -- 0.5716
				when others => in_gs := (others => '0');
			end case;

			case in_b is
				when "00000" => in_bs := "000000000000"; -- 0.0000
				when "00001" => in_bs := "000000000011"; -- 0.0034
				when "00010" => in_bs := "000000000111"; -- 0.0069
				when "00011" => in_bs := "000000001010"; -- 0.0103
				when "00100" => in_bs := "000000001110"; -- 0.0138
				when "00101" => in_bs := "000000010001"; -- 0.0172
				when "00110" => in_bs := "000000010101"; -- 0.0206
				when "00111" => in_bs := "000000011000"; -- 0.0241
				when "01000" => in_bs := "000000011100"; -- 0.0275
				when "01001" => in_bs := "000000011111"; -- 0.0309
				when "01010" => in_bs := "000000100011"; -- 0.0344
				when "01011" => in_bs := "000000100110"; -- 0.0378
				when "01100" => in_bs := "000000101010"; -- 0.0413
				when "01101" => in_bs := "000000101101"; -- 0.0447
				when "01110" => in_bs := "000000110001"; -- 0.0481
				when "01111" => in_bs := "000000110100"; -- 0.0516
				when "10000" => in_bs := "000000111000"; -- 0.0550
				when "10001" => in_bs := "000000111011"; -- 0.0584
				when "10010" => in_bs := "000000111111"; -- 0.0619
				when "10011" => in_bs := "000001000010"; -- 0.0653
				when "10100" => in_bs := "000001000110"; -- 0.0688
				when "10101" => in_bs := "000001001001"; -- 0.0722
				when "10110" => in_bs := "000001001101"; -- 0.0756
				when "10111" => in_bs := "000001010000"; -- 0.0791
				when "11000" => in_bs := "000001010100"; -- 0.0825
				when "11001" => in_bs := "000001011000"; -- 0.0859
				when "11010" => in_bs := "000001011011"; -- 0.0894
				when "11011" => in_bs := "000001011111"; -- 0.0928
				when "11100" => in_bs := "000001100010"; -- 0.0963
				when "11101" => in_bs := "000001100110"; -- 0.0997
				when "11110" => in_bs := "000001101001"; -- 0.1031
				when "11111" => in_bs := "000001101101"; -- 0.1066
				when others => in_bs := (others => '0');
			end case;

			rsigned := (others => '0');
			bsigned := (others => '0');
			
			rsigned (9 downto 5) := signed(in_r);
			bsigned (9 downto 5) := signed(in_b);
			
			var_y := signed(in_rs) + signed(in_gs) + signed(in_bs);
						
			worku24 := (bsigned-signed(var_y))* multu;
			workv24 := (rsigned-signed(var_y))* multv;
			
			out_u <= conv_std_logic_vector(worku24 (21 downto 10),12);
			out_v <= conv_std_logic_vector(workv24 (21 downto 10),12);
			out_y <= conv_std_logic_vector (var_y, var_y'length);
		end if;
	end process;
	
end Behavioral;
