---------------------------------------------------------------------------------------------------
--
-- Title       : trd_pio_std_v4
-- Design      : adp101v7_v20_admddc4x16_s
-- Author      : ILYA Ivanov
-- Company     : Instrumental System
--
---------------------------------------------------------------------------------------------------
--
-- Description : Модуль управления портом PIOX
--
---------------------------------------------------------------------------------------------------
--
-- Version     : 1.3
---------------------------------------------------------------------------------------------------
--					
-- Version 1.3  18.12.2009
--   			Исправлено формирование сигнала PIO_RD во время сброса
--
---------------------------------------------------------------------------------------------------
--					
-- Version 1.2  21.02.2006		 
--   			Добавлено использование сигналов TTL в режиме LVDS
--
---------------------------------------------------------------------------------------------------
--					
-- Version 1.1  12.12.2005
--				Убраны буфера с 3 состоянием
--
---------------------------------------------------------------------------------------------------


 
library ieee;   				  			   
use ieee.std_logic_1164.all;

use work.adm2_pkg.all;

package trd_pio_std_v4_pkg is
	
constant  ID_PIO_STD		: std_logic_vector( 15 downto 0 ):=x"0003"; -- идентификатор тетрады
constant  ID_MODE_PIO_STD	: std_logic_vector( 15 downto 0 ):=x"0004"; -- модификатор тетрады
constant  VER_PIO_STD		: std_logic_vector( 15 downto 0 ):=x"0103";	-- версия тетрады
constant  RES_PIO_STD		: std_logic_vector( 15 downto 0 ):=x"0000";	-- ресурсы тетрады
constant  FIFO_PIO_STD		: std_logic_vector( 15 downto 0 ):=x"0000"; -- размер FIFO
constant  FTYPE_PIO_STD 	: std_logic_vector( 15 downto 0 ):=x"0000"; -- ширина FIFO

component trd_pio_std_v4 is
	generic (					 
	  -- 1 - бит MODE1[ENABLE] не используется
	  -- 2 - бит MODE1[ENABLE] используется
	  use_enable : integer:=1 
	);
	port(		
	
		-- GLOBAL
		reset		: in std_logic;
		clk			: in std_logic;
		
		-- Управление тетрадой
		data_in		: in std_logic_vector( 15 downto 0 ); -- шина данных DATA
		cmd_data_in	: in std_logic_vector( 15 downto 0 ); -- шина данных CMD_DATA
		cmd			: in bl_cmd;						  -- сигналы управления
		
		data_out	: out std_logic_vector( 15 downto 0 ); -- выход данных с третьим состоянием (через buft)	
		data_out2   : out std_logic_vector( 15 downto 0 ); -- выход данных напрямую 
		cmd_data_out: out std_logic_vector( 15 downto 0 ); -- выходы регистров с третьим состоянием (через buft)
		cmd_data_out2 : out std_logic_vector( 15 downto 0 ); -- выходы регистров напрямую
		
		bx_irq		: out std_logic;  -- 1 - прерывание от тетрады

		--- сигналы управления PIOX ------------
	    pio_enable  : out std_logic; -- '0' - разрешение выхода pio_wr, pio_rd
		
		pen0		: out std_logic;
		
		pen1_in		: in  std_logic:='0';			
		pen1		: out std_logic;		
		pen1_oe		: out std_logic;	
		
		pio_oe0		: out std_logic; --	'0'	- разрешение выхода pio(7..0) 
		pio_oe1		: out std_logic; --	'0'	- разрешение выхода pio(15..8)
		
		pio_in		: in  std_logic_vector( 15 downto 0 ); -- вход данных
		pio_out		: out std_logic_vector( 15 downto 0 ); -- выход данных
		
		-- только для режима TTL
		pio_wr		: out std_logic; -- строб записи
		pio_rd		: out std_logic; -- строб чтения
		ack_wr		: in  std_logic; -- подтверждение записи
		ack_rd		: in  std_logic;  -- подтверждение чтения   	
		
		lvds		: out std_logic	 -- 0-режим LVDS разрешает выход pio(15,13,11,9)
		
	----------------------------------------
		
	    );
end component;
		
end trd_pio_std_v4_pkg;

			  
library ieee;
use ieee.std_logic_1164.all;	
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


use work.adm2_pkg.all;

