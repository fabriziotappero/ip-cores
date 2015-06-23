---------------------------------------------------------------------------------------------------
--
-- Title       : block_pe_main
-- Author      : Dmitry Smekhov
-- Company     : Instrumental System
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.1  
--
---------------------------------------------------------------------------------------------------
--
-- Description : 
--		Блок управления общими ресурсами прошивки с ядром PCI-Express
--		
--		Модификация 1
--		Реализованы регистры BRD_MODE, STATUS 
--					
--		
--
---------------------------------------------------------------------------------------------------
--
--  	Version 1.1   26.12.2009
--					  Добавлен регистр CPL_CNT - число ошибок Completion Timeout
--
---------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;   

library	work;
use	work.host_pkg.all;

package block_pe_main_pkg is
	
component block_pe_main is				
	generic (
		Device_ID		: in std_logic_vector( 15 downto 0 ):=x"0000"; -- идентификатор модуля
		Revision		: in std_logic_vector( 15 downto 0 ):=x"0000"; -- версия модуля
		PLD_VER			: in std_logic_vector( 15 downto 0 ):=x"0000"; -- версия ПЛИС
		BLOCK_CNT		: in std_logic_vector( 15 downto 0 ):=x"0000"  -- число блоков управления 
		
	);	
	port(
	
		---- Global ----
		reset_hr1		: in std_logic;		-- 0 - сброс
		clk				: in std_logic;		-- Тактовая частота DSP
		pb_reset		: out std_logic;	-- 0 - сброс ведомой ПЛИС
		
		---- HOST ----
		bl_adr			: in  std_logic_vector( 4 downto 0 );	-- адрес
		bl_data_in		: in  std_logic_vector( 31 downto 0 );	-- данные
		bl_data_out		: out std_logic_vector( 31 downto 0 );	-- данные
		bl_data_we		: in  std_logic;	-- 1 - запись данных   
		
		---- Управление ----
		brd_mode		: out std_logic_vector( 15 downto 0 )  -- регистр BRD_MODE

	);	
end component;

end package;



library ieee;
use ieee.std_logic_1164.all;   

library	work;
use	work.host_pkg.all;
use work.ctrl_ram16_v1_pkg.all;

library unisim;
use unisim.vcomponents.all;



entity block_pe_main is				
	generic (
		Device_ID		: in std_logic_vector( 15 downto 0 ):=x"0000"; -- идентификатор модуля
		Revision		: in std_logic_vector( 15 downto 0 ):=x"0000"; -- версия модуля
		PLD_VER			: in std_logic_vector( 15 downto 0 ):=x"0000"; -- версия ПЛИС
		BLOCK_CNT		: in std_logic_vector( 15 downto 0 ):=x"0000"  -- число блоков управления 
		
	);	
	port(
	
		---- Global ----
		reset_hr1		: in std_logic;		-- 0 - сброс
		clk				: in std_logic;		-- Тактовая частота DSP
		pb_reset		: out std_logic;	-- 0 - сброс ведомой ПЛИС
		
		---- HOST ----
		bl_adr			: in  std_logic_vector( 4 downto 0 );	-- адрес
		bl_data_in		: in  std_logic_vector( 31 downto 0 );	-- данные
		bl_data_out		: out std_logic_vector( 31 downto 0 );	-- данные
		bl_data_we		: in  std_logic;	-- 1 - запись данных   
		
		---- Управление ----
		brd_mode		: out std_logic_vector( 15 downto 0 )  -- регистр BRD_MODE
		
	);	
end block_pe_main;


architecture block_pe_main of block_pe_main is					   



---- Constant ----
constant BLOCK_ID		: std_logic_vector( 15 downto 0 ):=x"1013"; -- идентификатор блока PE_MAIN
constant BLOCK_VER		: std_logic_vector( 15 downto 0 ):=x"0101"; -- версия блока PE_MAIN

constant	bl_rom		: bh_rom:=( 0=> BLOCK_ID,
								1=> BLOCK_VER,
--								2=> Device_ID,
--								3=> Revision,
--								4=> PLD_VER,  

2=> x"5504",
3=> x"0210",
4=> x"0104",
								5=> BLOCK_CNT,
								6=> x"0000",
								7=> x"0000" );



								
	---- PLX ----
signal	bl_ram_out		: std_logic_vector( 15 downto 0 );	-- выход констант и командных
														-- регистров
signal	bl_reg_out		: std_logic_vector( 31 downto 0 );	-- выход непосредственных регистров


				
signal	c_brd_mode		: std_logic_vector( 15 downto 0 );	-- регистр BRD_MODE

	---- Reset ----
signal	dsp_reg_reset	: std_logic_vector( 11 downto 0 );
signal	reset_flag		: std_logic_vector( 7 downto 0 );
signal	reset_val		: std_logic_vector( 7 downto 0 );
signal	reset_val_0		: std_logic_vector( 7 downto 0 );
signal	reset_val_1		: std_logic_vector( 7 downto 0 );
signal	reset_host		: std_logic_vector( 7 downto 0 );




signal	brd_status_i	: std_logic_vector( 15 downto 0 );

attribute	tig : string;
attribute	tig		of reset_hr1	: signal	is "yes";


begin

	
bl_ram: ctrl_ram16_v1 
	generic map(
		rom			=> bl_rom		-- значения констант
	)
	port map(
		clk			=> clk,		-- Тактовая частота
		
		adr			=> bl_adr,			-- адрес 
		data_in		=> bl_data_in( 15 downto 0 ),	-- вход данных
		data_out	=> bl_ram_out,		-- выход данных
		
		data_we		=> bl_data_we		-- 1 - запись данных
	);
	

	
	
pr_data_out: process( clk )
begin
	
	if( rising_edge( clk ) ) then
		if( bl_adr(4)='0' ) then
			bl_data_out( 15 downto 0 ) <= bl_ram_out after 1 ns;
			bl_data_out( 31 downto 16 ) <= (others=>'0') after 1 ns;
		else
			case bl_adr( 3 downto 0 ) is
				when "0000" 	=> 	-- BRD_STATUS
						bl_data_out(15 downto 0 )<=brd_status_i after 1 ns;
						bl_data_out( 31 downto 16 ) <= (others=>'0') after 1 ns;
						
				when "0110"	=>  -- SPD_CTRL
						bl_data_out( 31 downto 0 ) <= (others=>'1') after 1 ns;
				
				when "1000"	=>  -- SPD_DATA
						bl_data_out( 31 downto 0 ) <= (others=>'1') after 1 ns;

				when others => bl_data_out<=(others=>'-');
			end case;
		end if;
	end if;
end process;   

	


pr_reg: process( reset_hr1, clk ) 
	
begin
	if( reset_hr1='0' ) then
		c_brd_mode<=(others=>'0');
	elsif( rising_edge( clk ) ) then
		if( bl_data_we='1' ) then
			case bl_adr( 4 downto 0 ) is
				when "01000"	=> -- BRD_MODE
						c_brd_mode <= bl_data_in( 15 downto 0 ) after 1 ns;
				when others => null;
			end case;
		end if;
		
	end if;
end process;
				

brd_mode <=c_brd_mode;

brd_status_i( 0 ) <= '1';
brd_status_i( 7 downto 1 ) <= (others=>'0');
brd_status_i( 9 downto 8 ) <= c_brd_mode( 9 downto 8 );
brd_status_i( 14 downto 10 ) <= (others=>'0');
brd_status_i( 15 ) <= '1';


end block_pe_main;
 