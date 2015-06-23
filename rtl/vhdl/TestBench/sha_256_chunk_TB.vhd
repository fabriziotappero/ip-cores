------------------------------------------------------------------- 
--                                                               --
--  Copyright (C) 2013 Author and VariStream Studio              --
--  Author : Yu Peng                                             --
--                                                               -- 
--  This source file may be used and distributed without         -- 
--  restriction provided that this copyright statement is not    -- 
--  removed from the file and that any derivative work contains  -- 
--  the original copyright notice and the associated disclaimer. -- 
--                                                               -- 
--  This source file is free software; you can redistribute it   -- 
--  and/or modify it under the terms of the GNU Lesser General   -- 
--  Public License as published by the Free Software Foundation; -- 
--  either version 2.1 of the License, or (at your option) any   -- 
--  later version.                                               -- 
--                                                               -- 
--  This source is distributed in the hope that it will be       -- 
--  useful, but WITHOUT ANY WARRANTY; without even the implied   -- 
--  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      -- 
--  PURPOSE.  See the GNU Lesser General Public License for more -- 
--  details.                                                     -- 
--                                                               -- 
--  You should have received a copy of the GNU Lesser General    -- 
--  Public License along with this source; if not, download it   -- 
--  from http://www.opencores.org/lgpl.shtml                     -- 
--                                                               -- 
-------------------------------------------------------------------

library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.NUMERIC_STD.ALL;

use work.sha_256_pkg.all;

	-- Add your library and packages declaration here ...

entity sha_256_chunk_tb is
end sha_256_chunk_tb;

