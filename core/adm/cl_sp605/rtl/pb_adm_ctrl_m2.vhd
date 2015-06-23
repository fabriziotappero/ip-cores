 ---------------------------------------------------------------------------------------------------
--
-- Title       : pb_adm_ctrl_m2
-- Author      : Dmitry Smekhov
-- Company     : Instrumental System
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.0   
--
---------------------------------------------------------------------------------------------------
--
-- Description : Узел декодирования адреса и подключения к тетрадам для шины PLD_BUS
--				 Поддерживается восемь тетрад
--					
--				 Модификация 2. 
--				 Увеличено число тактов на ответ.
--
---------------------------------------------------------------------------------------------------
--					
--  Version 1.0  01.04.2010
--				 Создан из pb_adm_ctrl  v1.6
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;


library work;
use work.adm2_pkg.all;

package pb_adm_ctrl_m2_pkg is
	
component pb_adm_ctrl_m2 is	 
	generic (					 
		---- Разрешение чтения из регистра DATA ----
		trd1_in		: in integer:=0;		
		trd2_in		: in integer:=0;		
		trd3_in		: in integer:=0;		
		trd4_in		: in integer:=0;		
		trd5_in		: in integer:=0;		
		trd6_in		: in integer:=0;		
		trd7_in		: in integer:=0;		

		---- Разрешение чтения из регистра STATUS ----
		trd1_st		: in integer:=0;		
		trd2_st		: in integer:=0;		
		trd3_st		: in integer:=0;		
		trd4_st		: in integer:=0;		
		trd5_st		: in integer:=0;		
		trd6_st		: in integer:=0;		
		trd7_st		: in integer:=0;		
		
		
		---- Константы тетрады ----
		rom0		: in bl_trd_rom;
		rom1		: in bl_trd_rom;
		rom2		: in bl_trd_rom;
		rom3		: in bl_trd_rom;
		rom4		: in bl_trd_rom;
		rom5		: in bl_trd_rom;
		rom6		: in bl_trd_rom;
		rom7		: in bl_trd_rom;
		
		---- Режим управления перепаковкой для тетрады 4 ----
		----  0 - перепаковка 32->64 разрешается битом MAIN.MODE2[4] ----
		----  2 - перепаковка разрешается при разрешении DRQ2 ----
		trd4_mode	: in integer:=0
	);

	port (			 
		---- GLOBAL ----
		reset			: in std_logic;		-- 0 - сброс
		clk				: in std_logic;		-- тактовая частота
		
		---- PLD_BUS ----
		lc_adr			: in  std_logic_vector( 6 downto 0 );	-- шина адреса
		lc_host_data	: in  std_logic_vector( 63 downto 0 );	-- шина данных, вход
		lc_data			: out std_logic_vector( 63 downto 0 );	-- шина данных, выход
		lc_wr			: in  std_logic;	-- 1 - запись
		lc_rd			: in  std_logic;	-- 1 - чтение
		

		test_mode		: in std_logic;		-- 1 - тестовый режим

		---- Шина адреса для подключения к узлу начального тестирования тетрады MAIN ----		
		trd_host_adr	: out std_logic_vector( 6 downto 0 );
		
		---- Шина данных, через которую производиться запись в регистры тетрады ----		
		trd_host_data	: out std_logic_vector( 63 downto 0 );

		---- Шина данных, через которую производиться запись в регистр DATA тетрады 4 ----		
		trd4_host_data	: out std_logic_vector( 63 downto 0 );
		
		---- Комада управления для каждой тетрады ----		
		trd_host_cmd	: out std_logic_array_16xbl_cmd;
		
		---- Выходы региста DATA от каждой тетрады ----
		trd_data		: in  std_logic_array_16x64:=(others=>(others=>'0'));
		
		---- Выходы регистров STATUS, CMD_ADR, CMD_DATA от каждой тетрады ----
		trd_cmd_data	: in  std_logic_array_16x16:=(others=>(others=>'0'));
		
		---- Сброс FIFO от каждой тетрады ----
		trd_reset_fifo	: in  std_logic_array_16xbl_reset_fifo:=(others=>'0');
		
		---- Запросы DMA от каждой тетрады ----
		trd_drq			: in  std_logic_array_16xbl_drq:=(others=>(others=>'0'));
		
		
		---- Источники прерываний и DRQ ----
		int1			: in std_logic:='0';
		            	
		drq0			: in bl_drq:=('0', '0', '0');
		drq1			: in bl_drq:=('0', '0', '0');
		drq2			: in bl_drq:=('0', '0', '0');
		drq3			: in bl_drq:=('0', '0', '0');	
		
		---- Выход DRQ и IRQ ----
		irq1			: out std_logic;
		dmar0			: out std_logic;
		dmar1			: out std_logic;
		dmar2			: out std_logic;
		dmar3			: out std_logic
		
		
	);
end component;

end package pb_adm_ctrl_m2_pkg;


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;



-- synopsys translate_off
library ieee;
use ieee.vital_timing.all;	

library unisim;
use unisim.VCOMPONENTS.all;
-- synopsys translate_on

library work;
use work.adm2_pkg.all;

