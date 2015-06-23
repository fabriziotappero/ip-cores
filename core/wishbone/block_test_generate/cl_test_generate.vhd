-------------------------------------------------------------------------------
--
-- Title       : cl_test_generate
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.0
--
-------------------------------------------------------------------------------
--
-- Description :	Узел формирования потока данных
--				
--		Тестовая последовательность представляет собой набор блоков. 
--		Размер блока задаётся кратным страницы размером 4 килобайта 
--		(512 слов по 64 бита)
--		Первое 64-х разрядное слово в блоке содержит сигнатуру и порядковый номер.	 
--		    31..0  - сигнатура 0xA5A50123
--			63..32 - порядковый номер блока
--
--		Содержимое блока зависит от его порядкового номера в последовательности.  
--
--		Содержимое блока:
--		0 - Бегущая единица по 64-м разрядам
--		1 - Бегущий ноль по 64-м разрядам
--		2 - Бегущая единица с инверсией по 64-м разрядам
---			Чётные номера слов - бегущая единица по 64-м разрядам
--			Нечётные номера - инверсия предыдущего слова		 
--		3 - Бегущая единица в блоке
--			Номер слова сравнивается с номером блока (сравниваются восемь младший разрядов)
--			При совпадении - в слово записывается бегущая 1.
--			Остальные слова - значение ноль.
--		4 - Бегущий ноль с инверсией по 64-м разрядам
--			Чётные номера - бегущий ноль по 64-м разрядам
--			Нечётные номера - инверсия предыдущего слова		 
--		5 - Бегущий ноль а в блоке
--			Номер слова сравнивается с номером блока (сравниваются восемь младший разрядов)
--			При совпадении - в слово записывается бегущий 0.
--			Остальные слова - значение 0xFFFFFFFFFFFFFFFF.
--		6,7 - Счётчик по 64-м разрядам
--			Чётные номера - значение счётчика
--			Нечётные номера - инверсия предыдущего слова
--		8,9 - Псевдослучайная последовательность
--			Формируется М-последовательность по 64 разрядам.
--			Начальное значение - 1
--			Слово формируется сдвигом на один разряд вправо.
--			В младший разряд слова записывается значение x[63] xor x[62]
--																
--
--		Для режима счётчика и псевдослучайной последовательности начальное значение
--		формируется при инициализации тестовой последовательности.
--		Для остальных режимов - при инициализации проверки блока
--
--
--		Регистр test_check_ctrl
--			   
--				0 - 1 сброс узла
--				5 - 1 старт приёма данных
--				7 - 1 фиксированный тип блока
--				11..8 - номер блока при test_check_ctrl[7]=1
--				

-------------------------------------------------------------------------------
--
-- Version     1.1   06.12.2010
--			    Исправлено использование сигнала СТАРТ при работе по счётчикам.
--				Исправлено использование бита test_gen_ctrl(12) 
--				при работе без счётчиков. 
--
-------------------------------------------------------------------------------




library ieee;
use ieee.std_logic_1164.all;	 

package	cl_test_generate_pkg is

component cl_test_generate is
	port(
	
		---- Global ----
		reset		: in std_logic;		-- 0 - сброс
		clk			: in std_logic;		-- тактовая частота
		
		---- DIO_IN ----
		di_clk		: in  std_logic;	-- тактовая частота записи в FIFO
		di_data		: out std_logic_vector( 63 downto 0 );	-- данные
		di_data_we	: out std_logic;	-- 1 - запись данных
		di_flag_paf	: in  std_logic;	-- 1 - есть место для записи
		di_fifo_rst	: in  std_logic;	-- 0 - сброс FIFO
		di_start	: in  std_logic;	-- 1 - разрешение работы (MODE0[5])
		
		
		---- Управление ----
		test_gen_ctrl	: in  std_logic_vector( 15 downto 0 );  -- Регистр управления
		test_gen_size	: in  std_logic_vector( 15 downto 0 );	-- размер в блоках по 512x64 (4096 байт)
		test_gen_bl_wr	: out std_logic_vector( 31 downto 0 );	-- Число записанных блоков
		test_gen_cnt1	: in  std_logic_vector( 15 downto 0 );  -- Счётчик разрешения работы
		test_gen_cnt2	: in  std_logic_vector( 15 downto 0 )	-- Счётчик запрещения работы
	
	);