architecture TB_ARCHITECTURE of sha_256_chunk_tb is
	-- Component declaration of the tested unit
	component sha_256_chunk
	generic(
		gMSG_IS_CONSTANT : std_logic_vector(0 to 15) := (others=>'1');
		gH_IS_CONST : std_logic_vector(0 to 7) := (others=>'1');
		gBASE_DELAY : integer := 3;
		gOUT_VALID_GEN : boolean := false;
		gUSE_BRAM_AS_LARGE_SHIFTREG : boolean := false
	);
	port(
		iClk : in STD_LOGIC;
		iRst_async : in STD_LOGIC;
		iValid : in STD_LOGIC;
		ivMsgDword : in tDwordArray(0 to 15);
		ivH0 : in STD_LOGIC_VECTOR(31 downto 0);
		ivH1 : in STD_LOGIC_VECTOR(31 downto 0);
		ivH2 : in STD_LOGIC_VECTOR(31 downto 0);
		ivH3 : in STD_LOGIC_VECTOR(31 downto 0);
		ivH4 : in STD_LOGIC_VECTOR(31 downto 0);
		ivH5 : in STD_LOGIC_VECTOR(31 downto 0);
		ivH6 : in STD_LOGIC_VECTOR(31 downto 0);
		ivH7 : in STD_LOGIC_VECTOR(31 downto 0);
		ovH0 : out STD_LOGIC_VECTOR(31 downto 0);
		ovH1 : out STD_LOGIC_VECTOR(31 downto 0);
		ovH2 : out STD_LOGIC_VECTOR(31 downto 0);
		ovH3 : out STD_LOGIC_VECTOR(31 downto 0);
		ovH4 : out STD_LOGIC_VECTOR(31 downto 0);
		ovH5 : out STD_LOGIC_VECTOR(31 downto 0);
		ovH6 : out STD_LOGIC_VECTOR(31 downto 0);
		ovH7 : out STD_LOGIC_VECTOR(31 downto 0);
		oValid : out std_logic);
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal iClk : STD_LOGIC := '1';
	signal iRst_async : STD_LOGIC := '1';
	signal iValid : STD_LOGIC := '0';
	signal ivMsgDword : tDwordArray(0 to 15) := (others=>(others=>'0'));
	signal ivH0 : STD_LOGIC_VECTOR(31 downto 0) := (others=>'0');
	signal ivH1 : STD_LOGIC_VECTOR(31 downto 0) := (others=>'0');
	signal ivH2 : STD_LOGIC_VECTOR(31 downto 0) := (others=>'0');
	signal ivH3 : STD_LOGIC_VECTOR(31 downto 0) := (others=>'0');
	signal ivH4 : STD_LOGIC_VECTOR(31 downto 0) := (others=>'0');
	signal ivH5 : STD_LOGIC_VECTOR(31 downto 0) := (others=>'0');
	signal ivH6 : STD_LOGIC_VECTOR(31 downto 0) := (others=>'0');
	signal ivH7 : STD_LOGIC_VECTOR(31 downto 0) := (others=>'0');
	signal oValid : std_logic;

	-- Observed signals - signals mapped to the output ports of tested entity

	-- Add your code here ...
	
	constant cTEST_NUM : integer := 3;
	type tTEST_MSG is array(0 to cTEST_NUM - 1) of tDwordArray(0 to 15);
	type tTEST_RESULT is array(0 to cTEST_NUM - 1) of tDwordArray(0 to 7);
	-- The test string length must <= 63
	constant cTEST_STR_00 : string := "";
	constant cTEST_STR_01 : string := "The quick brown fox jumps over the lazy dog";
	constant cTEST_STR_02 : string := "The quick brown fox jumps over the lazy dog.";
	
	constant cTEST_MSG : tTEST_MSG := (
										conv_str_to_msg(cTEST_STR_00),
										conv_str_to_msg(cTEST_STR_01),
										conv_str_to_msg(cTEST_STR_02)
										);
	
	constant cTEST_RESULT : tTEST_RESULT := (
										(X"e3b0c442", X"98fc1c14", X"9afbf4c8", X"996fb924", X"27ae41e4", X"649b934c", X"a495991b", X"7852b855"),
										(X"D7A8FBB3", X"07D78094", X"69CA9ABC", X"B0082E4F", X"8D5651E4", X"6D3CDB76", X"2D02D0BF", X"37C9E592"),
										(X"EF537F25", X"C895BFA7", X"82526529", X"A9B63D97", X"AA631564", X"D5D789C2", X"B765448C", X"8635FB6C")
										);

	constant cCLK_PERIOD : time := 10 ns;
	constant cRESET_INTERVAL : time := 71 ns;
	constant cSTRAT_TEST : integer := 19;
	
	
	signal ovH : tDwordArray(0 to 7) := (others=>(others=>'0'));
	
	signal siTestInCnt : integer := 0;
	signal siTestOutCnt : integer := 0;
	
	signal svResultMatch : std_logic_vector(0 to cTEST_NUM - 1) := (others=>'0');

