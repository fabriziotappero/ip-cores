-------------------------------------------------------------------------------
--
-- Title	: 8b/10b Encoder
-- Design	: 8-bit to 10-bit Encoder
-- Project	: 8000 - 8b10b_encdec
-- Author	: Ken Boyette
-- Company	: Critia Computer, Inc.
--
-------------------------------------------------------------------------------
--
-- File			: 8b10b_enc.vhd
-- Version		: 1.0
-- Generated	: 09.15.2006
-- By			: Itf2Vhdl ver. 1.20
--
-------------------------------------------------------------------------------
--
-- Description :
--	This module provides 8-bit to 10-bit encoding.
--	It accepts 8-bit parallel data input and generates 10-bit encoded data
--	output in accordance with the 8b/10b standard.  This coding method was
--	described in the 1983 IBM publication "A DC-Balanced, Partitioned-Block,
--	8B/10B Transmission Code" by A.X. Widmer and P.A. Franaszek and was granted
--	a U.S. Patent #4,486,739 in 1984 which has now expired.
--
--		The parallel 8-bit Binary input represent 256 possible values, called
--		characters.
--		The bits are identified as:
--			HI, GI, FI, EI, DI, CI, BI, AI (Most Significant to Least)
--		The	output is a 10-bit encoded character whose bits are identified as:
--			AO, BO, CO, DO, EO, IO, FO, GO, HO, AJO (Least Significant to Most)
--		An additional 12 output characters, K, are defined for command and
--		synchronization use.
--		KI, is used to indicate that the input is for a special character.
--		All inputs and outputs are synchronous with an externally supplied
--		byte rate clock BYTECLK.
--		The encoded output is valid one clock after the input.
--		There is a reset input, RESET, to reset the logic.  The next rising 
--		BYTECLK after RESET is deasserted latches valid input data.
--
--		Note: This VHDL structure closely follows the discrete logic defined 
--		in the original article and the subsequent patent.
--		The Figures referenced are those in the patent.
-------------------------------------------------------------------------------
--		This program is licensed under the GPL.
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity enc_8b10b is	
    port(
		RESET : in std_logic ;		-- Global asynchronous reset (active high) 
		SBYTECLK : in std_logic ;	-- Master synchronous send byte clock
		KI : in std_logic ;			-- Control (K) input(active high)
		AI, BI, CI, DI, EI, FI, GI, HI : in std_logic ;	-- Unencoded input data
		JO, HO, GO, FO, IO, EO, DO, CO, BO, AO : out std_logic 	-- Encoded out 
	    );
end enc_8b10b;

architecture behavioral of enc_8b10b is

-- Signals to tie things together
	signal XLRESET, LRESET : std_logic ; -- Local synchronized RESET
	signal L40, L04, L13, L31, L22 : std_logic ;	-- Figure 3 Signals
	signal F4, G4, H4, K4, S, FNEG : std_logic ;	-- Figure 4 Signals 
	signal PD1S6, ND1S6, PD0S6, ND0S6 : std_logic ;	-- Figure 5 Signals 
	signal ND1S4, ND0S4, PD1S4, PD0S4 : std_logic ;	-- ...Figure 5
	signal COMPLS4, COMPLS6, NDL6 : std_logic ;	-- Figure 6 Signals 
	signal PDL6, LPDL6, PDL4, LPDL4 : std_logic ;	-- Figure 6
	signal NAO, NBO, NCO, NDO, NEO, NIO : std_logic ;	-- Figure 7 Signals
	signal NFO, NGO, NHO, NJO, SINT : std_logic ;	-- Figure 8

