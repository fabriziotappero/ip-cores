-------------------------------------------------------------------------------
--
-- Title	: 8b/10b Decoder
-- Design	: 10-bit to 8-bit Decoder
-- Project	: 8000 - 8b10b_encdec
-- Author	: Ken Boyette
-- Company	: Critia Computer, Inc.
--
-------------------------------------------------------------------------------
--
-- File			: 8b10b_dec.vhd
-- Version		: 1.0
-- Generated	: 09.27.2006
-- By			: Itf2Vhdl ver. 1.20
--
-------------------------------------------------------------------------------
--
-- Description :
--	This module provides 10-bit to 9-bit encoding.
--	It accepts 10-bit encoded parallel data input and generates 8-bit decoded 
--	data output in accordance with the 8b/10b standard method.  This method was
--	described in the 1983 IBM publication "A DC-Balanced, Partitioned-Block, 
--	8B/10B Transmission Code" by A.X. Widmer and P.A. Franaszek.  The method
--	WAS granted a U.S. Patent #4,486,739 in 1984; now expired.
--
--		The parallel 10-bit Binary input represent 1024 possible values, called
--		characters - only 268 of which are valid.
--
--		The	input is a 10-bit encoded character whose bits are identified as:
--			AI, BI, CI, DI, EI, II, FI, GI, HI, JI (Least Significant to Most)
--
--		In addition to 256 data output characters, there are 12 special control
--		or K, characters defined for command and synchronization use.
--
--		The eight data output bits are identified as:
--			HI, GI, FI, EI, DI, CI, BI, AI (Most Significant to Least)
--
--		The output, KO, is used to indicate the output value is one of the
--		control characters.
--
--		All inputs and outputs are synchronous with an externally supplied
--		byte rate clock BYTECLK.
--		The encoded output is valid one clock after the input.
--		There is a reset input, RESET, to reset the logic.  The next rising
--		BYTECLK after RESET is deasserted latches valid input data.
--
--		Note: This VHDL structure closely follows the discrete logic defined
--		in the original article and the subsequent patent.  The Figures 
--		referenced are those in the patent.
-------------------------------------------------------------------------------
--	This program is licensed under the GPL
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity dec_8b10b is	
    port(
		RESET : in std_logic ;	-- Global asynchronous reset (AH) 
		RBYTECLK : in std_logic ;	-- Master synchronous receive byte clock
		AI, BI, CI, DI, EI, II : in std_logic ;
		FI, GI, HI, JI : in std_logic ; -- Encoded input (LS..MS)		
		KO : out std_logic ;	-- Control (K) character indicator (AH)
		HO, GO, FO, EO, DO, CO, BO, AO : out std_logic 	-- Decoded out (MS..LS)
	    );
end dec_8b10b;

architecture behavioral of dec_8b10b is

-- Signals to tie things together
	signal ANEB, CNED, EEI, P13, P22, P31 : std_logic ;	-- Figure 10 Signals
	signal IKA, IKB, IKC : std_logic ;	-- Figure 11 Signals
	signal XA, XB, XC, XD, XE : std_logic ;	-- Figure 12 Signals	
	signal OR121, OR122, OR123, OR124, OR125, OR126, OR127 : std_logic ;
	signal XF, XG, XH : std_logic ;	-- Figure 13 Signals
	signal OR131, OR132, OR133, OR134, IOR134 : std_logic ;