begin

	-- Unit Under Test port map
	UUT : sha_256_chunk
		generic map(
			gMSG_IS_CONSTANT => (others=>'0'),
			gH_IS_CONST => (others=>'0'),
			gBASE_DELAY => 1,
			gOUT_VALID_GEN => true
		)
		port map (
			iClk => iClk,
			iRst_async => iRst_async,
			iValid => iValid,
			ivMsgDword => ivMsgDword,
			ivH0 => ivH0,
			ivH1 => ivH1,
			ivH2 => ivH2,
			ivH3 => ivH3,
			ivH4 => ivH4,
			ivH5 => ivH5,
			ivH6 => ivH6,
			ivH7 => ivH7,
			ovH0 => ovH(0),
			ovH1 => ovH(1),
			ovH2 => ovH(2),
			ovH3 => ovH(3),
			ovH4 => ovH(4),
			ovH5 => ovH(5),
			ovH6 => ovH(6),
			ovH7 => ovH(7),
			oValid => oValid
		);

	-- Add your stimulus here ...
	iClk <= not iClk after (cCLK_PERIOD / 2);
	iRst_async <= '0' after cRESET_INTERVAL;
	
	iValid <= '1' after (cSTRAT_TEST * cCLK_PERIOD + 1 ns), '0' after ((cSTRAT_TEST * cCLK_PERIOD + 1 ns) + cTEST_NUM * cCLK_PERIOD);
	ivH0 <= X"6a09e667" after (cSTRAT_TEST * cCLK_PERIOD + 1 ns), (others=>'0') after ((cSTRAT_TEST * cCLK_PERIOD + 1 ns) + cTEST_NUM * cCLK_PERIOD);
	ivH1 <= X"bb67ae85" after (cSTRAT_TEST * cCLK_PERIOD + 1 ns), (others=>'0') after ((cSTRAT_TEST * cCLK_PERIOD + 1 ns) + cTEST_NUM * cCLK_PERIOD);
	ivH2 <= X"3c6ef372" after (cSTRAT_TEST * cCLK_PERIOD + 1 ns), (others=>'0') after ((cSTRAT_TEST * cCLK_PERIOD + 1 ns) + cTEST_NUM * cCLK_PERIOD);
	ivH3 <= X"a54ff53a" after (cSTRAT_TEST * cCLK_PERIOD + 1 ns), (others=>'0') after ((cSTRAT_TEST * cCLK_PERIOD + 1 ns) + cTEST_NUM * cCLK_PERIOD);
	ivH4 <= X"510e527f" after (cSTRAT_TEST * cCLK_PERIOD + 1 ns), (others=>'0') after ((cSTRAT_TEST * cCLK_PERIOD + 1 ns) + cTEST_NUM * cCLK_PERIOD);
	ivH5 <= X"9b05688c" after (cSTRAT_TEST * cCLK_PERIOD + 1 ns), (others=>'0') after ((cSTRAT_TEST * cCLK_PERIOD + 1 ns) + cTEST_NUM * cCLK_PERIOD);
	ivH6 <= X"1f83d9ab" after (cSTRAT_TEST * cCLK_PERIOD + 1 ns), (others=>'0') after ((cSTRAT_TEST * cCLK_PERIOD + 1 ns) + cTEST_NUM * cCLK_PERIOD);
	ivH7 <= X"5be0cd19" after (cSTRAT_TEST * cCLK_PERIOD + 1 ns), (others=>'0') after ((cSTRAT_TEST * cCLK_PERIOD + 1 ns) + cTEST_NUM * cCLK_PERIOD);
	
	process(iClk, iRst_async)
	begin
		if iRst_async = '1' then
			siTestInCnt <= 0;
			siTestOutCnt <= 0;
			svResultMatch <= (others=>'0');
		elsif rising_edge(iClk) then
			if iValid = '1' then
				siTestInCnt <= siTestInCnt + 1 after 1 ns;
			end if;
			
			if oValid = '1' then
				siTestOutCnt <= siTestOutCnt + 1;
			end if;
			
			if oValid = '1' then
				for i in 0 to cTEST_NUM - 1 loop
					if i = siTestOutCnt then
						if ovH = cTEST_RESULT(i) then
							svResultMatch(i) <= '1';
						else
							svResultMatch(i) <= '0';
						end if;
						
						assert ovH = cTEST_RESULT(i)
							report "The test " & integer'image(i) & " failed"
							severity ERROR;
					end if;
				end loop;
			end if;
		end if;
	end process;
	
	process(iValid, siTestInCnt)
	begin
		if iValid = '0' or siTestInCnt >= cTEST_NUM then
			ivMsgDword <= (others=>(others=>'0'));
		else
			ivMsgDword <= cTEST_MSG(siTestInCnt);
		end if;
	end process;
		
end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_sha_256_chunk of sha_256_chunk_tb is
	for TB_ARCHITECTURE
		for UUT : sha_256_chunk
			use entity work.sha_256_chunk(behavioral);
		end for;
	end for;
end TESTBENCH_FOR_sha_256_chunk;