entity trd_pio_std_v4 is 
	generic (					 
	  -- 1 - бит MODE1[ENABLE] не используется
	  -- 2 - бит MODE1[ENABLE] используется
	  use_enable : integer:=1 
	);
	port(		
	
		-- GLOBAL
		reset		: in std_logic;
		clk			: in std_logic;
		
		-- Управление тетрадой
		data_in		: in std_logic_vector( 15 downto 0 ); -- шина данных DATA
		cmd_data_in	: in std_logic_vector( 15 downto 0 ); -- шина данных CMD_DATA
		cmd			: in bl_cmd;						  -- сигналы управления
		
		data_out	: out std_logic_vector( 15 downto 0 ); -- выход данных с третьим состоянием (через buft)	
		data_out2   : out std_logic_vector( 15 downto 0 ); -- выход данных напрямую 
		cmd_data_out: out std_logic_vector( 15 downto 0 ); -- выходы регистров с третьим состоянием (через buft)
		cmd_data_out2 : out std_logic_vector( 15 downto 0 ); -- выходы регистров напрямую
		
		bx_irq		: out std_logic;  -- 1 - прерывание от тетрады

		--- сигналы управления PIOX ------------
	    pio_enable  : out std_logic; -- '0' - разрешение выхода pio_wr, pio_rd
		
		pen0		: out std_logic;
		
		pen1_in		: in  std_logic:='0';			
		pen1		: out std_logic;		
		pen1_oe		: out std_logic;	
		
		pio_oe0		: out std_logic; --	'0'	- разрешение выхода pio(7..0) 
		pio_oe1		: out std_logic; --	'0'	- разрешение выхода pio(15..8)
		
		pio_in		: in  std_logic_vector( 15 downto 0 ); -- вход данных
		pio_out		: out std_logic_vector( 15 downto 0 ); -- выход данных
		
		-- только для режима TTL
		pio_wr		: out std_logic; -- строб записи
		pio_rd		: out std_logic; -- строб чтения
		ack_wr		: in  std_logic; -- подтверждение записи
		ack_rd		: in  std_logic;  -- подтверждение чтения   	
		
		lvds		: out std_logic	 -- 0-режим LVDS разрешает выход pio(15,13,11,9)
		
	----------------------------------------
		
	    );
end trd_pio_std_v4;
														 

architecture trd_pio_std_v4 of trd_pio_std_v4 is 



signal  c_status		: std_logic_vector( 15 downto 0 );
signal  c_pio			: std_logic_vector( 15 downto 0 ); -- защёлкнутые данные с разъёма
signal  c_flag, c_irq	: std_logic_vector( 12 downto 9 );
signal  c_mask, c_inv	: std_logic_vector( 12 downto 9 );
signal  c_mode0			: std_logic_vector( 15 downto 0 );
signal	c_mode1			: std_logic_vector( 15 downto 0 );
signal	c_mode2			: std_logic_vector( 15 downto 0 );
signal  cnt_wr			: std_logic_vector( 7 downto 0 );  -- счётчик строба записи
signal  cnt_rd			: std_logic_vector( 7 downto 0 ):=(others=>'0');  -- счётчик строба чтения
signal 	cnt_wr_z		: std_logic; -- 1 - cnt_wr="0000"
signal  cnt_rd_z		: std_logic; -- 1 - cnt_rd="0000"
signal  fack_wr			: std_logic; -- 1 - фронт ack_wr
signal  fack_rd			: std_logic; -- 1 - фронт ack_rd
signal  fack_wr_clr 	: std_logic; -- 1 - сброс fack_wr
signal  fack_rd_clr 	: std_logic; -- 1 - сброс fack_rd
signal  pio_read		: std_logic; -- строб записи в c_pio
signal  start_rd		: std_logic; -- 1 - запуск счётчика cnt_rd
signal  c_rst			: std_logic; -- 0 - сброс тетрады
signal  cmd_rdy			: std_logic; -- 1 - готовность тетрады к выполнению команды	
--
signal  s_pio_in 		: std_logic_vector(15 downto 0);
signal  s_pio_out		: std_logic_vector(15 downto 0);   
signal  lvds_pio_in 	: std_logic_vector(15 downto 0);
signal  lvds_pio_out	: std_logic_vector(15 downto 0);  
signal	s_pio_wr		: std_logic; -- строб записи
signal	s_pio_rd		: std_logic; -- строб чтения
signal	s_ack_wr		: std_logic; -- подтверждение записи
signal	s_ack_rd		: std_logic;  -- подтверждение чтения 
signal  ack_wr_lvds 	: std_logic;
signal  ack_rd_lvds		: std_logic; 
signal 	pcout       	: std_logic;   
signal 	pio_en      	: std_logic;		   		 
signal	s_pio_wr_lvds	: std_logic;


begin		   
	
	
xstatus: ctrl_buft16 port map( 
	t => cmd.status_cs,
	i =>  c_status,
	o => cmd_data_out );
cmd_data_out2<=c_status;	
	
xdata: ctrl_buft16 port map(
	t => cmd.data_cs,
	i => c_pio,
	o => data_out ); 
data_out2<=c_pio;  
	
	
data_out2	<= c_pio; 
cmd_data_out2 <= c_status;