begin

	-- PROCESS: SYNCRST; Synchronize and delay RESET one clock for startup

	SYNCRST: process (RESET, XLRESET, SBYTECLK)
	begin
		if SBYTECLK'event and SBYTECLK = '1' then
			XLRESET <= RESET ;
		elsif SBYTECLK'event and SBYTECLK = '0' then
			LRESET <= XLRESET ;
		end if ;
	end process SYNCRST ;

	--
	-- 5b Input Function (Reference: Figure 3)
	--
	
	-- Four 1's
	L40 <= 	AI and BI and CI and DI ;					-- 1,1,1,1
	-- Four 0's
	L04 <= 	not AI and not BI and not CI and not DI ;	-- 0,0,0,0
	-- One 1 and three 0's
	L13 <=	(not AI and not BI and not CI and DI)		-- 0,0,0,1
			or (not AI and not BI and CI and not DI)	-- 0,0,1,0		
			or (not AI and BI and not CI and not DI)	-- 0,1,0,0
			or (AI and not BI and not CI and not DI) ;	-- 1,0,0,0
	-- Three 1's and one 0		
	L31 <=	(AI and BI and CI and not DI)			-- 1,1,1,0	
			or (AI and BI and not CI and DI)		-- 1,1,0,1
			or (AI and not BI and CI and DI)		-- 1,0,1,1
			or (not AI and BI and CI and DI) ;		-- 0,1,1,1
	-- Two 1's and two 0's
	L22 <=	(not AI and not BI and CI and DI)		-- 0,0,1,1
			or (not AI and BI and CI and not DI)	-- 0,1,1,0
			or (AI and BI and not CI and not DI)	-- 1,1,0,0
			or (AI and not BI and not CI and DI)	-- 1,0,0,1
			or (not AI and BI and not CI and DI)	-- 0,1,0,1
			or (AI and not BI and CI and not DI) ;	-- 1,0,1,0

	--
    -- 3b Input Function (Reference: Figure 4)
	--
	
	-- PROCESS: FN3B; Latch 3b and K inputs
    FN3B: process (SBYTECLK, FI, GI, HI, KI)
    begin	-- Falling edge of clock latches F,G,H,K inputs
    	if SBYTECLK'event and SBYTECLK = '0' then
        	F4 <= FI ;
        	G4 <= GI ;
			H4 <= HI ;
			K4 <= KI ;
    	end if;
    end process FN3B;
	
	-- PROCESS: FNS; Create and latch "S" function
	FNS: process (LRESET, SBYTECLK, PDL6, L31, DI, EI, NDL6, L13)
	begin
		if LRESET = '1' then
			S <= '0' ;
		elsif SBYTECLK'event and SBYTECLK = '1' then
			S <= (PDL6 and L31 and DI and not EI)
			or (NDL6 and L13 and EI and not DI) ;	
		end if;
	end process FNS ;
	
	-- Intermediate term for "F4 is Not Equal to G4"
	FNEG	<=  F4 xor	G4 ;
	
	--
	-- Disparity Control - Figure 5
	--
	
	PD1S6 <= (not L22 and not L31 and not EI)
		or (L13 and DI and EI) ;
	
	ND1S6 <= (L31 and not DI and not EI)
		or (EI and not L22 and not L13)
		or K4 ;
	
	PD0S6 <= (not L22 and not L13 and EI)
		or K4 ;
	
	ND0S6 <= (not L22 and not L31 and not EI)
		or (L13 and DI and EI) ;
	
	ND1S4 <= (F4 and G4);
	
	ND0S4 <= (not F4 and not G4);
	
	PD1S4 <= (not F4 and not G4)
		or (FNEG and K4) ;
	
	PD0S4 <= (F4 and G4 and H4) ;
		
	--
	-- Disparity Control - Figure 6
	--
	
	PDL6 <= (PD0S6 and not COMPLS6)
			or (COMPLS6 and ND0S6)
			or (not ND0S6 and not PD0S6 and LPDL4) ;
			
	NDL6 <= not PDL6 ;
			
	PDL4 <= (LPDL6 and not PD0S4 and not ND0S4)
			or (ND0S4 and COMPLS4)
			or (not COMPLS4 and PD0S4) ;
	
	-- PROCESS: CMPLS4; Disparity determines complimenting S4
	CMPLS4: process (LRESET, SBYTECLK, PDL6)
    begin
		if LRESET = '1' then
			LPDL6 <= '0' ;
    	elsif SBYTECLK'event and SBYTECLK = '1' then	-- Rising edge
			LPDL6 <= PDL6 ; 							-- .. latches S4
    	end if;
    end process CMPLS4 ;
	
	COMPLS4 <= (PD1S4 and not LPDL6)
			xor (ND1S4 and LPDL6) ;

    -- PROCESS: CMPLS6; Disparity determines complimenting S6
	CMPLS6: process (LRESET, SBYTECLK, PDL4)
    begin
		if LRESET = '1' then
			LPDL4 <= '0' ;
    	elsif SBYTECLK'event and SBYTECLK = '0' then  	-- Falling edge
        	LPDL4 <= PDL4 ;           					-- .. latches S6
		end if;
    end process CMPLS6;
	
	COMPLS6 <= (ND1S6 and LPDL4) 
			xor (PD1S6 and not LPDL4) ;
	
	--
	-- 5b/6b Encoder - Figure 7
	--
	
	-- Logic for non-complimented (Normal) A,B,C,D,E,I outputs
	NAO <= AI ;
	NBO <= L04
		or (BI and not L40) ;
	NCO <= CI
		or L04
		or (L13 and DI and EI) ;
	NDO <= (DI and not L40) ;
	NEO <= (EI and not (L13 and DI and EI))
		or (L13 and not EI) ; 
	NIO <= (L22 and not EI)
		or (L04 and EI)
		or (L13 and not DI and EI)
		or (L40 and EI) 
		or (L22 and KI) ;
	
	-- PROCESS: ENC5B6B; Generate and latch LS 6 encoded bits
	ENC5B6B: process (LRESET, SBYTECLK, COMPLS6, NAO, NBO, NCO, NDO, NEO, NIO)
	begin
		if LRESET = '1' then
			AO <= '0' ;
			BO <= '0' ;
			CO <= '0' ;
			DO <= '0' ;
			EO <= '0' ;
			IO <= '0' ;
		elsif SBYTECLK'event and SBYTECLK = '1' then
			AO <= COMPLS6 XOR NAO ;	-- Least significant bit 0
			BO <= COMPLS6 XOR NBO ;
			CO <= COMPLS6 XOR NCO ;
			DO <= COMPLS6 XOR NDO ;
			EO <= COMPLS6 XOR NEO ;
			IO <= COMPLS6 XOR NIO ;	-- Most significant bit 6
		end if;
	end process ENC5B6B;
	
	--
	-- 3b/4b Encoder - Figure 8
	--
	
	-- Logic for the non-complimented F,G,H,J outputs
	SINT <= (S and F4 and G4 and H4)
		or (K4 and F4 and G4 and H4) ;
	NFO <= (F4 and not SINT) ;
	NGO <= G4 
		or (not F4 and not G4 and not H4) ;
	NHO <= H4 ;
	NJO <= SINT
		or (FNEG and not H4) ;
	
	-- PROCESS: ENC3B4B; Generate and latch MS 4 encoded bits
	ENC3B4B: process (LRESET, SBYTECLK, COMPLS4, NFO, NGO, NHO, NJO)
	begin
		if LRESET = '1' then
			FO <= '0' ;
			GO <= '0' ;
			HO <= '0' ;
			JO <= '0' ;
		elsif SBYTECLK'event and SBYTECLK ='0' then
			FO <= COMPLS4 XOR NFO ;	-- Least significant bit 7
			GO <= COMPLS4 XOR NGO ;
			HO <= COMPLS4 XOR NHO ;
			JO <= COMPLS4 XOR NJO ;	-- Most significant bit 10
		end if;
	end process ENC3B4B ;
				
end behavioral;

