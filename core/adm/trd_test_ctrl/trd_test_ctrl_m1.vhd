---------------------------------------------------------------------------------------------------
--
-- Title       : trd_test_ctrl_m1
-- Author      : Ilya Ivanov
-- Company     : Instrumental System
--
-- Version     : 1.3
--------------------------------------------------------------------------------------------------
--
-- Description : 	Приём цифрового потока
--
---------------------------------------------------------------------------------------------------
--
--   Version 1.3  11.06.2008
--                Добавлена возможность измерения тактовой частоты
--
---------------------------------------------------------------------------------------------------
--
--   Version 1.2  17.07.2007
--                Добавлены выходы регистров MODE0, MODE1, MODE2, MODE3
--				  Добавлен выход счётчика слов
--
---------------------------------------------------------------------------------------------------
--
--   Version 1.1  18.08.2006
--                Используется FIFO cl_fifo1024x64_v2                          
--
---------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;



	

library work;
use work.cl_chn_v3_pkg.all;				
use work.adm2_pkg.all;

package trd_test_ctrl_m1_pkg is
	
constant  ID_TEST			: std_logic_vector( 15 downto 0 ):=x"004F"; -- идентификатор тетрады
constant  ID_MODE_TEST		: std_logic_vector( 15 downto 0 ):=x"0001"; -- модификатор тетрады
constant  VER_TEST			: std_logic_vector( 15 downto 0 ):=x"0103";	-- версия тетрады
constant  RES_TEST			: std_logic_vector( 15 downto 0 ):=x"0000";	-- ресурсы тетрады
constant  FIFO_TEST			: std_logic_vector( 15 downto 0 ):=x"0000"; -- размер FIFO
constant  FTYPE_TEST	 	: std_logic_vector( 15 downto 0 ):=x"0000"; -- ширина FIFO

component trd_test_ctrl_m1 is 
	generic(
		SystemFreq 	: integer:= 500  	-- значение системной тактовой частоты
	);
	port(		
		-- GLOBAL
		reset				: in std_logic;		-- 0 - сброс
		clk					: in std_logic;		-- тактовая частота
		
		-- Управление тетрадой
		cmd_data_in			: in std_logic_vector( 15 downto 0 ); -- шина данных CMD_DATA
		cmd					: in bl_cmd;		-- сигналы управления
		
		cmd_data_out		: out std_logic_vector( 15 downto 0 ); -- выходы регистров, выход через буфер
		cmd_data_out2		: out std_logic_vector( 15 downto 0 ); -- выходы регистров, выход без буфера
		
		bx_irq				: out std_logic;  	-- 1 - прерывание от тетрады
		bx_drq				: out bl_drq;		-- управление DMA
		
		mode0				: out std_logic_vector( 15 downto 0 );	-- регистр MODE0
		mode1				: out std_logic_vector( 15 downto 0 );	-- регистр MODE1
		mode2				: out std_logic_vector( 15 downto 0 );	-- регистр MODE2
		mode3				: out std_logic_vector( 15 downto 0 );	-- регистр MODE3
		
		---- DIO_IN ----
		di_clk				: out std_logic;	-- тактовая частота записи в FIFO
		di_data				: out std_logic_vector( 63 downto 0 );	-- данные
		di_data_we			: out std_logic;	-- 1 - запись данных
		di_flag_wr			: in  bl_fifo_flag;	-- флаги FIFO
		di_fifo_rst			: in  std_logic;	-- 0 - сброс FIFO
		di_mode1			: in  std_logic_vector( 15 downto 0 ); -- регистр MODE1
		di_start			: in  std_logic;	-- 1 - разрешение работы (MODE0[5])
		
		---- DIO_OUT ----
		do_clk				: out std_logic; 	-- тактовая частота чтения из FIFO
		do_data				: in  std_logic_vector( 63 downto 0 );
		do_data_cs			: out std_logic;	-- 0 - чтение данных
		do_flag_rd			: in  bl_fifo_flag;	-- флаги FIFO
		do_fifo_rst			: in  std_logic;	-- 0 - сброс FIFO
		do_mode1			: in  std_logic_vector( 15 downto 0 );	-- регистр MODE1
		do_start			: in  std_logic;	-- 1 - разрешение работы (MODE0[5])
		
		---- Определение тактовой частоты ----
		clk_sys				: in std_logic:='0';		-- опорная тактовая частота
		clk_check0			: in std_logic:='0';		-- измеряемая частота, вход 0
		clk_check1			: in std_logic:='0';		-- измеряемая частота, вход 1
		clk_check2			: in std_logic:='0'			-- измеряемая частота, вход 2
		
		--------------------------------------------
		
		
		
	    );