entity pb_adm_ctrl_m2 is	 
	generic (					 
		---- Разрешение чтения из регистра DATA ----
		trd1_in		: in integer:=0;		
		trd2_in		: in integer:=0;		
		trd3_in		: in integer:=0;		
		trd4_in		: in integer:=0;		
		trd5_in		: in integer:=0;		
		trd6_in		: in integer:=0;		
		trd7_in		: in integer:=0;		

		---- Разрешение чтения из регистра STATUS ----
		trd1_st		: in integer:=0;		
		trd2_st		: in integer:=0;		
		trd3_st		: in integer:=0;		
		trd4_st		: in integer:=0;		
		trd5_st		: in integer:=0;		
		trd6_st		: in integer:=0;		
		trd7_st		: in integer:=0;		
		
		
		---- Константы тетрады ----
		rom0		: in bl_trd_rom;
		rom1		: in bl_trd_rom;
		rom2		: in bl_trd_rom;
		rom3		: in bl_trd_rom;
		rom4		: in bl_trd_rom;
		rom5		: in bl_trd_rom;
		rom6		: in bl_trd_rom;
		rom7		: in bl_trd_rom;
		
		---- Режим управления перепаковкой для тетрады 4 ----
		----  0 - перепаковка 32->64 разрешается битом MAIN.MODE2[4] ----
		----  2 - перепаковка разрешается при разрешении DRQ2 ----
		trd4_mode	: in integer:=0
		
	);

	port (			 
		---- GLOBAL ----
		reset			: in std_logic;		-- 0 - сброс
		clk				: in std_logic;		-- тактовая частота
		
		---- PLD_BUS ----
		lc_adr			: in  std_logic_vector( 6 downto 0 );	-- шина адреса
		lc_host_data	: in  std_logic_vector( 63 downto 0 );	-- шина данных, вход
		lc_data			: out std_logic_vector( 63 downto 0 );	-- шина данных, выход
		lc_wr			: in  std_logic;	-- 1 - запись
		lc_rd			: in  std_logic;	-- 1 - чтение
		

		test_mode		: in std_logic;		-- 1 - тестовый режим

		---- Шина адреса для подключения к узлу начального тестирования тетрады MAIN ----		
		trd_host_adr	: out std_logic_vector( 6 downto 0 );
		
		---- Шина данных, через которую производиться запись в регистры тетрады ----		
		trd_host_data	: out std_logic_vector( 63 downto 0 );

		---- Шина данных, через которую производиться запись в регистр DATA тетрады 4 ----		
		trd4_host_data	: out std_logic_vector( 63 downto 0 );
		
		---- Комада управления для каждой тетрады ----		
		trd_host_cmd	: out std_logic_array_16xbl_cmd;
		
		---- Выходы региста DATA от каждой тетрады ----
		trd_data		: in  std_logic_array_16x64:=(others=>(others=>'0'));
		
		---- Выходы регистров STATUS, CMD_ADR, CMD_DATA от каждой тетрады ----
		trd_cmd_data	: in  std_logic_array_16x16:=(others=>(others=>'0'));

		---- Сброс FIFO от каждой тетрады ----
		trd_reset_fifo	: in  std_logic_array_16xbl_reset_fifo:=(others=>'0');

		---- Запросы DMA от каждой тетрады ----
		trd_drq			: in  std_logic_array_16xbl_drq:=(others=>(others=>'0'));
		
		---- Источники прерываний и DRQ ----
		int1			: in std_logic:='0';
		            	
		drq0			: in bl_drq:=('0', '0', '0');
		drq1			: in bl_drq:=('0', '0', '0');
		drq2			: in bl_drq:=('0', '0', '0');
		drq3			: in bl_drq:=('0', '0', '0');	
		
		---- Выход DRQ и IRQ ----
		irq1			: out std_logic;
		dmar0			: out std_logic;
		dmar1			: out std_logic;
		dmar2			: out std_logic;
		dmar3			: out std_logic
		
		
	);
end pb_adm_ctrl_m2;



architecture pb_adm_ctrl_m2 of pb_adm_ctrl_m2 is




component ctrl_dram256x16_v2 is
	port (
	addra: in std_logic_vector(7 downto 0);
	addrb: in std_logic_vector(7 downto 0);
	clka: in std_logic;
	clkb: in std_logic;
	dina: in std_logic_vector(15 downto 0);
	doutb: out std_logic_vector(15 downto 0);
	sinita: in std_logic;
	ena: in std_logic;
	enb: in std_logic;
	wea: in std_logic);
end component;

component RAMB16_S18
-- synopsys translate_off
  generic (



       WRITE_MODE : string := "WRITE_FIRST";
       INIT  : bit_vector  := X"00000";
       SRVAL : bit_vector  := X"00000";


       INITP_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INITP_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INITP_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INITP_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INITP_04 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INITP_05 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INITP_06 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INITP_07 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_04 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_05 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_06 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_07 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_08 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_09 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_0A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_0B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_0C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_0D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_0E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_0F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_10 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_11 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_12 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_13 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_14 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_15 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_16 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_17 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_18 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_19 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_1A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_1B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_1C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_1D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_1E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_1F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_20 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_21 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_22 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_23 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_24 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_25 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_26 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_27 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_28 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_29 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_2A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_2B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_2C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_2D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_2E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_2F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_30 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_31 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_32 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_33 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_34 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_35 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_36 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_37 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_38 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_39 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_3A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_3B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_3C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_3D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_3E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
       INIT_3F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000"
  );
 -- synopsys translate_on
  port (
        DO     : out STD_LOGIC_VECTOR (15 downto 0);
        DOP    : out STD_LOGIC_VECTOR (1 downto 0);
        ADDR   : in STD_LOGIC_VECTOR (9 downto 0);
        CLK    : in STD_ULOGIC;
        DI     : in STD_LOGIC_VECTOR (15 downto 0);
        DIP    : in STD_LOGIC_VECTOR (1 downto 0);
        EN     : in STD_ULOGIC;
        SSR    : in STD_ULOGIC;
        WE     : in STD_ULOGIC
       ); 
end component;

component ctrl_adsp_v2_decode_data_cs is	
	generic(
		trd			: in integer;			-- номер тетрады
		reg			: in integer			-- номер регистра
											-- 0 - STATUS
											-- 1 - DATA
											-- 2 - CMD_ADR
											-- 3 - CMD_DATA
	);					 
	port (
		reset		: in std_logic;			-- 0 - сброс
		clk			: in std_logic;			-- тактовая частота
		cmd_data_en	: in std_logic;			-- 1 - разрешение декодирования CMD_DATA
		adr			: in std_logic_vector( 4 downto 0 );	-- шина адреса
		rd			: in std_logic;							-- 0 - чтение данных
		data_cs		: out std_logic							-- 0 - чтение данных
	);
end component;

component ctrl_adsp_v2_decode_data_in_cs is	
	port (
		reset		: in std_logic;			-- 0 - сброс
		clk			: in std_logic;			-- тактовая частота
		cmd_adr		: in std_logic_vector( 9 downto 8 );	-- косвенный адрес
		adr			: in std_logic_vector( 4 downto 0 );	-- шина адреса
		rd			: in std_logic;							-- 0 - чтение данных
		data_cs		: out std_logic							-- 0 - чтение данных
	);