end component;

end package;


library ieee;
use ieee.std_logic_1164.all;	 
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;



entity cl_test_generate is
	port(
	
		---- Global ----
		reset		: in std_logic;		-- 0 - сброс
		clk			: in std_logic;		-- тактовая частота
		
		---- DIO_IN ----
		di_clk		: in  std_logic;	-- тактовая частота записи в FIFO
		di_data		: out std_logic_vector( 63 downto 0 );	-- данные
		di_data_we	: out std_logic;	-- 1 - запись данных
		di_flag_paf	: in  std_logic;	-- 1 - есть место для записи
		di_fifo_rst	: in  std_logic;	-- 0 - сброс FIFO
		di_start	: in  std_logic;	-- 1 - разрешение работы (MODE0[5])
		
		---- Управление ----
		test_gen_ctrl	: in  std_logic_vector( 15 downto 0 );  -- Регистр управления
		test_gen_size	: in  std_logic_vector( 15 downto 0 );	-- размер в блоках по 512x64 (4096 байт)
		test_gen_bl_wr	: out std_logic_vector( 31 downto 0 );	-- Число записанных блоков
		test_gen_cnt1	: in  std_logic_vector( 15 downto 0 );  -- Счётчик разрешения работы
		test_gen_cnt2	: in  std_logic_vector( 15 downto 0 )	-- Счётчик запрещения работы
	
	);
end cl_test_generate;


architecture cl_test_generate of cl_test_generate is

signal	block_rd		: std_logic_vector( 31 downto 0 );

signal	data_expect		: std_logic_vector( 63 downto 0 );

signal	cnt1			: std_logic_vector( 24 downto 0 );
signal	cnt1_z			: std_logic;
signal	cnt1_eq			: std_logic;

signal	rst				: std_logic;
signal	data_en			: std_logic;	-- 1 - приём слова данных  

signal	data_ex0		: std_logic_vector( 63 downto 0 );
signal	data_ex1		: std_logic_vector( 63 downto 0 );
signal	data_ex2		: std_logic_vector( 63 downto 0 );
signal	data_ex3		: std_logic_vector( 63 downto 0 );
signal	data_ex4		: std_logic_vector( 63 downto 0 );
signal	data_ex5		: std_logic_vector( 63 downto 0 );


signal	block_mode		: std_logic_vector( 3 downto 0 );	   

signal	xcnt1			: std_logic_vector( 15 downto 0 );
signal	xcnt2			: std_logic_vector( 15 downto 0 );	  

signal	xcnt1_z			: std_logic;
signal	xcnt2_z			: std_logic;

type stp_type is ( s0, s1, s2, s3 );
signal	stp				: stp_type;			

signal	di_rdy			: std_logic;

begin
	
pr_cnt1: process( di_clk ) begin	
	if( rising_edge( di_clk ) ) then
		if( rst='0' or (cnt1_eq='1' and data_en='1') ) then				   
			cnt1( 24 downto 0 )   <= (others=>'0') after 1 ns;
		elsif( data_en='1' ) then
			cnt1 <= cnt1 + 1 after 1 ns;
		end if;
	end if;
end process;

pr_cnt1_z: process( di_clk ) begin
	if( rising_edge( di_clk ) ) then
		
		if( rst='0' ) then
			cnt1_z <= '1' after 1 ns;
			cnt1_eq <= '0' after 1 ns;
		elsif( data_en='1' ) then
			
			if( cnt1_eq='1' ) then				   
				cnt1_z <= '1' after 1 ns;
			else
				cnt1_z <= '0' after 1 ns;
			end if;																		 
			
			if( cnt1( 24 downto 9 )=test_gen_size-1 and cnt1( 8 downto 0 )="111111110" ) then
				cnt1_eq <= '1' after 1 ns;
			else
				cnt1_eq <= '0' after 1 ns;
			end if;
		end if;
		
	end if;
