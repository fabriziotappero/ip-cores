-------------------------------------------------------------------------------
--
-- Title       : cl_test_check
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.0
--
-------------------------------------------------------------------------------
--
-- Description :	Узел проверки входного потока
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
-- Version     1.0  
--
-------------------------------------------------------------------------------




library ieee;
use ieee.std_logic_1164.all;	 

package	cl_test_check_pkg is

component cl_test_check is
	port(
	
		---- Global ----
		reset		: in std_logic;		-- 0 - сброс
		clk			: in std_logic;		-- тактовая частота
		
		---- DIO_OUT ----
		do_clk		: in  std_logic; 	-- тактовая частота чтения из FIFO
		do_data		: in  std_logic_vector( 63 downto 0 );
		do_data_en	: in  std_logic;	-- 1 - передача данных из dio_out
		
		
		---- Управление ----
		test_check_ctrl	: in  std_logic_vector( 15 downto 0 );
		test_check_size	: in  std_logic_vector( 15 downto 0 );	 -- размер в блоках по 512x64 (4096 байт)
		test_check_bl_rd	: out std_logic_vector( 31 downto 0 );
		test_check_bl_ok	: out std_logic_vector( 31 downto 0 );
		test_check_bl_err	: out std_logic_vector( 31 downto 0 );
		test_check_error	: out std_logic_vector( 31 downto 0 );
		test_check_err_adr	: in  std_logic_vector( 15 downto 0 );
		test_check_err_data: out std_logic_vector( 15 downto 0 )
	
	);
end component;

end package;


library ieee;
use ieee.std_logic_1164.all;	 
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;


entity cl_test_check is
	port(
	
		---- Global ----
		reset		: in std_logic;		-- 0 - сброс
		clk			: in std_logic;		-- тактовая частота
		
		---- DIO_OUT ----
		do_clk		: in  std_logic; 	-- тактовая частота чтения из FIFO
		do_data		: in  std_logic_vector( 63 downto 0 );
		do_data_en	: in  std_logic;	-- 1 - передача данных из dio_out
		
		
		---- Управление ----
		test_check_ctrl	: in  std_logic_vector( 15 downto 0 );
		test_check_size	: in  std_logic_vector( 15 downto 0 );	 -- размер в блоках по 512x64 (4096 байт)
		test_check_bl_rd	: out std_logic_vector( 31 downto 0 );
		test_check_bl_ok	: out std_logic_vector( 31 downto 0 );
		test_check_bl_err	: out std_logic_vector( 31 downto 0 );
		test_check_error	: out std_logic_vector( 31 downto 0 );
		test_check_err_adr	: in  std_logic_vector( 15 downto 0 );
		test_check_err_data: out std_logic_vector( 15 downto 0 )
	
	);
end cl_test_check;


architecture cl_test_check of cl_test_check is

signal	block_rd		: std_logic_vector( 31 downto 0 );
signal	block_ok		: std_logic_vector( 31 downto 0 );
signal	block_err		: std_logic_vector( 31 downto 0 );
signal	total_err		: std_logic_vector( 31 downto 0 );

signal	data_expect		: std_logic_vector( 63 downto 0 );

signal	cnt1			: std_logic_vector( 24 downto 0 );
signal	cnt1_z			: std_logic;
signal	cnt1_eq			: std_logic;

signal	rst				: std_logic;
signal	data_en			: std_logic;	-- 1 - приём слова данных  
signal	data_en_z		: std_logic;
signal	do_data_z		: std_logic_vector( 63 downto 0 );

signal	data_ex0		: std_logic_vector( 63 downto 0 );
signal	data_ex1		: std_logic_vector( 63 downto 0 );
signal	data_ex2		: std_logic_vector( 63 downto 0 );
signal	data_ex3		: std_logic_vector( 63 downto 0 );
signal	data_ex4		: std_logic_vector( 63 downto 0 );
signal	data_ex5		: std_logic_vector( 63 downto 0 );


signal	block_mode		: std_logic_vector( 3 downto 0 );	 
signal	word_error		: std_logic;	 
signal	flag_error		: std_logic;	-- 1 - признак ошибки при приёма блока
signal	flag_error_clr	: std_logic;	-- 1 - сброс flag_error