end component;


component ctrl_adsp_v2_decode_ram_cs is
	generic (
		reg			: in integer			-- номер регистра
											-- 0 - RAM
											-- 1 - ROM
	);
	port (
		reset		: in std_logic;			-- 0 - сброс
		clk			: in std_logic;			-- тактовая частота
		cmd_adr		: in std_logic_vector( 9 downto 8 );	-- косвенный адрес
		adr			: in std_logic_vector( 4 downto 0 );	-- шина адреса
		rd			: in std_logic;							-- 0 - чтение данных
		data_cs		: out std_logic							-- 0 - чтение данных
	);
end component;

component ctrl_adsp_v2_decode_data_we is	
	generic(
		trd			: in integer;			-- номер тетрады
		reg			: in integer			-- номер регистра
											-- 0 - STATUS
											-- 1 - DATA
											-- 2 - CMD_ADR
											-- 3 - CMD_DATA
	);					 
	port (
		reset		: in std_logic;			-- 0 - сброс
		clk			: in std_logic;			-- тактовая частота
		adr			: in std_logic_vector( 4 downto 0 );	-- шина адреса
		wr			: in std_logic;							-- 0 - запись данных
		data_we		: out std_logic							-- 1 - запись данных
	);
end component;


component ctrl_adsp_v2_decode_cmd_adr_cs is
	port (
		reset		: in std_logic;			-- 0 - сброс
		clk			: in std_logic;			-- тактовая частота
		adr			: in std_logic_vector( 4 downto 0 );	-- шина адреса
		rd			: in std_logic;							-- 0 - чтение данных
		data_cs		: out std_logic							-- 0 - чтение данных
	);
end component;



component ctrl_mux8x48 is
	port (
	ma: in std_logic_vector(47 downto 0);
	mb: in std_logic_vector(47 downto 0);
	mc: in std_logic_vector(47 downto 0);
	md: in std_logic_vector(47 downto 0);
	me: in std_logic_vector(47 downto 0);
	mf: in std_logic_vector(47 downto 0);
	mg: in std_logic_vector(47 downto 0);
	mh: in std_logic_vector(47 downto 0);
	s: in std_logic_vector(2 downto 0);
	o: out std_logic_vector(47 downto 0));
end component;


component ctrl_mux16x16 is
	port (
	ma: in std_logic_vector(15 downto 0);
	mb: in std_logic_vector(15 downto 0);
	mc: in std_logic_vector(15 downto 0);
	md: in std_logic_vector(15 downto 0);
	me: in std_logic_vector(15 downto 0);
	mf: in std_logic_vector(15 downto 0);
	mg: in std_logic_vector(15 downto 0);
	mh: in std_logic_vector(15 downto 0);
	maa: in std_logic_vector(15 downto 0);
	mab: in std_logic_vector(15 downto 0);
	mac: in std_logic_vector(15 downto 0);
	mad: in std_logic_vector(15 downto 0);
	mae: in std_logic_vector(15 downto 0);
	maf: in std_logic_vector(15 downto 0);
	mag: in std_logic_vector(15 downto 0);
	mah: in std_logic_vector(15 downto 0);
	s: in std_logic_vector(3 downto 0);
	o: out std_logic_vector(15 downto 0));
end component;

component ctrl_mux8x16r is
	port (
	ma: in std_logic_vector(15 downto 0);
	mb: in std_logic_vector(15 downto 0);
	mc: in std_logic_vector(15 downto 0);
	md: in std_logic_vector(15 downto 0);
	me: in std_logic_vector(15 downto 0);
	mf: in std_logic_vector(15 downto 0);
	mg: in std_logic_vector(15 downto 0);
	mh: in std_logic_vector(15 downto 0);
	s: in std_logic_vector(2 downto 0);
	q: out std_logic_vector(15 downto 0);
	clk: in std_logic);
end component;


--component s_delay is
--	port( 
--		i 	: in  std_logic;	-- входной сигнал
--		o	: out std_logic		-- выходной сигнад
--	);
--end component;

-- XST black box declaration
--attribute box_type : string;
--attribute BOX_TYPE of RAMB16_S18 : component is "BLACK_BOX";



signal ms1			 		: std_logic;
signal wrl1, wrl2, rd1, rd2: std_logic;
signal adr1, adr2			: std_logic_vector( 6 downto 0 );
signal data2				: std_logic_vector( 63 downto 0 );
signal	rd2z				: std_logic;

signal data_out2			: std_logic_vector( 63 downto 0 );



signal  cmd_data2			: std_logic_vector( 15 downto 0 );
signal  rom_data2			: std_logic_vector( 15 downto 0 );
signal  sinit, dpram_en		: std_logic;
signal	dpram_en0			: std_logic;
signal  addra				: std_logic_vector( 9 downto 0 );
signal  addra2				: std_logic_vector( 15 downto 0 );
signal  dpram_cs2			: std_logic;

signal  bl_status_cs		: std_logic_vector( 7 downto 0 );
signal  bl_data_cs			: std_logic_vector( 7 downto 0 );
signal  bl_cmd_data_cs		: std_logic_vector( 7 downto 0 );

signal  bl_data_we			: std_logic_vector( 7 downto 0 );
signal  bl_cmd_adr_we		: std_logic_vector( 7 downto 0 );
signal  bl_cmd_adr_we1		: std_logic_vector( 7 downto 0 );
signal  bl_cmd_data_we		: std_logic_vector( 7 downto 0 );
signal  bl_cmd_data_we1		: std_logic_vector( 7 downto 0 );

signal	ram_cs1, ram_cs2	: std_logic;   
signal	rom_cs2				: std_logic;   
signal  data_in_cs2			: std_logic;
signal	data_in_cs2_0		: std_logic;
signal	cmd_adr_cs2			: std_logic;

signal  cmd0_adr, cmd1_adr, cmd2_adr, cmd3_adr: std_logic_vector( 15 downto 0 );
signal  cmd4_adr, cmd5_adr, cmd6_adr, cmd7_adr: std_logic_vector( 15 downto 0 );