end process;


	
--pr_data_en: process( di_clk ) begin
--	if( rising_edge( di_clk ) ) then
--		if( rst='0' or test_gen_ctrl(5)='0' or di_flag_paf='0' or di_start='0' ) then
--			data_en <='0' after 1 ns;
--		else
--			data_en <= '1' after 1 ns;
--		end if;
--	end if;
--end process;				

di_rdy <= (di_flag_paf or test_gen_ctrl(12) ) and di_start after 1 ns when rising_edge( di_clk );

pr_state: process( di_clk ) begin
	if( rising_edge( di_clk ) ) then
		case( stp ) is
			when s0 => -- Ожидание --
				if( test_gen_ctrl(5)='1' ) then
					if( test_gen_ctrl( 6 )='1' ) then
						stp <= s2 after 1 ns;
					else
						stp <= s1 after 1 ns;
					end if;
				end if;
				data_en <= '0' after 1 ns;
				
			when s1 => -- Передача по готовности FIFO --
				data_en <= di_rdy after 1 ns;
				if( test_gen_ctrl(5)='0' ) then
					stp <= s0 after 1 ns;
				end if;
				
			when s2 => -- Передача по счётчикам CNT1, CNT2
				data_en <= di_rdy after 1 ns;
				if( test_gen_ctrl(5)='0' ) then
					stp <= s0 after 1 ns;
				elsif( xcnt1_z='1' ) then
					stp <= s3 after 1 ns;
				end if;
				
			when s3 =>
				data_en <= '0' after 1 ns;
				if( test_gen_ctrl(5)='0' ) then
					stp <= s0 after 1 ns;
				elsif( xcnt2_z='1' ) then
					stp <= s2 after 1 ns;
				end if;					 
		end case;
		
		if( rst='0' ) then
			stp <= s0 after 1 ns;
		end if;
		
	end if;
end process;	
		
pr_xcnt1: process( di_clk ) begin
	if( rising_edge( di_clk ) ) then
		if( stp/=s2 ) then
			xcnt1 <= test_gen_cnt1 after 1 ns;
		else
			xcnt1 <= xcnt1 - 1 after 1 ns;
		end if;
	end if;
end process;
					
pr_xcnt2: process( di_clk ) begin
	if( rising_edge( di_clk ) ) then
		if( stp/=s3 ) then
			xcnt2 <= test_gen_cnt2 after 1 ns;
		else
			xcnt2 <= xcnt2 - 1 after 1 ns;
		end if;
	end if;
end process;

xcnt1_z <= '1' when xcnt1=x"0002" else '0';
	
xcnt2_z <= '1' when xcnt2=x"0002" else '0';
	

rst <= reset and not test_gen_ctrl(0);
														  
pr_block_mode: process( di_clk ) begin
	if( rising_edge( di_clk ) ) then
		if( rst='0' ) then
			block_mode <= "0000" after 1 ns;	
		elsif( test_gen_ctrl(7)='1' ) then
			block_mode <= test_gen_ctrl( 11 downto 8 ) after 1 ns;
		elsif( data_en='1' and cnt1_eq='1' ) then
				if( block_mode="1001" ) then
					block_mode <= "0000" after 1 ns;
				else
					block_mode <= block_mode + 1 after 1 ns;
				end if;
		end if;
	end if;
end process;

pr_block_rd: process( di_clk ) begin
	if( rising_edge( di_clk ) ) then
		if( rst='0' ) then
			block_rd <= (others=>'0') after 1 ns;
		elsif( data_en='1' and cnt1_eq='1' ) then
			block_rd <= block_rd + 1 after 1 ns;
		end if;
	end if;
end process;
	
