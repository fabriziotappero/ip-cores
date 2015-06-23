-------------------------------------------------------------------------------
--
-- Title	: Test Bench for enc_8b10b and dec_8b10b
-- Design	: 8b-10b Encoder/Decoder Test Bench
-- Project	: 8000 - 8b10b_encdec
-- Author	: Ken Boyette
-- Company	: Critia Computer, Inc.
--
-------------------------------------------------------------------------------
--
-- File			: encdec_8b10b_TB.vhd
-- Version		: 1.0
-- Generated	: 09.25.2006
-- From			: y:\Projects\8000\FPGA\VHDLSource\8b10b\8b10_enc.vhd
-- By			: Active-HDL Built-in Test Bench Generator ver. 1.2s
--
-------------------------------------------------------------------------------
--
-- Description : Test Bench for combined enc_8b10b_tb & dec_8b10b
--
--
--	This testbench provides a sequence of data pattern stimuli for the
--	enc_8b10b component.  It latches the encoded output and provides this
--	as input to the dec_8b10b component.  The test pattern generator
--	alternately drives all data patterns and then the 12 defined K patterns.
--	
-------------------------------------------------------------------------------
-- This program is licensed under the GPL
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity endec_8b10b_tb is
end endec_8b10b_tb;

architecture TB_ARCHITECTURE of endec_8b10b_tb is

	component enc_8b10b
	port(
		RESET : in std_logic;
		SBYTECLK : in std_logic;
		KI : in std_logic;
		AI : in std_logic;
		BI : in std_logic;
		CI : in std_logic;
		DI : in std_logic;
		EI : in std_logic;
		FI : in std_logic;
		GI : in std_logic;
		HI : in std_logic;
		AO : out std_logic;
		BO : out std_logic;
		CO : out std_logic;
		DO : out std_logic;
		EO : out std_logic;
		IO : out std_logic;
		FO : out std_logic;
		GO : out std_logic;
		HO : out std_logic;
		JO : out std_logic
		);
	end component;
	
 	component dec_8b10b
	port(
		RESET : in std_logic;
		RBYTECLK : in std_logic;
		AI : in std_logic;
		BI : in std_logic;
		CI : in std_logic;
		DI : in std_logic;
		EI : in std_logic;
		II : in std_logic;
		FI : in std_logic;
		GI : in std_logic;
		HI : in std_logic;
		JI : in std_logic;
		AO : out std_logic;
		BO : out std_logic;
		CO : out std_logic;
		DO : out std_logic;
		EO : out std_logic;
		FO : out std_logic;
		GO : out std_logic;
		HO : out std_logic;
		KO : out std_logic
		);
	end component;
   
	-- Special character code values
	constant K28d0 : std_logic_vector := "00011100"; -- Balanced
	constant K28d1 : std_logic_vector := "00111100"; -- Unbalanced comma
	constant K28d2 : std_logic_vector := "01011100"; -- Unbalanced
	constant K28d3 : std_logic_vector := "01111100"; -- Unbalanced
	constant K28d4 : std_logic_vector := "10011100"; -- Balanced
	constant K28d5 : std_logic_vector := "10111100"; -- Unbalanced comma
	constant K28d6 : std_logic_vector := "11011100"; -- Unbalanced
	constant K28d7 : std_logic_vector := "11111100"; -- Balanced comma
	constant K23d7 : std_logic_vector := "11110111"; -- Balanced
	constant K27d7 : std_logic_vector := "11111011"; -- Balanced
	constant K29d7 : std_logic_vector := "11111101"; -- Balanced
	constant K30d7 : std_logic_vector := "11111110"; -- Balanced
	
	-- Stimulus signals - mapped to the input  of enc_8b10b
	signal TRESET : std_logic;
	signal TBYTECLK : std_logic;
	signal TKO : std_logic;
	signal TAO : std_logic;
	signal TBO : std_logic;
	signal TCO : std_logic;
	signal TDO : std_logic;
	signal TEO : std_logic;
	signal TFO : std_logic;
	signal TGO : std_logic;
	signal THO : std_logic;
	
	-- Observed signals - mapped from output of enc_8b10b
	signal TA : std_logic;
	signal TB : std_logic;
	signal TC : std_logic;
	signal TD : std_logic;
	signal TE : std_logic;
	signal TF : std_logic;
	signal TI : std_logic;
	signal TG : std_logic;
	signal TH : std_logic;
	signal TJ : std_logic;
	
	-- Observed signals - mapped from output of dec_8b10b
	signal TDA : std_logic;
	signal TDB : std_logic;
	signal TDC : std_logic;
	signal TDD : std_logic;
	signal TDE : std_logic;
	signal TDF : std_logic;
	signal TDG : std_logic;
	signal TDH : std_logic;
	signal TDK : std_logic;
	
	-- Signals for TestBench control functions
	signal tchar : std_logic_vector (7 downto 0) ;		-- All character vector
	signal kcounter : std_logic_vector (3 downto 0) ;	-- K character counter
	signal dcounter : std_logic_vector (7 downto 0) ;	-- D value counter
	signal tcharout, tlcharout : std_logic_vector (9 downto 0) ;	-- Character output vector
	signal tclken : std_logic ; -- Enables clock after short delay starting up
	signal tcnten : std_logic ; -- Enables count after 1 cycle
	signal tks : std_logic ; -- Use to select control function of encoder
	signal dk : std_logic ;	-- '0' if D, '1' if K
	signal tdec : std_logic_vector (7 downto 0) ;	-- Decoder output monitor
	signal tdeck : std_logic ; -- Decoder K output monitor
