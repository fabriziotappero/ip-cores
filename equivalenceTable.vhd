
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:24:37 10/25/2008 
-- Design Name: 
-- Module Name:    equivalenceTable - Struct 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
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

entity equivalenceTable is
    Port ( a 					: in  STD_LOGIC_VECTOR (9 downto 0);
           b 					: in  STD_LOGIC_VECTOR (9 downto 0);
			  c 					: in  STD_LOGIC_VECTOR (9 downto 0);
           d 					: in  STD_LOGIC_VECTOR (9 downto 0);
			  we					: in  STD_LOGIC;
			  readAddr			: in  STD_LOGIC_VECTOR (9 downto 0);
           dout 				: out STD_LOGIC_VECTOR (9 downto 0);
			  equalcnt			: out STD_LOGIC_VECTOR (9 downto 0);
           fsync 				: in  STD_LOGIC;
           tableReady		: out  STD_LOGIC;
			  tablePreset 		: in  STD_LOGIC;
			  reset				: in  STD_LOGIC;
           clk 				: in  STD_LOGIC;
			  space				: out STD_LOGIC;
			  SetdoutrefA        : out std_logic_vector(9 downto 0);--asynchronous out put of memory
			  SetdoutrefB        : out std_logic_vector(9 downto 0)
			  );
end equivalenceTable;

architecture Struct of equivalenceTable is

signal SaddrRA,SdoutA,SaddrRB,SdoutB,SaddrW,Sdin : std_logic_vector(9 downto 0);
signal TaddrRA,TdoutA,TaddrRB,TdoutB,TaddrW,Tdin : std_logic_vector(9 downto 0);
signal Twe,Swe,eqready,spc,selectSpace : std_logic := '0';
			signal  Saddrefa :  STD_LOGIC_VECTOR (9 downto 0);
			signal  Saddrefb :  STD_LOGIC_VECTOR (9 downto 0);
			signal  Sdoutrefa : STD_LOGIC_VECTOR (9 downto 0);
			signal  Sdoutrefb:  STD_LOGIC_VECTOR (9 downto 0);
         signal  Taddrefa :  STD_LOGIC_VECTOR (9 downto 0);
			signal  Taddrefb :  STD_LOGIC_VECTOR (9 downto 0);
			signal  Tdoutrefa : STD_LOGIC_VECTOR (9 downto 0);
			signal  Tdoutrefb : STD_LOGIC_VECTOR (9 downto 0);
signal SetAddrW,PostAddrW,PreAddrW : std_logic_vector(9 downto 0);
																																																																																																																																																																																																						signal PostAddrR,PostAddrRDelayed : std_logic_vector(9 downto 0);
signal SetDoutA,SetDoutB,PostDout : std_logic_vector(9 downto 0);																																																																																																																																																																																																						signal SetDin, PostDin, PreDin : std_logic_vector(9 downto 0);

signal SetWe,PostWe,PreWe : std_logic;

signal a_delay1,b_delay1 : std_logic_vector(9 downto 0);

type ppstatetype is (idle,startup1,startup2,indexing,toFindEqual,findEqual);
signal ppstate : ppstatetype;
signal tblwrite : std_logic_vector(9 downto 0); -- Used for debugging purposes

type ByteT is (c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,
						c19,c20,c21,c22,c23,c24,c25,c26,c27,c28,c29,c30,c31,c32,c33,c34,
						c35,c36,c37,c38,c39,c40,c41,c42,c43,c44,c45,c46,c47,c48,c49,c50,
						c51,c52,c53,c54,c55,c56,c57,c58,c59,c60,c61,c62,c63,c64,c65,c66,
						c67,c68,c69,c70,c71,c72,c73,c74,c75,c76,c77,c78,c79,c80,c81,c82,
						c83,c84,c85,c86,c87,c88,c89,c90,c91,c92,c93,c94,c95,c96,c97,c98,
						c99,c100,c101,c102,c103,c104,c105,c106,c107,c108,c109,c110,c111,
						c112,c113,c114,c115,c116,c117,c118,c119,c120,c121,c122,c123,c124,
						c125,c126,c127,c128,c129,c130,c131,c132,c133,c134,c135,c136,c137,
						c138,c139,c140,c141,c142,c143,c144,c145,c146,c147,c148,c149,c150,
						c151,c152,c153,c154,c155,c156,c157,c158,c159,c160,c161,c162,c163,
						c164,c165,c166,c167,c168,c169,c170,c171,c172,c173,c174,c175,c176,
						c177,c178,c179,c180,c181,c182,c183,c184,c185,c186,c187,c188,c189,
						c190,c191,c192,c193,c194,c195,c196,c197,c198,c199,c200,c201,c202,
						c203,c204,c205,c206,c207,c208,c209,c210,c211,c212,c213,c214,c215,
						c216,c217,c218,c219,c220,c221,c222,c223,c224,c225,c226,c227,c228,
						c229,c230,c231,c232,c233,c234,c235,c236,c237,c238,c239,c240,c241,
				c242,c243,c244,c245,c246,c247,c248,c249,c250,c251,c252,c253,c254,c255);
  subtype Byte is ByteT;
  type ByteFileType is file of Byte;
  file outfile	: ByteFileType open write_mode is "Labels.bin";