pr_data_expect: process( di_clk ) begin
	if( rising_edge( di_clk ) ) then  
	  if( rst='0' ) then
		  data_ex4 <= (others=>'0') after 1 ns;
		  data_ex5 <= (0=>'1', others=>'0') after 1 ns;
		  data_ex0 <= x"0000000000000001" after 1 ns;
	  elsif( data_en='1' ) then
		if( cnt1_z='1' ) then
			data_expect( 31 downto 0 ) <= x"A5A50123" after 1 ns;
			data_expect( 63 downto 32 ) <= block_rd after 1 ns;
			case( block_mode( 3 downto 0 ) ) is
			  when "0000" => -- Бегущая 1 по 64-м разрядам
			  	data_ex0 <= x"0000000000000001" after 1 ns;
			  when "0001" => -- Бегущий 0 по 64-м разрядам
			  	data_ex0 <= not x"0000000000000001" after 1 ns;
			  when "0010" => -- Бегущая 1 с инверсией  по 64-м разрядам
			  	data_ex1 <= x"0000000000000001" after 1 ns;
			  when "0011" => -- Бегущий 0 с инверсией  по 64-м разрядам
			  	data_ex1 <= not x"0000000000000001" after 1 ns;
			  when "0100" => -- Бегущая 1 в блоке 0
			  	data_ex2 <= x"0000000000000001" after 1 ns;
			  	data_ex3 <= (others=>'0');
			  when "0101" => -- Бегущий 0 в блоке 1
			  	data_ex2 <= not x"0000000000000001" after 1 ns;
			  	data_ex3 <= (others=>'1') after 1 ns;
			  
			  when others=> null;
			end case;
		else
			case( block_mode( 3 downto 0 ) )is
			  when "0000" | "0001" => 
			  	data_expect <= data_ex0 after 1 ns;
			  	data_ex0( 63 downto 1 ) <= data_ex0( 62 downto 0 ) after  1 ns;
				data_ex0( 0 ) <= data_ex0( 63 ) after 1 ns;
				
			  when "0010" | "0011" => -- Бегущий 0 с инверсией  по 32-м разрядам
--			  when "0011" => -- Бегущий 0 с инверсией  по 64-м разрядам
				if( cnt1(0)='0' ) then
			  		data_expect <= data_ex1 after 1 ns;
				else
					data_expect <= not data_ex1 after 1 ns;
				  	data_ex1( 63 downto 1 ) <= data_ex1( 62 downto 0 ) after  1 ns;
					data_ex1( 0 ) <= data_ex1( 63 ) after 1 ns;
				end if;
			  when "0100" | "0101" => -- Бегущий 0 в блоке 1
--			  when "0111" => -- Бегущий 1 в блоке 0
			  	if( cnt1( 7 downto 0 )=block_rd( 7 downto 0 ) )then
					data_expect <= data_ex2 after 1 ns;
				  	data_ex2( 63 downto 1 ) <= data_ex2( 62 downto 0 ) after  1 ns;
					data_ex2( 0 ) <= data_ex2( 63 ) after 1 ns;
				else
					data_expect <= data_ex3 after 1 ns;
				end if;
				
			  when "0110" | "0111" => -- Счётчик 
			    if( cnt1(0)='0' ) then
			  		data_expect <= data_ex4 after 1 ns;		
				else
			  		data_expect <= not data_ex4 after 1 ns;		
--			  		data_ex4 <= data_ex4 + x"0000000000000001";
					data_ex4(31 downto 0) <= data_ex4(31 downto 0) + 1;
					if (data_ex4(31 downto 0)=x"FFFFFFFF") then
						data_ex4(63 downto 32) <= data_ex4(63 downto 32) + 1;
					end if;
						
				end if;
					  
			  
			  when "1000" | "1001" => -- Псевдослучайная последовательность		 
			  		data_expect <= data_ex5 after 1 ns;
			  		data_ex5( 63 downto 1 ) <= data_ex5( 62 downto 0 ) after 1 ns;
					--data_ex5( 0 ) <= data_ex5( 63 ) xor data_ex5(62) after 1 ns;
					data_ex5( 0 ) <= data_ex5( 63 ) xor data_ex5(62) xor data_ex5(60) xor data_ex5(59) after 1 ns;
			  when others=> null;
			end case;
		end if;	
	  end if;
	end if;
end process;
			
	
di_data <= data_expect;	
di_data_we <= data_en after 1 ns when rising_edge( di_clk );
test_gen_bl_wr <= block_rd;
						
end cl_test_generate;
