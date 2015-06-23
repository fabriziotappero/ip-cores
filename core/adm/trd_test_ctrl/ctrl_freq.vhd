-------------------------------------------------------------------------------
--
-- Title       : ctrl_freq
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.1
--
-------------------------------------------------------------------------------
--
-- Description :  Определение значения тактовой частоты
--
-------------------------------------------------------------------------------
--
-- Version   1.1  01.11.2008
--			 Исправлен сигнал new_cnt
--
-------------------------------------------------------------------------------
--
-- Version   1.0  Mon Jun  2 10:00:19 2008
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package	ctrl_freq_pkg is

component ctrl_freq is
	generic(
		SystemFreq 	: integer:= 1250;  	-- значение системной тактовой частоты
		FreqDiv		: integer:= 2    	-- коэффициент деления входной частоты
										-- ( 2 - на вход подаётся половина измеряемой частоты )
	);
	
	port( 
		reset		: in std_logic;		-- 0 - сброс
		clk_sys		: in std_logic;		-- системная тактовая частота
		clk_in		: in std_logic;		-- входная тактовая частота АЦП
		
		freq_adc	: out std_logic_vector(15 downto 0);	-- ориентировочное значение тактовой частоты АЦП в МГц
		freq_en		: out std_logic		-- 1 - подсчитано значение тактовой частоты
		
	);
end component;

end package;



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ctrl_freq is
	generic(
		SystemFreq 	: integer:= 1250;  	-- значение системной тактовой частоты
		FreqDiv		: integer:= 2    	-- коэффициент деления входной частоты
										-- ( 2 - на вход подаётся половина измеряемой частоты )
	);
	
	port( 
		reset		: in std_logic;		-- 0 - сброс
		clk_sys		: in std_logic;		-- системная тактовая частота
		clk_in		: in std_logic;		-- входная тактовая частота АЦП
		
		freq_adc	: out std_logic_vector(15 downto 0);	-- ориентировочное значение тактовой частоты АЦП в МГц
		freq_en		: out std_logic		-- 1 - подсчитано значение тактовой частоты
		
	);
end ctrl_freq;


architecture ctrl_freq of ctrl_freq is

component ctrl_multiplier_v1_0
	port (
	clk: IN std_logic;
	a: IN std_logic_VECTOR(15 downto 0);
	b: IN std_logic_VECTOR(10 downto 0);
	p: OUT std_logic_VECTOR(26 downto 0));
end component;	

constant	Freq			: integer:=SystemFreq*FreqDiv/2;

signal cnt_value			: std_logic_vector(12 downto 0); 
signal cnt_value_adc,cnt_value_adc0		: std_logic_vector(15 downto 0);  
signal freq_sys				: std_logic_vector(10 downto 0); 
signal result_freq			: std_logic_vector(26 downto 0);
signal new_cnt_c			: std_logic_vector(3 downto 0);
signal new_cnt				: std_logic;	
signal new_cnt_z			: std_logic;	
signal new_cnt_z1			: std_logic;	
signal new_cnt_z2			: std_logic;	


begin
	
-- определение ориентировочного значения тактовой частоты АЦП в МГц	

pr_value: process(clk_sys,reset)
begin		
	if(reset='0')then		 
		new_cnt<='0';
		cnt_value<=(others=>'0');
		new_cnt_c<=(others=>'0');
		freq_adc<=(others=>'0');	  
		freq_en <= '0';
	elsif(rising_edge(clk_sys))then	  
		if(new_cnt='0')then
			cnt_value<=cnt_value+'1';
			new_cnt_c<=(others=>'0');
			
			new_cnt<=cnt_value(12);
		else	
			if( new_cnt_z2='1' ) then
				new_cnt_c<=new_cnt_c+'1';
			end if;
			
			cnt_value<=(others=>'0');  
			--new_cnt_c<=new_cnt_c+'1';
			new_cnt<= not new_cnt_c(3);	
			
		end if;
		if(new_cnt_c(2)='1')then
			freq_adc(15 downto 0)<= result_freq(26 downto 11)+result_freq(10);
		end if;
		
		freq_en <= new_cnt_c(3) after 1 ns;		
	
	end if;
end process;	

new_cnt_z <= new_cnt after 1 ns when rising_edge( clk_in );
new_cnt_z1 <= new_cnt_z after 1 ns when rising_edge( clk_in );
new_cnt_z2 <= new_cnt_z1 after 1 ns when rising_edge( clk_sys );

pr_value_adc: process(clk_in)
begin		
	if(rising_edge(clk_in))then	  
		if(new_cnt_z='0' and reset='1')then
			cnt_value_adc<=cnt_value_adc+'1'; 
			cnt_value_adc0<= cnt_value_adc;	
		else	
			cnt_value_adc<=(others=>'0');
		end if;
	end if;
end process;  


freq_sys<=	conv_std_logic_vector( Freq, 11 );


x_mult:ctrl_multiplier_v1_0
	port map(
	clk=> clk_sys,
	a=> cnt_value_adc0,
	b=> freq_sys,
	p=> result_freq
);  
	
	
	
	
end ctrl_freq;
