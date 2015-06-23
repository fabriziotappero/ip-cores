--------------------------------------------------------------------------------
--
-- Title       : fp24_mult_m2
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     :
--
-------------------------------------------------------------------------------
--
-- Description : version 2.0 
--
-------------------------------------------------------------------------------
--
--	Version 1.0  22.02.2013
--			   	 Description:
--				  Multiplier for FP
--				  4 clock cycles
--
--
--	Version 1.1  15.01.2014
--			   	 Description:
--				  5 clock cycles	
--	
--	Version 2.0  24.03.2015
--			   	 Description:
--					Deleted din_en signal
--					This version is fully pipelined !!!
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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library unisim;
use unisim.vcomponents.all;
use work.sp_addsub_m1_pkg.all;
use work.sp_int2str_pkg.all;

entity fp24_mult_m2 is
	port(
		aa 		: in std_logic_vector(23 downto 0);
		bb 		: in std_logic_vector(23 downto 0);
		cc 		: out std_logic_vector(23 downto 0);
		enable 	: in std_logic;
		valid	: out std_logic;
		reset  	: in std_logic;
		clk 	: in std_logic	
	);	
end fp24_mult_m2;

architecture fp24_mult_m2 of fp24_mult_m2 is 

type std_logic_array_4x6 is array(3 downto 0) of std_logic_vector(5 downto 0);

signal rstn		: std_logic;   
signal man_aa	: std_logic_vector(29 downto 0);
signal man_bb	: std_logic_vector(17 downto 0);

signal exp_cc 	: std_logic_vector(6 downto 0);
signal exp_ccz	: std_logic_vector(6 downto 0);
signal exp_cczz	: std_logic_vector(6 downto 0);
signal exp_dec  : std_logic_vector(6 downto 0);

signal sig_cc 	: std_logic;
signal man_cc	: std_logic_vector(15 downto 0);
signal prod		: std_logic_vector(47 downto 0);

signal sig_ccz	: std_logic_vector(3 downto 0);

signal exp_underflow : std_logic;
signal exp_underflowz : std_logic;
---------------------------------------

signal exp_ab		: std_logic_vector(15 downto 0);
signal orab			: std_logic_vector(3 downto 0);
signal orabz		: std_logic_vector(3 downto 0);
signal exp_zero 	: std_logic;
signal exp_zeroz	: std_logic;
signal exp_zerozz	: std_logic;

attribute BEL		: string;
attribute RLOC		: string;

attribute RLOC of lut_zero	: label is "X1Y0"; 
attribute RLOC of fdr_zero	: label is "X1Y0";	

signal enaz			: std_logic_vector(3 downto 0);

begin
	
enaz <= enaz(2 downto 0) & enable after 1 ns when rising_edge(clk);	
	
exp_ab <= '0' & bb(23 downto 17) & '0' & aa(23 downto 17);

for_fd: for ii in 0 to 3 generate	-- CHECKING EXP ZERO MULTIPLIER
 
type str_array is array (3 downto 0) of string(1 downto 1);	
constant str : str_array:=(0=>"A", 1=>"B", 2=>"C",3=>"D"); 
attribute BEL of lut_ab		: label is str(ii) & "6LUT";
attribute BEL of fdr_ab		: label is "FF" & str(ii);
attribute RLOC of lut_ab	: label is "X0Y0"; 
attribute RLOC of fdr_ab	: label is "X0Y0";	

begin
	lut_ab: LUT4	-- LOGIC OR OF EXP(A) & EXP(B) 
	generic map(INIT => X"FFFE")--X"FFFFFFFE")
	port map(
		I0 => exp_ab(0+ii*4), 
		I1 => exp_ab(1+ii*4), 
		I2 => exp_ab(2+ii*4), 
		I3 => exp_ab(3+ii*4),
		--I4 => exp_ab(4+ii*5),
		O  => orab(ii) 
	); 
	fdr_ab: FDRE 
	generic map(INIT => '0')
	port map
	(
		Q 	=> orabz(ii),
		C   => clk, 
		R 	=> rstn,
		CE	=> enable,
		D   => orab(ii) 
	);
end generate;
	
lut_zero: LUT4 	 -- BIG AND EQUATION; FIND ZERO EXP: PARTIAL CONDITION "00" & "00"
generic map(INIT => X"EEE0")
port map(
	I0 => orabz(0), 
	I1 => orabz(1), 
	I2 => orabz(2), 
	I3 => orabz(3),
	--	I3 => '0',	-- ZERO???
	O  => exp_zero 
); 

fdr_zero: FDRE 
generic map(INIT => '0')
port map
(
	Q 	=> exp_zeroz,
	C   => clk,
	CE  => enaz(0),
	R 	=> rstn,
	D   => exp_zero 
);	
	
exp_zerozz <= exp_zeroz when rising_edge(clk);

rstn <= not reset;

man_aa(29 downto 18) <= x"000";
man_aa(17 downto 0) <= "01" & aa(15 downto 0);	
man_bb <= "01" & bb(15 downto 0);