end component;

end trd_test_ctrl_m1_pkg;

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.cl_chn_v3_pkg.all;				
use work.adm2_pkg.all;
use work.cl_test_generate_pkg.all;
use work.cl_test_check_pkg.all;
use work.ctrl_freq_pkg.all;

entity trd_test_ctrl_m1 is 
	generic(
		SystemFreq 	: integer:= 500  	-- значение системной тактовой частоты
	);
	port(		
		-- GLOBAL
		reset				: in std_logic;		-- 0 - сброс
		clk					: in std_logic;		-- тактовая частота
		
		-- Управление тетрадой
		cmd_data_in			: in std_logic_vector( 15 downto 0 ); -- шина данных CMD_DATA
		cmd					: in bl_cmd;		-- сигналы управления
		
		cmd_data_out		: out std_logic_vector( 15 downto 0 ); -- выходы регистров, выход через буфер
		cmd_data_out2		: out std_logic_vector( 15 downto 0 ); -- выходы регистров, выход без буфера
		
		bx_irq				: out std_logic;  	-- 1 - прерывание от тетрады
		bx_drq				: out bl_drq;		-- управление DMA
		
		mode0				: out std_logic_vector( 15 downto 0 );	-- регистр MODE0
		mode1				: out std_logic_vector( 15 downto 0 );	-- регистр MODE1
		mode2				: out std_logic_vector( 15 downto 0 );	-- регистр MODE2
		mode3				: out std_logic_vector( 15 downto 0 );	-- регистр MODE3
		
		---- DIO_IN ----
		di_clk				: out std_logic;	-- тактовая частота записи в FIFO
		di_data				: out std_logic_vector( 63 downto 0 );	-- данные
		di_data_we			: out std_logic;	-- 1 - запись данных
		di_flag_wr			: in  bl_fifo_flag;	-- флаги FIFO
		di_fifo_rst			: in  std_logic;	-- 0 - сброс FIFO
		di_mode1			: in  std_logic_vector( 15 downto 0 ); -- регистр MODE1
		di_start			: in  std_logic;	-- 1 - разрешение работы (MODE0[5])
		
		---- DIO_OUT ----
		do_clk				: out std_logic; 	-- тактовая частота чтения из FIFO
		do_data				: in  std_logic_vector( 63 downto 0 );
		do_data_cs			: out std_logic;	-- 0 - чтение данных
		do_flag_rd			: in  bl_fifo_flag;	-- флаги FIFO
		do_fifo_rst			: in  std_logic;	-- 0 - сброс FIFO
		do_mode1			: in  std_logic_vector( 15 downto 0 );	-- регистр MODE1
		do_start			: in  std_logic;	-- 1 - разрешение работы (MODE0[5])
		
		---- Определение тактовой частоты ----
		clk_sys				: in std_logic:='0';		-- опорная тактовая частота
		clk_check0			: in std_logic:='0';		-- измеряемая частота, вход 0
		clk_check1			: in std_logic:='0';		-- измеряемая частота, вход 1
		clk_check2			: in std_logic:='0'			-- измеряемая частота, вход 2
		
		--------------------------------------------
		
		
		
	    );
end trd_test_ctrl_m1;
														 
architecture trd_test_ctrl_m1 of trd_test_ctrl_m1 is 