begin
	---------------------------------------------------------------------------
	-- Instantiate modules
	---------------------------------------------------------------------------
	encoder : enc_8b10b 
		port map (
			RESET => TRESET,
			SBYTECLK => TBYTECLK,
			KI => TKO,
			AI => TAO,
			BI => TBO,
			CI => TCO,
			DI => TDO,
			EI => TEO,
			FI => TFO,
			GI => TGO,
			HI => THO,
			AO => TA,
			BO => TB,
			CO => TC,
			DO => TD,
			EO => TE,
			IO => TI,
			FO => TF,
			GO => TG,
			HO => TH,
			JO => TJ
		);
	decoder : dec_8b10b 
		port map (
			RESET => TRESET,
			RBYTECLK => TBYTECLK,
			AI => tlcharout(0),	-- Note: Use the latched encoded data
			BI => tlcharout(1),
			CI => tlcharout(2),
			DI => tlcharout(3),
			EI => tlcharout(4),
			II => tlcharout(5),
			FI => tlcharout(6),
			GI => tlcharout(7),
			HI => tlcharout(8),
			JI => tlcharout(9),
			AO => TDA,
			BO => TDB,
			CO => TDC,
			DO => TDD,
			EO => TDE,
			FO => TDF,
			GO => TDG,
			HO => TDH,
			KO => TDK
		);
		
TRESET <= '1', '0' after 200 ns ; -- Start with a valid reset for 100ns
tclken <= '0', '1' after 10 ns ; -- Start clock with valid state, then 10MHz

process (TBYTECLK, tclken)
begin
	If (tclken = '0') then 
		TBYTECLK <= '0';
	else TBYTECLK <= (not TBYTECLK) after 50 ns ;	-- Generate 10MHz byte clock
	end if;
end process ;

process (TRESET, TBYTECLK)
begin
	if (TRESET = '1') then	-- Delay count 1 cycle 
		tcnten <= '0' ;
	elsif (TBYTECLK'event and TBYTECLK = '0') then
		tcnten <= '1' ;
	end if ;
end process ;

process (TRESET, TBYTECLK, tks, tcnten, kcounter, dcounter, tchar)
begin
	if (TRESET = '1') then
		tchar <= "00000000" ;
		tks <= '1' ; -- Set for K initially
		dk <= '0' ;
		kcounter <= "0000" ; -- Preset K counter
		dcounter <= "00000000" ;	-- Preset D counter
	elsif (TBYTECLK'event and TBYTECLK = '1') then
		dk <= tks ;
		if tks = '1' then	-- Output K characters
			kcounter <= kcounter + tcnten ;	-- Increment counter
			dcounter <= "00000000" ;
			case kcounter is
				when "0000" => tchar <= K28d0 ;
				when "0001" => tchar <= K28d1 ;
				when "0010" => tchar <= K28d2 ;
				when "0011" => tchar <= K28d3 ;
				when "0100" => tchar <= K28d4 ;
				when "0101" => tchar <= K28d5 ;
				when "0110" => tchar <= K28d6 ;
				when "0111" => tchar <= K28d7 ;
				when "1000" => tchar <= K23d7 ;
				when "1001" => tchar <= K27d7 ;
				when "1010" => tchar <= K29d7 ;
				when "1011" => tchar <= K30d7 ;
					tks <= '0' ;	-- Switch to D output
				when "1100" => tchar <= "00000000" ;
				when others => tchar(7 downto 0) <= K28d5 ; 
			end case;
		else dcounter <= dcounter + tcnten ;	-- Output D values
			tchar <= dcounter ;
			if dcounter = "11111111" then
				tks <= '1' ;	-- Repeat K portion
				kcounter <= "0000" ; -- Reset K counter
			end if;
		end if ;
	end if;
end process ;

-- Latch encoder output each rising edge for simulation and input into decoder
process (TBYTECLK)
begin
	if (TBYTECLK'event and TBYTECLK = '1') then
		tlcharout(0) <= TA;
		tlcharout(1) <= TB;
		tlcharout(2) <= TC;
		tlcharout(3) <= TD;
		tlcharout(4) <= TE;
		tlcharout(5) <= TI;
		tlcharout(6) <= TF;
		tlcharout(7) <= TG;
		tlcharout(8) <= TH;
		tlcharout(9) <= TJ;
	end if;
end process ;

-- Connect our test values to the encoder inputs
TAO <= tchar(0);
TBO <= tchar(1);
TCO <= tchar(2);
TDO <= tchar(3);
TEO <= tchar(4);
TFO <= tchar(5);
TGO <= tchar(6);
THO <= tchar(7);
TKO <= dk;

-- Monitor encoder output
tcharout(0) <= TA;
tcharout(1) <= TB;
tcharout(2) <= TC;
tcharout(3) <= TD;
tcharout(4) <= TE;
tcharout(5) <= TI;
tcharout(6) <= TF;
tcharout(7) <= TG;
tcharout(8) <= TH;
tcharout(9) <= TJ;

-- Monitor decoder output
tdec(0) <= TDA;
tdec(1) <= TDB;
tdec(2) <= TDC;
tdec(3) <= TDD;
tdec(4) <= TDE;
tdec(5) <= TDF;
tdec(6) <= TDG;
tdec(7) <= TDH;
tdeck <= TDK;

end TB_ARCHITECTURE;