signal  rom_di			: std_logic_vector( 15 downto 0 ); 

signal sel_cmd_data 	: std_logic;	-- 1 - чтение непосредственных регистров
signal sel_cmd_ram		: std_logic;	-- 1 - чтение командных регистров
signal sel_cmd_rom  	: std_logic;	-- 1 - чтение констант		

signal flyby1			: std_logic;	-- 1 - выполнение цикла DMA
signal ram_rom_cs		: std_logic;
signal en_ram			: std_logic;


signal	ma, mb, mc, md, me, mf, mg, mh : std_logic_vector( 63 downto 0 );
signal  maa, mab, mac, mad, mae, maf, mag, mah	: std_logic_vector( 15 downto 0 );

signal  na, nb, nc, nd, ne, nf, ng, nh	: std_logic_vector( 15 downto 0 );

signal	mux_sel	: std_logic_vector( 3 downto 0 );					   

signal	flyby2			: std_logic;			   
signal	flag_data_we	: std_logic_vector( 7 downto 0 );
signal	main_mode2_4	: std_logic:='0';  
signal	trd4i_host_data	: std_logic_vector( 63 downto 0 );

signal	flag_rd_block 	: std_logic_vector( 15 downto 0 );
signal	flag_rd_repack	: std_logic_vector( 15 downto 0 );
signal  trd_repack_data	: std_logic_array_16x64:=(others=>(others=>'0'));

signal	lc_data_i		: std_logic_vector( 63 downto 0 );

function conv_rom( rom: in bl_trd_rom; mode: integer ) return bit_vector is
 variable ret: bit_vector( 255 downto 0 );
begin
	for i in 0 to 15 loop
		ret( i*16+15 downto i*16 ):=to_bitvector( rom( i+mode*16 ), '0' );
	end loop;
	return ret;
end conv_rom;	

function conv_string( rom: in bl_trd_rom; mode: integer ) return string is
 variable str: string( 64 downto 1 );
 
 variable d	: std_logic_vector( 15 downto 0 );
 variable c	: std_logic_vector( 3 downto 0 );
 variable k	: integer;
begin			 
	
	
	
  for i in 0 to 15 loop  
	d:=rom( i+mode*16 );
	for j in 0 to 3 loop
	 c:=d( j*4+3 downto j*4 );
	 k:=i*4+j+1;
  	 case c is
		when x"0" => str(k) := '0';
		when x"1" => str(k) := '1';
		when x"2" => str(k) := '2';
		when x"3" => str(k) := '3';
		when x"4" => str(k) := '4';
		when x"5" => str(k) := '5';
		when x"6" => str(k) := '6';
		when x"7" => str(k) := '7';
		when x"8" => str(k) := '8';
		when x"9" => str(k) := '9';
		when x"A" => str(k) := 'A';
		when x"B" => str(k) := 'B';
		when x"C" => str(k) := 'C';
		when x"D" => str(k) := 'D';
		when x"E" => str(k) := 'E';
		when x"F" => str(k) := 'F';	
		when others => null;
	 end case;
	end loop; 
  end loop;
		
  return str;
end conv_string;	


constant rom_init_00	: bit_vector( 255 downto 0 ):= conv_rom( rom0, 0 );
constant rom_init_01	: bit_vector( 255 downto 0 ):= conv_rom( rom0, 1 );
constant rom_init_02	: bit_vector( 255 downto 0 ):= conv_rom( rom1, 0 );
constant rom_init_03	: bit_vector( 255 downto 0 ):= conv_rom( rom1, 1 );
constant rom_init_04	: bit_vector( 255 downto 0 ):= conv_rom( rom2, 0 );
constant rom_init_05	: bit_vector( 255 downto 0 ):= conv_rom( rom2, 1 );
constant rom_init_06	: bit_vector( 255 downto 0 ):= conv_rom( rom3, 0 );
constant rom_init_07	: bit_vector( 255 downto 0 ):= conv_rom( rom3, 1 );
constant rom_init_08	: bit_vector( 255 downto 0 ):= conv_rom( rom4, 0 );
constant rom_init_09	: bit_vector( 255 downto 0 ):= conv_rom( rom4, 1 );
constant rom_init_0A	: bit_vector( 255 downto 0 ):= conv_rom( rom5, 0 );
constant rom_init_0B	: bit_vector( 255 downto 0 ):= conv_rom( rom5, 1 );
constant rom_init_0C	: bit_vector( 255 downto 0 ):= conv_rom( rom6, 0 );
constant rom_init_0D	: bit_vector( 255 downto 0 ):= conv_rom( rom6, 1 );
constant rom_init_0E	: bit_vector( 255 downto 0 ):= conv_rom( rom7, 0 );
constant rom_init_0F	: bit_vector( 255 downto 0 ):= conv_rom( rom7, 1 );



constant str_init_00	: string:= conv_string( rom0, 0 );
constant str_init_01	: string:= conv_string( rom0, 1 );
constant str_init_02	: string:= conv_string( rom1, 0 );
constant str_init_03	: string:= conv_string( rom1, 1 );
constant str_init_04	: string:= conv_string( rom2, 0 );
constant str_init_05	: string:= conv_string( rom2, 1 );
constant str_init_06	: string:= conv_string( rom3, 0 );
constant str_init_07	: string:= conv_string( rom3, 1 );
constant str_init_08	: string:= conv_string( rom4, 0 );
constant str_init_09	: string:= conv_string( rom4, 1 );
constant str_init_0A	: string:= conv_string( rom5, 0 );
constant str_init_0B	: string:= conv_string( rom5, 1 );
constant str_init_0C	: string:= conv_string( rom6, 0 );
constant str_init_0D	: string:= conv_string( rom6, 1 );
constant str_init_0E	: string:= conv_string( rom7, 0 );
constant str_init_0F	: string:= conv_string( rom7, 1 );
	

attribute rom_style : string;
attribute rom_style of rom	: label is "block";

