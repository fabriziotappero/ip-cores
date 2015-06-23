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
use IEEE.NUMERIC_STD.all;
use work.sha_256_pkg.ALL;

entity sha_256_chunk is
	generic(
		gMSG_IS_CONSTANT : std_logic_vector(0 to 15) := (others=>'1');
		gH_IS_CONST : std_logic_vector(0 to 7) := (others=>'0');
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
end sha_256_chunk;


architecture behavioral of sha_256_chunk is
	component pipelines_without_reset IS
		GENERIC (gBUS_WIDTH : integer := 3; gNB_PIPELINES: integer range 1 to 255 := 2);
		PORT(
			iClk				: IN		STD_LOGIC;
			iInput				: IN		STD_LOGIC;
			ivInput				: IN		STD_LOGIC_VECTOR(gBUS_WIDTH-1 downto 0);
			oDelayed_output		: OUT		STD_LOGIC;
			ovDelayed_output	: OUT		STD_LOGIC_VECTOR(gBUS_WIDTH-1 downto 0)
		);
	end component;
	
	component SyncReset is
		port(
			iClk				: in std_logic;						-- Clock domain that the reset should be resynchronyze to
			iAsyncReset      	: in std_logic;						-- Asynchronous reset that should be resynchronyse
			oSyncReset       	: out std_logic						-- Synchronous reset output
		);
	end component;
	
	component sync_fifo_infer is
		generic (
			gADDRESS_WIDTH : integer range 4 to (integer'HIGH) := 5; 
			gDATA_WIDTH : integer := 24;
			gDYNAMIC_PROG_FULL_TH : boolean := false;
			gDYNAMIC_PROG_EMPTY_TH : boolean := false;
			gOUTPUT_PIPELINE_NUM : integer range 1 to (integer'HIGH) := 1 
			);
		port(
			iClk : in std_logic := '0';
			iReset_sync : in std_logic := '0';
	
			ivProgFullTh : in std_logic_vector(gADDRESS_WIDTH-1 downto 0) := conv_std_logic_vector(2**gADDRESS_WIDTH-3, gADDRESS_WIDTH);
			ivProgEmptyTh : in std_logic_vector(gADDRESS_WIDTH-1 downto 0) := conv_std_logic_vector(2, gADDRESS_WIDTH);
			
			iWrEn : in std_logic := '0';
			iRdEn : in std_logic := '0';
			ivDataIn : in std_logic_vector(gDATA_WIDTH-1 downto 0) := (others=>'0');
			ovDataOut : out std_logic_vector(gDATA_WIDTH-1 downto 0) := (others=>'0');
			oDataOutValid : out std_logic := '0';
			
			oFull : out std_logic := '0';
			oEmpty : out std_logic := '1';
			oAlmostFull : out std_logic := '0';
			oAlmostEmpty : out std_logic := '1';
			oProgFull : out std_logic := '0';
			oProgEmpty : out std_logic := '1';
			
			oOverflow : out std_logic := '0';
			oUnderflow : out std_logic := '0'
		);
	end component;

	component sha_256_ext_func is
		port(
			iClk : in std_logic;
			iRst_async : in std_logic;
	
			ivWIM2 : in std_logic_vector(31 downto 0);
			ivWIM7 : in std_logic_vector(31 downto 0);	
			ivWIM15 : in std_logic_vector(31 downto 0);
			ivWIM16 : in std_logic_vector(31 downto 0);
					 
			ovWO : out std_logic_vector(31 downto 0)
		);
	end component;
	
	component sha_256_ext_func_1c is
		port(
			iClk : in std_logic;
			iRst_async : in std_logic;
	
			ivWIM2 : in std_logic_vector(31 downto 0);
			ivWIM7 : in std_logic_vector(31 downto 0);	
			ivWIM15 : in std_logic_vector(31 downto 0);
			ivWIM16 : in std_logic_vector(31 downto 0);
					 
			ovWO : out std_logic_vector(31 downto 0)
		);
	end component;

	component sha_256_comp_func is
		port(
			iClk : in std_logic;
			iRst_async : in std_logic;
			
			ivA : in std_logic_vector(31 downto 0);
			ivB : in std_logic_vector(31 downto 0);
			ivC : in std_logic_vector(31 downto 0);
			ivD : in std_logic_vector(31 downto 0);
			ivE : in std_logic_vector(31 downto 0);
			ivF : in std_logic_vector(31 downto 0);
			ivG : in std_logic_vector(31 downto 0);
			ivH : in std_logic_vector(31 downto 0);
					 
			ivK : in std_logic_vector(31 downto 0);
			ivW : in std_logic_vector(31 downto 0);
					 
			ovA : out std_logic_vector(31 downto 0);
			ovB : out std_logic_vector(31 downto 0);
			ovC : out std_logic_vector(31 downto 0);
			ovD : out std_logic_vector(31 downto 0);
			ovE : out std_logic_vector(31 downto 0);
			ovF : out std_logic_vector(31 downto 0);
			ovG : out std_logic_vector(31 downto 0);
			ovH : out std_logic_vector(31 downto 0)
		);
	end component;
	
	component sha_256_comp_func_1c is
		port(
			iClk : in std_logic;
			iRst_async : in std_logic;
			
			ivA : in std_logic_vector(31 downto 0);
			ivB : in std_logic_vector(31 downto 0);
			ivC : in std_logic_vector(31 downto 0);
			ivD : in std_logic_vector(31 downto 0);
			ivE : in std_logic_vector(31 downto 0);
			ivF : in std_logic_vector(31 downto 0);
			ivG : in std_logic_vector(31 downto 0);
			ivH : in std_logic_vector(31 downto 0);
					 
			ivK : in std_logic_vector(31 downto 0);
			ivW : in std_logic_vector(31 downto 0);
					 
			ovA : out std_logic_vector(31 downto 0);
			ovB : out std_logic_vector(31 downto 0);
			ovC : out std_logic_vector(31 downto 0);
			ovD : out std_logic_vector(31 downto 0);
			ovE : out std_logic_vector(31 downto 0);
			ovF : out std_logic_vector(31 downto 0);
			ovG : out std_logic_vector(31 downto 0);
			ovH : out std_logic_vector(31 downto 0)
		);
	end component;

	constant cvK : tDwordArray(0 to 63) := (
		X"428a2f98", X"71374491", X"b5c0fbcf", X"e9b5dba5", X"3956c25b", X"59f111f1", X"923f82a4", X"ab1c5ed5",
		X"d807aa98", X"12835b01", X"243185be", X"550c7dc3", X"72be5d74", X"80deb1fe", X"9bdc06a7", X"c19bf174",
		X"e49b69c1", X"efbe4786", X"0fc19dc6", X"240ca1cc", X"2de92c6f", X"4a7484aa", X"5cb0a9dc", X"76f988da",
		X"983e5152", X"a831c66d", X"b00327c8", X"bf597fc7", X"c6e00bf3", X"d5a79147", X"06ca6351", X"14292967",
		X"27b70a85", X"2e1b2138", X"4d2c6dfc", X"53380d13", X"650a7354", X"766a0abb", X"81c2c92e", X"92722c85",
		X"a2bfe8a1", X"a81a664b", X"c24b8b70", X"c76c51a3", X"d192e819", X"d6990624", X"f40e3585", X"106aa070",
		X"19a4c116", X"1e376c08", X"2748774c", X"34b0bcb5", X"391c0cb3", X"4ed8aa4a", X"5b9cca4f", X"682e6ff3",
		X"748f82ee", X"78a5636f", X"84c87814", X"8cc70208", X"90befffa", X"a4506ceb", X"bef9a3f7", X"c67178f2");
		
	constant cvW_IS_CONST : std_logic_vector(0 to 63) := getW_IS_CONST(gMSG_IS_CONSTANT);
	
	type tDword2DArrayRow64Col64 is array(0 to 63) of tDwordArray(0 to 63);
	
	signal svResetHShiftFifo_sync : std_logic_vector(0 to 7) := (others=>'0');
	
	signal svH0 : std_logic_vector(31 downto 0) := (others=>'0');	
	signal svH1 : std_logic_vector(31 downto 0) := (others=>'0');
	signal svH2 : std_logic_vector(31 downto 0) := (others=>'0');
	signal svH3 : std_logic_vector(31 downto 0) := (others=>'0');
	signal svH4 : std_logic_vector(31 downto 0) := (others=>'0');
	signal svH5 : std_logic_vector(31 downto 0) := (others=>'0');
	signal svH6 : std_logic_vector(31 downto 0) := (others=>'0');
	signal svH7 : std_logic_vector(31 downto 0) := (others=>'0');
	
	signal sHShiftFifoRdEn : std_logic := '0';
	
	signal svAPipe : tDwordArray(0 to 64) := (others=>(others=>'0'));
	signal svBPipe : tDwordArray(0 to 64) := (others=>(others=>'0'));
	signal svCPipe : tDwordArray(0 to 64) := (others=>(others=>'0'));
	signal svDPipe : tDwordArray(0 to 64) := (others=>(others=>'0'));
	signal svEPipe : tDwordArray(0 to 64) := (others=>(others=>'0'));
	signal svFPipe : tDwordArray(0 to 64) := (others=>(others=>'0'));
	signal svGPipe : tDwordArray(0 to 64) := (others=>(others=>'0'));
	signal svHPipe : tDwordArray(0 to 64) := (others=>(others=>'0'));
	
	signal svW : tDword2DArrayRow64Col64 := (others=>(others=>(others=>'0')));
	
begin
--	Description of Algorithm
--	for i in 16 to 63 loop
--		s0 := (w[i-15] rightrotate 7) xor (w[i-15] rightrotate 18) xor (w[i-15] rightshift 3)
--		s1 := (w[i-2] rightrotate 17) xor (w[i-2] rightrotate 19) xor (w[i-2] rightshift 10)
--		w[i] := w[i-16] + s0 + w[i-7] + s1
--	end loop

	W_col_00_gen : for row in 0 to 15 generate
		svW(row)(0) <= ivMsgDword(row);
	end generate;

	W_01_to_15_gen_row : for row in 1 to 15 generate
		W_01_to_15_gen_col : for col in 1 to row generate
			W_01_to_15_gen_const : if cvW_IS_CONST(row) = '1' generate
				svW(row)(col) <= svW(row)(col - 1);
			end generate;
			
			W_01_to_15_gen_var : if cvW_IS_CONST(row) = '0' generate 
				pipelines_without_reset_inst: pipelines_without_reset
					GENERIC map(
						gBUS_WIDTH => 32, 
						gNB_PIPELINES => gBASE_DELAY)
					PORT map(
						iClk => iClk,
						iInput => '0',
						oDelayed_output => open,
						ivInput => svW(row)(col - 1),
						ovDelayed_output => svW(row)(col)
					);
			end generate;
		end generate;
	end generate;

	W_16_to_63_gen_row : for row in 16 to 63 generate
		W_16_to_63_gen_col : for col in (row - 15) to row generate
			W_16_to_63_gen_const : if cvW_IS_CONST(row) = '1' generate
				W_16_to_63_gen_const_first : if col = (row - 15) generate 
					svW(row)(col) <= svW(row - 16)(col - 1) + sigma_0(svW(row - 15)(col - 1)) + svW(row - 7)(col - 1) + sigma_1(svW(row - 2)(col - 1));
				end generate;
				
				W_16_to_63_gen_const_rest : if col > (row - 15) generate 
					svW(row)(col) <= svW(row)(col - 1);
				end generate;
			end generate;
		
			W_16_to_63_gen_var : if cvW_IS_CONST(row) = '0' generate
				W_16_to_63_gen_var_first : if col = (row - 15) generate
					W_16_to_63_gen_var_first_3c : if gBASE_DELAY = 3 generate 
						sha_256_ext_func_inst: sha_256_ext_func
							port map(
								iClk => iClk,
								iRst_async => iRst_async,
						
								ivWIM2 => svW(row-2)(col - 1),
								ivWIM7 => svW(row-7)(col - 1),	
								ivWIM15 => svW(row-15)(col - 1),
								ivWIM16 => svW(row-16)(col - 1),
										 
								ovWO => svW(row)(col)
							);
					end generate;
					
					W_16_to_63_gen_var_first_1c : if gBASE_DELAY = 1 generate 
						sha_256_ext_func_inst: sha_256_ext_func_1c
							port map(
								iClk => iClk,
								iRst_async => iRst_async,
						
								ivWIM2 => svW(row-2)(col - 1),
								ivWIM7 => svW(row-7)(col - 1),	
								ivWIM15 => svW(row-15)(col - 1),
								ivWIM16 => svW(row-16)(col - 1),
										 
								ovWO => svW(row)(col)
							);
					end generate;
				end generate;
				
				W_16_to_63_gen_var_rest : if col > (row - 15) generate	
					pipelines_without_reset_inst: pipelines_without_reset
						GENERIC map(
							gBUS_WIDTH => 32, 
							gNB_PIPELINES => gBASE_DELAY)
						PORT map(
							iClk => iClk,
							iInput => '0',
							oDelayed_output => open,
							ivInput => svW(row)(col - 1),
							ovDelayed_output => svW(row)(col)
						);
				end generate;
			end generate;
		end generate;
	end generate;
		
	svAPipe(0) <= ivH0;		  
	svBPipe(0) <= ivH1;
	svCPipe(0) <= ivH2;
	svDPipe(0) <= ivH3;
	svEPipe(0) <= ivH4;
	svFPipe(0) <= ivH5;
	svGPipe(0) <= ivH6;
	svHPipe(0) <= ivH7;
	
	loop_gen : for i in 0 to 63 generate
		loo_gen_3c : if gBASE_DELAY = 3 generate
			sha_256_comp_func_inst : sha_256_comp_func
				port map(
					iClk => iClk,
					iRst_async => iRst_async,
					
					ivA => svAPipe(i),
					ivB => svBPipe(i),
					ivC => svCPipe(i),
					ivD => svDPipe(i),
					ivE => svEPipe(i),
					ivF => svFPipe(i),
					ivG => svGPipe(i),
					ivH => svHPipe(i),
							 
					ivK => cvK(i),
					ivW => svW(i)(i),
							 
					ovA => svAPipe(i + 1),
					ovB => svBPipe(i + 1),
					ovC => svCPipe(i + 1),
					ovD => svDPipe(i + 1),
					ovE => svEPipe(i + 1),
					ovF => svFPipe(i + 1),
					ovG => svGPipe(i + 1),
					ovH => svHPipe(i + 1)
				);
		end generate;
		
		loo_gen_1c : if gBASE_DELAY = 1 generate
			sha_256_comp_func_inst : sha_256_comp_func_1c
				port map(
					iClk => iClk,
					iRst_async => iRst_async,
					
					ivA => svAPipe(i),
					ivB => svBPipe(i),
					ivC => svCPipe(i),
					ivD => svDPipe(i),
					ivE => svEPipe(i),
					ivF => svFPipe(i),
					ivG => svGPipe(i),
					ivH => svHPipe(i),
							 
					ivK => cvK(i),
					ivW => svW(i)(i),
							 
					ovA => svAPipe(i + 1),
					ovB => svBPipe(i + 1),
					ovC => svCPipe(i + 1),
					ovD => svDPipe(i + 1),
					ovE => svEPipe(i + 1),
					ovF => svFPipe(i + 1),
					ovG => svGPipe(i + 1),
					ovH => svHPipe(i + 1)
				);
		end generate;		
	end generate;
	
	H0_gen_const : if gH_IS_CONST(0) = '1' generate
		svH0 <= ivH0;
	end generate;
	
	H1_gen_const : if gH_IS_CONST(1) = '1' generate
		svH1 <= ivH1;
	end generate;
	
	H2_gen_const : if gH_IS_CONST(2) = '1' generate
		svH2 <= ivH2;
	end generate;
	
	H3_gen_const : if gH_IS_CONST(3) = '1' generate
		svH3 <= ivH3;
	end generate;

	H4_gen_const : if gH_IS_CONST(4) = '1' generate
		svH4 <= ivH4;
	end generate;
	
	H5_gen_const : if gH_IS_CONST(5) = '1' generate
		svH5 <= ivH5;
	end generate;
	
	H6_gen_const : if gH_IS_CONST(6) = '1' generate
		svH6 <= ivH6;
	end generate;
	
	H7_gen_const : if gH_IS_CONST(7) = '1' generate
		svH7 <= ivH7;
	end generate;
	
	HShiftFifoRdEn_gen : if gUSE_BRAM_AS_LARGE_SHIFTREG = true generate
			pipelines_without_reset_inst: pipelines_without_reset
				GENERIC map(
					gBUS_WIDTH => 1, 
					gNB_PIPELINES => (64 * gBASE_DELAY - 1) )
				PORT map(
					iClk => iClk,
					iInput => iValid,
					oDelayed_output => sHShiftFifoRdEn,
					ivInput => (others=>'0'),
					ovDelayed_output => open
				);
	end generate;
	
	H0_gen_var : if gH_IS_CONST(0) = '0' generate
		H0_gen_var_shiftreg : if gUSE_BRAM_AS_LARGE_SHIFTREG = false generate
			pipelines_without_reset_inst: pipelines_without_reset
				GENERIC map(
					gBUS_WIDTH => 32, 
					gNB_PIPELINES => 64 * gBASE_DELAY)
				PORT map(
					iClk => iClk,
					iInput => '0',
					oDelayed_output => open,
					ivInput => ivH0,
					ovDelayed_output => svH0
				);
		end generate;
		
		H0_gen_var_bram : if gUSE_BRAM_AS_LARGE_SHIFTREG = true generate
			SyncReset_inst : SyncReset
				port map(
					iClk => iClk,
					iAsyncReset => iRst_async,
					oSyncReset => svResetHShiftFifo_sync(0)
				);

			sync_fifo_infer_inst : sync_fifo_infer
				generic map(
					gADDRESS_WIDTH => 8,
					gDATA_WIDTH => 32
					)
				port map(
					iClk => iClk,
					iReset_sync => svResetHShiftFifo_sync(0),
			
					ivProgFullTh => conv_std_logic_vector(2**8-3, 8),
					ivProgEmptyTh => conv_std_logic_vector(2, 8),
					
					iWrEn => iValid,
					iRdEn => sHShiftFifoRdEn,
					ivDataIn => ivH0,
					ovDataOut => svH0,
					oDataOutValid => open,
					
					oFull => open,
					oEmpty => open,
					oAlmostFull => open,
					oAlmostEmpty => open,
					oProgFull => open,
					oProgEmpty => open,
					
					oOverflow => open,
					oUnderflow => open
				);
		end generate;			
	end generate;
	
	H1_gen_var : if gH_IS_CONST(1) = '0' generate
		H1_gen_var_shiftreg : if gUSE_BRAM_AS_LARGE_SHIFTREG = false generate
			pipelines_without_reset_inst: pipelines_without_reset
				GENERIC map(
					gBUS_WIDTH => 32, 
					gNB_PIPELINES => 64 * gBASE_DELAY)
				PORT map(
					iClk => iClk,
					iInput => '0',
					oDelayed_output => open,
					ivInput => ivH1,
					ovDelayed_output => svH1
				);
		end generate;
		
		H1_gen_var_bram : if gUSE_BRAM_AS_LARGE_SHIFTREG = true generate
			SyncReset_inst : SyncReset
				port map(
					iClk => iClk,
					iAsyncReset => iRst_async,
					oSyncReset => svResetHShiftFifo_sync(1)
				);

			sync_fifo_infer_inst : sync_fifo_infer
				generic map(
					gADDRESS_WIDTH => 8,
					gDATA_WIDTH => 32
					)
				port map(
					iClk => iClk,
					iReset_sync => svResetHShiftFifo_sync(1),
			
					ivProgFullTh => conv_std_logic_vector(2**8-3, 8),
					ivProgEmptyTh => conv_std_logic_vector(2, 8),
					
					iWrEn => iValid,
					iRdEn => sHShiftFifoRdEn,
					ivDataIn => ivH1,
					ovDataOut => svH1,
					oDataOutValid => open,
					
					oFull => open,
					oEmpty => open,
					oAlmostFull => open,
					oAlmostEmpty => open,
					oProgFull => open,
					oProgEmpty => open,
					
					oOverflow => open,
					oUnderflow => open
				);
		end generate;
	end generate;
	
	H2_gen_var : if gH_IS_CONST(2) = '0' generate
		H2_gen_var_shiftreg : if gUSE_BRAM_AS_LARGE_SHIFTREG = false generate
			pipelines_without_reset_inst: pipelines_without_reset
				GENERIC map(
					gBUS_WIDTH => 32, 
					gNB_PIPELINES => 64 * gBASE_DELAY)
				PORT map(
					iClk => iClk,
					iInput => '0',
					oDelayed_output => open,
					ivInput => ivH2,
					ovDelayed_output => svH2
				);
		end generate;
		
		H2_gen_var_bram : if gUSE_BRAM_AS_LARGE_SHIFTREG = true generate
			SyncReset_inst : SyncReset
				port map(
					iClk => iClk,
					iAsyncReset => iRst_async,
					oSyncReset => svResetHShiftFifo_sync(2)
				);

			sync_fifo_infer_inst : sync_fifo_infer
				generic map(
					gADDRESS_WIDTH => 8,
					gDATA_WIDTH => 32
					)
				port map(
					iClk => iClk,
					iReset_sync => svResetHShiftFifo_sync(2),
			
					ivProgFullTh => conv_std_logic_vector(2**8-3, 8),
					ivProgEmptyTh => conv_std_logic_vector(2, 8),
					
					iWrEn => iValid,
					iRdEn => sHShiftFifoRdEn,
					ivDataIn => ivH2,
					ovDataOut => svH2,
					oDataOutValid => open,
					
					oFull => open,
					oEmpty => open,
					oAlmostFull => open,
					oAlmostEmpty => open,
					oProgFull => open,
					oProgEmpty => open,
					
					oOverflow => open,
					oUnderflow => open
				);
		end generate;
	end generate;
	
	H3_gen_var : if gH_IS_CONST(3) = '0' generate
		H3_gen_var_shiftreg : if gUSE_BRAM_AS_LARGE_SHIFTREG = false generate
			pipelines_without_reset_inst: pipelines_without_reset
				GENERIC map(
					gBUS_WIDTH => 32, 
					gNB_PIPELINES => 64 * gBASE_DELAY)
				PORT map(
					iClk => iClk,
					iInput => '0',
					oDelayed_output => open,
					ivInput => ivH3,
					ovDelayed_output => svH3
				);
		end generate;
		
		H3_gen_var_bram : if gUSE_BRAM_AS_LARGE_SHIFTREG = true generate
			SyncReset_inst : SyncReset
				port map(
					iClk => iClk,
					iAsyncReset => iRst_async,
					oSyncReset => svResetHShiftFifo_sync(3)
				);

			sync_fifo_infer_inst : sync_fifo_infer
				generic map(
					gADDRESS_WIDTH => 8,
					gDATA_WIDTH => 32
					)
				port map(
					iClk => iClk,
					iReset_sync => svResetHShiftFifo_sync(3),
			
					ivProgFullTh => conv_std_logic_vector(2**8-3, 8),
					ivProgEmptyTh => conv_std_logic_vector(2, 8),
					
					iWrEn => iValid,
					iRdEn => sHShiftFifoRdEn,
					ivDataIn => ivH3,
					ovDataOut => svH3,
					oDataOutValid => open,
					
					oFull => open,
					oEmpty => open,
					oAlmostFull => open,
					oAlmostEmpty => open,
					oProgFull => open,
					oProgEmpty => open,
					
					oOverflow => open,
					oUnderflow => open
				);
		end generate;
	end generate;

	H4_gen_var : if gH_IS_CONST(4) = '0' generate
		H4_gen_var_shiftreg : if gUSE_BRAM_AS_LARGE_SHIFTREG = false generate
			pipelines_without_reset_inst: pipelines_without_reset
				GENERIC map(
					gBUS_WIDTH => 32, 
					gNB_PIPELINES => 64 * gBASE_DELAY)
				PORT map(
					iClk => iClk,
					iInput => '0',
					oDelayed_output => open,
					ivInput => ivH4,
					ovDelayed_output => svH4
				);
		end generate;
		
		H4_gen_var_bram : if gUSE_BRAM_AS_LARGE_SHIFTREG = true generate
			SyncReset_inst : SyncReset
				port map(
					iClk => iClk,
					iAsyncReset => iRst_async,
					oSyncReset => svResetHShiftFifo_sync(4)
				);

			sync_fifo_infer_inst : sync_fifo_infer
				generic map(
					gADDRESS_WIDTH => 8,
					gDATA_WIDTH => 32
					)
				port map(
					iClk => iClk,
					iReset_sync => svResetHShiftFifo_sync(4),
			
					ivProgFullTh => conv_std_logic_vector(2**8-3, 8),
					ivProgEmptyTh => conv_std_logic_vector(2, 8),
					
					iWrEn => iValid,
					iRdEn => sHShiftFifoRdEn,
					ivDataIn => ivH4,
					ovDataOut => svH4,
					oDataOutValid => open,
					
					oFull => open,
					oEmpty => open,
					oAlmostFull => open,
					oAlmostEmpty => open,
					oProgFull => open,
					oProgEmpty => open,
					
					oOverflow => open,
					oUnderflow => open
				);
		end generate;
	end generate;
	
	H5_gen_var : if gH_IS_CONST(5) = '0' generate
		H5_gen_var_shiftreg : if gUSE_BRAM_AS_LARGE_SHIFTREG = false generate
			pipelines_without_reset_inst: pipelines_without_reset
				GENERIC map(
					gBUS_WIDTH => 32, 
					gNB_PIPELINES => 64 * gBASE_DELAY)
				PORT map(
					iClk => iClk,
					iInput => '0',
					oDelayed_output => open,
					ivInput => ivH5,
					ovDelayed_output => svH5
				);
		end generate;
		
		H5_gen_var_bram : if gUSE_BRAM_AS_LARGE_SHIFTREG = true generate
			SyncReset_inst : SyncReset
				port map(
					iClk => iClk,
					iAsyncReset => iRst_async,
					oSyncReset => svResetHShiftFifo_sync(5)
				);

			sync_fifo_infer_inst : sync_fifo_infer
				generic map(
					gADDRESS_WIDTH => 8,
					gDATA_WIDTH => 32
					)
				port map(
					iClk => iClk,
					iReset_sync => svResetHShiftFifo_sync(5),
			
					ivProgFullTh => conv_std_logic_vector(2**8-3, 8),
					ivProgEmptyTh => conv_std_logic_vector(2, 8),
					
					iWrEn => iValid,
					iRdEn => sHShiftFifoRdEn,
					ivDataIn => ivH5,
					ovDataOut => svH5,
					oDataOutValid => open,
					
					oFull => open,
					oEmpty => open,
					oAlmostFull => open,
					oAlmostEmpty => open,
					oProgFull => open,
					oProgEmpty => open,
					
					oOverflow => open,
					oUnderflow => open
				);
		end generate;
	end generate;
	
	H6_gen_var : if gH_IS_CONST(6) = '0' generate
		H6_gen_var_shiftreg : if gUSE_BRAM_AS_LARGE_SHIFTREG = false generate
			pipelines_without_reset_inst: pipelines_without_reset
				GENERIC map(
					gBUS_WIDTH => 32, 
					gNB_PIPELINES => 64 * gBASE_DELAY)
				PORT map(
					iClk => iClk,
					iInput => '0',
					oDelayed_output => open,
					ivInput => ivH6,
					ovDelayed_output => svH6
				);
		end generate;
		
		H6_gen_var_bram : if gUSE_BRAM_AS_LARGE_SHIFTREG = true generate
			SyncReset_inst : SyncReset
				port map(
					iClk => iClk,
					iAsyncReset => iRst_async,
					oSyncReset => svResetHShiftFifo_sync(6)
				);

			sync_fifo_infer_inst : sync_fifo_infer
				generic map(
					gADDRESS_WIDTH => 8,
					gDATA_WIDTH => 32
					)
				port map(
					iClk => iClk,
					iReset_sync => svResetHShiftFifo_sync(6),
			
					ivProgFullTh => conv_std_logic_vector(2**8-3, 8),
					ivProgEmptyTh => conv_std_logic_vector(2, 8),
					
					iWrEn => iValid,
					iRdEn => sHShiftFifoRdEn,
					ivDataIn => ivH6,
					ovDataOut => svH6,
					oDataOutValid => open,
					
					oFull => open,
					oEmpty => open,
					oAlmostFull => open,
					oAlmostEmpty => open,
					oProgFull => open,
					oProgEmpty => open,
					
					oOverflow => open,
					oUnderflow => open
				);
		end generate;
	end generate;
	
	H7_gen_var : if gH_IS_CONST(7) = '0' generate
		H7_gen_var_shiftreg : if gUSE_BRAM_AS_LARGE_SHIFTREG = false generate
			pipelines_without_reset_inst: pipelines_without_reset
				GENERIC map(
					gBUS_WIDTH => 32, 
					gNB_PIPELINES => 64 * gBASE_DELAY)
				PORT map(
					iClk => iClk,
					iInput => '0',
					oDelayed_output => open,
					ivInput => ivH7,
					ovDelayed_output => svH7
				);
		end generate;
		
		H7_gen_var_bram : if gUSE_BRAM_AS_LARGE_SHIFTREG = true generate
			SyncReset_inst : SyncReset
				port map(
					iClk => iClk,
					iAsyncReset => iRst_async,
					oSyncReset => svResetHShiftFifo_sync(7)
				);

			sync_fifo_infer_inst : sync_fifo_infer
				generic map(
					gADDRESS_WIDTH => 8,
					gDATA_WIDTH => 32
					)
				port map(
					iClk => iClk,
					iReset_sync => svResetHShiftFifo_sync(7),
			
					ivProgFullTh => conv_std_logic_vector(2**8-3, 8),
					ivProgEmptyTh => conv_std_logic_vector(2, 8),
					
					iWrEn => iValid,
					iRdEn => sHShiftFifoRdEn,
					ivDataIn => ivH7,
					ovDataOut => svH7,
					oDataOutValid => open,
					
					oFull => open,
					oEmpty => open,
					oAlmostFull => open,
					oAlmostEmpty => open,
					oProgFull => open,
					oProgEmpty => open,
					
					oOverflow => open,
					oUnderflow => open
				);
		end generate;
	end generate;

	process (iClk)
	begin
		if rising_edge(iClk) then
			ovH0 <= svAPipe(64) + svH0;
			ovH1 <= svBPipe(64) + svH1;
			ovH2 <= svCPipe(64) + svH2;
			ovH3 <= svDPipe(64) + svH3;
			ovH4 <= svEPipe(64) + svH4;
			ovH5 <= svFPipe(64) + svH5;
			ovH6 <= svGPipe(64) + svH6;
			ovH7 <= svHPipe(64) + svH7;
		end if;
	end process;
	
	OUT_VALID_gen : if gOUT_VALID_GEN = true generate
		pipelines_without_reset_inst: pipelines_without_reset
			GENERIC map(
				gBUS_WIDTH => 1, 
				gNB_PIPELINES => (64 * gBASE_DELAY + 1))
			PORT map(
				iClk => iClk,
				iInput => iValid,
				oDelayed_output => oValid,
				ivInput => (others=>'0'),
				ovDelayed_output => open
			);
	end generate;

end behavioral;

