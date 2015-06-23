-------------------------------------------------------------------------------
--
-- Title       : fp24_sub_m2
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     :
--
-- Description : FP adder, width = 27
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library unisim;
use unisim.vcomponents.all;

use work.sp_addsub_m1_pkg.all;
use work.sp_msb_decoder_m2_pkg.all;

entity fp24_sub_m2 is
	port(
		aa 		: in std_logic_vector(23 downto 0);
		bb 		: in std_logic_vector(23 downto 0);
		cc 		: out std_logic_vector(23 downto 0);
		enable 	: in std_logic;
		valid	: out std_logic;
		reset  	: in std_logic;
		clk 	: in std_logic	
	);
end fp24_sub_m2;

architecture fp24_sub_m2 of fp24_sub_m2 is 

type std_logic_array_9x7 is array (8 downto 0) of std_logic_vector(6 downto 0);
type std_logic_array_5x16 is array (4 downto 0) of std_logic_vector(16 downto 0);

signal rstn				: std_logic; 

signal aa_z			   	: std_logic_vector(23 downto 0);	  
signal bb_z				: std_logic_vector(23 downto 0);
signal aatr				: std_logic_vector(22 downto 0);
signal bbtr				: std_logic_vector(22 downto 0);
signal muxa             : std_logic_vector(23 downto 0);
signal muxb             : std_logic_vector(23 downto 0);
signal muxaz            : std_logic_vector(23 downto 0);
signal muxbz            : std_logic_vector(15 downto 0);

signal exp_dif			: std_logic_vector(6 downto 0);

signal implied_a		: std_logic;
signal implied_b		: std_logic; 

signal man_a			: std_logic_vector(47 downto 0);
signal man_b			: std_logic_vector(29 downto 0);

signal man_az			: std_logic_vector(16 downto 0);
signal subtract         : std_logic_vector(2 downto 0);

signal sh_mask_aligne	: std_logic_vector(31 downto 0);
signal sh_mask_align	: std_logic_vector(31 downto 0);
signal sh_mask_alignx	: std_logic_vector(17 downto 0);

signal sum_man		    : std_logic_vector(47 downto 0);
signal sum_manz			: std_logic_array_5x16;

signal msb_dec			: std_logic_vector(31 downto 0);
signal msb_num			: std_logic_vector(4 downto 0);
signal msb_numn			: std_logic_vector(6 downto 0);

signal sh_mask			: std_logic_vector(31 downto 0);
signal sh_mask_norm		: std_logic_vector(16 downto 0);
signal sh_mask_normx	: std_logic_vector(17 downto 0);

signal expc				: std_logic_vector(6 downto 0);
signal norm_c           : std_logic_vector(47 downto 0);
signal expci			: std_logic_vector(6 downto 0);
signal expciz			: std_logic_vector(6 downto 0);
signal expcizz			: std_logic_vector(6 downto 0);
signal set_zero			: std_logic;

signal expaz			: std_logic_array_9x7;
signal exp_underflow	: std_logic;
signal exp_underflowz	: std_logic;
signal sign_c			: std_logic_vector(12 downto 0);

signal exch				: std_logic;
signal exchange			: std_logic; 
signal sum_manx			: std_logic_vector(29 downto 0);
signal msb_numz			: std_logic_vector(4 downto 0);
signal msb_numzz		: std_logic_vector(4 downto 0);
--signal msb_numzz		: std_logic_vector(4 downto 0);
signal alu_mode			: std_logic_vector(3 downto 0);

signal dout_val_v		: std_logic_vector(15 downto 0);

signal enaz_lo			: std_logic;
signal enaz				: std_logic;

begin	
	
rstn <= not reset;	

nor_enal: OR4
  port map (
    O  => enaz_lo,
    I0 => dout_val_v(5),
    I1 => dout_val_v(6),
    I2 => dout_val_v(7),	 
    I3 => dout_val_v(8)	
  ); 
  
enaz <=	enaz_lo after 1 ns when rising_edge(clk);

pr_val: process(clk, reset) is
begin
	if reset = '0' then
		dout_val_v <= (others=>'0');
	elsif rising_edge(clk) then
		dout_val_v <= dout_val_v(14 downto 0) & enable after 1 ns;
	end if;
end process;

