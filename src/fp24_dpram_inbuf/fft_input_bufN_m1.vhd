-------------------------------------------------------------------------------
--
-- Title       : fp24fftk_input_bufN_m1
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     :
--
-------------------------------------------------------------------------------
--
-- Description : version 1.0 
--
-- Universal input buffer for FFT project
-- It has 6 independent	DPRAM components for FFT stages between 1k and 64k
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

package	fft_input_bufN_m1_pkg is
	component fft_input_bufN_m1 is
		generic(
			stages		: integer :=16
		);		
		port(
			ia_re		: in std_logic_vector(15 downto 0);
			ia_im		: in std_logic_vector(15 downto 0);
			ib_re		: in std_logic_vector(15 downto 0);
			ib_im		: in std_logic_vector(15 downto 0);
	
			clk_in		: in std_logic;							-- тактовая частота входных данных
			start 		: in std_logic;							-- 1 - запуск БПФ
			cnt_in		: out std_logic_vector(stages-2 downto 0); 	-- счётчик входных данных
			cnt_out		: out std_logic_vector(stages-2 downto 0);	-- счетчик выходных данных
			
			ca_re		: out std_logic_vector(15 downto 0);
			ca_im		: out std_logic_vector(15 downto 0);
			cb_re		: out std_logic_vector(15 downto 0);
			cb_im		: out std_logic_vector(15 downto 0);		
			fix_en		: out std_logic;
	
			reset  		: in std_logic;
			clk 		: in std_logic			
		);	
	end component;
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all; 

--use work.fp27_v0_pkg.all;
--use work.ramb_init_v3_pkg.all; 
use work.fft_dpram36_ZxY_m1_pkg.all; 
--use work.fp27_fix2float_m3_pkg.all;

entity fft_input_bufN_m1 is
	generic(
		stages		: integer :=16
	);
	port(
		ia_re		: in std_logic_vector(15 downto 0);
		ia_im		: in std_logic_vector(15 downto 0);
		ib_re		: in std_logic_vector(15 downto 0);
		ib_im		: in std_logic_vector(15 downto 0);
	
		clk_in		: in std_logic;							-- тактовая частота входных данных
		start 		: in std_logic;							-- 1 - запуск БПФ
		cnt_in		: out std_logic_vector(stages-2 downto 0); 	-- счётчик входных данных
		cnt_out		: out std_logic_vector(stages-2 downto 0);	-- счетчик выходных данных
		
		ca_re		: out std_logic_vector(15 downto 0);
		ca_im		: out std_logic_vector(15 downto 0);
		cb_re		: out std_logic_vector(15 downto 0);
		cb_im		: out std_logic_vector(15 downto 0);		
		fix_en		: out std_logic;
	
		reset  		: in std_logic;
		clk 		: in std_logic		
	);	
end fft_input_bufN_m1;

architecture fft_input_bufN_m1 of fft_input_bufN_m1 is

signal	port_p0			: std_logic_vector(47 downto 0);
signal	opmode			: std_logic_vector(6 downto 0);
signal	dsp_rst			: std_logic;
signal	rstp			: std_logic;
signal	carry0			: std_logic;	
signal 	carry1			: std_logic;

type stp_type is (s0, s1, s2);				  
signal stp				: stp_type;
signal stw				: stp_type;

type std_logic_array_3x15 is array(2 downto 0) of std_logic_vector(stages-2 downto 0);
signal  st_cnt			: std_logic_array_3x15;

signal	start_rd0		: std_logic;
signal	start_rd		: std_logic;

signal	port_p1			: std_logic_vector(47 downto 0);
signal	dsp_rst1		: std_logic;

signal	rstp1			: std_logic;  

signal	bram_rd			: std_logic;  

signal	addra,addra_z	: std_logic_vector(stages-3 downto 0);
signal	addrb			: std_logic_vector(stages-3 downto 0);
signal  addrb_rev		: std_logic_vector(stages-3 downto 0);
signal	wr_en, wr_en_z	: std_logic_vector(3 downto 0);
signal  cnt_z			: std_logic_vector(stages-2 downto 0);	  