attribute init_10	: string;
attribute init_11	: string;
attribute init_12	: string;
attribute init_13	: string;
attribute init_14	: string;
attribute init_15	: string;
attribute init_16	: string;
attribute init_17	: string;
attribute init_18	: string;
attribute init_19	: string;
attribute init_1A	: string;
attribute init_1B	: string;
attribute init_1C	: string;
attribute init_1D	: string;
attribute init_1E	: string;
attribute init_1F	: string;

attribute init_10	of rom	: label is  str_init_00;
attribute init_11	of rom	: label is  str_init_01;
attribute init_12	of rom	: label is  str_init_02;
attribute init_13	of rom	: label is  str_init_03;
attribute init_14	of rom	: label is  str_init_04;
attribute init_15	of rom	: label is  str_init_05;
attribute init_16	of rom	: label is  str_init_06;
attribute init_17	of rom	: label is  str_init_07;
attribute init_18	of rom	: label is  str_init_08;
attribute init_19	of rom	: label is  str_init_09;
attribute init_1A	of rom	: label is  str_init_0A;
attribute init_1B	of rom	: label is  str_init_0B;
attribute init_1C	of rom	: label is  str_init_0C;
attribute init_1D	of rom	: label is  str_init_0D;
attribute init_1E	of rom	: label is  str_init_0E;
attribute init_1F	of rom	: label is  str_init_0F;

begin


rd1<= not lc_rd;

wrl1<= not lc_wr;

pr_ms2: process( reset, clk ) begin
	if( reset='0' ) then
		 wrl2<='1'; rd2<='1'; 
	elsif( rising_edge( clk ) ) then
			wrl2<=wrl1 after 1 ns; rd2<=rd1 after 1 ns; 
	end if;
end process;	


adr1<=lc_adr( 6 downto 0 ) when test_mode='0' else "0000010";

pr_adr_in: process( clk ) begin
	if( rising_edge( clk ) ) then	
		if( test_mode='1' ) then
		  adr2<="0000010";
		else 
		  adr2<=adr1;
		end if;	 
	end if;
end process;
	
data2<=lc_host_data when rising_edge( clk );
trd_host_data<=data2;	   

pr_bl_adr_out: process( clk ) begin
	if( rising_edge( clk ) ) then
		trd_host_adr( 6 downto 0 )<=lc_adr( 6 downto 0 );
	end if;
end process;

rom:	RAMB16_S18 
-- synopsys translate_off
generic map (
	INIT_10	=> rom_init_00,
	INIT_11	=> rom_init_01,
	INIT_12	=> rom_init_02,
	INIT_13	=> rom_init_03,
	INIT_14	=> rom_init_04,
	INIT_15	=> rom_init_05,
	INIT_16	=> rom_init_06,
	INIT_17	=> rom_init_07,
	INIT_18	=> rom_init_08,
	INIT_19	=> rom_init_09,
	INIT_1A	=> rom_init_0A,
	INIT_1B	=> rom_init_0B,
	INIT_1C	=> rom_init_0C,
	INIT_1D	=> rom_init_0D,
	INIT_1E	=> rom_init_0E,
	INIT_1F	=> rom_init_0F
)
-- synopsys translate_on
port map (
        DO     		=> rom_data2,
        ADDR(8 downto 0) => addra( 8 downto 0 ),	 
		ADDR(9) 	=> '0',
        CLK    		=> clk,
        DI     		=> data2( 15 downto 0 ), 
		DIP			=> "00",
        EN     		=> '1',
        SSR    		=> '0',
        WE     		=> dpram_en
); 	

en_ram	<= ((dpram_en or ram_cs1) and not (addra(8)) )or (ram_cs1 and addra(8));

addra2( 7 downto 5 )<=(others=>'0'); 	-- не используются
addra2( 15 downto 10 )<=(others=>'0'); 	-- не используется

pr_addra: process( clk ) 
 variable vsel: bit_vector( 2 downto 0 );
begin									 
	vsel:=to_bitvector( adr1( 5 downto 3 ), '0' );
	if( rising_edge( clk ) ) then
		addra( 7 downto 5 )<=adr1( 5 downto 3 );
		ram_cs1<=not rd1;
		case vsel is
			when "000" => 
				addra( 4 downto 0 )<=cmd0_adr( 4 downto 0 ); 
				addra( 9 downto 8 )<=cmd0_adr( 9 downto 8 );
			when "001" => 
				addra( 4 downto 0 )<=cmd1_adr( 4 downto 0 );
			 	addra( 9 downto 8 )<=cmd1_adr( 9 downto 8);
			when "010" => 
				addra( 4 downto 0 )<=cmd2_adr( 4 downto 0 );
			 	addra( 9 downto 8 )<=cmd2_adr( 9 downto 8);
			when "011" => 
				addra( 4 downto 0 )<=cmd3_adr( 4 downto 0 );
			 	addra( 9 downto 8 )<=cmd3_adr( 9 downto 8);
			when "100" => 
				addra( 4 downto 0 )<=cmd4_adr( 4 downto 0 ); 
				addra( 9 downto 8 )<=cmd4_adr( 9 downto 8);
			when "101" => 
				addra( 4 downto 0 )<=cmd5_adr( 4 downto 0 );
			 	addra( 9 downto 8 )<=cmd5_adr( 9 downto 8);
			when "110" => 
				addra( 4 downto 0 )<=cmd6_adr( 4 downto 0 );
			 	addra( 9 downto 8 )<=cmd6_adr( 9 downto 8);
			when "111" => 
				addra( 4 downto 0 )<=cmd7_adr( 4 downto 0 );
			 	addra( 9 downto 8 )<=cmd7_adr( 9 downto 8);
		end case;	
		addra2( 9 downto 8 )<=addra( 9 downto 8 );
		addra2( 4 downto 0 )<=addra( 4 downto 0 );
	end if;
end process;

pr_dpram_en: process( clk ) 
 variable ven: std_logic;
begin					 
	ven:='0';
	if( rising_edge( clk ) ) then
		if( test_mode='0' ) then
		  if( wrl1='0' and adr1(2)='1' and adr1(1)='1' ) then ven:='1'; end if;	
		end if;
		dpram_en0<=ven;
	end if;
end process;   

dpram_en <='1' when dpram_en0='1' and addra(9)='0' and addra(8)='0' else '0';