begin

	--
	-- 6b Input Function (Reference: Figure 10)
	--
	
	-- One 1 and three 0's
	P13 <=	(ANEB and (not CI and not DI))
			or (CNED and (not AI and not BI)) ;
	-- Three 1's and one 0		
	P31 <=	(ANEB and CI and DI)
			or (CNED and AI and BI) ;
	-- Two 1's and two 0's
	P22 <=	(AI and BI and (not CI and not DI))
			or (CI and DI and (not AI and not BI))
			or (ANEB and CNED) ;
			
	-- Intermediate term for "AI is Not Equal to BI"
	ANEB <=  AI xor	BI ;
	
	-- Intermediate term for "CI is Not Equal to DI"
	CNED <=  CI xor	DI ;
	
	-- Intermediate term for "E is Equal to I"
	EEI <= EI xnor II ;
	
	--
	-- K Decoder - Figure 11
	--
	
	-- Intermediate terms
	IKA	<= (CI and DI and EI and II)
		or (not CI and not DI and not EI and not II) ;
	IKB <= P13 and (not EI and II and GI and HI and JI) ;
	IKC <= P31 and (EI and not II and not GI and not HI and not JI) ;
	
	-- PROCESS: KFN; Determine K output
	KFN: process (RESET, RBYTECLK, IKA, IKB, IKC)
	begin
		if RESET = '1' then
			KO <= '0';
		elsif RBYTECLK'event and RBYTECLK = '0' then
			KO <= IKA or IKB or IKC;
		end if;
	end process KFN;
	
	--
	-- 5b Decoder Figure 12
	--
	
	-- Logic to determine complimenting A,B,C,D,E,I inputs
	OR121 <= (P22 and (not AI and not CI and EEI))
		or (P13 and not EI) ;
	OR122 <= (AI and BI and EI and II)
		or (not CI and not DI and not EI and not II)
		or (P31 and II) ;
	OR123 <= (P31 and II)
		or (P22 and BI and CI and EEI)
		or (P13 and DI and EI and II) ;
	OR124 <= (P22 and AI and CI and EEI)
		or (P13 and not EI) ;
	OR125 <= (P13 and not EI)
		or (not CI and not DI and not EI and not II)
		or (not AI and not BI and not EI and not II) ;
	OR126 <= (P22 and not AI and not CI and EEI)
		or (P13 and not II) ;
	OR127 <= (P13 and DI and EI and II)
		or (P22 and not BI and not CI and EEI) ;
	
	XA <= OR127
		or OR121
		or OR122 ;
	XB <= OR122
		or OR123
		or OR124 ;
	XC <= OR121
		or OR123
		or OR125 ;
	XD <= OR122
		or OR124
		or OR127 ;
	XE <= OR125
		or OR126
		or OR127 ; 
	
	-- PROCESS: DEC5B; Generate and latch LS 5 decoded bits
	DEC5B: process (RESET, RBYTECLK, XA, XB, XC, XD, XE, AI, BI, CI, DI, EI)
	begin
		if RESET = '1' then
			AO <= '0' ;
			BO <= '0' ;
			CO <= '0' ;
			DO <= '0' ;
			EO <= '0' ;
		elsif RBYTECLK'event and RBYTECLK = '0' then
			AO <= XA XOR AI ;	-- Least significant bit 0
			BO <= XB XOR BI ;
			CO <= XC XOR CI ;
			DO <= XD XOR DI ;
			EO <= XE XOR EI ;	-- Most significant bit 6
		end if;
	end process DEC5B;
	
	--
	-- 3b Decoder - Figure 13
	--
	
	-- Logic for complimenting F,G,H outputs
	OR131 <= (GI and HI and JI)
		or (FI and HI and JI) 
		or (IOR134);
	OR132 <= (FI and GI and JI)
		or (not FI and not GI and not HI)
		or (not FI and not GI and HI and JI);
	OR133 <= (not FI and not HI and not JI)
		or (IOR134)
		or (not GI and not HI and not JI) ;
	OR134 <= (not GI and not HI and not JI)
		or (FI and HI and JI)
		or (IOR134) ;
	IOR134 <= (not (HI and JI))
		and (not (not HI and not JI))
		and (not CI and not DI and not EI and not II) ;
	
	XF <= OR131
		or OR132 ;
	XG <= OR132 
		or OR133 ;
	XH <= OR132
		or OR134 ;
	
	-- PROCESS: DEC3B; Generate and latch MS 3 decoded bits
	DEC3B: process (RESET, RBYTECLK, XF, XG, XH, FI, GI, HI)
	begin
		if RESET = '1' then
			FO <= '0' ;
			GO <= '0' ;
			HO <= '0' ;
		elsif RBYTECLK'event and RBYTECLK ='0' then
			FO <= XF XOR FI ;	-- Least significant bit 7
			GO <= XG XOR GI ;
			HO <= XH XOR HI ;	-- Most significant bit 10
		end if;
	end process DEC3B ;
				
end behavioral;