aa_z <= aa after 1 ns when rising_edge(clk);
bb_z <= (bb(23 downto 17) & (not bb(16)) & bb(15 downto 0)) after 1 ns when rising_edge(clk);

aatr <= aa(23 downto 17) & aa(15 downto 0);
bbtr <= bb(23 downto 17) & bb(15 downto 0);

ab_subtr: sp_addsub_m1
	generic map(N => 22)
	port map(
	data_a 	=> aatr, 
	data_b 	=> bbtr, 
	--data_c 	=> , 		
	add_sub	=> '0', 				
	cin     => '1', 	
	cout    => exchange,	
	clk    	=> clk, 				
	ce 		=> enable, 								
	aclr  	=> rstn 				
	);

pr_ex: process(reset, clk) is
begin
	if reset = '0' then
		exch <= '1';
	elsif rising_edge(clk) then
		exch <= exchange after 1 ns;
	end if;
end process;
		
pr_mux: process(clk, reset) is
begin
	if reset='0' then 
		muxa	<= (others => '0'); 
		muxb	<= (others => '0');
	elsif rising_edge(clk) then
		if exch = '0' then
			muxa <= bb_z;--_z; 
			muxb <= aa_z;--_z; --	 muxa <= bb; muxb <= aa; --
		else
			muxa <= aa_z;--_z; 
			muxb <= bb_z;--_z; --	 muxa <= aa; muxb <= bb; --
		end if;
	end if;							   
end process;

pr_muxab: process(clk, reset) is
begin
	if reset = '0' then
		muxaz <= (others=>'0');
		muxbz <= (others=>'0');
	elsif rising_edge(clk) then
		if dout_val_v(1) = '1' then
			muxaz <= muxa(23 downto 0) after 1 ns;
			muxbz <= muxb(15 downto 0) after 1 ns;			
		else 
			null;
		end if;
	end if;
end process;

pr_imp: process(clk, reset) is
begin
	if reset='0' then 
		implied_a	<= '0'; 
		implied_b	<= '0';
	elsif rising_edge(clk) then
		if muxa(23 downto 17) = "0000000" then
			implied_a <= '0' after 1 ns;
		else
			implied_a <= '1' after 1 ns;
		end if;
		if muxb(23 downto 17) = "0000000" then
			implied_b <= '0' after 1 ns;
		else
			implied_b <= '1' after 1 ns;
		end if;	
	end if;
end process;

----------------------------------------
exp_subtract: sp_addsub_m1
	generic map(N => 6) 
	port map(
	data_a 	=> muxa(23 downto 17), 
	data_b 	=> muxb(23 downto 17), 
	data_c 	=> exp_dif, 		
	add_sub	=> '0', 				
	cin     => '1', 	
	--cout    => ,	
	clk    	=> clk, 				
	ce 		=> dout_val_v(1), 								
	aclr  	=> rstn 				
	);
----------------------------------------	
mask_align_gen: for ii in 0 to 31 generate
constant init: bit_vector(31 downto 0):=to_bitvector( conv_std_logic_vector( 2**(31-ii), 32) ); 
begin
	mask_align_lut: LUT5 
	  generic map(init => init)	
	  port map(
	    I0 => exp_dif(0),
	    I1 => exp_dif(1),
	    I2 => exp_dif(2),
	    I3 => exp_dif(3),
	    I4 => exp_dif(4),
--	    I5 => exp_dif(5),		
	    O  => sh_mask_aligne(ii)		
	    ); 
	pr_sh_align: process(clk, reset) is
	begin
		if reset='0' then 
			sh_mask_align(ii) <= '0';
		elsif rising_edge(clk) then
			if dout_val_v(2) = '1' then
				sh_mask_align(ii) <= sh_mask_aligne(ii) and not(exp_dif(5) or exp_dif(6));
			else 
				null;
			end if;
		end if;
	end process;		
end generate;

sh_mask_alignx <= '0' & sh_mask_align(31 downto 15) after 1 ns;
----------------------------------------

man_a <= x"000" & "000" & man_az  & x"0000" after 1 ns when rising_edge(clk);	   -- NB 
man_b <= '0' & x"000" & implied_b & muxbz(15 downto 0);