data_out2<=c_pio;  

	
	
pr_mode0: process( reset, clk ) begin
	if( reset='0' ) then
		c_mode0<=(others=>'0');
	elsif( rising_edge( clk ) ) then
		if( cmd.cmd_data_we='1' ) then
			if( cmd.adr(9)='0' and cmd.adr(8)='0' ) then
			  case cmd.adr( 3 downto 0 ) is
				  when "0000" => c_mode0<=cmd_data_in;
				  when others=>null;
			  end case;
			end if;
		end if;
	end if;
end process;			  

c_rst <= reset and ( not c_mode0(0) );


pr_reg: process( c_rst, clk ) 
begin
	if( c_rst='0' ) then
		c_mode1	<=(others=>'0');
		c_mode2	<=(others=>'0');	 
		c_mask	<=(others=>'0'); 			 
		c_inv	<=(others=>'0');		
	elsif( rising_edge( clk ) ) then
		if( cmd.cmd_data_we='1' ) then
			if( cmd.adr(9)='0' and cmd.adr(8)='0' ) then
			  case cmd.adr( 3 downto 0 ) is
				  when "0001" => c_mask( 12 downto 9 )<=cmd_data_in( 12 downto 9 );
				  when "0010" => c_inv( 12 downto 9 )<=cmd_data_in( 12 downto 9 );
				  when "1001" => c_mode1<=cmd_data_in;
				  when "1010" => c_mode2<=cmd_data_in;
				  when others=>null;
			  end case;
			end if;
		end if;
	end if;
end process;

c_status(1)<='0';
c_status(2)<='0';
c_status(3)<='0';
c_status(4)<='0';
c_status(5)<='0';
c_status(6)<='0';  
c_status(7)<='0';
c_status(8)<='0';
c_status(13)<='0';
c_status(14)<='0';
c_status(15)<='0';

c_status(11)<=fack_wr;
c_status(12)<=fack_rd;

pr_status: process( clk ) begin
	if( rising_edge( clk ) ) then
		c_status(0)<=cmd_rdy;
		c_status(9)<=s_ack_wr;
		c_status(10)<=s_ack_rd;
	end if;
end process; 


c_flag<=c_status( 12 downto 9 ) xor c_inv;
c_irq<= c_flag and c_mask;

pr_irq: process( c_irq, clk ) 
 variable v: std_logic;
begin	
	v:='0';
	for i in 9 to 12 loop
		v:=v or c_irq( i );
	end loop;
	if( rising_edge( clk ) ) then
		bx_irq<=v and c_mode0(2);
	end if;
end process;


pr_s_pio_wr: process( c_rst, clk ) begin
	if( c_rst='0' ) then
		cnt_wr<=(others=>'0');
	elsif( rising_edge( clk ) ) then
		if( cmd.data_we='1' ) then
			cnt_wr<=c_mode2( 7 downto 0 );
		elsif( cnt_wr_z='0' ) then
			cnt_wr<=cnt_wr-1;
		end if;
	end if;
end process;

cnt_wr_z<='1' when cnt_wr=x"00" else '0';
	
s_pio_wr<=cnt_wr_z or not c_rst;
	
--pr_s_pio_rd: process( c_rst, clk ) begin
--	if( c_rst='0' ) then
--		cnt_rd<=(others=>'0');
--	elsif( rising_edge( clk ) ) then
--		if( start_rd='1' ) then
--			cnt_rd<=c_mode2( 15 downto 8 );
--		elsif( cnt_rd_z='0' ) then
--			cnt_rd<=cnt_rd-1;
--		end if;
--	end if;
--end process;

pr_s_pio_rd: process( start_rd, c_rst, clk )
begin				 
	if( c_rst='0' ) then
		cnt_rd<=(others=>'0');
	elsif( start_rd='1' ) then
		cnt_rd<=c_mode2( 15 downto 8 );
	elsif( rising_edge( clk ) ) then
		if( cnt_rd_z='0' ) then
			cnt_rd<=cnt_rd-1;
		end if;
	end if;
end process;

cnt_rd_z<='1' when cnt_rd=x"00" else '0';
	
s_pio_rd<=cnt_rd_z or not c_rst;

pr_fack_wr: process( c_rst, s_ack_wr, fack_wr_clr ) begin
	if( c_rst='0' or fack_wr_clr='1' ) then
		fack_wr<='0';
	elsif( rising_edge( s_ack_wr ) ) then
		fack_wr<='1';
	end if;
end process;

pr_fack_rd: process( c_rst, s_ack_rd, fack_rd_clr ) begin
	if( c_rst='0' or fack_rd_clr='1' ) then
		fack_rd<='0';
	elsif( rising_edge( s_ack_rd ) ) then
		fack_rd<='1';
	end if;
end process;