type std_logic_array_4x32 is array(3 downto 0) of std_logic_vector(31 downto 0);

signal	ram_din			:  std_logic_array_4x32;
signal	ram_dout		:  std_logic_array_4x32;	

signal	fix				: std_logic;
signal	fix_en0			: std_logic; 
signal	fix_en_block	: std_logic;

begin

opmode	<= '0' & '1' & '1' & "00" & '1' & '0';	

rstp <= not reset after 0.5 ns when rising_edge(clk_in);
rstp1 <= not reset after 0.5 ns when rising_edge(clk);
cnt_z <= port_p0(stages-2 downto 0) after 0.5 ns when rising_edge(clk_in);
cnt_in <= cnt_z after 0.5 ns when rising_edge(clk_in);

pr_stp: process(clk_in) is
begin
	if rising_edge(clk_in) then
		case(stp) is
			when s0 =>
				dsp_rst 	<= '1' after 0.5 ns;
				carry0 		<= '0' after 0.5 ns;
				if start = '1' then
					stp 	<= s1 after 0.5 ns;
				end if;			
			when s1 =>
				dsp_rst 	<= '0' after 0.5 ns;	  
				stp 		<= s2 after 0.5 ns;
			when s2 =>
				carry0 		<= '1' after 0.5 ns; 
				if port_p0(stages-1) = '1' then
					stp 	<= s0 after 0.5 ns;
				end if;
		end case;	
		if rstp = '1' then
			stp <= s0 after 0.5 ns;
		end if;		
	end if;
end process;

pr_stw: process(clk) is
begin
	if rising_edge(clk) then	
		case stw is
			when s0 =>
				dsp_rst1 	<= '1' after 0.5 ns;	  
				carry1 		<= '0' after 0.5 ns;
				if start_rd = '1' then
					stw 	<= s1 after 0.5 ns;		   
				end if;		 		
			when s1 =>
				dsp_rst1 	<= '0' after 0.5 ns;	  	   	 
				stw 		<= s2 after 0.5 ns;
			when s2 =>
				carry1 		<= '1' after 0.5 ns;
				if port_p1(stages-1) = '1' then
					stw 	<= s0 after 0.5 ns;
				end if;
		end case;
		if rstp1 = '1' then
			stw <= s0 after 0.5 ns;
		end if;
	end if;
end process;


pr_start_rd0: process(clk) is
begin
	if rising_edge(clk) then
		if (rstp1 = '1' or dsp_rst1 = '0') then
			start_rd0 <= '0' after  1 ns;
		elsif port_p0(stages-2) = '1' then
			start_rd0 <= '1' after 0.5 ns;
		end if;
	end if;
end process;

start_rd <= start_rd0 after 0.5 ns when rising_edge(clk);
bram_rd <= not dsp_rst1 after 0.5 ns when rising_edge(clk);