signal rst,fifo_rst0		: std_logic;
signal flag_rdi		        : bl_fifo_flag;	
signal cmode0				: std_logic_vector( 15 downto 0 );
signal status				: std_logic_vector( 15 downto 0 );  
signal cmd_data_int			: std_logic_vector( 15 downto 0 );

signal test_check_ctrl		: std_logic_vector( 15 downto 0 );
signal test_check_size		: std_logic_vector( 15 downto 0 );	 
signal test_check_bl_rd	 	: std_logic_vector( 31 downto 0 );
signal test_check_bl_ok	    : std_logic_vector( 31 downto 0 );
signal test_check_bl_err	: std_logic_vector( 31 downto 0 );
signal test_check_error	    : std_logic_vector( 31 downto 0 );
signal test_check_err_adr	: std_logic_vector( 15 downto 0 );
signal test_check_err_data	: std_logic_vector( 15 downto 0 );
signal test_gen_ctrl		: std_logic_vector( 15 downto 0 );
signal test_gen_size		: std_logic_vector( 15 downto 0 );
signal test_gen_bl_wr		: std_logic_vector( 31 downto 0 );

signal	di_gen_data			: std_logic_vector( 63 downto 0 );
signal	di_gen_data_we		: std_logic;
signal	do_cs_rdy			: std_logic;
signal	do_data_en			: std_logic;
signal	mux_ctrl			: std_logic_vector( 1 downto 0 );

signal	cmd_reg				: std_logic_vector( 15 downto 0 );
signal	cmd_reg0			: std_logic_vector( 15 downto 0 );
signal	cmd_reg1			: std_logic_vector( 15 downto 0 );
signal	cmd_reg_i0			: std_logic_vector( 15 downto 0 );				 
signal	cmd_reg_i1			: std_logic_vector( 15 downto 0 );				 

signal	test_gen_cnt1		: std_logic_vector( 15 downto 0 );
signal	test_gen_cnt2		: std_logic_vector( 15 downto 0 );

signal	freq0				: std_logic_vector( 15 downto 0 );
signal	freq1				: std_logic_vector( 15 downto 0 );
signal	freq2				: std_logic_vector( 15 downto 0 );

begin		   

xstatus: ctrl_buft16 port map( 
	t => cmd.status_cs,
	i => cmd_data_int,
	o => cmd_data_out );

cmd_data_out2 <= cmd_data_int;	

cmd_data_int <= status when cmd.status_cs='0' else
				cmd_reg;
	
chn: cl_chn_v3 
	generic map(					 
	  -- 2 - out - для тетрады вывода
	  -- 1 - in  - для тетрады ввода
	  chn_type 			=> 1
	)
	port map (
		reset 			=> reset,
		clk 			=> clk,
		-- Флаги
		cmd_rdy 		=> '1',
		rdy				=> flag_rdi.ef,
		fifo_flag		=> flag_rdi,
		-- Тетрада	
		data_in			=> cmd_data_in,
		cmd				=> cmd,
		bx_irq			=> bx_irq,
		bx_drq			=> bx_drq,
		status			=> status,
		-- Управление
		mode0			=> cmode0,
		mode1			=> mode1,
		mode2			=> mode2,
		mode3			=> mode3,
		rst				=> rst,
		fifo_rst		=> fifo_rst0
	);

mode0 <= cmode0;

test_gen: cl_test_generate 
	port map(
	
		---- Global ----
		reset		=> rst,				-- 0 - сброс
		clk			=> clk,				-- тактовая частота
		
		---- DIO_IN ----
		di_clk		=> clk,				-- тактовая частота записи в FIFO
		di_data		=> di_gen_data,		-- данные
		di_data_we	=> di_gen_data_we,	-- 1 - запись данных
		di_flag_paf	=> di_flag_wr.paf,	-- 1 - есть место для записи
		di_fifo_rst	=> di_fifo_rst,		-- 0 - сброс FIFO
		di_start	=> di_start,		-- 1 - разрешение работы (MODE0[5])
		
		
		---- Управление ----
		test_gen_ctrl	=> test_gen_ctrl,
		test_gen_size	=> test_gen_size,		 -- размер в блоках по 512x64 (4096 байт)
		test_gen_bl_wr	=> test_gen_bl_wr,
		test_gen_cnt1	=> test_gen_cnt1,	-- Счётчик разрешения работы
		test_gen_cnt2	=> test_gen_cnt2	-- Счётчик запрещения работы
		
	);
	
	