rd2z <= rd2 after 1 ns when rising_edge( clk );
gen_data_cs: for i in 0 to 7 generate

xstatus: ctrl_adsp_v2_decode_data_cs 
	generic map( trd=>i, reg=>0 )					 
	port map (
		reset	=> reset,
		clk		=> clk,
		cmd_data_en =>'0',
		adr		=> adr1(5 downto 1),
		rd		=> rd1,
		data_cs	=> bl_status_cs(i)
	);
	
xdata: ctrl_adsp_v2_decode_data_cs 
	generic map( trd=>i, reg=>1 )					 
	port map (
		reset	=> reset,
		clk		=> clk,
		cmd_data_en =>'0',
		adr		=> adr2(5 downto 1),
		rd		=> rd2z,
		data_cs	=> bl_data_cs(i)
	);


xcmd_data: ctrl_adsp_v2_decode_data_cs 
	generic map( trd=>i, reg=>3 )					 
	port map(
		reset	=> reset,
		clk		=> clk,
		cmd_data_en =>sel_cmd_data,
		adr		=> adr1( 5 downto 1 ),
		rd		=> rd1,
		data_cs	=> bl_cmd_data_cs(i)  
	);

xdata_we: ctrl_adsp_v2_decode_data_we 
	generic map( trd=>i, reg=>1 )
	port map(
		reset		=> reset,
		clk			=> clk,
		adr			=> adr1( 5 downto 1 ),
		wr			=> wrl1,
		data_we		=> bl_data_we(i)
	);

xcmd_adr_we: ctrl_adsp_v2_decode_data_we 
	generic map( trd=>i, reg=>2 )
	port map(
		reset		=> reset,
		clk			=> clk,
		adr			=> adr1( 5 downto 1 ),
		wr			=> wrl1,
		data_we		=> bl_cmd_adr_we(i)
	);

xcmd_data_we: ctrl_adsp_v2_decode_data_we 
	generic map( trd=>i, reg=>3 )
	port map(
		reset		=> reset,
		clk			=> clk,
		adr			=> adr1( 5 downto 1 ),
		wr			=> wrl1,
		data_we		=> bl_cmd_data_we(i)
	);
	
	
end generate;	

xcmd_ram: ctrl_adsp_v2_decode_ram_cs 
	generic  map( reg => 0 )
	port map (
		reset		=> reset,
		clk			=> clk,
		cmd_adr		=> addra( 9 downto 8 ),
		adr			=> adr2( 5 downto 1 ),
		rd			=> rd2,
		data_cs		=> ram_cs2
	);

xcmd_rom: ctrl_adsp_v2_decode_ram_cs 
	generic  map( reg => 1 )
	port map (
		reset		=> reset,
		clk			=> clk,
		cmd_adr		=> addra( 9 downto 8 ),
		adr			=> adr2( 5 downto 1 ),
		rd			=> rd2,
		data_cs		=> rom_cs2
	);
	

xcmd_adr: ctrl_adsp_v2_decode_cmd_adr_cs 
	port map(
		reset		=> reset,
		clk			=> clk,
		adr			=> adr2( 5 downto 1 ),
		rd			=> rd2,
		data_cs		=> cmd_adr_cs2
	);
 
--sel_cmd_data <= addra(9);
sel_cmd_ram  <= '1' when addra(9)='0' and addra(8)='0' else '0';
sel_cmd_rom  <= '1' when addra(9)='0' and addra(8)='1' else '0';

pr_sel_cmd_data: process( adr1, cmd0_adr, cmd1_adr, cmd2_adr, cmd3_adr,
	cmd4_adr, cmd5_adr, cmd6_adr, cmd7_adr ) 
 variable vsel: bit_vector( 2 downto 0 );
begin									 
	vsel:=to_bitvector( adr1( 5 downto 3 ), '0' );
		case vsel is
			when "000" => sel_cmd_data <= cmd0_adr( 9 );
			when "001" => sel_cmd_data <= cmd1_adr( 9 );
			when "010" => sel_cmd_data <= cmd2_adr( 9 );
			when "011" => sel_cmd_data <= cmd3_adr( 9 );
			when "100" => sel_cmd_data <= cmd4_adr( 9 );
			when "101" => sel_cmd_data <= cmd5_adr( 9 );
			when "110" => sel_cmd_data <= cmd6_adr( 9 );
			when "111" => sel_cmd_data <= cmd7_adr( 9 );
		end case;	
end process;
	
	
pr_cmd_adr: process( reset, clk ) begin
	if( reset='0' ) then
		cmd0_adr<=(others=>'0');
		cmd1_adr<=(others=>'0');
		cmd2_adr<=(others=>'0');
		cmd3_adr<=(others=>'0');
		cmd4_adr<=(others=>'0');
		cmd5_adr<=(others=>'0');
		cmd6_adr<=(others=>'0');
		cmd7_adr<=(others=>'0');
	elsif( rising_edge( clk ) ) then
		if( bl_cmd_adr_we(0)='1' ) then cmd0_adr( 9 downto 0 )<=data2( 9 downto 0 ); end if;
		if( bl_cmd_adr_we(1)='1' ) then cmd1_adr( 9 downto 0 )<=data2( 9 downto 0 ); end if; 
		if( bl_cmd_adr_we(2)='1' ) then cmd2_adr( 9 downto 0 )<=data2( 9 downto 0 ); end if; 
		if( bl_cmd_adr_we(3)='1' ) then cmd3_adr( 9 downto 0 )<=data2( 9 downto 0 ); end if; 
		if( bl_cmd_adr_we(4)='1' ) then cmd4_adr( 9 downto 0 )<=data2( 9 downto 0 ); end if; 
		if( bl_cmd_adr_we(5)='1' ) then cmd5_adr( 9 downto 0 )<=data2( 9 downto 0 ); end if; 
		if( bl_cmd_adr_we(6)='1' ) then cmd6_adr( 9 downto 0 )<=data2( 9 downto 0 ); end if;
		if( bl_cmd_adr_we(7)='1' ) then cmd7_adr( 9 downto 0 )<=data2( 9 downto 0 ); end if; 
	end if;
end process;					 

