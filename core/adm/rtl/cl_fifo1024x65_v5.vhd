---------------------------------------------------------------------------------------------------
--
-- Title       : cl_fifo1024x65_v5
-- Author      : Dmitry Smekhov
-- Company     : Instrumental System
--
-- Version	   : 1.1	   
--
---------------------------------------------------------------------------------------------------
--
-- Description : Модуль FIFO 1024x65
--				 Модификация 5
--				 Выход FIFO - с регистра
--				 Уровни срабатывания флагов PAE, PAF - 32 слова
--				 Нет выходов от счётчиков слов
--
---------------------------------------------------------------------------------------------------
--
--	Version 1.1  17.05.2007
--				 Добавлен выход flag_empty
--
---------------------------------------------------------------------------------------------------
--
--	Version 1.0  26.12.2006
--				 Базовая версия
--
---------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use work.adm2_pkg.all;

package cl_fifo1024x65_v5_pkg is

component cl_fifo1024x65_v5 is   
	 port(				
	 	-- сброс
		 reset 		: in std_logic;							-- 0 - сброс
		 
	 	-- запись
		 clk_wr 	: in std_logic;							-- тактовая частота записи
		 data_in 	: in std_logic_vector( 63 downto 0 ); 	-- вход данных
		 data_inx 	: in std_logic:='0';					-- дополнительный разряд данных
		 data_en	: in std_logic;							-- 1 - запись в fifo
		 flag_wr	: out bl_fifo_flag;						-- флаги fifo, синхронно с clk_wr
		 
		 -- чтение
		 clk_rd 	: in std_logic;							-- тактовая частота чтения
		 data_out 	: out std_logic_vector( 63 downto 0 ); 	-- выход данных
		 data_outx	: out std_logic;						-- дополнительный разряд данных
		 data_cs	: in std_logic;							-- 0 - чтение из fifo
		 flag_rd	: out bl_fifo_flag;						-- флаги fifo, синхронно с clk_rd 
		 flag_empty	: out std_logic						  	-- 1 - внутреннее FIFO пустое
	    );
end component;

end package;




library ieee;
use ieee.std_logic_1164.all;
use work.adm2_pkg.all;

entity cl_fifo1024x65_v5 is   
	 port(				
	 	-- сброс
		 reset 		: in std_logic;							-- 0 - сброс
		 
	 	-- запись
		 clk_wr 	: in std_logic;							-- тактовая частота записи
		 data_in 	: in std_logic_vector( 63 downto 0 ); 	-- вход данных
		 data_inx 	: in std_logic:='0';					-- дополнительный разряд данных
		 data_en	: in std_logic;							-- 1 - запись в fifo
		 flag_wr	: out bl_fifo_flag;						-- флаги fifo, синхронно с clk_wr
		 
		 -- чтение
		 clk_rd 	: in std_logic;							-- тактовая частота чтения
		 data_out 	: out std_logic_vector( 63 downto 0 ); 	-- выход данных
		 data_outx	: out std_logic;						-- дополнительный разряд данных
		 data_cs	: in std_logic;							-- 0 - чтение из fifo
		 flag_rd	: out bl_fifo_flag;						-- флаги fifo, синхронно с clk_rd 
		 flag_empty	: out std_logic						  -- 1 - внутреннее FIFO пустое
	    );
end cl_fifo1024x65_v5;


architecture cl_fifo1024x65_v5 of cl_fifo1024x65_v5 is  


component ctrl_fifo1024x65_v5 is
	port (
	din: in std_logic_vector(64 downto 0);
	rd_clk: in std_logic;
	rd_en: in std_logic;
	rst: in std_logic;
	wr_clk: in std_logic;
	wr_en: in std_logic;
	dout: out std_logic_vector(64 downto 0);
	empty: out std_logic;
	full: out std_logic;
	prog_empty: out std_logic;
	prog_full: out std_logic;
	rd_data_count: out std_logic_vector(0 downto 0);
	wr_data_count: out std_logic_vector(0 downto 0));
end component;


component cl_fifo_control_v2 is   
	port(  
		reset		: in std_logic;		-- 0 - сброс
		clk			: in std_logic;		-- тактовая частота
		ef			: out std_logic;	-- 0 - FIFO пустое
		rd			: out std_logic;	-- 1 - чтение из FIFO
		we			: out std_logic;	-- 1 - запись во входной буфер
		empty		: in std_logic;		-- 1 - FIFO пустое
		read		: in std_logic 		-- 0 - запрос на чтение
		);
