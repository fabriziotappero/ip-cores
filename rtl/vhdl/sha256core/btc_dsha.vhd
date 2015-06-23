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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.NUMERIC_STD.ALL;
use work.sha_256_pkg.ALL;

entity btc_dsha is
	generic(
		gBASE_DELAY : integer := 1
	);
	port(
		iRst_async : in std_logic := '0';
		
		iClkReg : in std_logic := '0';
		iClkProcess : in std_logic := '0';
		
		iValid_p : in std_logic := '0';
		ivAddr : in std_logic_vector(3 downto 0) := (others=>'0');
		ivData : in std_logic_vector(31 downto 0) := (others=>'0');
		
		oReachEnd_p : out std_logic := '0';
		oFoundNonce_p : out std_logic := '0';
		ovNonce : out std_logic_vector(31 downto 0) := (others=>'0');
		ovDigest : out tDwordArray(0 to 7) := (others=>(others=>'0'))
	);				 	 
end btc_dsha;

architecture behavioral of btc_dsha is
	component pipelines_without_reset IS
		GENERIC (gBUS_WIDTH : integer := 1; gNB_PIPELINES: integer range 1 to 255 := 2);
		PORT(
			iClk				: IN		STD_LOGIC;
			iInput				: IN		STD_LOGIC;
			ivInput				: IN		STD_LOGIC_VECTOR(gBUS_WIDTH-1 downto 0);
			oDelayed_output		: OUT		STD_LOGIC;
			ovDelayed_output	: OUT		STD_LOGIC_VECTOR(gBUS_WIDTH-1 downto 0)
		);
	END component;
	
	component edgedtc is port
		(
			iD				: in		std_logic; 		
			iClk			: in		std_logic;
			iResetSync_Clk	: in		std_logic;
			iEdge			: in		std_logic;
			oQ				: out		std_logic := '0'
		);
	end component;

	component sha_256_chunk is
		generic(
			gMSG_IS_CONSTANT : std_logic_vector(0 to 15) := (others=>'1');
			gH_IS_CONST : std_logic_vector(0 to 7) := (others=>'1');
			gBASE_DELAY : integer := 3;
			gOUT_VALID_GEN : boolean := false;
			gUSE_BRAM_AS_LARGE_SHIFTREG : boolean := false
		);
		port(
			iClk : in std_logic := '0';
			iRst_async : in std_logic := '0';
			
			iValid : in std_logic := '0';
					 
			ivMsgDword : in tDwordArray(0 to 15) := (others=>(others=>'0'));
			
			ivH0 : in std_logic_vector(31 downto 0) := (others=>'0');
			ivH1 : in std_logic_vector(31 downto 0) := (others=>'0'); 
			ivH2 : in std_logic_vector(31 downto 0) := (others=>'0'); 
			ivH3 : in std_logic_vector(31 downto 0) := (others=>'0'); 
			ivH4 : in std_logic_vector(31 downto 0) := (others=>'0'); 
			ivH5 : in std_logic_vector(31 downto 0) := (others=>'0'); 
			ivH6 : in std_logic_vector(31 downto 0) := (others=>'0'); 
			ivH7 : in std_logic_vector(31 downto 0) := (others=>'0');
			
			ovH0 : out std_logic_vector(31 downto 0) := (others=>'0');
			ovH1 : out std_logic_vector(31 downto 0) := (others=>'0'); 
			ovH2 : out std_logic_vector(31 downto 0) := (others=>'0'); 
			ovH3 : out std_logic_vector(31 downto 0) := (others=>'0'); 
			ovH4 : out std_logic_vector(31 downto 0) := (others=>'0'); 
			ovH5 : out std_logic_vector(31 downto 0) := (others=>'0'); 
			ovH6 : out std_logic_vector(31 downto 0) := (others=>'0'); 
			ovH7 : out std_logic_vector(31 downto 0) := (others=>'0');
		
			oValid : out std_logic := '0'
		);				 	 
	end component;
	
	component HandShake is port
		(
			iResetSync_Clk			: in		std_logic;						-- Active Hi Reset
			iClk					: in		std_logic;						-- Clock	 
			
			iExternalDemand			: in		std_logic;						-- Async External Demand : one positive pulse
			oInternalDemand			: out		std_logic;						-- Sync with iClk Internal demand 
			iInternalClrDemand		: in		std_logic						-- Clr Internal Demand
			);
	end component;
	
	component SyncReset is
		port(
			iClk				: in std_logic;						-- Clock domain that the reset should be resynchronyze to
			iAsyncReset      	: in std_logic;						-- Asynchronous reset that should be resynchronyse
			oSyncReset       	: out std_logic						-- Synchronous reset output
		);
	end component;
	
	constant cCMD_ADDR : std_logic_vector(3 downto 0) := X"D";
	constant cCMD_NOP : std_logic_vector(15 downto 0) := X"0000";
	constant cCMD_START : std_logic_vector(15 downto 0) := X"0001";
	
	constant cPROCESS_DEALY : std_logic_vector(15 downto 0) := conv_std_logic_vector(64 * gBASE_DELAY * 2 + 1, 16);
	constant cCMP_DELAY : std_logic_vector(15 downto 0) := conv_std_logic_vector(64 * gBASE_DELAY * 2 + 1 + 2, 16);	
	
	type tProcessStateMachine is (stIdle, stSearch); --, stFound, stNone);
	
	signal sReset_syncProcess : std_logic := '0';
	
	signal svMidState : tDwordArray(0 to 7) := (others=>(others=>'0'));
	signal svMerkleRootDword7 : std_logic_vector(31 downto 0) := (others=>'0');
	signal svTimeStamp : std_logic_vector(31 downto 0) := (others=>'0'); 
	signal svTargetBits : std_logic_vector(31 downto 0) := (others=>'0');
	signal svTargetIndex : std_logic_vector(7 downto 0) := (others=>'0'); 
	signal svTargetFraction : std_logic_vector(23 downto 0) := (others=>'0');
	
	signal svH : tDwordArray(0 to 7) := (others=>(others=>'0'));
	
	signal svStage1MsgDword : tDwordArray(0 to 15) := (others=>(others=>'0'));
	signal svStage1Digest : tDwordArray(0 to 7) := (others=>(others=>'0'));
	
	signal svStage2MsgDword : tDwordArray(0 to 15) := (others=>(others=>'0'));
	
	signal svStartNonce : std_logic_vector(31 downto 0) := (others=>'0');
	signal svEndNonce : std_logic_vector(31 downto 0) := (others=>'0');
	signal svNonce : std_logic_vector(31 downto 0) := (others=>'0');
	signal svCmd : std_logic_vector(15 downto 0) := (others=>'0');
	signal sCmdValid_syncReg_p : std_logic := '0';
	signal sCmdStart_syncReg_p : std_logic := '0';
	signal sCmdStart_syncProcess_p : std_logic := '0';
	signal sCmdStart_syncProcess_p_1d : std_logic := '0';
	
	signal sProcess : tProcessStateMachine := stIdle;
	signal svProcessDelayCnt : std_logic_vector(15 downto 0) := (others=>'0');
	signal sProcessOutValid : std_logic := '0';
	signal sProcessOutValid_1d : std_logic := '0';
	signal sProcessOutValid_2d : std_logic := '0';
	signal svCmpNounce : std_logic_vector(31 downto 0) := (others=>'0');
	signal svProcessNounce_1d : std_logic_vector(31 downto 0) := (others=>'0');
	signal svProcessNounce_2d : std_logic_vector(31 downto 0) := (others=>'0');
	
	
	signal svStage2DigestBig : std_logic_vector(255 downto 0) := (others=>'0');
	signal svStage2DigestLittle : std_logic_vector(255 downto 0) := (others=>'0');
	signal svDigestIsZero : std_logic_vector(31 downto 0) := (others=>'0');
	signal svDigestSignificant : std_logic_vector(23 downto 0) := (others=>'0');
	signal sDigestHighBitsZero : std_logic := '0';
	signal sDigestSignificantFit : std_logic := '0';
	signal svCmpDelayCnt : std_logic_vector(15 downto 0) := (others=>'0');
	signal sCmpResultValid : std_logic := '0';
	signal sFoundNonceToIdle : std_logic := '0';
	signal sReachEndToIdle : std_logic := '0';
	