pr_adr_we1: process( clk ) begin
	if( rising_edge( clk ) ) then
		bl_cmd_adr_we1<=bl_cmd_adr_we;
	end if;
end process;

cmd0_adr( 15 downto 10 ) <= ( others=>'0' );
cmd1_adr( 15 downto 10 ) <= ( others=>'0' );
cmd2_adr( 15 downto 10 ) <= ( others=>'0' );
cmd3_adr( 15 downto 10 ) <= ( others=>'0' );
cmd4_adr( 15 downto 10 ) <= ( others=>'0' );
cmd5_adr( 15 downto 10 ) <= ( others=>'0' );
cmd6_adr( 15 downto 10 ) <= ( others=>'0' );
cmd7_adr( 15 downto 10 ) <= ( others=>'0' );

ram_rom_cs	<= ram_cs2 and rom_cs2;

									   
pr_irq: process( clk ) begin
	if( rising_edge( clk ) ) then
		irq1 <= int1;
	end if;
end process;


dmar0 <= '1' when drq0.en='1' and drq0.req='1' else '0';
dmar1 <= '1' when drq1.en='1' and drq1.req='1' else '0';
dmar2 <= '1' when drq2.en='1' and drq2.req='1' else '0';
dmar3 <= '1' when drq3.en='1' and drq3.req='1' else '0';

--		
--gen_cmd_data_we: for i in 0 to 7 generate
--	
--xcmd_data_we:	s_delay port map( o=>bl_cmd_data_we1(i), i=>bl_cmd_data_we(i) );
--
--end generate;
--

bl_cmd_data_we1 <= bl_cmd_data_we;
 
gen_trd_cmd: for i in 0 to 7 generate
												   
	trd_host_cmd(i).data_we		<=bl_data_we(i) and flag_data_we(i);
	trd_host_cmd(i).cmd_data_we	<=bl_cmd_data_we1(i);
	trd_host_cmd(i).status_cs	<=bl_status_cs(i);
	trd_host_cmd(i).data_cs		<=bl_data_cs(i) or flag_rd_block(i); --flag_rd_repack(i);		
	trd_host_cmd(i).data_oe		<=bl_data_cs(i);		
	trd_host_cmd(i).cmd_data_cs	<=bl_cmd_data_cs(i);
	trd_host_cmd(i).cmd_adr_we	<=bl_cmd_adr_we1(i);

end generate;

trd_host_cmd(0).adr			<=cmd0_adr( 9 downto 0 ); 
trd_host_cmd(1).adr			<=cmd1_adr( 9 downto 0 ); 
trd_host_cmd(2).adr			<=cmd2_adr( 9 downto 0 ); 
trd_host_cmd(3).adr			<=cmd3_adr( 9 downto 0 ); 
trd_host_cmd(4).adr			<=cmd4_adr( 9 downto 0 ); 
trd_host_cmd(5).adr			<=cmd5_adr( 9 downto 0 ); 
trd_host_cmd(6).adr			<=cmd6_adr( 9 downto 0 ); 
trd_host_cmd(7).adr			<=cmd7_adr( 9 downto 0 ); 






mux8: ctrl_mux8x48 
	port map (
	ma	=> ma( 63 downto 16 ),
	mb	=> mb( 63 downto 16 ),
	mc	=> mc( 63 downto 16 ),
	md	=> md( 63 downto 16 ),
	me	=> me( 63 downto 16 ),
	mf	=> mf( 63 downto 16 ),
	mg	=> mg( 63 downto 16 ),
	mh	=> mh( 63 downto 16 ),
	s	=> mux_sel( 2 downto 0 ),
	o	=> lc_data_i( 63 downto 16 ) );



mux16: ctrl_mux16x16 
	port map(
	ma		=> ma( 15 downto 0 ),
	mb		=> mb( 15 downto 0 ),
	mc		=> mc( 15 downto 0 ),
	md		=> md( 15 downto 0 ),
	me		=> me( 15 downto 0 ),
	mf		=> mf( 15 downto 0 ),
	mg		=> mg( 15 downto 0 ),
	mh		=> mh( 15 downto 0 ),
	maa		=> maa( 15 downto 0 ),
	mab		=> mab( 15 downto 0 ),
	mac		=> mac( 15 downto 0 ),
	mad		=> mad( 15 downto 0 ),
	mae		=> mae( 15 downto 0 ),
	maf		=> maf( 15 downto 0 ),
	mag		=> mag( 15 downto 0 ),
	mah		=> mah( 15 downto 0 ),
	s		=> mux_sel( 3 downto 0 ),
	o		=> lc_data_i( 15 downto 0 ) );
	
lc_data <= lc_data_i after 1 ns when rising_edge( clk );	
	
ma <= trd_repack_data(0) after 1 ns when rising_edge( clk );

xd1p: if( trd1_in=1 ) generate  mb <= trd_repack_data(1) after 1 ns when rising_edge( clk );   end generate;
xd1n: if( trd1_in=0 ) generate  mb <= (others=>'0'); end generate;

xd2p: if( trd2_in=1 ) generate  mc <= trd_repack_data(2) after 1 ns when rising_edge( clk );   end generate;
xd2n: if( trd2_in=0 ) generate  mc <= (others=>'0'); end generate;
	
xd3p: if( trd3_in=1 ) generate  md <= trd_repack_data(3) after 1 ns when rising_edge( clk );   end generate;
xd3n: if( trd3_in=0 ) generate  md <= (others=>'0'); end generate;
	
xd4p: if( trd4_in=1 ) generate  me <= trd_repack_data(4) after 1 ns when rising_edge( clk );   end generate;
xd4n: if( trd4_in=0 ) generate  me <= (others=>'0'); end generate;
	
xd5p: if( trd5_in=1 ) generate  mf <= trd_repack_data(5) after 1 ns when rising_edge( clk );   end generate;
xd5n: if( trd5_in=0 ) generate  mf <= (others=>'0'); end generate;
	
xd6p: if( trd6_in=1 ) generate  mg <= trd_repack_data(6) after 1 ns when rising_edge( clk );   end generate;
xd6n: if( trd6_in=0 ) generate  mg <= (others=>'0'); end generate;

