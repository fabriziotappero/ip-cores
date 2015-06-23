-------------------------------------------------------------------------------
--
-- Title       : fp24_fix2float_m1
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     : 
--
-------------------------------------------------------------------------------
--
-- Description : version 1.3 
--
-------------------------------------------------------------------------------
--
--	Version 1.0  25.05.2013
--			   	 Description:
--					Bus width for:
--					din = 16
--					dout = 24	
-- 					exp = 7
-- 					sign = 1
-- 					mant = 16 + 1
--				 Math expression: 
--					A = (-1)^sign(A) * 2^(exp(A)-32) * mant(A)
--				 NB:
--				 1's complement
--				 Converting from fixed to float takes only 8 clock cycles
--
--	MODES: 	Mode0	: normal fix2float (1's complement data)
--			Mode1	: +1 fix2float for negative data (uncomment and change this code a little: add a component sp_addsub_m1 and some signals): 2's complement data.
--	
--
--	Version 1.1  15.01.2015
--			   	 Description:
--					Based on fp27_fix2float_m3 (FP27 FORMAT)
--					New version of FP (Reduced fraction width)
--	
--	Version 1.2  18.03.2015
--			   	 Description:
--					Changed CE signal
--					This version has din_en. See OR5+OR5 stages
--
--	Version 1.3  24.03.2015
--			   	 Description:
--					Deleted ENABLE signal
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

package	fp24_fix2float_m1_pkg is
	component fp24_fix2float_m1 is
		port(
			din			: in std_logic_vector(15 downto 0);	
			din_en		: in std_logic;
			dout		: out std_logic_vector(23 downto 0);
			dout_val	: out std_logic;
			clk			: in std_logic;
			reset		: in std_logic
		);
	end component;
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library unisim;
use unisim.vcomponents.all;

use work.sp_addsub_m1_pkg.all;
use work.sp_msb_decoder_m2_pkg.all;

entity fp24_fix2float_m1 is
	port(
		din			: in std_logic_vector(15 downto 0);	
		din_en		: in std_logic;
		dout		: out std_logic_vector(23 downto 0);
		dout_val	: out std_logic;
		clk			: in std_logic;
		reset		: in std_logic
	);
end fp24_fix2float_m1;

architecture fp24_fix2float_m1 of fp24_fix2float_m1 is 

type std_logic_array_2x7  is array (1 downto 0) of std_logic_vector(6 downto 0);
type std_logic_array_5x15 is array (4 downto 0) of std_logic_vector(14 downto 0);  

signal true_form		: std_logic_vector(15 downto 0):=(others => '0');	
signal rstn				: std_logic;

signal sum_man		    : std_logic_vector(31 downto 0);
signal sum_manz			: std_logic_array_5x15:=(others => (others=> '0' )); -- 15x4
signal sum_manx			: std_logic_vector(29 downto 0);
signal msb_num			: std_logic_vector(4 downto 0);
signal msb_numn			: std_logic_vector(6 downto 0);
signal sh_mask			: std_logic_vector(31 downto 0);
signal sh_mask_norm		: std_logic_vector(15 downto 0);
signal sh_mask_normx	: std_logic_vector(17 downto 0);

constant exp_in			: std_logic_vector(6 downto 0):="0100000";	 -- x = 32 - exp!	

signal expc				: std_logic_vector(6 downto 0);
signal expci			: std_logic_vector(6 downto 0);	
signal norm_c           : std_logic_vector(47 downto 0);
signal set_zero			: std_logic;
signal expciz			: std_logic_array_2x7;	
signal exp_underflow	: std_logic;
signal exp_underflowz	: std_logic;
signal sign_c			: std_logic_vector(6 downto 0):=( others => '0');
signal dout_val_v		: std_logic_vector(9 downto 0);
--signal din_buf			: std_logic_vector(15 downto 0);
--signal din_conq			: std_logic;
signal dinz				: std_logic_vector(15 downto 0);

signal enaz_lo			: std_logic;
signal enaz_hi			: std_logic;
signal enaz_loz			: std_logic;
signal enaz_hiz			: std_logic;
signal enaz				: std_logic;

signal true_formz		: std_logic;

begin	
	
rstn <= not reset;

nor_enal: OR4
  port map (
    O  => enaz_lo,
    I0 => dout_val_v(0),
    I1 => dout_val_v(1),
    I2 => dout_val_v(2),
    I3 => dout_val_v(3)
  );

nor_enah: OR3
  port map (
    O  => enaz_hi,
    I0 => dout_val_v(4),
    I1 => dout_val_v(5),	
    I2 => dout_val_v(6)
  ); 
  
enaz_loz <= enaz_lo after 1 ns when rising_edge(clk); 
enaz_hiz <= enaz_hi after 1 ns when rising_edge(clk);
enaz <= enaz_loz or enaz_hiz after 1 ns when rising_edge(clk);  

dinz <= din after 1 ns when rising_edge(clk);

-- -- UNCOMMENT TO CHANGE FLOATING MODE!
--din_conq <= not din(15);
--din15z	<= din(15) when rising_edge(clk);

--add_din: sp_addsub_m1	-- +1 for negative data
--	generic map(N => 15) 
--	port map(
--	data_a 	=> din,
--	data_b 	=> x"0000",  
--	data_c 	=> din_buf, 		
--	add_sub	=> '1',--din_conq,--'0', 
--	cin     => '0',--din(15), 
----	cout    => ,	 
--	clk    	=> clk, 
--	ce 		=> enable, --
--	aclr  	=> rstn 
--	);

pr_val: process(clk, reset) is
begin
	if reset = '0' then
		dout_val_v <= (others=>'0');
	elsif rising_edge(clk) then
		dout_val_v <= dout_val_v(8 downto 0) & din_en after 1 ns;
	end if;
end process;	
dout_val <= dout_val_v(9) after 1 ns when rising_edge(clk);--dout_val_v(8); -- 8 clock corresponds actual data (+1 for mode 1)		

pr_abs: process(clk) is
begin
	if reset = '0' then
		true_form <= (others => '0');
		true_formz <= '0';
	elsif rising_edge(clk) then
		true_formz <= true_form(15);
		if dout_val_v(0) = '1' then	
			true_form(15) <= dinz(15) after 1 ns;	--din15z;	--din(15);
			for ii in 0 to 14 loop
				true_form(ii) <= dinz(ii) xor dinz(15) after 1 ns;	--din_buf(ii) xor din_buf(15);
			end loop;
		else
			null;
		end if;	
	end if;
end process;	

sum_man(31 downto 29) <= "000";
sum_man(28 downto 14) <= true_form(14 downto 0);
sum_man(11 downto 0) <= x"000";
sum_man(13 downto 12) <= "00";


----------------------------------------
msb_seeker: sp_msb_decoder_m2 
port map(
	din 	=> sum_man(31 downto 0), 	
	din_en  => enaz_loz, 					
	clk 	=> clk, 					
	reset 	=> rstn, 					
	dout 	=> msb_num 			 						
); 	

msb_numn <= "00" & (not msb_num);	
----------------------------------------
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
			sh_mask_norm <= sh_mask(18 downto 3) after 1 ns;
		end if;
	end process;
end generate;
sh_mask_normx <= '0' & sh_mask_norm & '0';

pr_manz_delay: process(clk) begin
	if rising_edge(clk) then 
		sum_manz(0) <= sum_man(27 downto 13) after 1 ns; 
		for ii in 0 to 3 loop			
			sum_manz(ii+1) <= sum_manz(ii) after 1 ns;
		end loop;
	end if;
end process; 

sum_manx(17 downto 0) <= ('0' & sum_manz(4) & "00");
sum_manx(29 downto 18) <= (others => '0');	
----------------------------------------
norm_sub: sp_addsub_m1
	generic map(N => 6) 
	port map(
	data_a 	=> exp_in,
	data_b 	=> msb_numn,  
	data_c 	=> expc, 		
	add_sub	=> '0', 
	cin     => '1', 
	cout    => exp_underflow,	 
	clk    	=> clk, 
	ce 		=> dout_val_v(5),
	aclr  	=> rstn 
	);					 
 
	
pr_und: process(clk, reset) is 
begin
	if reset = '0' then 
		exp_underflowz <= '1';
	elsif rising_edge(clk) then
		exp_underflowz <= exp_underflow after 1 ns;
	end if;
end process;	
	
pr_exp_under: process(clk, reset) is
begin
	if reset = '0' then 
		set_zero 	<= '0';
	elsif rising_edge(clk) then
		set_zero <= not ((msb_num(4) or msb_num(3) or msb_num(2) or msb_num(1) or msb_num(0))) and exp_underflowz after 1 ns; --not exp_underflow;
	end if;
end process;	
	
exp_inc: sp_addsub_m1
	generic map(N => 6)
	port map(
	data_a 	=> expc, 
	data_b 	=> "0000000", 
	data_c 	=> expci, 		
	add_sub	=> '1', 
	cin     => '1',--true_form(15), 
	--cout    =>  ,	 
	clk    	=> clk, 
	ce 		=> dout_val_v(6),
	aclr  	=> set_zero 
	); 																								

pr_expciz: process(clk, reset) is
begin
	if reset = '0' then
		expciz(0) <= (others => '0');
		expciz(1) <= (others => '0');
	elsif rising_edge(clk) then
		expciz(0) <= expci;
		expciz(1) <= expciz(0);
	end if;	
end process;

normalize: DSP48E1 --   +/-(A*B+Cin)   -- for Virtex-6 families and 7 series 
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
		if enaz = '1' then
		--if enable = '0' then	
			sign_c(6 downto 0) <= sign_c(5 downto 0) & true_formz;--sign_c <= (others => '0');	
		else
			null;--
		end if;
	end if;
end process;	
-- output data: 
dout <= expciz(1) & sign_c(6) & norm_c(17 downto 2) after 1 ns when rising_edge(clk);

end fp24_fix2float_m1;

