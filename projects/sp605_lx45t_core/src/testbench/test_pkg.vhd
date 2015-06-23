---------------------------------------------------------------------------------------------------
--
-- Title       : test_pkg.vhd
-- Author      : Dmitry Smekhov 
-- Company     : Instrumental System
--	
-- Version     : 1.0			 
--
---------------------------------------------------------------------------------------------------
--
-- Description : Пакет для тестирования ambpex5.
--
---------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;		
use ieee.std_logic_arith.all;  
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use std.textio.all;


library work;
use work.cmd_sim_pkg.all;	  	
use work.block_pkg.all;	
use work.trd_pkg.all;



package test_pkg is
	
--! Инициализация теста	
procedure test_init(
		fname: in string 	--! имя файла отчёта
	);
	
--! Завершение теста		
procedure test_close;						
	
	
	
--! Запуск DMA с неправильным дескриптором 
procedure test_dsc_incorrect (
		signal  cmd:	out bh_cmd; --! команда
		signal  ret:	in  bh_ret  --! ответ
		);

--! Запуск DMA на приём одного блока 4 кБ
procedure test_read_4kb (
		signal  cmd:	out bh_cmd; --! команда
		signal  ret:	in  bh_ret  --! ответ
		);

				
--! Чтение 8 кБ из тетрады DIO_IN 
procedure test_adm_read_8kb (
		signal  cmd:	out bh_cmd; --! команда
		signal  ret:	in  bh_ret  --! ответ
		);

--! Проверка обращений к блоку MAIN 
procedure test_block_main (
		signal  cmd:	out bh_cmd; --! команда
		signal  ret:	in  bh_ret  --! ответ
		);
		
--! Чтение 16 кБ с использованием двух блоков дескрипторов
procedure test_adm_read_16kb (
		signal  cmd:	out bh_cmd; --! команда
		signal  ret:	in  bh_ret  --! ответ
		);
		
--! Запись 16 кБ с использованием двух блоков дескрипторов
procedure test_adm_write_16kb (
		signal  cmd:	out bh_cmd; --! команда
		signal  ret:	in  bh_ret  --! ответ
		);		
	
end package	test_pkg;