--------------------------------------------------------------------

pr_start_rd: process( c_rst, clk ) begin
	if( c_rst='0' ) then
		start_rd<='0';
	elsif( rising_edge( clk ) ) then
		if( c_mode1(2)='0' ) then  -- внутренняя синхронизация
			if( cmd.cmd_data_we='1' and cmd.adr(9)='1' and cmd.adr(8)='0' 
				and cmd.adr(0)='1' )  then
				start_rd<='1';
			else
				start_rd<='0';
			end if;
		else                       -- внешняя синхронизация
			start_rd<=not cmd.data_cs;
		end if;
	end if;
end process;

pr_fack_clr: process( c_rst, clk ) 
 variable v0, v1: std_logic;
begin
	if( c_rst='0' ) then
		fack_wr_clr<='0';
		fack_rd_clr<='0';
	elsif( rising_edge( clk ) ) then
		v0:='0'; v1:='0';
		
		if( c_mode1(2)='0' ) then
		 if( cmd.cmd_data_we='1' ) then
			if( cmd.adr(9)='1' and cmd.adr(8)='0' and cmd.adr(0)='0' ) then
				v1:=cmd_data_in( 12 );
			end if;
		 end if;
		else
			v1:=not cmd.data_cs;
		end if;
		
		if( cmd.cmd_data_we='1' ) then
			if( cmd.adr(9)='1' and cmd.adr(8)='0' and cmd.adr(0)='0' ) then
				v0:=cmd_data_in( 11 );
			end if;
		end if;
		
		fack_wr_clr<=v0;
		fack_rd_clr<=v1;
		
	end if;
end process;

cmd_rdy <= cnt_wr_z and (cnt_rd_z or c_mode1(3)) ;   

pr_pio_out: process( c_rst, clk ) begin
	if( c_rst='0' ) then
		s_pio_out<=(others=>'0');
	elsif( rising_edge( clk ) ) then
		if( cmd.data_we='1' ) then
			s_pio_out<=data_in;	  
		end if;
	end if;
end process;

pr_c_pio: process( c_rst, pio_read ) begin
	if( c_rst='0' ) then
		c_pio<=(others=>'0');
	elsif( rising_edge( pio_read ) ) then
		c_pio<=s_pio_in;
	end if;
end process;
	
process(c_mode1(3 downto 2),cnt_rd_z,s_ack_rd,clk )
begin
	case c_mode1(3 downto 2) is 
		when "00" => pio_read <= cnt_rd_z;
		when "01" => pio_read <= s_ack_rd;
		when "10" => pio_read <= clk;
		when others => null;
	end case;
end process;	
	
pio_out  <=lvds_pio_out when c_mode1(10)='1' else s_pio_out; 

s_pio_in <=lvds_pio_in  when c_mode1(10)='1' else pio_in;  
	
gen_pio: for ii in 0 to 7 generate
	lvds_pio_out(ii*2)<= s_pio_out(ii); 
	lvds_pio_in(ii) <= pio_in(2*ii);
end generate; 

lvds_pio_out(9)<='1';	--pen0
lvds_pio_out(11)<='0';	--pen1
lvds_pio_out(13)<=c_mode1(0);
lvds_pio_out(15)<=c_mode1(1);




pio_enable<=pio_en; -- not c_mode1(11); 

gen_en1: if use_enable=2 generate pio_en <= not c_mode1(11); end generate;
gen_en2: if use_enable=1 generate pio_en <= '0';			 end generate;
	
pio_wr    <= s_pio_wr when c_mode1(10)='0' else s_pio_wr_lvds;
pio_rd    <= s_pio_rd;
s_ack_wr  <= ack_wr when c_mode1(10)='0' else ack_wr_lvds  ;
s_ack_rd  <= ack_rd when c_mode1(10)='0' else ack_rd_lvds  ;  
	
process(c_mode1(13), pen1_in)
begin
	if c_mode1(13) ='0' then
		ack_wr_lvds<=pen1_in; ack_rd_lvds<=ack_rd;
	else
		ack_rd_lvds<=pen1_in; ack_wr_lvds<=ack_rd;
	end if;
end process;									 

s_pio_wr_lvds <= s_pio_wr when c_mode1(12)='0' else s_pio_rd;

pcout<=s_pio_rd when c_mode1(12)='0' else s_pio_wr;

pen0 <= pcout when c_mode1(10)='1' else not c_mode1(0);
pen1 <= not c_mode1(1);	

pio_oe0 <= not c_mode1(0) or  pio_en; 
pio_oe1 <= not c_mode1(1) or  pio_en; 
lvds	<= not c_mode1(1) or  pio_en when  c_mode1(10) ='0' else pio_en; 

pen1_oe<=c_mode1(10) or pio_en;

end trd_pio_std_v4;