dsp0: DSP48E1 --   +/-(A*B+Cin)   -- for Virtex-6 and 7 families	
generic map(
	--	ACASCREG		=> 1,	
		ADREG			=> 0,		
		ALUMODEREG	    => 1,
		AREG			=> 1,		
	--	AUTORESET_PATDET
	--	A_INPUT		
		BCASCREG		=> 1,	
		BREG			=> 1,		
		B_INPUT			=> "DIRECT",		
		CARRYINREG		=> 1,	
		CARRYINSELREG	=> 1,	
		CREG			=> 1,		
		DREG			=> 0,		
	--	INMODEREG		=> 1,	
	--	MASK        
		MREG			=> 1,		
		OPMODEREG		=> 1,	
	--	PATTERN     
		PREG			=> 1,		
	--	SEL_MASK	
	--	SEL_PATTERN	
	--	USE_DPORT		=> FALSE	
		USE_MULT		=> "DYNAMIC"	
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
        P                       => port_p0, 
--		PCOUT                   => , 
--		UNDERFLOW				=> ,
        A                       => (others=>'0'),
		ACIN					=> (others=>'0'),
		ALUMODE					=> "0000", --  SUBTRACT = '0' in V4
        B                       => (others=>'0'), 
        BCIN                    => (others=>'0'), 
        C                       => (others=>'0'),
		CARRYCASCIN				=> '0',
        CARRYIN                 => carry0, 
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
        CLK                     => clk_in,
		D                       => (others=>'0'),
		INMODE					=> "00000",		-- for DSP48E1 
		MULTSIGNIN				=> '0',                    
        OPMODE                  => OPMODE, 		
        PCIN                    => (others=>'0'), 	
        RSTA                    => dsp_rst,
		RSTALLCARRYIN			=> dsp_rst,
		RSTALUMODE   			=> dsp_rst,
        RSTB                    => dsp_rst, 
        RSTC                    => dsp_rst, 
        RSTCTRL                 => dsp_rst,
		RSTD					=> dsp_rst,
		RSTINMODE				=> dsp_rst,
        RSTM                    => dsp_rst, 
        RSTP                    => dsp_rst 
	);

dsp1: DSP48E1 --   +/-(A*B+Cin)   -- for Virtex-6 and 7 families	
generic map(
	--	ACASCREG		=> 1,	
		ADREG			=> 0,		
		ALUMODEREG	    => 1, -- '0'
		AREG			=> 1,		
	--	AUTORESET_PATDET
	--	A_INPUT		
		BCASCREG		=> 1,	
		BREG			=> 1,		
		B_INPUT			=> "DIRECT",		
		CARRYINREG		=> 1,	
		CARRYINSELREG	=> 1,	
		CREG			=> 1,		
		DREG			=> 0,		
	--	INMODEREG		=> 1,	
	--	MASK        
		MREG			=> 1,		
		OPMODEREG		=> 1,	
	--	PATTERN     
		PREG			=> 1,		
	--	SEL_MASK	
	--	SEL_PATTERN	
	--	USE_DPORT		=> FALSE	
		USE_MULT		=> "DYNAMIC"	
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
        P                       => port_p1, 
--		PCOUT                   => , 
--		UNDERFLOW				=> ,
        A                       => (others=>'0'),
		ACIN					=> (others=>'0'),
		ALUMODE					=> "0000", --  SUBTRACT = '0' in V4
        B                       => (others=>'0'), 
        BCIN                    => (others=>'0'), 
        C                       => (others=>'0'),
		CARRYCASCIN				=> '0',
        CARRYIN                 => carry1, 
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
        OPMODE                  => OPMODE, 		
        PCIN                    => (others=>'0'), 	
        RSTA                    => dsp_rst1,
		RSTALLCARRYIN			=> dsp_rst1,
		RSTALUMODE   			=> dsp_rst1,
        RSTB                    => dsp_rst1, 
        RSTC                    => dsp_rst1, 
        RSTCTRL                 => dsp_rst1,
		RSTD					=> dsp_rst1,
		RSTINMODE				=> dsp_rst1,
        RSTM                    => dsp_rst1, 
        RSTP                    => dsp_rst1 
	);

addrb_rev <= port_p1(stages-2 downto 1) after 0.5 ns;
--addrb <= port_p1(stages-2 downto 1) after 0.5 ns; -- addrb_rev
addra <= port_p0(stages-3 downto 0) when rising_edge(clk_in);	

wr_en_z <= wr_en after 0.5 ns when rising_edge(clk_in);
addra_z <= addra after 0.5 ns when rising_edge(clk_in);

wr_en(0) <= not port_p0(stages-2) and not dsp_rst when rising_edge(clk_in);
wr_en(1) <= not port_p0(stages-2) and not dsp_rst when rising_edge(clk_in);
wr_en(2) <= port_p0(stages-2) and not dsp_rst when rising_edge(clk_in);
wr_en(3) <= port_p0(stages-2) and not dsp_rst when rising_edge(clk_in);