normalize: DSP48E1 --   +/-(A*B+Cin)   -- for Virtex-6 and 7 families
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
	--	MREG		
	--	OPMODEREG	
	--	PATTERN     
	--	PREG		
	--	SEL_MASK	
	--	SEL_PATTERN	
		USE_DPORT		=> FALSE	
	--	USE_MULT	
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
        P                       => prod, 
--		PCOUT                   => , 
--		UNDERFLOW				=> ,
        A                       => man_aa,
		ACIN					=> (others=>'0'),
		ALUMODE					=> (others=>'0'),
        B                       => man_bb, 
        BCIN                    => (others=>'0'), 
        C                       => (others=>'0'),
		CARRYCASCIN				=> '0',
        CARRYIN                 => '0', 
        CARRYINSEL              => (others=>'0'),
        CEA1                    => enable,--enable, -- '1'
        CEA2                    => '1',--enable, 		
        CEAD                    => '1',
		CEALUMODE               => '1',
		CEB1                    => enable,--enable,-- '1' 
        CEB2                    => '1',--enable, 		
        CEC                     => '0', 
        CECARRYIN               => '0', 
        CECTRL                  => '1',
        CED						=> '1',
		CEINMODE				=> '1',
        CEM                     => enaz(0), -- '1'
        CEP                     => enaz(1),--'1',--enaz(1), 
        CLK                     => clk,
		D                       => (others=>'0'),
		INMODE					=> "00000",		-- for DSP48E1 
		MULTSIGNIN				=> '0',                    
        OPMODE                  => "0000101", 		
        PCIN                    => (others=>'0'), 	
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
	
exp_subtr: sp_addsub_m1
	generic map(N => 6)
	port map(
	data_a 	=> aa(23 downto 17), 
	data_b 	=> bb(23 downto 17), 
	data_c 	=> exp_cc, 		
	add_sub	=> '1', 				
	cin     => '0', 	
	--cout    => ,	
	clk    	=> clk, 				
	ce 		=> enable, 								
	aclr  	=> rstn 				
	);								  
	
exp_ccz <= exp_cc when rising_edge(clk);
exp_cczz <= exp_ccz when rising_edge(clk);

exp_decr: sp_addsub_m1 	-- "0000001111" = FOR NORMAL MULTIPLICATION,  "0000011111", = FOR FFT64K
	generic map(N => 6)
	port map(
	data_a 	=> exp_cczz, --exp_cc, 
	data_b 	=> "0011111",--"0000011111", "0000100000" -- ATTENTION! IF THIS FIELD AREN'T GOOD - YOU CAN'T GET FFT!! --"0000001111",---"0000001111", -- (exp - 16) 
	data_c 	=> exp_dec, 		
	add_sub	=> '0', 				
	cin     => prod(33),--'0',--not prod(33),--'0',--'0',--prod(32), 	
	cout    => exp_underflow,	
	clk    	=> clk, 				
	ce 		=> enaz(2), 				 				
	aclr  	=> rstn 				
	);

--sig_cc <= aa(16) xor bb(16) when rising_edge(clk);		

pr_sig_cc: process(clk, reset) is
begin
	if reset = '0' then
		sig_cc <= '0';	
	elsif rising_edge(clk) then
		if enable = '1' then
			sig_cc <= aa(16) xor bb(16) after 1 ns;
		else 
			null;
		end if;
	end if;
end process;

pr_sig_del: process(clk, reset) is
begin
	if reset = '0' then
		sig_ccz <= (others => '0');		
	elsif rising_edge(clk) then
		sig_ccz(0) <= sig_cc after 1 ns;
		for ii in 0 to 2 loop
			sig_ccz(ii+1) <= sig_ccz(ii) after 1 ns;
		end loop;	
	end if;
end process;

pr_man_cc: process(clk, reset) is
begin
	if reset = '0' then
		man_cc	<= (others=>'0');
	elsif rising_edge(clk) then
		if prod(33) = '0' then
			man_cc <= prod(31 downto 16); --man_cc<=prod(32 downto 21);
		else
			man_cc <= prod(32 downto 17);
		end if;
	end if;
end process;

--cc<=exp_deczz & sig_ccz(2) & man_cc(10 downto 0);	
pr_mult_out: process(clk, reset) is
begin 	
	if reset = '0' then
		cc <= (others => '0');
		exp_underflowz <= '0';
	elsif rising_edge(clk) then
		exp_underflowz <= exp_underflow and exp_zerozz;
		if enaz(3) = '1' then
			if exp_underflowz = '0' then
				cc <= (others=>'0') after 1 ns;
			else
				cc <= exp_dec & sig_ccz(2) & man_cc(15 downto 0) after 1 ns;
			end if;
		else
			null;
		end if;
	end if;
end process;	

valid <= enaz(3) after 1 ns when rising_edge(clk);

end fp24_mult_m2;
