---------------------------------------------------------------------------------------------------
--
-- Title       : ctrl_thdac
-- Design      : ADM2
-- Author      : Ilya Ivanov
-- Company     : Instrumental System
--									
-- Version     : 1.0
---------------------------------------------------------------------------------------------------
--
-- Description :  Управление ИПН
--
---------------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all ;


entity ctrl_thdac is
	 port(
		 reset : in STD_LOGIC;
		 clk : in STD_LOGIC;
		 start : in STD_LOGIC;
		 data_dac : in STD_LOGIC_VECTOR(11 downto 0);
		 clkDAC_out : out STD_LOGIC;
		 ld : out STD_LOGIC;
		 ready : out STD_LOGIC;
		 thrs  : out STD_LOGIC;
		 sdo_dac : out STD_LOGIC
	     );
end ctrl_thdac;



architecture ctrl_thdac of ctrl_thdac is	

signal counter : std_logic_vector(5 downto 0) ;		-- counter for reset
signal counter2 : std_logic_vector(7 downto 0) ;		-- counter for reset
signal counter_data : std_logic_vector(5 downto 0) ;		-- counter for reset
signal l_ready,l_ready2,l_clk:std_logic;   
signal l_data_dac : STD_LOGIC_VECTOR(11 downto 0);

begin	
thrs<=reset;	
pr_start: process( clk,reset ) 
begin  
	if(reset='0') then
		l_ready<='0';
	elsif( rising_edge( clk ) ) then
		if(start='1')then
			l_ready<='1';
			l_data_dac<=data_dac;
		elsif(counter_data = "11000")then
			l_ready<='0';	
		end if;			
			
	end if;			  
end process; 

pr_count: process( clk,reset ) 
begin  
	if(reset='0') then
		counter <= (others => '0') ;
		counter_data <= (others => '0') ;
	elsif( rising_edge( clk ) ) then
		if(l_ready='1')then
			counter <= counter + 1 ;  
			if (counter = "01010") then	
				counter <= (others => '0') ;
				counter_data <= counter_data + 1 ;
			end if;	 
		else   
			counter <= (others => '0') ;
			counter_data <= (others => '0') ;
		end if;
	end if;			  
end process;	


pr_clk_out: process( clk,reset ) 
begin  
	if(reset='0') then
		l_clk<='0';	
	clkDAC_out<='0';	
	elsif( rising_edge( clk ) ) then
		if(counter = "101")then
			l_clk<=not l_clk;
		end if;				
		clkDAC_out<=l_clk;
	end if;			  
end process;	
--clkDAC_out<=clk;
pr_data_out: process( clk,reset ) 
begin  
	if(reset='0') then
		sdo_dac<='0';	
	elsif( rising_edge( clk ) ) then
		if(counter = "00010" )then
			if( counter_data="00000")then
				sdo_dac<=l_data_dac(11);
			elsif( counter_data="00010")then
				sdo_dac<=l_data_dac(10);
			elsif( counter_data="00100")then
				sdo_dac<=l_data_dac(9);
			elsif( counter_data="00110")then
				sdo_dac<=l_data_dac(8);
			elsif( counter_data="01000")then
				sdo_dac<=l_data_dac(7);
			elsif( counter_data="01010")then
				sdo_dac<=l_data_dac(6);
			elsif( counter_data="01100")then
				sdo_dac<=l_data_dac(5);
			elsif( counter_data="01110")then
				sdo_dac<=l_data_dac(4);
			elsif( counter_data="10000")then
				sdo_dac<=l_data_dac(3);
			elsif( counter_data="10010")then
				sdo_dac<=l_data_dac(2);
			elsif( counter_data="10100")then
				sdo_dac<=l_data_dac(1);
			elsif( counter_data="10110")then
				sdo_dac<=l_data_dac(0);
			end if;
		 end if;
			 
	
	end if;			  
end process;


pr_count2: process( clk,reset ) 
begin  
	if(reset='0') then	 
		counter2 <= (others => '0') ;
	elsif( rising_edge( clk ) ) then
		if(l_ready2='1')then
			counter2 <= counter2 + 1 ;
		else
			counter2 <= (others => '0') ;
		end if;				
	end if;			  
end process;	

pr_ready2: process( clk,reset ) 
begin  
	if(reset='0') then	 
		l_ready2<='0';	
		ld<='0';
	elsif( rising_edge( clk ) ) then
		if(counter_data = "10111")then
			l_ready2<='1'; 
		elsif(counter2 = "1010")then
			ld<='1';   
		elsif(counter2 = "11111")then
			ld<='0'; 
		elsif(counter2 = "110110")then
			l_ready2<='0'; 
			 
		end if;				
	end if;			  
end process;	

pr_redy: process( clk,reset ) 
begin  
	if(reset='0') then	 
		ready<='1';
	elsif( rising_edge( clk ) ) then
		ready<=not (l_ready or l_ready2);
	end if;			  
end process;


end ctrl_thdac;