xd7p: if( trd6_in=1 ) generate  mh <= trd_repack_data(7) after 1 ns when rising_edge( clk );   end generate;
xd7n: if( trd6_in=0 ) generate  mh <= (others=>'0'); end generate;
	
	
gen_repack: for ii in 0 to 7 generate
	
trd_repack_data(ii)( 31 downto 0 ) <= trd_data(ii)( 31 downto 0 ) when flag_rd_repack(ii)='0' else trd_data(ii)( 63 downto 32 );
trd_repack_data(ii)( 63 downto 32 ) <= trd_data(ii)( 63 downto 32 );	
	
pr_flag4: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( trd_drq(ii).en='1' ) then
			flag_rd_repack(ii) <= '0' after 1 ns;
			flag_rd_block(ii) <= '0' after 1 ns;
		elsif( trd_reset_fifo(ii)='0' ) then
			flag_rd_repack(ii) <= '0' after 1 ns;
			flag_rd_block(ii) <= '1' after 1 ns;
		elsif( bl_data_cs(ii)='0' ) then		
			flag_rd_repack(ii) <= not flag_rd_repack(ii) after 1 ns;
			flag_rd_block(ii)  <= not flag_rd_block(ii) after 1 ns;
		end if;
	end if;
end process;

end generate;
			



maa <= rom_data2  after 1 ns when rising_edge( clk );
mab <= cmd_data2  after 1 ns when rising_edge( clk );
mac <= addra2  after 1 ns when rising_edge( clk );

mad <= (others=>'-');
mae <= (others=>'-');
maf <= (others=>'-');
mag <= (others=>'-');
mah <= (others=>'-');


pr_mux_sel: process( clk ) begin
	if( rising_edge( clk ) ) then
		case( adr2( 2 downto 1 ) ) is
		  when "00" =>  -- STATUS
		    mux_sel <= "1001";
		  when "01" =>  -- DATA
			mux_sel( 2 downto 0 ) <= adr2( 5 downto 3 );
			mux_sel( 3 ) <= '0';
		  when "10" =>  -- CMD_ADR
		  	mux_sel <= "1010";
		  when "11" =>  -- CMD_DATA
		    mux_sel( 3 downto 1 ) <= "100";
		  	mux_sel( 0 ) <= addra( 9 );
		  when others => null;
		end case;
	end if;
end process;
		  
		  

mux_cmd: ctrl_mux8x16r 
	port map (
		ma	=> na,
		mb	=> nb,
		mc	=> nc,
		md	=> nd,
		me	=> ne,
		mf	=> nf,
		mg	=> ng, 
		mh	=> nh,
		s	=> adr2( 5 downto 3 ),
		q	=> cmd_data2,
		clk	=> clk
);

na <= trd_cmd_data(0) after 1 ns when rising_edge( clk );	  

xc1p:	if( trd1_st=1 ) generate nb <= trd_cmd_data(1) after 1 ns when rising_edge( clk );  end generate;
xc1n:	if( trd1_st=0 ) generate nb <= (others=>'1'); end generate;
	
xc2p:	if( trd2_st=1 ) generate nc <= trd_cmd_data(2) after 1 ns when rising_edge( clk );  end generate;
xc2n:	if( trd2_st=0 ) generate nc <= (others=>'1'); end generate;
	
xc3p:	if( trd3_st=1 ) generate nd <= trd_cmd_data(3) after 1 ns when rising_edge( clk );  end generate;
xc3n:	if( trd3_st=0 ) generate nd <= (others=>'1'); end generate;
	
xc4p:	if( trd4_st=1 ) generate ne <= trd_cmd_data(4) after 1 ns when rising_edge( clk );  end generate;
xc4n:	if( trd4_st=0 ) generate ne <= (others=>'1'); end generate;
	
xc5p:	if( trd5_st=1 ) generate nf <= trd_cmd_data(5) after 1 ns when rising_edge( clk );  end generate;
xc5n:	if( trd5_st=0 ) generate nf <= (others=>'1'); end generate;
	
xc6p:	if( trd6_st=1 ) generate ng <= trd_cmd_data(6) after 1 ns when rising_edge( clk );  end generate;
xc6n:	if( trd6_st=0 ) generate ng <= (others=>'1'); end generate;
	
xc7p:	if( trd7_st=1 ) generate nh <= trd_cmd_data(7) after 1 ns when rising_edge( clk );  end generate;
xc7n:	if( trd7_st=0 ) generate nh <= (others=>'1'); end generate;
	
	
	
pr_flag_data_we4: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( main_mode2_4='0' ) then
			flag_data_we(4) <= '1' after 1 ns;		  
		elsif( trd_reset_fifo( 4 )='0' ) then
			flag_data_we(4) <= '0' after 1 ns;		  
		elsif( 	bl_data_we( 4 )='1' ) then
			flag_data_we( 4 ) <= not flag_data_we( 4 ) after 1 ns;
		end if;
	end if;
end process;

trd4i_host_data( 31 downto 0 ) <=  data2( 31 downto 0 ) when rising_edge( clk ) and flag_data_we(4)='0' and bl_data_we(4)='1';
trd4i_host_data( 63 downto 32 ) <= data2( 31 downto 0 );

trd4_host_data <= trd4i_host_data when main_mode2_4='1' else data2;

flag_data_we( 3 downto 0 ) <= (others=>'1');
flag_data_we( 7 downto 5 ) <= (others=>'1');
			

gen_mode2: if( 	trd4_mode=0 ) generate 
	
	pr_main_mode2: process( clk ) begin
		if( rising_edge( clk ) ) then
			if( reset='0' ) then
				main_mode2_4 <= '0' after 1 ns;	   
			elsif( bl_cmd_data_we1(0)='1' and cmd0_adr( 9 downto 8 )="00" and cmd0_adr( 4 downto 0 )="01010" ) then
				main_mode2_4 <= data2(4) after 1 ns;
			end if;
		end if;
	end process;

end generate;

gen_dmar2: if( trd4_mode=2 ) generate
	
	main_mode2_4 <= not trd_drq(4).en;
	
end generate;	
			

end pb_adm_ctrl_m2;