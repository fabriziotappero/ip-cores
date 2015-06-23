---------------------------------------------------------------------
----                                                             ----
----  FFT Filter IP core                                         ----
----                                                             ----
----  Authors: Anatoliy Sergienko, Volodya Lepeha                ----
----  Company: Unicore Systems http://unicore.co.ua              ----
----                                                             ----
----  Downloaded from: http://www.opencores.org                  ----
----                                                             ----
---------------------------------------------------------------------
----                                                             ----
---- Copyright (C) 2006-2010 Unicore Systems LTD                 ----
---- www.unicore.co.ua                                           ----
---- o.uzenkov@unicore.co.ua                                     ----
----                                                             ----
---- This source file may be used and distributed without        ----
---- restriction provided that this copyright statement is not   ----
---- removed from the file and that any derivative work contains ----
---- the original copyright notice and the associated disclaimer.----
----                                                             ----
---- THIS SOFTWARE IS PROVIDED "AS IS"                           ----
---- AND ANY EXPRESSED OR IMPLIED WARRANTIES,                    ----
---- INCLUDING, BUT NOT LIMITED TO, THE IMPLIED                  ----
---- WARRANTIES OF MERCHANTABILITY, NONINFRINGEMENT              ----
---- AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.        ----
---- IN NO EVENT SHALL THE UNICORE SYSTEMS OR ITS                ----
---- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,            ----
---- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL            ----
---- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT         ----
---- OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,               ----
---- DATA, OR PROFITS; OR BUSINESS INTERRUPTION)                 ----
---- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,              ----
---- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT              ----
---- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING                 ----
---- IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,                 ----
---- EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.          ----
----                                                             ----
---------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;	  
use IEEE.STD_LOGIC_UNSIGNED.all;

entity ROM_COSI is 						 
	generic(n: integer; --- FFT factor= 6,7,8,9,10,11
		wwdth: integer:=15;-- output word width =8...15  , cos>0
		wnd:integer);
	port  (	SELW:in STD_LOGIC_vector(1 downto 0);
		ADDRROM :in std_logic_vector(n-2 downto 0);
		COS : out std_logic_vector(wwdth-1 downto 0)
		);