end component;


	
signal reset_p  	: std_logic;
signal r_en			: std_logic;	
signal full			: std_logic;
signal empty		: std_logic;
signal ef			: std_logic;  
signal s_pae,s_paf,s_hf	: std_logic;  
signal s_ovr,s_und:std_logic;
signal w_cnt,r_cnt	: std_logic_vector( 0 downto 0 ); 
signal fifo_in		: std_logic_vector( 64 downto 0 );
signal fifo_out		: std_logic_vector( 64 downto 0 );
signal data_out_we	: std_logic; 
signal prog_full	: std_logic;
signal prog_empty	: std_logic;

--attribute rlock_range: string;
--attribute rlock_range of crl: label is "R0C0:R3C0";
begin							   
	
	
fifo_in( 63 downto 0 ) <= data_in;
fifo_in( 64 ) <= data_inx;
	
ctrl_fifo : ctrl_fifo1024x65_v5
	port map (
		din 	 	=> fifo_in,
		wr_en 		=> data_en,
		wr_clk 		=> clk_wr,
		rd_en 		=> r_en,
		rd_clk 		=> clk_rd,
		rst 		=> reset_p,
		dout 		=> fifo_out,
		full 		=> full,
		empty 		=> empty,
		prog_empty  => prog_empty,
		prog_full   => prog_full,
		wr_data_count 	=> w_cnt,
		rd_data_count 	=> r_cnt
	);	
			
crl : cl_fifo_control_v2
	port map (

		reset		=> reset,		-- 0 - сброс
		clk			=> clk_rd,		-- тактовая частота
		ef			=> ef,			-- 0 - FIFO пустое
		rd			=> r_en,		-- 1 - чтение из FIFO
		we			=> data_out_we,	-- 1 - запись в выходной буфер
		empty		=> empty,		-- 1 - FIFO пустое
		read		=> data_cs 		-- 0 - запрос на чтение
	 );		

reset_p<=not reset;
flag_empty <= empty;
		

pr_fifo_out: process( clk_rd ) begin
	if( rising_edge( clk_rd ) ) then
	  if( data_out_we='1' ) then
		data_out<=fifo_out( 63 downto 0 ) after 1 ns;
	  end if;
	end if;
end process;

pr_fifo_outx: process( reset, clk_rd ) begin
	if( reset='0' ) then
		data_outx <= '0' after 1 ns;
	elsif( rising_edge( clk_rd ) ) then
	  if( data_out_we='1' ) then
		data_outx <= fifo_out( 64 ) after 1 ns;
	  end if;
	end if;
end process;

	
pr_errorU: process( reset, clk_rd )   
begin								 
	if (reset='0') then
		s_und<='0' after 1 ns;	
	elsif( rising_edge( clk_rd ) ) then	
		if( ef='0'  ) then		
			if(data_cs='0') then
				s_und<='1' after 1 ns;
			end if;
		end if;	
	end if;
end process;   

pr_errorA: process( reset, clk_wr )  
begin								 
	
	if (reset='0') then
		s_ovr<='0' after 1 ns;  
	elsif( rising_edge( clk_wr ) ) then		
		if(full='1' ) then
			if(data_en='1') then
				s_ovr<='1' after 1 ns;  	
			end if;
		end if;	
	end if;
end process; 
	
	

flag_rd.ef<=ef;
	
pr_flag_rd: process( reset, clk_rd ) 
 variable vef, vff: std_logic;
begin  
  if(reset='0') then
	  flag_rd.pae<='0' after 1 ns;
	  flag_rd.hf<='1'  after 1 ns;
	  flag_rd.paf<='1' after 1 ns;
	  flag_rd.ff<='1'  after 1 ns;
  elsif( rising_edge( clk_rd ) ) then
  		flag_rd.pae <= not prog_empty after 1 ns;
  		flag_rd.paf <= not prog_full  or not r_cnt(0) after 1 ns;
		flag_rd.hf  <= not r_cnt(0)   after 1 ns;
		flag_rd.ff  <= not full or not r_cnt(0) after 1 ns;
  end if;			  
end process;           

flag_rd.ovr<=s_ovr;
flag_rd.und<=s_und;


flag_wr.ff<=( not full ) or not w_cnt(0) after 1 ns;

pr_flag_wr: process( reset, clk_wr ) 

begin  
	if(reset='0') then
	  flag_wr.ef<='0'   after 1 ns;
	  flag_wr.pae<='0'  after 1 ns;
	  flag_wr.hf<='1'   after 1 ns;
	  flag_wr.paf<='1'  after 1 ns;

	elsif( rising_edge( clk_wr ) ) then
 		flag_wr.pae<=  not prog_empty after 1 ns;
 		flag_wr.paf<=  not prog_full or not w_cnt(0) after 1 ns;
		flag_wr.hf<=   not w_cnt(0)   after 1 ns;
		flag_wr.ef<=   ef             after 1 ns;
	end if;			  
	
end process;           
	
flag_wr.ovr<=s_ovr;
flag_wr.und<=s_und;




end cl_fifo1024x65_v5;

