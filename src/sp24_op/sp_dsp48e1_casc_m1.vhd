-------------------------------------------------------------------------------
--
-- Title       : fp24_dsp48_casc_m1
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     : 
--
-------------------------------------------------------------------------------
--
-- Description : version 1.0
--
-- Multiplier contains 2 DSP48E1 units. Data width: A' = 42, B' = 18, C' = 60;
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--		(c) Copyright 2015 													 
--		Kapitanov.                                          				 
--		All rights reserved.                                                 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package sp_dsp48e1_casc_m1_pkg is
	component sp_dsp48e1_casc_m1 is
		port(
			d_a				: in std_logic_vector(41 downto 0);
			d_b				: in std_logic_vector(17 downto 0);
			d_c				: out std_logic_vector(59 downto 0);
			clk				: in std_logic;
			reset			: in std_logic
		);
	end component;
end package;

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity sp_dsp48e1_casc_m1 is
	port(
			d_a				: in std_logic_vector(41 downto 0);
			d_b				: in std_logic_vector(17 downto 0);
			d_c				: out std_logic_vector(59 downto 0);
			clk				: in std_logic;
			reset			: in std_logic                                                                 
	);
end sp_dsp48e1_casc_m1;

architecture sp_dsp48e1_casc_m1 of sp_dsp48e1_casc_m1 is 
				   	
signal p1, p2, pc 		: std_logic_vector(47 downto 0);
signal rstn 			: std_logic;
signal a1, a2 			: std_logic_vector(29 downto 0); 
signal p_out 			: std_logic_vector(59 downto 0);

begin

a1(29 downto 0) <= "0000000000000" & d_a(16 downto 0); -- CORRECT! 
a2(29 downto 0) <= d_a(41) &  d_a(41) & d_a(41) & d_a(41) & d_a(41) & d_a(41 downto 17);

p_out <= (others => '0') when reset = '0' else p2(42 downto 0) & p1(16 downto 0);
d_c <= p_out; -- when rising_edge(clk);

align_p1: DSP48E1 --   +/-(A*B+Cin)   -- for Virtex-6 families and 7 series 
-- normalize: DSP48E --   +/-(A*B+Cin) -- for Virtex-5	
generic map(
		ACASCREG		=> 1,	
		ADREG			=> 0,		
	--	ALUMODEREG	
		AREG			=> 1,		
	--	AUTORESET_PATDET
	--	A_INPUT		
		BCASCREG		=> 1,	
		BREG			=> 1,		
	--	B_INPUT		
	--	CARRYINREG	
	--	CARRYINSELREG	
	--	CREG		
		DREG			=> 0,		
		INMODEREG		=> 1,	
	--	MASK        
		MREG			=> 1,		
	--	OPMODEREG	
	--	PATTERN     
		PREG			=> 0,		
	--	SEL_MASK	
	--	SEL_PATTERN	
		USE_DPORT		=> FALSE	
	--	USE_MULT		=> "MULTIPLY"
	--	USE_PATTERN_DETECT	
	--	USE_SIMD	
	)		