test_check: cl_test_check 
	port map(
	
		---- Global ----
		reset		=> rst,				-- 0 - сброс
		clk			=> clk,				-- тактовая частота
		
		---- DIO_OUT ----
		do_clk		=> clk,		 		-- тактовая частота чтения из FIFO
		do_data		=> do_data,
		do_data_en	=> do_data_en,		-- 1 - передача данных из dio_out
		
		
		---- Управление ----
		test_check_ctrl			 => test_check_ctrl,		     
		test_check_size			 => test_check_size,		     
		test_check_bl_rd		 => test_check_bl_rd,	     
		test_check_bl_ok		 => test_check_bl_ok,	     
		test_check_bl_err		 => test_check_bl_err,	     
		test_check_error		 => test_check_error,	     
		test_check_err_adr		 => test_check_err_adr,	     
		test_check_err_data		 => test_check_err_data	     
);	

---- Мультиплексор для выходной последовательности ----
di_data <= do_data 			when mux_ctrl( 1 downto 0 )="00" else
		   di_gen_data		when mux_ctrl( 1 downto 0 )="01" else
			(others=>'0');		   
			
di_data_we <= do_data_en	 when mux_ctrl( 1 downto 0 )="00" else
		      di_gen_data_we when mux_ctrl( 1 downto 0 )="01" else
			  '0';
		 
pr_do_cs_rdy: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( mux_ctrl="00" ) then
			if( di_flag_wr.paf='1' and di_start='1' ) then
				do_cs_rdy <= '1' after 1 ns;
			else
				do_cs_rdy <= '0' after 1 ns;
			end if;
		else
			do_cs_rdy <= '1' after 1 ns;
		end if;
		
		if( do_flag_rd.pae='1' and do_start='1'  and do_cs_rdy='1' and rst='1') then
			do_data_en <= '1' after 1 ns;
			do_data_cs <= '0' after 1 ns;
		else
			do_data_en <= '0' after 1 ns;
			do_data_cs <= '1' after 1 ns;
		end if;
			
	end if;
end process;
			

cmd_reg_i0 <= 	test_check_bl_rd( 15 downto 0 )  	when cmd.adr( 3 downto 0 )=x"0" else
				test_check_bl_rd( 31 downto 16 ) 	when cmd.adr( 3 downto 0 )=x"1" else	
				test_check_bl_ok( 15 downto 0 )  	when cmd.adr( 3 downto 0 )=x"2" else
				test_check_bl_ok( 31 downto 16 ) 	when cmd.adr( 3 downto 0 )=x"3" else	
				test_check_bl_err( 15 downto 0 ) 	when cmd.adr( 3 downto 0 )=x"4" else
				test_check_bl_err( 31 downto 16 ) 	when cmd.adr( 3 downto 0 )=x"5" else	
				test_check_error( 15 downto 0 )  	when cmd.adr( 3 downto 0 )=x"6" else
				test_check_error( 31 downto 16 ) 	when cmd.adr( 3 downto 0 )=x"7" else	
				test_check_err_adr( 15 downto 0 )  	when cmd.adr( 3 downto 0 )=x"8" else
				test_check_err_data( 15 downto 0 )  when cmd.adr( 3 downto 0 )=x"9" else
				test_gen_bl_wr( 15 downto 0 )  		when cmd.adr( 3 downto 0 )=x"A" else
				test_gen_bl_wr( 31 downto 16 ) 		when cmd.adr( 3 downto 0 )=x"B" else	
				(others=>'-');