begin
	
	SyncReset_inst_Process : SyncReset
		port map(
			iClk => iClkProcess,
			iAsyncReset => iRst_async,
			oSyncReset => sReset_syncProcess
		);
	
	process(iClkReg)
	begin
		if rising_edge(iClkReg) then
			if iValid_p = '1' then
				case ivAddr is
					when X"0" =>
					svMidState(0) <= ivData;
					
					when X"1" =>
					svMidState(1) <= ivData;
					
					when X"2" =>
					svMidState(2) <= ivData;
					
					when X"3" =>
					svMidState(3) <= ivData;
					
					when X"4" =>
					svMidState(4) <= ivData;
					
					when X"5" =>
					svMidState(5) <= ivData;
					
					when X"6" =>
					svMidState(6) <= ivData;
					
					when X"7" =>
					svMidState(7) <= ivData;
					
					when X"8" =>
					svMerkleRootDword7 <= ivData;
					
					when X"9" =>
					svTimeStamp <= ivData;
					
					when X"A" =>
					svTargetBits <= ivData;
					
					when X"B" =>
					svStartNonce(31 downto 0) <= ivData;
					
					when X"C" =>
					svEndNonce(31 downto 0) <= ivData;

					when cCMD_ADDR =>
					svCmd <= ivData(15 downto 0);

					when others =>
					svCmd <= ivData(15 downto 0);
				end case;
			end if;
		end if;
	end process;
	
	process(iClkReg, iRst_async)
	begin
		if iRst_async = '1' then
			sCmdValid_syncReg_p <= '0';
			sCmdStart_syncReg_p <= '0';
		elsif rising_edge(iClkReg) then			
			if iValid_p = '1' and ivAddr = cCMD_ADDR then
				sCmdValid_syncReg_p <= '1';
			else
				sCmdValid_syncReg_p <= '0';
			end if;
			
			if iValid_p = '1' and ivAddr = cCMD_ADDR and ivData(15 downto 0) = cCMD_START then
				sCmdStart_syncReg_p <= '1';
			else
				sCmdStart_syncReg_p <= '0';
			end if;			
		end if;
	end process;

	HandShake_inst : HandShake
		port map (
			iResetSync_Clk => sReset_syncProcess,
			iClk => iClkProcess,	 
			
			iExternalDemand => sCmdStart_syncReg_p,
			oInternalDemand => sCmdStart_syncProcess_p,
			iInternalClrDemand => sCmdStart_syncProcess_p
			);
			
	process(iClkProcess, iRst_async)
	begin
		if iRst_async = '1' then
			sCmdStart_syncProcess_p_1d <= '0';
		elsif rising_edge(iClkProcess) then
			sCmdStart_syncProcess_p_1d <= sCmdStart_syncProcess_p;
		end if;
	end process; 
	
	process(iClkProcess)
	begin
		if rising_edge(iClkProcess) then
			if sCmdStart_syncProcess_p = '1' then
				for i in 0 to 7 loop
					svH(i) <= svMidState(i);
				end loop;
				
				svStage1MsgDword(0)	<= svMerkleRootDword7; 
				svStage1MsgDword(1)	<= svTimeStamp;
				svStage1MsgDword(2)	<= svTargetBits;
			end if;
		end if;
	end process; 
	
	process(iClkProcess)
	begin
		if rising_edge(iClkProcess) then
			if sCmdStart_syncProcess_p = '1' then
				svNonce <= svStartNonce;
			elsif sCmdStart_syncProcess_p_1d = '1' or sProcess = stSearch then
				svNonce <= svNonce + '1';
			end if;

			svStage1MsgDword(3) <= svNonce;
		end if;
	end process;
	
	process(iClkProcess)
	begin
		if rising_edge(iClkProcess) then
			if sCmdStart_syncProcess_p = '1' then
				svProcessDelayCnt <= (others=>'0');
				sProcessOutValid <= '0';
				sProcessOutValid_1d <= '0';
				sProcessOutValid_2d <= '0';
			else
				if sProcess = stSearch and svProcessDelayCnt < cPROCESS_DEALY then
					svProcessDelayCnt <= svProcessDelayCnt + '1';
				end if;
				
				if sProcess = stSearch and svProcessDelayCnt = cPROCESS_DEALY then
					sProcessOutValid <= '1';
				elsif sReachEndToIdle = '1' or sFoundNonceToIdle = '1' then
					sProcessOutValid <= '0';
				end if;	
			
				sProcessOutValid_1d <= sProcessOutValid;
				sProcessOutValid_2d <= sProcessOutValid_1d;
			end if;
		end if;
	end process;
	
	process(iClkProcess)
	begin
		if rising_edge(iClkProcess) then
			if sCmdStart_syncProcess_p = '1' then
				sProcess <= stIdle;
			else
				case sProcess is
					when stIdle =>
					if sCmdStart_syncProcess_p_1d = '1' then
						sProcess <= stSearch;
					end if;
					
					when stSearch =>
					if sFoundNonceToIdle = '1' then
						sProcess <= stIdle;
					elsif sReachEndToIdle = '1' then
						sProcess <= stIdle;
					end if;
					
					when others =>
					sProcess <= stIdle;
				end case;
			end if;
		end if;
	end process;
	
	svStage1MsgDword(4) <= X"80000000";
	svStage1MsgDword(5) <= X"00000000";
	svStage1MsgDword(6) <= X"00000000";
	svStage1MsgDword(7) <= X"00000000";
	svStage1MsgDword(8) <= X"00000000";
	svStage1MsgDword(9) <= X"00000000";
	svStage1MsgDword(10) <= X"00000000";
	svStage1MsgDword(11) <= X"00000000";
	svStage1MsgDword(12) <= X"00000000";
	svStage1MsgDword(13) <= X"00000000";
	svStage1MsgDword(14) <= X"00000000";
	svStage1MsgDword(15) <= X"00000280";

	sha_256_chunk_inst_stage1: sha_256_chunk
		generic map(
			gMSG_IS_CONSTANT => (3 => '0', others => '1'),
			gH_IS_CONST => (others => '1'),
			gBASE_DELAY => gBASE_DELAY
		)
		port map(
			iClk => iClkProcess,
			iRst_async => iRst_async,
			
			iValid => '0',
					 
			ivMsgDword => svStage1MsgDword,
			
			ivH0 => svH(0),
			ivH1 => svH(1),
			ivH2 => svH(2),
			ivH3 => svH(3),
			ivH4 => svH(4),
			ivH5 => svH(5),
			ivH6 => svH(6),
			ivH7 => svH(7),
			
			ovH0 => svStage1Digest(0),
			ovH1 => svStage1Digest(1),
			ovH2 => svStage1Digest(2),
			ovH3 => svStage1Digest(3),
			ovH4 => svStage1Digest(4),
			ovH5 => svStage1Digest(5),
			ovH6 => svStage1Digest(6),
			ovH7 => svStage1Digest(7),
			
			oValid => open
		);

	svStage2MsgDword(0) <= svStage1Digest(0);
	svStage2MsgDword(1) <= svStage1Digest(1);
	svStage2MsgDword(2) <= svStage1Digest(2);
	svStage2MsgDword(3) <= svStage1Digest(3);
	svStage2MsgDword(4) <= svStage1Digest(4);
	svStage2MsgDword(5) <= svStage1Digest(5);
	svStage2MsgDword(6) <= svStage1Digest(6);
	svStage2MsgDword(7) <= svStage1Digest(7);
	svStage2MsgDword(8) <= X"80000000";
	svStage2MsgDword(9) <= X"00000000";
	svStage2MsgDword(10) <= X"00000000";
	svStage2MsgDword(11) <= X"00000000";
	svStage2MsgDword(12) <= X"00000000";
	svStage2MsgDword(13) <= X"00000000";
	svStage2MsgDword(14) <= X"00000000";
	svStage2MsgDword(15) <= X"00000100";

	sha_256_chunk_inst_stage2: sha_256_chunk
		generic map(
			gMSG_IS_CONSTANT => (0 => '0',
								1 => '0',
								2 => '0',
								3 => '0',
								4 => '0',
								5 => '0',
								6 => '0',
								7 => '0',
								others => '1'),
			gH_IS_CONST => (others => '1'),
			gBASE_DELAY => gBASE_DELAY
		)
		port map(
			iClk => iClkProcess,
			iRst_async => iRst_async,
			
			iValid => '0',
					 
			ivMsgDword => svStage2MsgDword,
			
			ivH0 => X"6a09e667",
			ivH1 => X"bb67ae85",
			ivH2 => X"3c6ef372",
			ivH3 => X"a54ff53a",
			ivH4 => X"510e527f",
			ivH5 => X"9b05688c",
			ivH6 => X"1f83d9ab",
			ivH7 => X"5be0cd19",			
			
			ovH0 => svStage2DigestBig(((7 + 1) * 32 - 1) downto (7 * 32)),
			ovH1 => svStage2DigestBig(((6 + 1) * 32 - 1) downto (6 * 32)),
			ovH2 => svStage2DigestBig(((5 + 1) * 32 - 1) downto (5 * 32)),
			ovH3 => svStage2DigestBig(((4 + 1) * 32 - 1) downto (4 * 32)), 
			ovH4 => svStage2DigestBig(((3 + 1) * 32 - 1) downto (3 * 32)),
			ovH5 => svStage2DigestBig(((2 + 1) * 32 - 1) downto (2 * 32)),
			ovH6 => svStage2DigestBig(((1 + 1) * 32 - 1) downto (1 * 32)),
			ovH7 => svStage2DigestBig(((0 + 1) * 32 - 1) downto (0 * 32)),
			
			oValid => open
		);
	
	Stage2DigestLittle_gen : for i in 0 to 31 generate
		svStage2DigestLittle(((i + 1) * 8 - 1) downto (i * 8)) <= svStage2DigestBig(((31 - i + 1) * 8 - 1) downto ((31 - i) * 8));
	end generate;
		
	Digest_gen : for i in 0 to 7 generate
		ovDigest(i) <= svStage2DigestBig(((i + 1) * 32 - 1) downto (i * 32));
	end generate;
		
	process(iClkProcess)
	begin
		if rising_edge(iClkProcess) then
			for i in 0 to 31 loop
				if svStage2DigestLittle(((i + 1) * 8 - 1) downto (i * 8)) = X"00" then
					svDigestIsZero(i) <= '1';
				else
					svDigestIsZero(i) <= '0';
				end if;
			end loop;
			
			case svTargetIndex(4 downto 0) is
				when "00011" => 
				svDigestSignificant <= svStage2DigestLittle(8 * 3 - 1 downto 8 * (3 - 3));
				
				when "00100" => 
				svDigestSignificant <= svStage2DigestLittle(8 * 4 - 1 downto 8 * (4 - 3));
				
				when "00101" => 
				svDigestSignificant <= svStage2DigestLittle(8 * 5 - 1 downto 8 * (5 - 3));
				
				when "00110" => 
				svDigestSignificant <= svStage2DigestLittle(8 * 6 - 1 downto 8 * (6 - 3));
				
				when "00111" => 
				svDigestSignificant <= svStage2DigestLittle(8 * 7 - 1 downto 8 * (7 - 3));
				
				when "01000" => 
				svDigestSignificant <= svStage2DigestLittle(8 * 8 - 1 downto 8 * (8 - 3));
				
				when "01001" => 
				svDigestSignificant <= svStage2DigestLittle(8 * 9 - 1 downto 8 * (9 - 3));
				
				when "01010" => 
				svDigestSignificant <= svStage2DigestLittle(8 * 10 - 1 downto 8 * (10 - 3));
				
				when "01011" => 
				svDigestSignificant <= svStage2DigestLittle(8 * 11 - 1 downto 8 * (11 - 3));
				
				when "01100" => 
				svDigestSignificant <= svStage2DigestLittle(8 * 12 - 1 downto 8 * (12 - 3));
				
				when "01101" => 
				svDigestSignificant <= svStage2DigestLittle(8 * 13 - 1 downto 8 * (13 - 3));
				
				when "01110" => 
				svDigestSignificant <= svStage2DigestLittle(8 * 14 - 1 downto 8 * (14 - 3));
				
				when "01111" => 
				svDigestSignificant <= svStage2DigestLittle(8 * 15 - 1 downto 8 * (15 - 3));
				
				when "10000" => 
				svDigestSignificant <= svStage2DigestLittle(8 * 16 - 1 downto 8 * (16 - 3));
				
				when "10001" => 
				svDigestSignificant <= svStage2DigestLittle(8 * 17 - 1 downto 8 * (17 - 3));
				
				when "10010" => 
				svDigestSignificant <= svStage2DigestLittle(8 * 18 - 1 downto 8 * (18 - 3));
				
				when "10011" => 
				svDigestSignificant <= svStage2DigestLittle(8 * 19 - 1 downto 8 * (19 - 3));
				
				when "10100" => 
				svDigestSignificant <= svStage2DigestLittle(8 * 20 - 1 downto 8 * (20 - 3));
				
				when "10101" => 
				svDigestSignificant <= svStage2DigestLittle(8 * 21 - 1 downto 8 * (21 - 3));
											   
				when "10110" => 
				svDigestSignificant <= svStage2DigestLittle(8 * 22 - 1 downto 8 * (22 - 3));
				
				when "10111" => 
				svDigestSignificant <= svStage2DigestLittle(8 * 23 - 1 downto 8 * (23 - 3));
				
				when "11000" => 
				svDigestSignificant <= svStage2DigestLittle(8 * 24 - 1 downto 8 * (24 - 3));
				
				when "11001" => 
				svDigestSignificant <= svStage2DigestLittle(8 * 25 - 1 downto 8 * (25 - 3));
				
				when "11010" => 
				svDigestSignificant <= svStage2DigestLittle(8 * 26 - 1 downto 8 * (26 - 3));
				
				when "11011" => 
				svDigestSignificant <= svStage2DigestLittle(8 * 27 - 1 downto 8 * (27 - 3));
				
				when "11100" => 
				svDigestSignificant <= svStage2DigestLittle(8 * 28 - 1 downto 8 * (28 - 3));
				
				when others => --"11101", Maximum difficulty
				svDigestSignificant <= svStage2DigestLittle(8 * 29 - 1 downto 8 * (29 - 3));
			end case;
		end if;
	end process;
	
	svTargetIndex <= svTargetBits(7 downto 0);
	svTargetFraction(7 downto 0) <= svTargetBits(31 downto 24);
	svTargetFraction(15 downto 8) <= svTargetBits(23 downto 16);
	svTargetFraction(23 downto 16) <= svTargetBits(15 downto 8);
	
	process(iClkProcess)
	begin
		if rising_edge(iClkProcess) then			
			case svTargetIndex(4 downto 0) is
				when "00011" =>
				if svDigestIsZero(31 downto 3) = conv_std_logic_vector(-1, 31 - 3 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
			
				when "00100" =>
				if svDigestIsZero(31 downto 4) = conv_std_logic_vector(-1, 31 - 4 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
				
				when "00101" => 
				if svDigestIsZero(31 downto 5) = conv_std_logic_vector(-1, 31 - 5 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
				
				when "00110" => 
				if svDigestIsZero(31 downto 6) = conv_std_logic_vector(-1, 31 - 6 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
				
				when "00111" => 
				if svDigestIsZero(31 downto 7) = conv_std_logic_vector(-1, 31 - 7 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
				
				when "01000" => 
				if svDigestIsZero(31 downto 8) = conv_std_logic_vector(-1, 31 - 8 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
				
				when "01001" => 
				if svDigestIsZero(31 downto 9) = conv_std_logic_vector(-1, 31 - 9 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
				
				when "01010" => 
				if svDigestIsZero(31 downto 10) = conv_std_logic_vector(-1, 31 - 10 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
				
				when "01011" => 
				if svDigestIsZero(31 downto  11) = conv_std_logic_vector(-1, 31 - 11 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
				
				when "01100" => 
				if svDigestIsZero(31 downto  12) = conv_std_logic_vector(-1, 31 - 12 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
				
				when "01101" => 
				if svDigestIsZero(31 downto  13) = conv_std_logic_vector(-1, 31 -13 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
				
				when "01110" => 
				if svDigestIsZero(31 downto  14) = conv_std_logic_vector(-1, 31 - 14 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
				
				when "01111" => 
				if svDigestIsZero(31 downto  15) = conv_std_logic_vector(-1, 31 - 15 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
				
				when "10000" => 
				if svDigestIsZero(31 downto  16) = conv_std_logic_vector(-1, 31 - 16 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
				
				when "10001" => 
				if svDigestIsZero(31 downto  17) = conv_std_logic_vector(-1, 31 - 17 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
				
				when "10010" => 
				if svDigestIsZero(31 downto  18) = conv_std_logic_vector(-1, 31 - 18 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
				
				when "10011" => 
				if svDigestIsZero(31 downto  19) = conv_std_logic_vector(-1, 31 - 19 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
				
				when "10100" => 
				if svDigestIsZero(31 downto  20) = conv_std_logic_vector(-1, 31 - 20 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
				
				when "10101" => 
				if svDigestIsZero(31 downto  21) = conv_std_logic_vector(-1, 31 - 21 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
				
				when "10110" => 
				if svDigestIsZero(31 downto  22) = conv_std_logic_vector(-1, 31 - 22 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
				
				when "10111" => 
				if svDigestIsZero(31 downto  23) = conv_std_logic_vector(-1, 31 - 23 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
				
				when "11000" => 
				if svDigestIsZero(31 downto  24) = conv_std_logic_vector(-1, 31 - 24 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
				
				when "11001" => 
				if svDigestIsZero(31 downto  25) = conv_std_logic_vector(-1, 31 - 25 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
				
				when "11010" => 
				if svDigestIsZero(31 downto  26) = conv_std_logic_vector(-1, 31 - 26 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
				
				when "11011" => 
				if svDigestIsZero(31 downto  27) = conv_std_logic_vector(-1, 31 - 27 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
				
				when "11100" => 
				if svDigestIsZero(31 downto  28) = conv_std_logic_vector(-1, 31 - 28 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
				
				when others => --"11101", Maximum difficulty
				if svDigestIsZero(31 downto  29) = conv_std_logic_vector(-1, 31 - 29 + 1) then
					sDigestHighBitsZero <= '1';
				else
					sDigestHighBitsZero <= '0';
				end if;
			end case;
			
			if svDigestSignificant <= svTargetFraction(23 downto 0) then
				sDigestSignificantFit <= '1';
			else
				sDigestSignificantFit <= '0';
			end if;
		end if;
	end process;
	
	process(iClkProcess)
	begin
		if rising_edge(iClkProcess) then
			if sCmdStart_syncProcess_p = '1' then
				svCmpDelayCnt <= (others=>'0');
				sCmpResultValid <= '0';
			else
				if sProcess = stSearch and svCmpDelayCnt < cCMP_DELAY then
					svCmpDelayCnt <= svCmpDelayCnt + '1';
				end if;
				
				if sProcess = stSearch and svCmpDelayCnt = cCMP_DELAY then
					sCmpResultValid <= '1';
				else
					sCmpResultValid <= '0';
				end if;
			end if;
		end if;
	end process;
	
	process(iClkProcess)
	begin
		if rising_edge(iClkProcess) then
			if sCmdStart_syncProcess_p = '1' then
				svCmpNounce <= svStartNonce;
			elsif sCmpResultValid = '1' then
				svCmpNounce <= svCmpNounce + '1';
			end if;
		end if;
	end process;
	
	process(iClkProcess)
	begin
		if rising_edge(iClkProcess) then
			if sCmdStart_syncProcess_p = '1' then
				sReachEndToIdle <= '0';
			else
				if sProcess = stSearch and sCmpResultValid = '1' and svCmpNounce = svEndNonce then
					sReachEndToIdle <= '1';
				else
					sReachEndToIdle <= '0';
				end if;
			end if;
		end if;
	end process;
	
	process(iClkProcess)
	begin
		if rising_edge(iClkProcess) then
			if sCmdStart_syncProcess_p = '1' then
				oReachEnd_p <= '0';
			else
				if sProcess = stSearch and sReachEndToIdle = '1' and sFoundNonceToIdle = '0' then
					oReachEnd_p <= '1';
				else
					oReachEnd_p <= '0';
				end if;
			end if;
		end if;
	end process;
	
	process(iClkProcess)
	begin
		if rising_edge(iClkProcess) then
			if sCmdStart_syncProcess_p = '1' then
				sFoundNonceToIdle <= '0';
			else
				if sProcess = stSearch and sCmpResultValid = '1' and sDigestHighBitsZero = '1' and sDigestSignificantFit = '1' then
					sFoundNonceToIdle <= '1';
				else
					sFoundNonceToIdle <= '0';
				end if;
			end if;
		end if;
	end process;
	
	process(iClkProcess)
	begin
		if rising_edge(iClkProcess) then
			if sCmdStart_syncProcess_p = '1' then
				oFoundNonce_p <= '0';
			else
				if sProcess = stSearch and sFoundNonceToIdle = '1' then
					oFoundNonce_p <= '1';
				else
					oFoundNonce_p <= '0';
				end if;
			end if;
		end if;
	end process;
	
	pipelines_without_reset_inst_Nonce : pipelines_without_reset
		GENERIC map(gBUS_WIDTH => 32, gNB_PIPELINES => 2)
		PORT map(
			iClk => iClkProcess,
			iInput => '0',
			ivInput => svCmpNounce,
			oDelayed_output => open,
			ovDelayed_output => ovNonce
		);

end behavioral;