pr_data: process(clk_in) is
begin
	if rising_edge(clk_in) then
		ram_din(0) <= ia_im & ia_re after 0.5 ns;
		ram_din(1) <= ib_im & ib_re after 0.5 ns;
		ram_din(2) <= ia_im & ia_re after 0.5 ns;
		ram_din(3) <= ib_im & ib_re after 0.5 ns;				
	end if;			
end process;

----reverse order:
--pr_addr: for ii in 0 to stages-3 generate
--	addrb(stages-3-ii) <= addrb_rev(ii);
--end generate;

-- natural order:
	addrb <= addrb_rev;

---- RAMB GENERATE FOR STAGES BETWEEN 11 AND 16
ramb_gen: for ii in 0 to 3 generate
	stages16: if stages = 16 generate	-- 64K
		ram1: fft_dpram36_16kx32_m1 
		port map(
			addr_in 	=> addra_z, 				
			din			=> ram_din(ii), 		
			wr_en		=> wr_en_z(ii),
			ena			=> '1',
			clk_in		=> clk_in,
			addr_out 	=> addrb,  -- bit_reverse or natural;			
			dout		=> ram_dout(ii), 		
			rd_en		=> bram_rd, 			 					
			clk			=> clk,	  
			reset		=> reset
		);
	end generate;
	stages15: if stages = 15 generate	-- 32K
		ram1: fft_dpram36_8kx32_m1 
		port map(
			addr_in 	=> addra_z, 				
			din			=> ram_din(ii), 		
			wr_en		=> wr_en_z(ii),
			ena			=> '1',
			clk_in		=> clk_in,
			addr_out 	=> addrb,  -- bit_reverse or natural;			
			dout		=> ram_dout(ii), 		
			rd_en		=> bram_rd, 			 					
			clk			=> clk,	  
			reset		=> reset
		);
	end generate;	
	stages14: if stages = 14 generate	-- 16K
		ram1: fft_dpram36_4kx32_m1 
		port map(
			addr_in 	=> addra_z, 				
			din			=> ram_din(ii), 		
			wr_en		=> wr_en_z(ii),
			ena			=> '1',
			clk_in		=> clk_in,
			addr_out 	=> addrb,  -- bit_reverse or natural;			
			dout		=> ram_dout(ii), 		
			rd_en		=> bram_rd, 			 					
			clk			=> clk,	  
			reset		=> reset
		);
	end generate;	
	stages13: if stages = 13 generate	-- 8K
		ram1: fft_dpram36_2kx32_m1 
		port map(
			addr_in 	=> addra_z, 				
			din			=> ram_din(ii), 		
			wr_en		=> wr_en_z(ii),
			ena			=> '1',
			clk_in		=> clk_in,
			addr_out 	=> addrb,  -- bit_reverse or natural;			
			dout		=> ram_dout(ii), 		
			rd_en		=> bram_rd, 			 					
			clk			=> clk,	  
			reset		=> reset
		);
	end generate;
	stages12: if stages = 12 generate	-- 4K
		ram1: fft_dpram36_1kx32_m1 
		port map(
			addr_in 	=> addra_z, 				
			din			=> ram_din(ii), 		
			wr_en		=> wr_en_z(ii),
			ena			=> '1',
			clk_in		=> clk_in,
			addr_out 	=> addrb,  -- bit_reverse or natural;			
			dout		=> ram_dout(ii), 		
			rd_en		=> bram_rd, 			 					
			clk			=> clk,	  
			reset		=> reset
		);
	end generate;	
	stages11: if stages = 11 generate	-- 2K
		ram1: fft_dpram36_512x32_m1 
		port map(
			addr_in 	=> addra_z, 				
			din			=> ram_din(ii), 		
			wr_en		=> wr_en_z(ii),
			ena			=> '1',
			clk_in		=> clk_in,
			addr_out 	=> addrb,  -- bit_reverse or natural;			
			dout		=> ram_dout(ii), 		
			rd_en		=> bram_rd, 			 					
			clk			=> clk,	  
			reset		=> reset
		);
	end generate;
	stages10: if stages = 10 generate	-- 1K
		signal addra7	: std_logic_vector(8 downto 0);
		signal addrb7	: std_logic_vector(8 downto 0);
		begin
		addra7 <= '0' & addra_z; addrb7 <= '0' & addrb;
		ram1: fft_dpram36_512x32_m1 
		port map(
			addr_in 	=> addra7, 				
			din			=> ram_din(ii), 		
			wr_en		=> wr_en_z(ii),
			ena			=> '1',
			clk_in		=> clk_in,
			addr_out 	=> addra7,  -- bit_reverse or natural;			
			dout		=> ram_dout(ii), 		
			rd_en		=> bram_rd, 			 					
			clk			=> clk,	  
			reset		=> reset
		);
	end generate;			