cmd_reg_i1 <= 		freq0  	when cmd.adr( 3 downto 0 )=x"0" else
					freq1	when cmd.adr( 3 downto 0 )=x"1" else	
					freq2;
				
cmd_reg0 <= cmd_reg_i0 after 1 ns when rising_edge( clk );
cmd_reg1 <= cmd_reg_i1 after 1 ns when rising_edge( clk );

cmd_reg <= cmd_reg0 when cmd.adr( 5 )='0' else cmd_reg1;

pr_reg: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( rst='0' ) then
			mux_ctrl <= (others=>'0') after 1 ns;
			test_check_ctrl <= (others=>'0') after 1 ns;
			test_check_size <= (others=>'0') after 1 ns;
			test_gen_ctrl <= (others=>'0') after 1 ns;
			test_gen_size <= (others=>'0') after 1 ns;
		elsif( cmd.cmd_data_we='1' and cmd.adr( 9 downto 8 )="00" ) then
			case( cmd.adr( 4 downto 0 ) ) is
				when "01111" =>  mux_ctrl <= cmd_data_in( 1 downto 0 ) after 1 ns;
				when "11010" =>  test_gen_cnt1   <= cmd_data_in after 1 ns;
				when "11011" =>  test_gen_cnt2   <= cmd_data_in after 1 ns;
				when "11100" =>  test_check_ctrl <= cmd_data_in after 1 ns;
				when "11101" =>  test_check_size <= cmd_data_in after 1 ns;
				when "11110" =>  test_gen_ctrl   <= cmd_data_in after 1 ns;
				when "11111" =>  test_gen_size   <= cmd_data_in after 1 ns;
				when others => null;
			end case;
		elsif( cmd.cmd_data_we='1' and cmd.adr( 9 downto 8 )="10" ) then
			case( cmd.adr( 4 downto 0 ) ) is
				when "11000" =>  test_check_err_adr   <= cmd_data_in after 1 ns;
				when others => null;
			end case;
		end if;
	end if;
end process;

do_clk <= clk;
di_clk <= clk;


fr0: ctrl_freq 
	generic map(
		SystemFreq 	=> SystemFreq,  	-- значение системной тактовой частоты
		FreqDiv		=> 1    			-- коэффициент деления входной частоты
										-- ( 2 - на вход подаётся половина измеряемой частоты )
	)
	port map( 
		reset		=> rst,			-- 0 - сброс
		clk_sys		=> clk_sys,		-- системная тактовая частота
		clk_in		=> clk_check0,	-- входная тактовая частота АЦП
		freq_adc	=> freq0		-- ориентировочное значение тактовой частоты АЦП в МГц
	);
	
fr1: ctrl_freq 
	generic map(
		SystemFreq 	=> SystemFreq,  	-- значение системной тактовой частоты
		FreqDiv		=> 1    			-- коэффициент деления входной частоты
										-- ( 2 - на вход подаётся половина измеряемой частоты )
	)
	port map( 
		reset		=> rst,			-- 0 - сброс
		clk_sys		=> clk_sys,		-- системная тактовая частота
		clk_in		=> clk_check1,	-- входная тактовая частота АЦП
		freq_adc	=> freq1		-- ориентировочное значение тактовой частоты АЦП в МГц
	);
	
fr2: ctrl_freq 
	generic map(
		SystemFreq 	=> SystemFreq,  	-- значение системной тактовой частоты
		FreqDiv		=> 1    			-- коэффициент деления входной частоты
										-- ( 2 - на вход подаётся половина измеряемой частоты )
	)
	port map( 
		reset		=> rst,			-- 0 - сброс
		clk_sys		=> clk_sys,		-- системная тактовая частота
		clk_in		=> clk_check2,	-- входная тактовая частота АЦП
		freq_adc	=> freq2		-- ориентировочное значение тактовой частоты АЦП в МГц
	);
	
	

end trd_test_ctrl_m1;
