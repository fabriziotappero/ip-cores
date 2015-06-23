---------------------------------------------------------------------------------------------------
--
-- Title       : adm2_pkg
-- Author      : Dmitry Smekhov
-- Company     : Instrumental System
--
-- Version     : 2.1   
--
---------------------------------------------------------------------------------------------------
--
-- Description :  Определение типов данных и общих модулей
--					
---------------------------------------------------------------------------------------------------
--					
--  Version 2.1  18.07.2007
--				 Добавлено описание типа std_logic_array16x6
--
---------------------------------------------------------------------------------------------------
--					
--  Version 2.0  15.12.2006
--				 Добавлены описания типов std_logic_array16x ...
--
---------------------------------------------------------------------------------------------------
--					
--  Version 1.4  17.06.2005
--				 Удалены описания компонентов
--
---------------------------------------------------------------------------------------------------
--
--	Version 1.3  31.10.2003
--			   	 Добавлены описания модулей cl_fifo256x32_v2
--
---------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all; 

package adm2_pkg is
	
type bl_cmd is record
	data_we			: std_logic; 	-- 1 - запись в регистр DATA
	cmd_data_we		: std_logic;	-- 1 - запись в регистр CMD_DATA
	status_cs		: std_logic;	-- 0 - чтение из регистра STATUS
	data_cs			: std_logic;	-- 0 - чтение из регистра DATA
	cmd_data_cs		: std_logic;	-- 0 - чтение из регистра CMD_DATA
	cmd_adr_we		: std_logic;  	-- 1 - запись в регистр косвенного адреса
	adr				: std_logic_vector( 9 downto 0 ); -- косвенный адрес
	data_oe			: std_logic;	-- 0 - разрешение выхода регистра DATA
	
end record;

type bl_drq is record
	en				: std_logic;	-- 1 - разрешение запроса DMA
	req				: std_logic;  	-- 1 - запрос на выполнение цикла DMA
	ack				: std_logic;	-- 1 - выполнение цикла DMA
end record;	

type bl_trd_rom is array( 31 downto 0 ) of std_logic_vector( 15 downto 0 );

type bl_fifo_flag is record
	ef		: std_logic; 	-- 0 - FIFO пустое
	pae		: std_logic;	-- 0 - FIFO почти пустое
	hf		: std_logic;	-- 0 - FIFO заполнено наполовину 
	paf		: std_logic;	-- 0 - FIFO почти полное
	ff		: std_logic;	-- 0 - FIFO полное
	ovr		: std_logic;	-- 1 - запись в полное FIFO
	und		: std_logic;	-- 1 - чтение из пустого FIFO
end record;	

type std_logic_array_16x64 is array (15 downto 0) of std_logic_vector(63 downto 0);
type std_logic_array_16x16 is array (15 downto 0) of std_logic_vector(15 downto 0);
type std_logic_array_16x6  is array (15 downto 0) of std_logic_vector(6 downto 0);
type std_logic_array_16xbl_cmd is array (15 downto 0) of bl_cmd;
type std_logic_array_16xbl_drq is array (15 downto 0) of bl_drq;
type std_logic_array_16xbl_irq is array (15 downto 0) of std_logic;
type std_logic_array_16xbl_reset_fifo is array (15 downto 0) of std_logic;
type std_logic_array_16xbl_trd_rom is array (15 downto 0) of bl_trd_rom;
type std_logic_array_16x7 is array (15 downto 0) of std_logic_vector(6 downto 0);
type std_logic_array_16xbl_fifo_flag is array (15 downto 0) of bl_fifo_flag;

component ctrl_buft16 is
	port (
	t: in std_logic;
	i: in std_logic_vector(15 downto 0);
	o: out std_logic_vector(15 downto 0));
end component;	

component ctrl_buft32 is
	port (
	t: in std_logic;
	i: in std_logic_vector(31 downto 0);
	o: out std_logic_vector(31 downto 0));
end component;	

component ctrl_buft64 is
	port (
	t: in std_logic;
	i: in std_logic_vector(63 downto 0);
	o: out std_logic_vector(63 downto 0));
end component;	


end package;