pr_del: process(clk, reset) is
begin
	if reset = '0' then
		subtract <= "000";
		man_az <= (others => '0');
	elsif rising_edge(clk) then
		man_az <= implied_a & muxaz(15 downto 0) after 1 ns;
		subtract(0) <= muxa(16) xor muxb(16) after 1 ns;
		subtract(1) <= subtract(0) after 1 ns;
		subtract(2) <= subtract(1) after 1 ns;
	end if;
end process;

alu_mode <= "00" & subtract(2) & subtract(2);		

align_add: DSP48E1 --   +/-(A*B+Cin)   -- for Virtex-6 and 7 families
-- normalize: DSP48E --   +/-(A*B+Cin) -- for Virtex-5	
generic map(
	--	ACASCREG		=> 1,	
		ADREG			=> 0,		
	--	ALUMODEREG	
		AREG			=> 2,		
	--	AUTORESET_PATDET
	--	A_INPUT		
		BCASCREG		=> 1,	
		BREG			=> 1,		
	--	B_INPUT		
	--	CARRYINREG	
	--	CARRYINSELREG	
		CREG			=> 1,		
		DREG			=> 0		
	--	INMODEREG		=> 1,	
	--	MASK        
	--	MREG		
	--	OPMODEREG	
	--	PATTERN     
	--	PREG		
	--	SEL_MASK	
	--	SEL_PATTERN	
	--	USE_DPORT		=> FALSE	
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
        P                       => sum_man, 
--		PCOUT                   => , 
--		UNDERFLOW				=> ,
        A                       => man_b,
		ACIN					=> (others=>'0'),
		ALUMODE					=> alu_mode,
        B                       => sh_mask_alignx, 
        BCIN                    => (others=>'0'), 
        C                       => man_a,
		CARRYCASCIN				=> '0',
        CARRYIN                 => '0', 
        CARRYINSEL              => (others=>'0'),
        CEA1                    => dout_val_v(2),	-- dout_val_v(3)
        CEA2                    => '1', 		
        CEAD                    => '1',
		CEALUMODE               => '1',
		CEB1                    => dout_val_v(3), 
        CEB2                    => '1', 		
        CEC                     => dout_val_v(4), 
        CECARRYIN               => '1', 
        CECTRL                  => '1',
        CED						=> '1',
		CEINMODE				=> '1',
        CEM                     => '1', 
        CEP                     => dout_val_v(5), 
        CLK                     => clk,
		D                       => (others=>'0'),
		INMODE					=> "00000",		-- for DSP48E1 
		MULTSIGNIN				=> '0',                    
        OPMODE                  => "0110101", 		
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
 
--msb_dec <= "000" & x"000" & sum_man(33 downto 18) & '0';	

msb_dec(31 downto 16) <= sum_man(33 downto 18);
msb_dec(15 downto 0) <= x"0000";

msb_seeker: sp_msb_decoder_m2 
	port map(
	din 	=> msb_dec, 	
	din_en  => enaz, 					
	clk 	=> clk, 					
	reset 	=> rstn, 					
	dout 	=> msb_num 			
	--dout_val=> 						
	);
	
msb_numn <= "00" & not msb_num after 1 ns when rising_edge(clk);
msb_numz <= msb_num(4 downto 0) after 1 ns when rising_edge(clk);
msb_numzz <= msb_numz after 1 ns when rising_edge(clk);
---------------------------------------------------

mask_norm_gen: for ii in 0 to 31 generate
constant init: bit_vector(31 downto 0):=to_bitvector(conv_std_logic_vector(2**(31-ii), 32));
begin
	mask_norm_lut: LUT5 
	  generic map(init => init)--&init)	
	  port map(
	    I0 => msb_numn(0),
	    I1 => msb_numn(1),
	    I2 => msb_numn(2),
	    I3 => msb_numn(3),
		I4 => msb_numn(4),
	    O  => sh_mask(31-ii)		
	    );
	pr_maskz: process(clk, reset) is
	begin
		if reset = '0' then 
			sh_mask_norm <= (others=>'0');
		elsif rising_edge(clk) then
			sh_mask_norm <= sh_mask(16 downto 0) after 1 ns;
		end if;
	end process;
--sh_mask_norm <= sh_mask(16 downto 0) after 1 ns;
end generate;
sh_mask_normx <= '0' & sh_mask_norm;-- after 1 ns when rising_edge(clk);