begin

ramS : entity work.ram1w2r port map ( 
          addrefa => Saddrefa,     
			  addrefb=> Saddrefb,
			  doutrefa => Sdoutrefa,
			  doutrefb => Sdoutrefb,
			  addrW => SaddrW,
           din => Sdin,
           we => Swe,
           addrRA => SaddrRA,
           doutA => SdoutA,
           addrRB => SaddrRB,
           doutB => SdoutB,
           clk => clk);

ramT : entity work.ram1w2r port map ( 
           addrefa => Taddrefa,     
			  addrefb=> Taddrefb,
			  doutrefa => Tdoutrefa,
			  doutrefb => Tdoutrefb,
			  addrW => TaddrW,
           din => Tdin,
           we => Twe,
           addrRA => TaddrRA,
           doutA => TdoutA,
           addrRB => TaddrRB,
           doutB => TdoutB,
           clk => clk);
			  
--=============== Multiplexer statements for selecting memories for interlieving of table accesses =======
--=============== selectSpace is the signal that controls interlieveing per frames                 =======

----------  Memory inputs -----------------------------
	SaddrRA <= c when selectSpace ='0' else
				 PostAddrR;
	SaddrRB <= d when selectSpace = '0' else
				  readAddr;
	SaddrW  <= SetAddrW when selectSpace='0' else
			     PostAddrW when eqready='0' else
				  PreAddrW;
	Sdin	  <= SetDin when selectSpace = '0' else
				  PostDin when eqready = '0' else
				  PreDin;
	Swe 	  <= SetWe when selectSpace='0' else
				  PostWe when eqready = '0' else
				  PreWe;
	Saddrefa <= a when selectSpace = '0' ;
	Saddrefb <= b when selectSpace = '0' ;
	
	TaddrRA <= c when selectSpace ='1' else
				 PostAddrR;
	TaddrRB <= d when selectSpace = '1' else
				  readAddr;
	TaddrW  <= SetAddrW when selectSpace='1' else
			     PostAddrW when eqready='0' else
				  PreAddrW;
	Tdin	  <= SetDin when selectSpace = '1' else
				  PostDin when eqready = '0' else
				  PreDin;
	Twe 	  <= SetWe when selectSpace='1' else
				  PostWe when eqready = '0' else
				  PreWe;
   Taddrefa <= a when selectSpace = '1'; 
	Taddrefb <= b when selectSpace = '1' ;
-------------------------------------------------------
	
----------  Memory outputs ----------------------------

	SetDoutA  <= SdoutA when selectSpace = '0' else
				   TdoutA;
	SetDoutB <= SdoutB when selectSpace = '0' else
				   TdoutB;
	PostDout <= SdoutA when selectSpace = '1' else
					TdoutA;
	dout 		<= SdoutB when selectSpace = '1' else
					TdoutB;
	SetdoutrefA  <= Sdoutrefa when selectSpace = '0' else
                   Tdoutrefa;	
	SetdoutrefB  <= Sdoutrefb when selectSpace = '0' else 
	                Tdoutrefb;
	
-------------------------------------------------------

--====================== Other signal mappings =========================================================
	tableReady <= eqready;
	space <= selectspace;
--======================================================================================================

EqualSet : process(clk,reset)

   variable contentA, contentB : std_logic_vector(9 downto 0);
	begin
		if reset = '1' then
			Setwe <= '0';
			a_delay1 <= (others=>'0');
			b_delay1 <= (others=>'0');
			tblwrite <= (others=>'0');
		
		elsif clk'event and clk = '1' then
		
			if fsync = '1' then