port map(
--		ACOUT					=> ,
--		BCOUT                   => ,
--		CARRYCASCOUT			=> ,  
--		CARRYOUT				=> ,      
--		MULTSIGNOUT				=> ,   
--		OVERFLOW				=> ,      
        P                       => p2, 
--		PCOUT                   => , 
--		UNDERFLOW				=> ,
        A                       => a2,
		ACIN					=> (others=>'0'),
		ALUMODE					=> (others=>'0'),
        B                       => d_b, 
        BCIN                    => (others=>'0'), 
        C                       => (others=>'0'),
		CARRYCASCIN				=> '0',
        CARRYIN                 => '0', 
        CARRYINSEL              => (others=>'0'),
        CEA1                    => '1',
        CEA2                    => '1', 		
        CEAD                    => '1',
		CEALUMODE               => '1',
		CEB1                    => '1', 
        CEB2                    => '1', 		
        CEC                     => '1', 
        CECARRYIN               => '1', 
        CECTRL                  => '1',
        CED						=> '1',
		CEINMODE				=> '1',
        CEM                     => '1', 
        CEP                     => '1', 
        CLK                     => clk,
		D                       => (others=>'0'),
		INMODE					=> "00000",		-- for DSP48E1 
		MULTSIGNIN				=> '0',                    
        OPMODE                  => "1010101", 		
--       PCIN                    => (others=>'0'),
        PCIN                    => pc,
		RSTA                    => rstn,
		RSTALLCARRYIN			=> rstn,
		RSTALUMODE   			=> rstn,
        RSTB                    => rstn, 
        RSTC                    => rstn, 
        RSTCTRL                 => rstn,
		RSTD					=> rstn,
		RSTINMODE				=> rstn,
        RSTM                    => rstn, 
        RSTP                    => rstn 
	);	  

align_p2: DSP48E1 --   +/-(A*B+Cin)   -- for Virtex-6 families and 7 series 
-- normalize: DSP48E --   +/-(A*B+Cin) -- for Virtex-5	
generic map(
		ACASCREG		=> 1,	
		ADREG			=> 0,		
	--	ALUMODEREG	
		AREG			=> 1,		
	--	AUTORESET_PATDET
	--	A_INPUT		
		BCASCREG		=> 1,	
		BREG			=> 1,		
	--	B_INPUT		
	--	CARRYINREG	
	--	CARRYINSELREG	
	--	CREG		
		DREG			=> 0,		
		INMODEREG		=> 1,	
	--	MASK        
		MREG			=> 0,		
	--	OPMODEREG	
	--	PATTERN     
		PREG			=> 1,		
	--	SEL_MASK	
	--	SEL_PATTERN	
		USE_DPORT		=> FALSE,	
		USE_MULT		=> "MULTIPLY"	
	--	USE_PATTERN_DETECT	
	--	USE_SIMD	
	)		
port map(
--		ACOUT					=> ,
--		BCOUT                   => ,
--		CARRYCASCOUT			=> ,  
--		CARRYOUT				=> ,      
--		MULTSIGNOUT				=> ,   
--		OVERFLOW				=> ,      
        P                       => p1, 
		PCOUT                   => pc, 
--		UNDERFLOW				=> ,
        A                       => a1,
		ACIN					=> (others=>'0'),
		ALUMODE					=> (others=>'0'),
        B                       => d_b, 
        BCIN                    => (others=>'0'), 
        C                       => (others=>'0'),
		CARRYCASCIN				=> '0',
        CARRYIN                 => '0', 
        CARRYINSEL              => (others=>'0'),
        CEA1                    => '1',
        CEA2                    => '1', 		
        CEAD                    => '1',
		CEALUMODE               => '1',
		CEB1                    => '1', 
        CEB2                    => '1', 		
        CEC                     => '1', 
        CECARRYIN               => '1', 
        CECTRL                  => '1',
        CED						=> '1',
		CEINMODE				=> '1',
        CEM                     => '1', 
        CEP                     => '1', 
        CLK                     => clk,
		D                       => (others=>'0'),
		INMODE					=> "00000",		-- for DSP48E1 
		MULTSIGNIN				=> '0',                    
        OPMODE                  => "0000101", 		
        PCIN                    => (others=>'0'),--pc, 	
        RSTA                    => rstn,
		RSTALLCARRYIN			=> rstn,
		RSTALUMODE   			=> rstn,
        RSTB                    => rstn, 
        RSTC                    => rstn, 
        RSTCTRL                 => rstn,
		RSTD					=> rstn,
		RSTINMODE				=> rstn,
        RSTM                    => rstn, 
        RSTP                    => rstn 
	);	

rstn <= not reset; 

end sp_dsp48e1_casc_m1;