pr_manz: process(clk) is
begin
	if rising_edge(clk) then 
		sum_manz(0) <= sum_man(33 downto 17); --sum_man(33 downto 16);
		for ii in 0 to 3 loop			
			sum_manz(ii+1) <= sum_manz(ii);
		end loop;	
	end if;
end process;	

norm_sub: sp_addsub_m1
	generic map(N => 6)
	port map(
	data_a 	=> expaz(8),  --expaz(8), --
	data_b 	=> msb_numn, 
	data_c 	=> expc, 		
	add_sub	=> '0', 
	cin     => '1', 
	cout    => exp_underflow ,	 
	clk    	=> clk, 
	ce 		=> dout_val_v(11),
	aclr  	=> rstn 
	);					 

exp_inc: sp_addsub_m1
	generic map(N => 6)
	port map(
	data_a 	=> expc, 
	data_b 	=> "0000000", 
	data_c 	=> expci, 		
	add_sub	=> '1', 
	cin     => '1', 
	--cout    =>  ,	 
	clk    	=> clk, 
	ce 		=> dout_val_v(12),
	aclr  	=> set_zero 
	); 																								
	
pr_und: process(clk, reset) is 
begin
	if reset = '0' then 
		exp_underflowz <= '1';
	elsif rising_edge(clk) then
		if dout_val_v(11) = '1' then
			exp_underflowz <= exp_underflow;
		else
			null;
		end if;
	end if;
end process;

set_zero <= not ((msb_numzz(4) or msb_numzz(3) or msb_numzz(2) or msb_numzz(1) or msb_numzz(0)) and exp_underflowz);

pr_expz: process(clk, reset) is
begin
	if reset = '0' then
		expaz <= (others => (others => '0'));
	elsif rising_edge(clk) then
		expaz(0) 	<= muxaz(23 downto 17) after 1 ns;
		for ii in 0 to 7 loop
			expaz(ii+1) 	<= expaz(ii) after 1 ns;
		end loop;		
	end if;
end process;	
	
sum_manx(17 downto 0) <= '0' & sum_manz(4);
sum_manx(29 downto 18) <= (others => '0');

normalize: DSP48E1 --   +/-(A*B+Cin)   -- for Virtex-6 and 7 families
-- normalize: DSP48E --   +/-(A*B+Cin) -- for Virtex-5	
generic map(
		ACASCREG		=> 1,	
		ADREG			=> 0,		
	--	ALUMODEREG	
		AREG			=> 2,		
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
        P                       => norm_c, 
--		PCOUT                   => , 
--		UNDERFLOW				=> ,
        A                       => sum_manx,
		ACIN					=> (others=>'0'),
		ALUMODE					=> (others=>'0'),
        B                       => sh_mask_normx, 
        BCIN                    => (others=>'0'), 
        C                       => (others=>'0'),
		CARRYCASCIN				=> '0',
        CARRYIN                 => '0', 
        CARRYINSEL              => (others=>'0'),
        CEA1                    => dout_val_v(11),
        CEA2                    => '1', 		
        CEAD                    => '1',
		CEALUMODE               => '1',
		CEB1                    => dout_val_v(12), 
        CEB2                    => '1', 		
        CEC                     => '1', 
        CECARRYIN               => '1', 
        CECTRL                  => '1',
        CED						=> '1',
		CEINMODE				=> '1',
        CEM                     => '1', 
        CEP                     => dout_val_v(14), 
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
	  
pr_sign: process(clk, reset) is
begin
	if reset = '0' then
		sign_c <= (others => '0');	
	elsif rising_edge(clk) then	
		--if enable = '0' then
		--	sign_c <= (others => '0');	
		--else			
			sign_c <= sign_c(11 downto 0) & muxaz(16) after 1 ns;
		--end if;		
	end if;
end process; 

expciz <= expci after 1 ns when rising_edge(clk);
expcizz <= expciz after 1 ns when rising_edge(clk);

cc <= expcizz & sign_c(12) & norm_c(15 downto 0) after 1 ns when rising_edge(clk); 
valid <= dout_val_v(15) after 1 ns when rising_edge(clk);

end fp24_sub_m2;