--				write(outfile, ByteT'val(0));
--				write(outfile, ByteT'val(0));
--				write(outfile, ByteT'val(0));
			end  if;
		
			if we = '1' or fsync = '1' then
				if a_delay1 = SetaddrW and Setwe = '1' then
					contentA := Setdin;
				else
					contentA := SetDoutA;
				end if;
				if b_delay1 = SetaddrW and Setwe = '1' then
					contentB := Setdin;
				else
					contentB := SetDoutB;
				end if;
				
				if contentA > contentB and a_delay1/= 0 and b_delay1/= 0 then
					SetaddrW <= contentA; -- Position a_store is overwritten by the smaller label in b_out
					Setdin <= contentB;
					Setwe <= '1';
					tblwrite <= tblwrite + 1;
--					write(outfile, ByteT'val(ieee.numeric_std.To_Integer(ieee.numeric_std.unsigned(contentA))));
--					write(outfile, ByteT'val(ieee.numeric_std.To_Integer(ieee.numeric_std.unsigned(contentB))));
					--write(outfile, ByteT'val(0));
				elsif contentB > contentA and a_delay1/=0	and b_delay1/= 0 then
					SetaddrW <= contentB; -- Position b_store is overwritten by the smaller label in a_out
					Setdin <= contentA;
					Setwe <= '1';
					tblwrite <= tblwrite + 1;
--					write(outfile, ByteT'val(ieee.numeric_std.To_Integer(ieee.numeric_std.unsigned(contentB))));
--					write(outfile, ByteT'val(ieee.numeric_std.To_Integer(ieee.numeric_std.unsigned(contentA))));
					--write(outfile, ByteT'val(0));
				else
					Setwe <= '0';
				end if;
			else
				Setwe <= '0';
			end if;
		   if(fsync = '1' ) then
				a_delay1 <= (others=>'0');
				b_delay1 <= (others=>'0');
				tblwrite <= (others=>'0');
			elsif we = '1' then
				a_delay1 <= c;
				b_delay1 <= d;
			end if;
			
		end if;

	end process EqualSet;
PostProc : process(clk,reset)
		
	variable eqindex,aindex,bindex,equcnt : std_logic_vector(9 downto 0);
	variable incIndex : std_logic := '0';
	variable scount : std_logic_vector(6 downto 0);
	begin
		if reset = '1' then
			spc <= '0';
			selectSpace <= '0';
			eqready <= '1';
			eqindex := (others=>'0');
			PostAddrR <= eqindex;
			PostWe <= '0';
			incIndex := '0';
			equcnt := (others=>'0');
			scount := (others=>'0');
			
		elsif clk'event and clk = '1' then
			
			selectSpace <= spc;
			
			case ppstate is
				when idle=>
					if fsync = '1' then
						ppstate <= startup1;
						PostAddrR <= eqindex;
						eqready <= '0';
						eqindex := (others=>'0');
						spc <= not spc;
						equcnt := (others=>'0');
						scount := (others=>'0');
					end if;
					PostWe <= '0';
				when startup1 =>
					ppstate <= startup2;
					PostAddrR <= eqindex;
					PostWe <= '0';
				when startup2 => 
					scount := (others=>'0');
					ppstate <= indexing;
					PostAddrR <= eqindex;
					PostWe <= '0';
				when indexing =>
					if fsync = '1' then
						ppstate <= startup1;
						PostAddrR <= eqindex;
						eqready <= '0';
						eqindex := (others=>'0');
						spc <= not spc;
						PostWe <= '0';
					elsif eqindex = 1023 then
						ppstate <= idle;
						eqready <= '1';
						PostWe <= '0';
					elsif PostAddrRDelayed /= PostDout and PostDout /= 0 then
						aindex := PostAddrRDelayed;
						bindex := PostDout;
						PostAddrR <= bindex;
						equcnt := equcnt + 1;
						ppstate <= toFindEqual;
						if incIndex = '1' then
							eqindex := eqindex + 1;
						else
							incIndex := '1';
						end if;
					elsif eqindex < 1023 then
						eqindex := eqindex + 1;
						PostAddrR <= eqindex;
						incIndex := '0';
					else 
						eqready <= '1';
						equalcnt <= equcnt;
						ppstate <= idle;
					end if;
					PostWe <= '0';
				when toFindEqual =>
					ppstate <= FindEqual;
					PostWe <= '0';
				when findEqual =>
					if fsync = '1' then
						ppstate <= startup1;
						PostAddrR <= eqindex;
						eqready <= '0';
						eqindex := (others=>'0');
						spc <= not spc;
						PostWe <= '0';
					elsif PostAddrRDelayed /= PostDout and PostDout /= 0  and scount < 127 then
						bindex := PostDout;
						PostAddrR <= bindex;
						scount := scount + 1;
						PostWe <= '0';
					else
						PostAddrW <= aindex;
						PostDin <= bindex;
						PostWe <= '1';
						PostAddrR <= eqindex;
						ppstate <= startup2;
					end if;
				when others =>
					ppstate <= idle;
			end case;
			PostAddrRDelayed <= PostAddrR;
		end if;
	end process PostProc;
	
	
PreSet : process(clk,reset)
	
	variable ind : std_logic_vector(9 downto 0);
	constant maxind : std_logic_vector(9 downto 0):= (others=>'1');
	begin
		if reset='1' then	
			ind := maxind;
			PreWe <= '0';
		elsif clk'event and clk='1' then
			if tablePreset = '1' and ind = maxind then
				ind := (others=>'0');
				PreAddrW <= ind;
				PreDin <= ind;
				PreWe <= '1';
			elsif ind < maxind then
				ind := ind + 1;
				PreAddrW <= ind;
				PreDin <= ind;
				PreWe <= '1';
			else
				PreWe <= '0';
			end if;
		end if;
	end process PreSet;
	
end Struct;