end  ROM_COSI ;
-----------
architecture DISTR of  ROM_COSI  is		
	
	type ARR17 is array (0 to 31) of STD_LOGIC_VECTOR(15 downto  0);
	constant black:arr17:=(
	X"0000",X"0685",X"1268",X"2665",X"3fff",X"5999",X"6d96",X"797a",
	X"7fff",X"797a",X"6d96",X"5999",X"3fff",X"2665",X"1268",X"0685",
	X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",
	X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000");
	
	--signal hanns:STD_LOGIC_VECTOR(wwdth-1 downto 0);
	signal addrful:STD_LOGIC_VECTOR(8 downto 0);
	signal wind:std_logic_vector(wwdth-1 downto 0);	
	constant nulls:	STD_LOGIC_VECTOR(wwdth-1 downto 0):=(others=>'0');
	
	
	
	signal ADDR :std_logic_vector(n-3 downto 0);	
	type ROM16_16 is array(0 to 15 ) of std_logic_vector(15 downto 0); 
	type ROM128_8 is array(0 to 127 ) of std_logic_vector(7 downto 0);
	
	constant ROM0000:ROM16_16:= 	(                                                                            
	X"7FFF",X"7F61",X"7D89",X"7A7C",X"7641",X"70E2",X"6A6D",X"62F1",
	X"5A82",X"5133",X"471C",X"3C56", X"30FB",X"2528",X"18F9",X"0C8C");			
	
	constant ROM1000:ROM16_16:= 	(                                                                            
	X"7FD8",X"7E9C",X"7C29",X"7884",X"73B5",X"6DC9",X"66CF",X"5ED7",
	X"55F5",X"4C3F",X"41CE",X"36BA",X"2B1F",X"1F1A",X"12C8",X"0648");
	
	constant ROM0100:ROM16_16:= 	(                                                                            
	X"7FF5",X"7F09",X"7CE3",X"7989",X"7504",X"6F5E",X"68A6",X"60EB",
	X"5842",X"4EBF",X"447A",X"398C",X"2E11",X"2223",X"15E2",X"096A");
	constant ROM1100:ROM16_16:= 	(                                                                            
	X"7FA6",X"7E1D",X"7B5C",X"776B",X"7254",X"6C23",X"64E8",X"5CB3",
	X"539B",X"49B4",X"3F17",X"33DF",X"2826",X"1C0B",X"0FAB",X"0324");
	
	
	constant ROM0010:ROM16_16:= 	(                                                                            
	X"7FFD",X"7F37",X"7D39",X"7A05",X"75A5",X"7022",X"698B",X"61F0",
	X"5964",X"4FFB",X"45CD",X"3AF2",X"2F87",X"23A6",X"176E",X"0AFB");
	constant ROM1010:ROM16_16:= 	(                                                                            
	X"7FC1",X"7E5F",X"7BC5",X"77FA",X"7307",X"6CF8",X"65DD",X"5DC7",
	X"54C9",X"4AFB",X"4073",X"354D",X"29A3",X"1D93",X"113A",X"04B6");
	constant ROM0110:ROM16_16:= 	(                                                                            
	X"7FE9",X"7ED5",X"7C88",X"7909",X"745F",X"6E96",X"67BC",X"5FE3",
	X"571D",X"4D81",X"4325",X"3824",X"2C99",X"209F",X"1455",X"07D9");
	constant ROM1110:ROM16_16:= 	(                                                                            
	X"7F86",X"7DD5",X"7AEE",X"76D8",X"719D",X"6B4A",X"63EE",X"5B9C",
	X"5268",X"4869",X"3DB8",X"326E",X"26A8",X"1A82",X"0E1C",X"0192");	 
	
	constant ROM0001:ROM16_16:= 	(                                                                            
	X"7FFE",X"7F4D",X"7D62",X"7A41",X"75F3",X"7083",X"69FD",X"6271",
	X"59F3",X"5097",X"4675",X"3BA5",X"3041",X"2467",X"1833",X"0BC4");
	constant ROM0011:ROM16_16:= 	(                                                                            
	X"7FF9",X"7F21",X"7D0E",X"79C8",X"7555",X"6FC1",X"6919",X"616E",
	X"58D3",X"4F5D",X"4524",X"3A40",X"2ECC",X"22E5",X"16A8",X"0A33");
	constant ROM0101:ROM16_16:= 	(                                                                            
	X"7FF0",X"7EEF",X"7CB6",X"794A",X"74B2",X"6EFB",X"6832",X"6068",
	X"57B0",X"4E20",X"43D0",X"38D9",X"2D55",X"2161",X"151C",X"08A2");
	constant ROM0111:ROM16_16:= 	(                                                                            
	X"7FE1",X"7EB9",X"7C59",X"78C7",X"740A",X"6E30",X"6746",X"5F5D",
	X"568A",X"4CE0",X"427A",X"376F",X"2BDC",X"1FDD",X"138F",X"0711");
	constant ROM1001:ROM16_16:= 	(                                                                            
	X"7FCD",X"7E7E",X"7BF8",X"783F",X"735E",X"6D61",X"6656",X"5E4F",
	X"5560",X"4B9D",X"4121",X"3604",X"2A61",X"1E57",X"1201",X"057F");
	constant ROM1011:ROM16_16:= 	(                                                                            
	X"7FB4",X"7E3E",X"7B91",X"77B3",X"72AE",X"6C8E",X"6563",X"5D3E",
	X"5432",X"4A58",X"3FC5",X"3496",X"28E5",X"1CCF",X"1072",X"03ED");
	constant ROM1101:ROM16_16:= 	(                                                                            
	X"7F97",X"7DFA",X"7B26",X"7722",X"71F9",X"6BB7",X"646C",X"5C28",
	X"5302",X"490F",X"3E68",X"3326",X"2767",X"1B47",X"0EE3",X"025B");
	constant ROM1111:ROM16_16:= 	(                                                                            
	X"7F74",X"7DB0",X"7AB6",X"768D",X"7140",X"6ADC",X"6370",X"5B0F",
	X"51CE",X"47C3",X"3D07",X"31B5",X"25E8",X"19BE",X"0D54",X"00C9");
	constant ROMINCR:ROM128_8:= 	(                                                                            
	X"00",X"01",X"02",X"04",X"05",X"06",X"07",X"09",
	X"0a",X"0b",X"0d",X"0e",X"0f",X"10",X"11",X"12",
	X"13",X"15",X"16",X"17",X"19",X"1a",X"1b",X"1c",
	X"1d",X"1e",X"1f",X"21",X"22",X"23",X"24",X"25",
	
	X"27",X"28",X"29",X"2a",X"2b",X"2c",X"2d",X"2e",
	X"2f",X"30",X"32",X"33",X"34",X"35",X"36",X"37",
	X"38",X"39",X"3a",X"3b",X"3c",X"3d",X"3e",X"3f",
	X"40",X"41",X"42",X"43",X"44",X"45",X"45",X"46",
	
	X"47",X"48",X"49",X"4a",X"4b",X"4c",X"4d",X"4d",
	X"4e",X"4f",X"4f",X"50",X"51",X"52",X"53",X"53",
	X"54",X"55",X"55",X"56",X"56",X"57",X"58",X"58",
	X"58",X"59",X"59",X"5a",X"5b",X"5b",X"5c",X"5d",
	
	X"5d",X"5d",X"5e",X"5f",X"5f",X"5f",X"5f",X"60",
	X"60",X"60",X"61",X"61",X"62",X"62",X"62",X"62",
	X"63",X"63",X"63",X"63",X"64",X"64",X"64",X"64",
	X"64",X"64",X"64",X"64",X"64",X"64",X"64",X"64");
	
	
	signal MUX:std_logic_vector(wwdth-1 downto 0);	 
	signal MUXi:std_logic_vector(15 downto 0);
	signal AD: std_logic_vector(1 downto 0);
	
begin
	
	ADDR<=ADDRROM(n-3 downto 0);
	
	N16: if n=4 generate   
		AD<=ADDR;
		with AD select
		MUXi<=X"7FFF" when "00",
		X"7641" when "01" ,
		X"5A82" when "10" ,
		X"30FB"  when others;    
		
		MUX<=MUXi(14 downto 15- wwdth);             
	end generate;
	
	N32: if n=5  generate
		process (ADDR) is
			variable B:std_logic_vector(15 downto 0);	
		begin
			B:=ROM0000(conv_integer(ADDR&'0'));
			MUX<=B(14 downto 15- wwdth);
		end process;
	end generate;
	
	N64: if n=6  generate
		process (ADDR) is
			variable B:std_logic_vector(15 downto 0);	
		begin
			B:=ROM0000(conv_integer(ADDR));
			MUX<=B(14 downto 15- wwdth);
		end process;
	end generate;
	
	N128: if n=7  generate
		process (ADDR) is 
			variable B0,B1:std_logic_vector(15 downto 0);	
			
		begin	
			B0:=ROM0000(conv_integer(ADDR(4 downto 1)));
			B1:=ROM1000(conv_integer(ADDR(4 downto 1)));
			
			case ADDR(0) is
				when '0' =>  MUX<=B0(14 downto 15- wwdth);
				when '1' =>  MUX<=B1(14 downto 15- wwdth);	
				when others => null	 ;
			end case;
		end process;
	end generate; 
	
	N256: if n=8  generate
		process (ADDR) is
			variable B00:std_logic_vector(15 downto 0);	
			variable B01:std_logic_vector(15 downto 0);	 
			variable B10:std_logic_vector(15 downto 0);	
			variable B11:std_logic_vector(15 downto 0);
			variable sel:std_logic_vector(1 downto 0);	 
		begin	  
			B00:=ROM0000(conv_integer(ADDR(5 downto 2)));
			B01:=ROM0100(conv_integer(ADDR(5 downto 2)));
			B10:=ROM1000(conv_integer(ADDR(5 downto 2)));
			B11:=ROM1100(conv_integer(ADDR(5 downto 2)));
			sel:=ADDR(1 downto 0) ;
			case sel is
				when "00" => MUX<=B00(14 downto 15- wwdth);
				when "01" => MUX<=B01(14 downto 15- wwdth);	
				when "10" => MUX<=B10(14 downto 15- wwdth);
				when "11" => MUX<=B11(14 downto 15- wwdth);	
				when others => null	 ;
			end case;
		end process;
	end generate;
	
	N512: if n=9  generate
		process (ADDR) is		
			variable B000,B001:std_logic_vector(15 downto 0);	
			variable B010,B011:std_logic_vector(15 downto 0);	 
			variable B100,B101:std_logic_vector(15 downto 0);
			variable B110,B111:std_logic_vector(15 downto 0);	 
			variable sel:std_logic_vector(2 downto 0);	 
			
		begin	  
			B000:=ROM0000(conv_integer(ADDR(6 downto 3)));
			B001:=ROM0010(conv_integer(ADDR(6 downto 3)));
			B010:=ROM0100(conv_integer(ADDR(6 downto 3)));
			B011:=ROM0110(conv_integer(ADDR(6 downto 3)));
			B100:=ROM1000(conv_integer(ADDR(6 downto 3)));
			B101:=ROM1010(conv_integer(ADDR(6 downto 3)));
			B110:=ROM1100(conv_integer(ADDR(6 downto 3)));
			B111:=ROM1110(conv_integer(ADDR(6 downto 3)));
			sel:=ADDR(2 downto 0) ;
			
			case sel is
				when "000" =>MUX<=B000(14 downto 15- wwdth);
				when "001" =>MUX<=B001(14 downto 15- wwdth);	
				when "010" =>MUX<=B010(14 downto 15- wwdth);
				when "011" =>MUX<=B011(14 downto 15- wwdth);	
				when "100" =>MUX<=B100(14 downto 15- wwdth);
				when "101" =>MUX<=B101(14 downto 15- wwdth);	
				when "110" =>MUX<=B110(14 downto 15- wwdth);
				when "111" =>MUX<=B111(14 downto 15- wwdth);	
				when others => null	 ;
			end case;
		end process;
	end generate;	
	
	N1024: if n=10  generate
		process (ADDR) is 
			variable B0000:std_logic_vector(15 downto 0);
			variable B0001:std_logic_vector(15 downto 0);
			variable B0010:std_logic_vector(15 downto 0);
			variable B0011:std_logic_vector(15 downto 0);	 
			variable B0100,B0101,B0110,B0111:std_logic_vector(15 downto 0);	 
			variable B1000,B1001,B1010,B1011:std_logic_vector(15 downto 0);
			variable B1100,B1101,B1110,B1111:std_logic_vector(15 downto 0);	 
			variable sel:std_logic_vector(3 downto 0);	 
			
		begin  
			B0000:=ROM0000(conv_integer(ADDR(7 downto 4)));
			B0001:=ROM0001(conv_integer(ADDR(7 downto 4)));
			B0010:=ROM0010(conv_integer(ADDR(7 downto 4)));
			B0011:=ROM0011(conv_integer(ADDR(7 downto 4)));
			B0100:=ROM0100(conv_integer(ADDR(7 downto 4)));
			B0101:=ROM0101(conv_integer(ADDR(7 downto 4)));
			B0110:=ROM0110(conv_integer(ADDR(7 downto 4)));
			B0111:=ROM0111(conv_integer(ADDR(7 downto 4)));
			B1000:=ROM1000(conv_integer(ADDR(7 downto 4)));
			B1001:=ROM1001(conv_integer(ADDR(7 downto 4)));
			B1010:=ROM1010(conv_integer(ADDR(7 downto 4)));
			B1011:=ROM1011(conv_integer(ADDR(7 downto 4)));
			B1100:=ROM1100(conv_integer(ADDR(7 downto 4)));
			B1101:=ROM1101(conv_integer(ADDR(7 downto 4)));
			B1110:=ROM1110(conv_integer(ADDR(7 downto 4)));
			B1111:=ROM1111(conv_integer(ADDR(7 downto 4)));			   
			
			sel:=ADDR(3 downto 0) ;
			
			case sel is
				when "0000" =>MUX<=B0000(14 downto 15- wwdth);
				when "0001" =>MUX<=B0001(14 downto 15- wwdth);	
				when "0010" =>MUX<=B0010(14 downto 15- wwdth);
				when "0011" =>MUX<=B0011(14 downto 15- wwdth);	
				when "0100" =>MUX<=B0100(14 downto 15- wwdth);
				when "0101" =>MUX<=B0101(14 downto 15- wwdth);	
				when "0110" =>MUX<=B0110(14 downto 15- wwdth);
				when "0111" =>MUX<=B0111(14 downto 15- wwdth);	
				when "1000" =>MUX<=B1000(14 downto 15- wwdth);
				when "1001" =>MUX<=B1001(14 downto 15- wwdth);	
				when "1010" =>MUX<=B1010(14 downto 15- wwdth);
				when "1011" =>MUX<=B1011(14 downto 15- wwdth);	
				when "1100" =>MUX<=B1100(14 downto 15- wwdth);
				when "1101" =>MUX<=B1101(14 downto 15- wwdth);	
				when "1110" =>MUX<=B1110(14 downto 15- wwdth);
				when "1111" =>MUX<=B1111(14 downto 15- wwdth);	
				when others => null	 ;
			end case;
		end process;
	end generate;	   
	
	N2048: if n=11  generate
		process (ADDR) is 
			variable B0000:std_logic_vector(15 downto 0);
			variable B0001:std_logic_vector(15 downto 0);
			variable B0010:std_logic_vector(15 downto 0);
			variable B0011:std_logic_vector(15 downto 0);	 
			variable B0100,B0101,B0110,B0111:std_logic_vector(15 downto 0);	 
			variable B1000,B1001,B1010,B1011:std_logic_vector(15 downto 0);
			variable B1100,B1101,B1110,B1111:std_logic_vector(15 downto 0);	 
			variable MUXI:std_logic_vector(wwdth-1 downto 0);    
			variable INCI:std_logic_vector(wwdth-8 downto 0);
			variable INC:std_logic_vector(7 downto 0);
			variable sel:std_logic_vector(3 downto 0);
			
		begin  
			
			INC:=ROMINCR(conv_integer(ADDR(8 downto 2)));
			INCI:=INC( 7 downto 15- wwdth);
			
			B0000:=ROM0000(conv_integer(ADDR(8 downto 5)));
			B0001:=ROM0001(conv_integer(ADDR(8 downto 5)));
			B0010:=ROM0010(conv_integer(ADDR(8 downto 5)));
			B0011:=ROM0011(conv_integer(ADDR(8 downto 5)));
			B0100:=ROM0100(conv_integer(ADDR(8 downto 5)));
			B0101:=ROM0101(conv_integer(ADDR(8 downto 5)));
			B0110:=ROM0110(conv_integer(ADDR(8 downto 5)));
			B0111:=ROM0111(conv_integer(ADDR(8 downto 5)));
			B1000:=ROM1000(conv_integer(ADDR(8 downto 5)));
			B1001:=ROM1001(conv_integer(ADDR(8 downto 5)));
			B1010:=ROM1010(conv_integer(ADDR(8 downto 5)));
			B1011:=ROM1011(conv_integer(ADDR(8 downto 5)));
			B1100:=ROM1100(conv_integer(ADDR(8 downto 5)));
			B1101:=ROM1101(conv_integer(ADDR(8 downto 5)));
			B1110:=ROM1110(conv_integer(ADDR(8 downto 5)));
			B1111:=ROM1111(conv_integer(ADDR(8 downto 5)));	   
			
			sel:=ADDR(4 downto 1) ;
			
			case sel is
				when "0000" =>MUXI:=B0000(14 downto 15- wwdth);
				when "0001" =>MUXI:=B0001(14 downto 15- wwdth);	
				when "0010" =>MUXI:=B0010(14 downto 15- wwdth);
				when "0011" =>MUXI:=B0011(14 downto 15- wwdth);	
				when "0100" =>MUXI:=B0100(14 downto 15- wwdth);
				when "0101" =>MUXI:=B0101(14 downto 15- wwdth);	
				when "0110" =>MUXI:=B0110(14 downto 15- wwdth);
				when "0111" =>MUXI:=B0111(14 downto 15- wwdth);	
				when "1000" =>MUXI:=B1000(14 downto 15- wwdth);
				when "1001" =>MUXI:=B1001(14 downto 15- wwdth);	
				when "1010" =>MUXI:=B1010(14 downto 15- wwdth);
				when "1011" =>MUXI:=B1011(14 downto 15- wwdth);	
				when "1100" =>MUXI:=B1100(14 downto 15- wwdth);
				when "1101" =>MUXI:=B1101(14 downto 15- wwdth);	
				when "1110" =>MUXI:=B1110(14 downto 15- wwdth);
				when "1111" =>MUXI:=B1111(14 downto 15- wwdth);	
				when others => null	 ;
			end case; 
			
			if ADDR(0)='1' then	
				MUX<=CONV_STD_LOGIC_VECTOR((unsigned(MUXI)-unsigned(INCi)),wwdth);
			else
				MUX<=MUXI;
			end if;
			
		end process;
	end generate;	   
	
	process(ADDRROM,addrful)
		variable windi:	STD_LOGIC_VECTOR(15 downto 0);
	begin
		
		--addrful<=ADDRROM(n-3 downto 0); 
		if wnd=1  then
			windi:=black(conv_integer(addrrom(4 downto 0)));
			wind<=windi(14 downto 15-wwdth);
		else   		
			--wind(wwdth-1)<='0' ;
			wind(wwdth-1 downto 0)<=(others=>'1');
		end if;	
	end process;
	
	
	COS<=MUX when SELW="00" 
	else wind when SELW="01" 
	else	addrrom & nulls(wwdth-n downto 0) when SELW="10"
	else (others=>'1');	
	
end DISTR;