signal	data_error		: std_logic_vector( 191 downto 0 );
signal	data_error_wr	: std_logic;
signal	data_error_wr1	: std_logic;
signal	data_error_ovr	: std_logic;	  
signal	data_error_out	: std_logic_vector( 191 downto 0 );
signal	err_data		: std_logic_vector( 15 downto 0 );			 

signal	block_ok_en		: std_logic;

begin
	
pr_cnt1: process( do_clk ) begin	
	if( rising_edge( do_clk ) ) then
		if( rst='0' or (cnt1_eq='1' and data_en='1') ) then				   
			cnt1( 24 downto 0 )   <= (others=>'0') after 1 ns;
		elsif( data_en='1' ) then
			cnt1 <= cnt1 + 1 after 1 ns;
		end if;
	end if;
end process;

pr_cnt1_z: process( do_clk ) begin
	if( rising_edge( do_clk ) ) then
		
		if( rst='0' ) then
			cnt1_z <= '1' after 1 ns;
			cnt1_eq <= '0' after 1 ns;
		elsif( data_en='1' ) then
			
			if( cnt1_eq='1' ) then				   
				cnt1_z <= '1' after 1 ns;
			else
				cnt1_z <= '0' after 1 ns;
			end if;																		 
			
			if( cnt1( 24 downto 9 )=test_check_size-1 and cnt1( 8 downto 0 )="111111110" ) then
				cnt1_eq <= '1' after 1 ns;
			else
				cnt1_eq <= '0' after 1 ns;
			end if;
		end if;
		
	end if;
end process;


	
data_en <= do_data_en;

rst <= reset and not test_check_ctrl(0);

pr_block_mode: process( do_clk ) begin
	if( rising_edge( do_clk ) ) then
		if( rst='0' ) then
			block_mode <= "0000" after 1 ns;	
		elsif( test_check_ctrl(7)='1' ) then
			block_mode <= test_check_ctrl( 11 downto 8 ) after 1 ns;
		elsif( data_en='1' and cnt1_eq='1' ) then
				if( block_mode="1001" ) then
					block_mode <= "0000" after 1 ns;
				else
					block_mode <= block_mode + 1 after 1 ns;
				end if;
		end if;
	end if;
end process;

pr_block_rd: process( do_clk ) begin
	if( rising_edge( do_clk ) ) then
		if( rst='0' ) then
			block_rd <= (others=>'0') after 1 ns;
		elsif( data_en='1' and cnt1_eq='1' ) then
			block_rd <= block_rd + 1 after 1 ns;
		end if;
	end if;
end process;


pr_data_expect: process( do_clk ) begin
	if( rising_edge( do_clk ) ) then  
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
			
	
	
do_data_z <= do_data after 1 ns when rising_edge( do_clk );	
data_en_z <= data_en after 1 ns when rising_edge( do_clk );

word_error <= '1' when do_data_z /= data_expect else '0';		 
	
pr_total_err: process( do_clk ) begin
	if( rising_edge( do_clk ) ) then
		if( rst='0' ) then
			total_err <= (others=>'0') after 1 ns;
		elsif( data_en_z='1' and word_error='1' and total_err/=x"FFFFFFFF" ) then
			total_err <= total_err + 1 after 1 ns;
		end if;
	end if;
end process;

pr_flag_error_clr: process( do_clk ) begin
	if( rising_edge( do_clk ) ) then
		if( rst='0' ) then					 
			flag_error_clr <= '0' after 1 ns;
		elsif(  cnt1_z='1' and data_en='1' ) then
			flag_error_clr <= '1' after 1 ns;
		else
			flag_error_clr <= '0' after 1 ns;
		end if;
	end if;
end process;


pr_flag_error: process( do_clk ) begin
	if( rising_edge( do_clk ) ) then
		if( rst='0' ) then
			flag_error <= '0' after 1 ns;
		elsif( data_en_z='1' and word_error='1' ) then
			flag_error <= '1' after 1 ns;
		elsif( flag_error_clr='1' ) then
			flag_error <= '0' after 1 ns;
		end if;
	end if;