end generate;			  		  

pr_ca: process(clk) is
begin
	if rising_edge(clk) then
		if fix = '1' then
			if port_p1(0) = '1' then
				ca_re <= ram_dout(0)(15 downto 0) after 0.5 ns;
				ca_im <= ram_dout(0)(31 downto 16) after 0.5 ns;
				cb_re <= ram_dout(2)(15 downto 0) after 0.5 ns;
				cb_im <= ram_dout(2)(31 downto 16) after 0.5 ns;
			else
				ca_re <= ram_dout(1)(15 downto 0) after 0.5 ns;
				ca_im <= ram_dout(1)(31 downto 16) after 0.5 ns;
				cb_re <= ram_dout(3)(15 downto 0) after 0.5 ns;
				cb_im <= ram_dout(3)(31 downto 16) after 0.5 ns;
			end if;
		else
			ca_re <= x"0000" after 0.5 ns; 
			ca_im <= x"0000" after 0.5 ns;
			cb_re <= x"0000" after 0.5 ns;
			cb_im <= x"0000" after 0.5 ns;
		end if;
	end if;
end process;

xfix: srl16 port map(q => fix_en0, clk => clk, d => dsp_rst1, a0=>'0', a1=>'0', a2=>'1', a3=>'0');

pr_fix_en_block: process(clk) is
begin
	if rising_edge(clk) then
		if fix_en0 = '1' then
			fix_en_block <= '1' after 0.5 ns;
		elsif (port_p1(stages-1)='1' and port_p1(1)='1') then
			fix_en_block <= '0' after 0.5 ns;
		end if;
	end if;
end process;

fix <= fix_en_block and not fix_en0 after 0.5 ns;
fix_en <= fix after 0.5 ns when rising_edge(clk);

st_cnt(0)(stages-2 downto 0)  <= port_p1(stages-2 downto 0) after 0.5 ns when rising_edge(clk);
st_cnt(1)(stages-2 downto 0)  <= st_cnt(0)(stages-2 downto 0) after 0.5 ns when rising_edge(clk);
st_cnt(2)(stages-2 downto 0)  <= st_cnt(1)(stages-2 downto 0) after 0.5 ns when rising_edge(clk);
--cnt_out(stages-2 downto 0)  <= st_cnt(2)(stages-2 downto 0) after 0.5 ns when rising_edge(clk); 

pr_cntout: process(clk) is
begin
	if rising_edge(clk) then
		if fix = '1' then
			cnt_out	<= st_cnt(2) after 0.5 ns;
		else
			cnt_out <= (others => '0') after 0.5 ns;
		end if;
	end if;
end process;

-- TEST FOR INPUT BUFFER (from TB):
--	constant t0			: time := 10 ns;
--	constant tt			: time := t0*(2**(N-1));
--	
--  clk_in <= clk;
--  clk <= not clk after 5 ns;
--
--	pr_start: process
--	begin
--		start <= '0';
--		wait for 150 ns;
--		loop 
--			start <= '1'; 
--			wait for 20 ns; 
--			start <= '0'; 
--			wait for tt; -- 327.68 
--			start <= '0'; 
--			wait for 500 ns;		
--		end loop;	
--	end process;	
	
end fft_input_bufN_m1;