package body test_pkg is
	
	FILE   log: text;
	
	shared variable cnt_ok, cnt_error: integer;
	
	-- Инициализация теста	
	procedure test_init(
		fname: in string 					-- имя файла отчёта
		) is
	begin
		
		file_open( log, fname, WRITE_MODE );
		cnt_ok:=0;
		cnt_error:=0;
		
	end test_init;	
	
	-- Завершение теста		
	procedure test_close is		
		variable str : LINE;		-- pointer to string
	begin					  	
		
		std.textio.write( str, string'(" " ));
		writeline( log, str );		
		writeline( log, str );		
		
		write( str, string'("Проверка завершена" ));
		writeline( log, str );		
		write( str, string'("Число успешных тестов:  " ));
		write( str, cnt_ok );
		writeline( log, str );		
		write( str, string'("Число ошибочных тестов: " ));
		write( str, cnt_error );
		writeline( log, str );		
		
		
		file_close( log ); 
		
	end test_close;	
	
	
	
--! Запуск DMA с неправильным дескриптором 
procedure test_dsc_incorrect (
		signal  cmd:	out bh_cmd; --! команда
		signal  ret:	in  bh_ret  --! ответ
		) 
is

variable	adr		: std_logic_vector( 31 downto 0 );
variable	data	: std_logic_vector( 31 downto 0 );
variable	str		: line;
begin
		
	write( str, string'("TEST_DSC_INCORRECT" ));
	writeline( log, str );	
	
	---- Формирование блока дескрипторов ---
	for ii in 0 to 127 loop
		adr:= x"00100000";
		adr:=adr + ii*4;
		int_mem_write( cmd, ret, adr,  x"00000000" );
	end loop;										 
	
	int_mem_write( cmd, ret, x"00100000",  x"03020100" );
	int_mem_write( cmd, ret, x"001001FC",  x"FF00AA00" );
	
	---- Программирование канала DMA ----
	block_write( cmd, ret, 4, 8, x"00000027" );		-- DMA_MODE 
	block_write( cmd, ret, 4, 9, x"00000010" );		-- DMA_CTRL - RESET FIFO 
	
	block_write( cmd, ret, 4, 20, x"00100000" );	-- PCI_ADRL 
	block_write( cmd, ret, 4, 21, x"00100000" );	-- PCI_ADRH  
	block_write( cmd, ret, 4, 23, x"0000A400" );	-- LOCAL_ADR 
	
	block_write( cmd, ret, 4, 9, x"00000001" );		-- DMA_CTRL - START 
	
	wait for 10 us;
	
	block_read( cmd, ret, 4, 16, data );			-- STATUS 
	
	write( str, string'("STATUS: " )); hwrite( str, data( 15 downto 0 ) );
	if( data( 15 downto 0 )=x"A021" ) then
		write( str, string'(" - Ok" ));	
		cnt_ok := cnt_ok + 1;
	else
		write( str, string'(" - Error" ));
		cnt_error := cnt_error + 1;
	end if;
	
	writeline( log, str );	
	
	block_write( cmd, ret, 4, 9, x"00000000" );		-- DMA_CTRL - STOP  
		
end test_dsc_incorrect;
	

--! Запуск DMA приём одного блока 4 кБ
procedure test_read_4kb (
		signal  cmd:	out bh_cmd; --! команда
		signal  ret:	in  bh_ret  --! ответ
		)
is

variable	adr				: std_logic_vector( 31 downto 0 );
variable	data			: std_logic_vector( 31 downto 0 );
variable	str				: line;			   

variable	error			: integer:=0;
variable	dma_complete	: integer;

begin
		
	write( str, string'("TEST_READ_4KB" ));
	writeline( log, str );	
	
	---- Формирование блока дескрипторов ---
	for ii in 0 to 127 loop
		adr:= x"00100000";
		adr:=adr + ii*4;
		int_mem_write( cmd, ret, adr,  x"00000000" );
	end loop;										 
	
	int_mem_write( cmd, ret, x"00100000",  x"00008000" );
	int_mem_write( cmd, ret, x"00100004",  x"00000100" );

	
	int_mem_write( cmd, ret, x"001001F8",  x"00000000" );
	int_mem_write( cmd, ret, x"001001FC",  x"762C4953" );
	
	---- Программирование канала DMA ----
	block_write( cmd, ret, 4, 8, x"00000025" );		-- DMA_MODE 
	block_write( cmd, ret, 4, 9, x"00000010" );		-- DMA_CTRL - RESET FIFO 
	
	block_write( cmd, ret, 4, 20, x"00100000" );	-- PCI_ADRL 
	block_write( cmd, ret, 4, 21, x"00100000" );	-- PCI_ADRH  
	block_write( cmd, ret, 4, 23, x"0000A400" );	-- LOCAL_ADR 
	
	block_write( cmd, ret, 4, 9, x"00000001" );		-- DMA_CTRL - START 
	
	wait for 20 us;
	
	block_read( cmd, ret, 4, 16, data );			-- STATUS 
	
	write( str, string'("STATUS: " )); hwrite( str, data( 15 downto 0 ) );
	if( data( 8 )='1' ) then
		write( str, string'(" - Дескриптор правильный" ));	
	else
		write( str, string'(" - Ошибка чтения дескриптора" ));
		error := error + 1;
	end if;
	
	writeline( log, str );	
	
	if( error=0 ) then
		
		---- Ожидание завершения DMA ----
		dma_complete := 0;
		for ii in 0 to 100 loop
			
		block_read( cmd, ret, 4, 16, data );			-- STATUS 
		write( str, string'("STATUS: " )); hwrite( str, data( 15 downto 0 ) );
			if( data(5)='1' ) then
				write( str, string'(" - DMA завершён " ));
				dma_complete := 1;
			end if;
			writeline( log, str );			
			
			if( dma_complete=1 ) then
				exit;
			end if;		   
			
			wait for 1 us;
			
		end loop;
	
		writeline( log, str );			
		
		if( dma_complete=0 ) then
			write( str, string'("Ошибка - DMA не завершён " ));
			writeline( log, str );			
			error:=error+1;
		end if;

	end if; 
	
	for ii in 0 to 3 loop
			
		block_read( cmd, ret, 4, 16, data );			-- STATUS 
		write( str, string'("STATUS: " )); hwrite( str, data( 15 downto 0 ) );
		writeline( log, str );			
		wait for 500 ns;
		
	end loop;
	
	
	block_write( cmd, ret, 4, 9, x"00000000" );		-- DMA_CTRL - STOP  	
	
	write( str, string'(" Прочитано: " ));
	writeline( log, str );		
	
	for ii in 0 to 15 loop

		adr:= x"00800000";
		adr:=adr + ii*4;
		int_mem_read( cmd, ret, adr,  data );
		
		write( str, ii ); write( str, string'("   " )); hwrite( str, data );
		writeline( log, str );		
		
	end loop;
	
	
--	block_write( cmd, ret, 4, 9, x"00000010" );		-- DMA_CTRL - RESET FIFO 
--	block_write( cmd, ret, 4, 9, x"00000000" );		-- DMA_CTRL 
--	block_write( cmd, ret, 4, 9, x"00000001" );		-- DMA_CTRL - START  	
	
	
	writeline( log, str );		
	if( error=0 ) then
		write( str, string'(" Тест завершён успешно " ));
		cnt_ok := cnt_ok + 1;
	else
		write( str, string'(" Тест не выполнен " ));
		cnt_error := cnt_error + 1;
	end if;
	writeline( log, str );	
	writeline( log, str );		

end test_read_4kb;


--! Чтение 8 кБ из тетрады DIO_IN 
procedure test_adm_read_8kb (
		signal  cmd:	out bh_cmd; --! команда
		signal  ret:	in  bh_ret  --! ответ
		)
is

variable	adr				: std_logic_vector( 31 downto 0 );
variable	data			: std_logic_vector( 31 downto 0 );
variable	str				: line;			   

variable	error			: integer:=0;
variable	dma_complete	: integer;

begin
		
	write( str, string'("TEST_ADM_READ_8KB" ));
	writeline( log, str );	
	
	---- Формирование блока дескрипторов ---
	for ii in 0 to 127 loop
		adr:= x"00100000";
		adr:=adr + ii*4;
		int_mem_write( cmd, ret, adr,  x"00000000" );
	end loop;										 
	
	--- Дескриптор 0 ---
	int_mem_write( cmd, ret, x"00100000",  x"00008000" ); 
	int_mem_write( cmd, ret, x"00100004",  x"00000111" );  	-- переход к следующему 

	--- Дескриптор 1 ---
	int_mem_write( cmd, ret, x"00100008",  x"00008010" ); 
	int_mem_write( cmd, ret, x"0010000C",  x"00000110" );  	-- остановка
	
	
	int_mem_write( cmd, ret, x"001001F8",  x"00000000" );
	int_mem_write( cmd, ret, x"001001FC",  x"D6644953" );
	
	trd_test_mode( cmd, ret, 0 );	-- переход в рабочий режим --
	
	---- Программирование канала DMA ----
	block_write( cmd, ret, 4, 8, x"00000027" );		-- DMA_MODE 
	block_write( cmd, ret, 4, 9, x"00000010" );		-- DMA_CTRL - RESET FIFO 
	
	block_write( cmd, ret, 4, 20, x"00100000" );	-- PCI_ADRL 
	block_write( cmd, ret, 4, 21, x"00100000" );	-- PCI_ADRH  
	block_write( cmd, ret, 4, 23, x"00019000" );	-- LOCAL_ADR 
	
	
	---- Подготовка тетрады ----
	trd_test_mode( cmd, ret, 0 );	-- переход в рабочий режим --
	trd_wait_cmd( cmd, ret, 0, 16, x"1600" );		-- DMAR0 - от тетрады 6 --

	trd_wait_cmd( cmd, ret, 1, 16#1F#, x"0001" );	-- Размер блока = 4 кБ --

	block_write( cmd, ret, 4, 9, x"00000001" );		-- DMA_CTRL - START 

	trd_wait_cmd( cmd, ret, 1, 16#0F#, x"0001" );	-- Подключение выхода генератора к DIO_IN --
	
	trd_wait_cmd( cmd, ret, 6, 	0, x"2038" );		-- запуск тетрады DIO_IN
	
	trd_wait_cmd( cmd, ret, 1, 16#1E#, x"0020" );	-- Запуск тестовой последовательности --
	
	wait for 20 us;
	
	block_read( cmd, ret, 4, 16, data );			-- STATUS 
	
	write( str, string'("STATUS: " )); hwrite( str, data( 15 downto 0 ) );
	if( data( 8 )='1' ) then
		write( str, string'(" - Дескриптор правильный" ));	
	else
		write( str, string'(" - Ошибка чтения дескриптора" ));
		error := error + 1;
	end if;
	
	writeline( log, str );	
	
	if( error=0 ) then
		
		---- Ожидание завершения DMA ----
		dma_complete := 0;
		for ii in 0 to 100 loop
			
		block_read( cmd, ret, 4, 16, data );			-- STATUS 
		write( str, string'("STATUS: " )); hwrite( str, data( 15 downto 0 ) );
			if( data(5)='1' ) then
				write( str, string'(" - DMA завершён " ));
				dma_complete := 1;	
				
				block_write( cmd, ret, 4, 16#11#, x"00000010" );		-- FLAG_CLR - сброс EOT 
				
			end if;
			writeline( log, str );			
			
			if( dma_complete=1 ) then
				exit;
			end if;		   
			
			wait for 1 us;
			
		end loop;
	
		writeline( log, str );			
		
		if( dma_complete=0 ) then
			write( str, string'("Ошибка - DMA не завершён " ));
			writeline( log, str );			
			error:=error+1;
		end if;

	end if; 
	
	for ii in 0 to 3 loop
			
		block_read( cmd, ret, 4, 16, data );			-- STATUS 
		write( str, string'("STATUS: " )); hwrite( str, data( 15 downto 0 ) );
		writeline( log, str );			
		wait for 500 ns;
		
	end loop;
	
	
	block_write( cmd, ret, 4, 9, x"00000000" );		-- DMA_CTRL - STOP  	
	
	write( str, string'(" Блок 0 - прочитано: " ));
	writeline( log, str );		
	
	for ii in 0 to 15 loop

		adr:= x"00800000";
		adr:=adr + ii*4;
		int_mem_read( cmd, ret, adr,  data );
		
		write( str, ii ); write( str, string'("   " )); hwrite( str, data );
		writeline( log, str );		
		
	end loop;

	writeline( log, str );		
	
	write( str, string'(" Блок 1 - прочитано: " ));
	writeline( log, str );		
	
	for ii in 0 to 15 loop

		adr:= x"00801000";
		adr:=adr + ii*4;
		int_mem_read( cmd, ret, adr,  data );
		
		write( str, ii ); write( str, string'("   " )); hwrite( str, data );
		writeline( log, str );		
		
	end loop;
	
	
--	block_write( cmd, ret, 4, 9, x"00000010" );		-- DMA_CTRL - RESET FIFO 
--	block_write( cmd, ret, 4, 9, x"00000000" );		-- DMA_CTRL 
--	block_write( cmd, ret, 4, 9, x"00000001" );		-- DMA_CTRL - START  	
	
	
	writeline( log, str );		
	if( error=0 ) then
		write( str, string'(" Тест завершён успешно " ));
		cnt_ok := cnt_ok + 1;
	else
		write( str, string'(" Тест не выполнен " ));
		cnt_error := cnt_error + 1;
	end if;
	writeline( log, str );	
	writeline( log, str );		

end test_adm_read_8kb;


--! Проверка обращений к блоку MAIN 
procedure test_block_main (
		signal  cmd:	out bh_cmd; --! команда
		signal  ret:	in  bh_ret  --! ответ
		)
is

variable	adr				: std_logic_vector( 31 downto 0 );
variable	data			: std_logic_vector( 31 downto 0 );
variable	str				: line;			   

variable	error			: integer:=0;
variable	dma_complete	: integer;

begin
		
	write( str, string'("TEST_BLOCK_MAIN" ));
	writeline( log, str );	

	block_read( cmd, ret, 4, 16#00#, data );			
	write( str,  string'("БЛОК 4: " )); hwrite( str, data ); writeline( log, str );	

	wait for 10 us;
	
--	write( str, "Константы:" );
--	writeline( log, str );	
--	for ii in 0 to 5 loop
--		write( str, "Блок " );
--		write( str, ii );
--		for jj in 0 to 7 loop
--			block_read( cmd, ret, ii, jj, data );			
--			write( str, "   " );
--			hwrite( str, data );
--		end loop;
--		writeline( log, str );		
--	end loop;
--		
--	
--	writeline( log, str );							
--	
--	block_read( cmd, ret, 0, 16#10#, data );			
--	write( str,  "STATUS: " ); hwrite( str, data ); writeline( log, str );	
--	
--	block_write( cmd, ret, 80, 16#08#, x"00000100" );			
--	
--	block_read( cmd, ret, 0, 16#10#, data );			
--	write( str, "STATUS: " ); hwrite( str, data ); writeline( log, str );	
--	
--	block_write( cmd, ret, 80, 16#08#, x"00000200" );			
--	
--	block_read( cmd, ret, 0, 16#10#, data );			
--	write( str, "STATUS: " ); hwrite( str, data ); writeline( log, str );	
--	
--	
--	writeline( log, str );		
--	if( error=0 ) then
--		write( str, " Тест завершён успешно " );
--		cnt_ok := cnt_ok + 1;
--	else
--		write( str, " Тест не выполнен " );
--		cnt_error := cnt_error + 1;
--	end if;

	for ii in 0 to 127 loop
	
		block_write( cmd, ret, 4, 16#08#, x"0000AA55" );				
		block_read( cmd, ret, 4, 8, data );
		write( str, string'("READ: " )); hwrite( str, data( 15 downto 0 ) ); writeline( log, str );		
		if( data/=x"0000AA55" ) then
			error:=error+1;
		end if;
	
	end loop;
	
	


	writeline( log, str );	
	writeline( log, str );		

end test_block_main;
			



--! Чтение 16 кБ с использованием двух блоков дескрипторов
procedure test_adm_read_16kb (
		signal  cmd:	out bh_cmd; --! команда
		signal  ret:	in  bh_ret  --! ответ
		)
is

variable	adr				: std_logic_vector( 31 downto 0 );
variable	data			: std_logic_vector( 31 downto 0 );
variable	str				: line;			   

variable	error			: integer:=0;
variable	dma_complete	: integer; 
variable	kk				: integer;	 
variable	status			: std_logic_vector( 15 downto 0 );

begin
		
	write( str, string'("TEST_ADM_READ_16KB" ));
	writeline( log, str );	
	
	---- Формирование блока дескрипторов ---
	for ii in 0 to 256 loop
		adr:= x"00100000";
		adr:=adr + ii*4;
		int_mem_write( cmd, ret, adr,  x"00000000" );
	end loop;										 
	
	--- Блок 0 ---
	
	--- Дескриптор 0 ---
	int_mem_write( cmd, ret, x"00100000",  x"00008000" ); 
	int_mem_write( cmd, ret, x"00100004",  x"00000111" );  	-- переход к следующему дескриптору 

	--- Дескриптор 1 ---
	int_mem_write( cmd, ret, x"00100008",  x"00008010" ); 
	int_mem_write( cmd, ret, x"0010000C",  x"00000112" );  	-- переход к следующему блоку 

	--- Дескриптор 2 ---
	int_mem_write( cmd, ret, x"00100010",  x"00001002" ); 	-- адрес следующего дескриптора 
	int_mem_write( cmd, ret, x"00100014",  x"00000000" );  	
	
	
	int_mem_write( cmd, ret, x"001001F8",  x"00000000" );
	int_mem_write( cmd, ret, x"001001FC",  x"14644953" );	   
	

	--- Блок 1 ---
	
	--- Дескриптор 0 ---
	int_mem_write( cmd, ret, x"00100200",  x"00008020" ); 
	int_mem_write( cmd, ret, x"00100204",  x"00000111" );  	-- переход к следующему дескриптору 

	--- Дескриптор 1 ---
	int_mem_write( cmd, ret, x"00100208",  x"00008030" ); 
	int_mem_write( cmd, ret, x"0010020C",  x"00000110" );  	-- остановка
	
	
	int_mem_write( cmd, ret, x"001003F8",  x"00000000" );
	int_mem_write( cmd, ret, x"001003FC",  x"D67C4953" );	   
	
	
	
	---- Программирование канала DMA ----
	block_write( cmd, ret, 4, 8, x"00000027" );		-- DMA_MODE 
	block_write( cmd, ret, 4, 9, x"00000010" );		-- DMA_CTRL - RESET FIFO 
	
	block_write( cmd, ret, 4, 20, x"00100000" );	-- PCI_ADRL 
	block_write( cmd, ret, 4, 21, x"00100000" );	-- PCI_ADRH  
	block_write( cmd, ret, 4, 23, x"00019000" );	-- LOCAL_ADR 
	
	
	---- Подготовка тетрады ----
	trd_test_mode( cmd, ret, 0 );	-- переход в рабочий режим --
	trd_wait_cmd( cmd, ret, 0, 16, x"1600" );		-- DMAR0 - от тетрады 6 --

	trd_wait_cmd( cmd, ret, 1, 16#1F#, x"0001" );	-- Размер блока = 4 кБ --

	block_write( cmd, ret, 4, 9, x"00000001" );		-- DMA_CTRL - START 

	trd_wait_cmd( cmd, ret, 1, 16#0F#, x"0001" );	-- Подключение выхода генератора к DIO_IN --
	
	trd_wait_cmd( cmd, ret, 6, 	0, x"2038" );		-- запуск тетрады DIO_IN
	
	trd_wait_cmd( cmd, ret, 1, 16#1E#, x"0020" );	-- Запуск тестовой последовательности --
	
	wait for 20 us;
	
	block_read( cmd, ret, 4, 16, data );			-- STATUS 
	
	write( str, string'("STATUS: " )); hwrite( str, data( 15 downto 0 ) );
	if( data( 8 )='1' ) then
		write( str, string'(" - Дескриптор правильный" ));	
	else
		write( str, string'(" - Ошибка чтения дескриптора" ));
		error := error + 1;
	end if;
	
	writeline( log, str );	
	
	if( error=0 ) then		   
		
		kk:=0;
		loop
			
		trd_status( cmd, ret, 6, status );
		write( str, string'("TRD_STATUS: " )); hwrite( str, status );
			
		block_read( cmd, ret, 4, 16, data );			-- STATUS 
		write( str, string'("    STATUS: " )); hwrite( str, data( 15 downto 0 ) );
		
			if( data(4)='1' ) then
				write( str, string'(" - завершено чтение блока " ));
				block_write( cmd, ret, 4, 16#11#, x"00000010" );		-- FLAG_CLR - сброс EOT 
				kk:=kk+1;
				if( kk=4 ) then
					exit;
				end if;
			end if;
			writeline( log, str );			
			
			wait for 500 ns;
			
			
		end loop;
		
		---- Ожидание завершения DMA ----
		dma_complete := 0;
		for ii in 0 to 100 loop
			
		block_read( cmd, ret, 4, 16, data );			-- STATUS 
		write( str, string'("STATUS: " )); hwrite( str, data( 15 downto 0 ) );
			if( data(5)='1' ) then
				write( str, string'(" - DMA завершён " ));
				dma_complete := 1;	
				
				block_write( cmd, ret, 4, 16#11#, x"00000010" );		-- FLAG_CLR - сброс EOT 
				
			end if;
			writeline( log, str );			
			
			if( dma_complete=1 ) then
				exit;
			end if;		   
			
			wait for 1 us;
			
		end loop;
	
		writeline( log, str );			
		
		if( dma_complete=0 ) then
			write( str, string'("Ошибка - DMA не завершён " ));
			writeline( log, str );			
			error:=error+1;
		end if;

	end if; 
	
	for ii in 0 to 3 loop
			
		block_read( cmd, ret, 4, 16, data );			-- STATUS 
		write( str, string'("STATUS: " )); hwrite( str, data( 15 downto 0 ) );
		writeline( log, str );			
		wait for 500 ns;
		
	end loop;
	
	
	block_write( cmd, ret, 4, 9, x"00000000" );		-- DMA_CTRL - STOP  	
	
	write( str, string'(" Блок 0 - прочитано: " ));
	writeline( log, str );		
	
	for ii in 0 to 15 loop

		adr:= x"00800000";
		adr:=adr + ii*4;
		int_mem_read( cmd, ret, adr,  data );
		
		write( str, ii ); write( str, string'("   " )); hwrite( str, data );
		writeline( log, str );		
		
	end loop;

	writeline( log, str );		
	
	write( str, string'(" Блок 1 - прочитано: " ));
	writeline( log, str );		
	
	for ii in 0 to 15 loop

		adr:= x"00801000";
		adr:=adr + ii*4;
		int_mem_read( cmd, ret, adr,  data );
		
		write( str, ii ); write( str, string'("   " )); hwrite( str, data );
		writeline( log, str );		
		
	end loop;

	write( str, string'(" Блок 2 - прочитано: " ));
	writeline( log, str );		
	
	for ii in 0 to 15 loop

		adr:= x"00802000";
		adr:=adr + ii*4;
		int_mem_read( cmd, ret, adr,  data );
		
		write( str, ii ); write( str, string'("   " )); hwrite( str, data );
		writeline( log, str );		
		
	end loop;
		
	
	write( str, string'(" Блок 3 - прочитано: " ));
	writeline( log, str );		
	
	for ii in 0 to 15 loop

		adr:= x"00803000";
		adr:=adr + ii*4;
		int_mem_read( cmd, ret, adr,  data );
		
		write( str, ii ); write( str, string'("   " )); hwrite( str, data );
		writeline( log, str );		
		
	end loop;
		
--	block_write( cmd, ret, 4, 9, x"00000010" );		-- DMA_CTRL - RESET FIFO 
--	block_write( cmd, ret, 4, 9, x"00000000" );		-- DMA_CTRL 
--	block_write( cmd, ret, 4, 9, x"00000001" );		-- DMA_CTRL - START  	
	
	
	writeline( log, str );		
	if( error=0 ) then
		write( str, string'(" Тест завершён успешно " ));
		cnt_ok := cnt_ok + 1;
	else
		write( str, string'(" Тест не выполнен " ));
		cnt_error := cnt_error + 1;
	end if;
	writeline( log, str );	
	writeline( log, str );		

end test_adm_read_16kb;




--! Запись 16 кБ с использованием двух блоков дескрипторов
procedure test_adm_write_16kb (
		signal  cmd:	out bh_cmd; --! команда
		signal  ret:	in  bh_ret  --! ответ
		)
is

variable	adr				: std_logic_vector( 31 downto 0 );
variable	data			: std_logic_vector( 31 downto 0 );
variable	str				: line;			   

variable	error			: integer:=0;
variable	dma_complete	: integer; 
variable	kk				: integer;	 
variable	status			: std_logic_vector( 15 downto 0 );

begin
		
	write( str, string'("TEST_ADM_WRITE_16KB" ));
	writeline( log, str );	
	
	---- Формирование блока дескрипторов ---
	for ii in 0 to 256 loop
		adr:= x"00100000";
		adr:=adr + ii*4;
		int_mem_write( cmd, ret, adr,  x"00000000" );
	end loop;										 
	
	---- Заполнение памяти ----
	for ii in 0 to 256 loop
		adr:= x"00800000";
		adr:=adr + ii*4;
		data:=x"00A00000";
		data:=data + ii;
		int_mem_write( cmd, ret, adr,  data );
	end loop;	

	for ii in 0 to 1023 loop
		adr:= x"00801000";
		adr:=adr + ii*4;
		data:=x"00A10000";
		data:=data + ii;
		int_mem_write( cmd, ret, adr,  data );
	end loop;	

	for ii in 0 to 256 loop
		adr:= x"00802000";
		adr:=adr + ii*4;
		data:=x"00A20000";
		data:=data + ii;
		int_mem_write( cmd, ret, adr,  data );
	end loop;	

	for ii in 0 to 256 loop
		adr:= x"00803000";
		adr:=adr + ii*4;
		data:=x"00A30000";
		data:=data + ii;
		int_mem_write( cmd, ret, adr,  data );
	end loop;	
	
	--- Блок 0 ---
	
	--- Дескриптор 0 ---
	int_mem_write( cmd, ret, x"00100000",  x"00008000" ); 
	int_mem_write( cmd, ret, x"00100004",  x"00000011" );  	-- переход к следующему дескриптору 

	--- Дескриптор 1 ---
	int_mem_write( cmd, ret, x"00100008",  x"00008010" ); 
	int_mem_write( cmd, ret, x"0010000C",  x"00000012" );  	-- переход к следующему блоку 

	--- Дескриптор 2 ---
	int_mem_write( cmd, ret, x"00100010",  x"00001002" ); 	-- адрес следующего дескриптора 
	int_mem_write( cmd, ret, x"00100014",  x"00000000" );  	
	
	
	int_mem_write( cmd, ret, x"001001F8",  x"00000000" );
	int_mem_write( cmd, ret, x"001001FC",  x"14A44953" );	   
	

	--- Блок 1 ---
	
	--- Дескриптор 0 ---
	int_mem_write( cmd, ret, x"00100200",  x"00008020" ); 
	int_mem_write( cmd, ret, x"00100204",  x"00000011" );  	-- переход к следующему дескриптору 

	--- Дескриптор 1 ---
	int_mem_write( cmd, ret, x"00100208",  x"00008030" ); 
	int_mem_write( cmd, ret, x"0010020C",  x"00000010" );  	-- остановка
	
	
	int_mem_write( cmd, ret, x"001003F8",  x"00000000" );
	int_mem_write( cmd, ret, x"001003FC",  x"D6BC4953" );	   
	
	
	
	---- Программирование канала DMA ----
	block_write( cmd, ret, 4, 8, x"00000023" );		-- DMA_MODE 
	block_write( cmd, ret, 4, 9, x"00000010" );		-- DMA_CTRL - RESET FIFO 
	
	block_write( cmd, ret, 4, 20, x"00100000" );	-- PCI_ADRL 
	block_write( cmd, ret, 4, 21, x"00100000" );	-- PCI_ADRH  
	block_write( cmd, ret, 4, 23, x"0001D000" );	-- LOCAL_ADR 
	
	
	---- Подготовка тетрады ----
	trd_test_mode( cmd, ret, 0 );	-- переход в рабочий режим --
	trd_wait_cmd( cmd, ret, 0, 16, x"1700" );		-- DMAR0 - от тетрады 7 --

	trd_wait_cmd( cmd, ret, 1, 16#1D#, x"0001" );	-- Размер блока = 4 кБ --

	block_write( cmd, ret, 4, 9, x"00000001" );		-- DMA_CTRL - START 

	trd_wait_cmd( cmd, ret, 1, 16#0F#, x"0001" );	-- Подключение выхода генератора к DIO_IN --
	
	trd_wait_cmd( cmd, ret, 7, 	0, x"2038" );		-- запуск тетрады DIO_OUT 
	
	trd_wait_cmd( cmd, ret, 1, 16#1C#, x"0020" );	-- Запуск тестовой последовательности --
	
	wait for 20 us;
	
	
	for ii in 0 to 20 loop
		block_read( cmd, ret, 4, 16, data );			-- STATUS 
		
		write( str, string'("STATUS: " )); hwrite( str, data( 15 downto 0 ) );
		if( data( 8 )='1' ) then
			write( str, string'(" - Дескриптор правильный" ));	
			error := 0;
			exit;
		else
			write( str, string'(" - Ошибка чтения дескриптора" ));
			error := error + 1;
			wait for 10 us;
		end if;
		
		writeline( log, str );	
	end loop;
	
	
	if( error=0 ) then		   
		
		kk:=0;
		loop
			
		trd_status( cmd, ret, 6, status );
		write( str, string'("TRD_STATUS: " )); hwrite( str, status );
			
		block_read( cmd, ret, 4, 16, data );			-- STATUS 
		write( str, string'("    STATUS: " )); hwrite( str, data( 15 downto 0 ) );
		
			if( data(4)='1' ) then
				write( str, string'(" - завершено чтение блока " ));
				block_write( cmd, ret, 4, 16#11#, x"00000010" );		-- FLAG_CLR - сброс EOT 
				kk:=kk+1;
				if( kk=4 ) then
					exit;
				end if;
			end if;
			writeline( log, str );			
			
			wait for 500 ns;
			
			
		end loop;
		
		---- Ожидание завершения DMA ----
		dma_complete := 0;
		for ii in 0 to 100 loop
			
		block_read( cmd, ret, 4, 16, data );			-- STATUS 
		write( str, string'("STATUS: " )); hwrite( str, data( 15 downto 0 ) );
			if( data(5)='1' ) then
				write( str, string'(" - DMA завершён " ));
				dma_complete := 1;	
				
				block_write( cmd, ret, 4, 16#11#, x"00000010" );		-- FLAG_CLR - сброс EOT 
				
			end if;
			writeline( log, str );			
			
			if( dma_complete=1 ) then
				exit;
			end if;		   
			
			wait for 1 us;
			
		end loop;
	
		writeline( log, str );			
		
		if( dma_complete=0 ) then
			write( str, string'("Ошибка - DMA не завершён " ));
			writeline( log, str );			
			error:=error+1;
		end if;

	end if; 
	
	for ii in 0 to 3 loop
			
		block_read( cmd, ret, 4, 16, data );			-- STATUS 
		write( str, string'("STATUS: " )); hwrite( str, data( 15 downto 0 ) );
		writeline( log, str );			
		wait for 500 ns;
		
	end loop;
	
	
	block_write( cmd, ret, 4, 9, x"00000000" );		-- DMA_CTRL - STOP  	
	
		
--	block_write( cmd, ret, 4, 9, x"00000010" );		-- DMA_CTRL - RESET FIFO 
--	block_write( cmd, ret, 4, 9, x"00000000" );		-- DMA_CTRL 
--	block_write( cmd, ret, 4, 9, x"00000001" );		-- DMA_CTRL - START  	
	
	
	writeline( log, str );		
	if( error=0 ) then
		write( str, string'(" Тест завершён успешно " ));
		cnt_ok := cnt_ok + 1;
	else
		write( str, string'(" Тест не выполнен " ));
		cnt_error := cnt_error + 1;
	end if;
	writeline( log, str );	
	writeline( log, str );		

end test_adm_write_16kb;
		
end package	body test_pkg;

								