end process;

	
data_error_wr <= data_en_z and word_error;

data_error( 63 downto 0 ) <= do_data_z;
data_error( 127 downto 64 ) <= data_expect;
data_error( 152 downto 128 ) <= cnt1 after 1 ns when rising_edge( do_clk );
data_error( 159 downto 153 ) <= (others=>'0');
data_error( 191 downto 160 ) <= block_rd after 1 ns when rising_edge( do_clk );

pr_data_error_ovr: process( do_clk ) begin
	if( rising_edge( do_clk ) ) then
		if( rst='0' ) then
			data_error_ovr <= '0' after 1 ns;
		elsif( data_error_wr='1' and total_err( 3 downto 0 )="1111" ) then
			data_error_ovr <= '1' after 1 ns;
		end if;
	end if;
end process;

data_error_wr1 <= data_error_wr and not data_error_ovr;

pr_block_ok: process( do_clk ) begin
	if( rising_edge( do_clk ) ) then
		if( rst='0' ) then
			block_ok <= (others=>'0') after 1 ns;
			block_err <= (others=>'0' ) after 1 ns;
		elsif( block_ok_en='1' ) then
			if( flag_error_clr='1' and flag_error='0' ) then
				block_ok <= block_ok + 1 after 1 ns;
			end if;
			if( flag_error_clr='1' and flag_error='1' ) then
				block_err <= block_err + 1 after 1 ns;
			end if;		 
		end if;
	end if;
end process;

pr_block_ok_en: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( rst='0' ) then
			block_ok_en <= '0' after 1 ns;
		elsif( cnt1_eq='1' ) then
			block_ok_en <= '1' after 1 ns;
		end if;
	end if;
end process;
			

gen_data_error: for ii in 0 to 191 generate
	
ram0:	ram16x1d 
		port map(
			we 	=> data_error_wr1,
			d 	=> data_error( ii ),
			wclk => do_clk,
			a0	=> total_err( 0 ),
			a1	=> total_err( 1 ),
			a2	=> total_err( 2 ),
			a3	=> total_err( 3 ),
			--spo	=> data_out( 0 ),
			dpra0 => test_check_err_adr( 4 ),
			dpra1 => test_check_err_adr( 5 ),
			dpra2 => test_check_err_adr( 6 ),
			dpra3 => test_check_err_adr( 7 ),
			dpo	  => data_error_out( ii )
		);	
	
end generate;	

err_data <= 			data_error_out( 15 downto 0 )   when test_check_err_adr( 3 downto 0 )="0000" else
						data_error_out( 31 downto 16 )   when test_check_err_adr( 3 downto 0 )="0001" else
						data_error_out( 47 downto 32 )   when test_check_err_adr( 3 downto 0 )="0010" else
						data_error_out( 63 downto 48 )   when test_check_err_adr( 3 downto 0 )="0011" else
						data_error_out( 79 downto 64 )   when test_check_err_adr( 3 downto 0 )="0100" else
						data_error_out( 95 downto 80 )   when test_check_err_adr( 3 downto 0 )="0101" else
						data_error_out( 111 downto 96 )  when test_check_err_adr( 3 downto 0 )="0110" else
						data_error_out( 127 downto 112 ) when test_check_err_adr( 3 downto 0 )="0111" else
						data_error_out( 143 downto 128 ) when test_check_err_adr( 3 downto 0 )="1000" else
						data_error_out( 159 downto 144 ) when test_check_err_adr( 3 downto 0 )="1001" else
						data_error_out( 175 downto 160 ) when test_check_err_adr( 3 downto 0 )="1010" else
						data_error_out( 191 downto 176 ) when test_check_err_adr( 3 downto 0 )="1011" else
						(others=>'-');
						
						
test_check_err_data <= err_data after 1 ns when rising_edge( clk );						


test_check_bl_rd	<= block_rd;
test_check_bl_ok	<= block_ok;
test_check_bl_err	<= block_err;
test_check_error	<= total_err;


end cl_test_check;


