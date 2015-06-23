---------------------------------------------------------------------------------------------------
--
-- Title       : cl_chn_v3
-- Author      : Ilya Ivanov
-- Company     : Instrumental System
--
-- Version     : 3.0
---------------------------------------------------------------------------------------------------
--
-- Description : Реализация общих регистров управления,
--				 формирование прерывания и запроса DMA
--				 Для дешифрации адреса используются только разряды 3..0.
--				 Добавлена дешифрация регистров MODE3 и SFLAG
--
---------------------------------------------------------------------------------------------------
--
--   Version 3.1   05.04.2010
--					Добавлены триггеры на сигналы rst, fifo_rst
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

use work.adm2_pkg.all; 

package cl_chn_v3_pkg is	
	
component cl_chn_v3 is	  
	generic (					 
	  -- 2 - out - для тетрады вывода
	  -- 1 - in  - для тетрады ввода
	  chn_type : integer 
	);

	port(
		reset: in std_logic;				-- 0 - общий сброс
		clk: in std_logic;					-- тактовая частота
		
		-- Флаги
		cmd_rdy		: in std_logic;		  	-- 1 - готовность тетрады
		rdy			: in std_logic;			-- 1 - готовность FIFO
		fifo_flag	: in bl_fifo_flag;		-- флаги FIFO
		st9			: in std_logic:='0';	-- Разряды регистры STATUS
		st10		: in std_logic:='0';
		st11		: in std_logic:='0';
		st12		: in std_logic:='0';
		st13		: in std_logic:='0';
		st14		: in std_logic:='0';
		st15		: in std_logic:='0';
		
		-- Тетрада	
		data_in		: in std_logic_vector( 15 downto 0 );	-- шина данных
		cmd			: in bl_cmd;							-- команда
		bx_irq		: out std_logic;					  	-- 1 - прерывание от тетрады
		bx_drq		: out bl_drq;							-- запрос DMA
		
		status		: out std_logic_vector( 15 downto 0 );	-- регистр STATUS
				
		-- Управление
		mode0		: out std_logic_vector( 15 downto 0 );	-- регистры тетрады
		mode1		: out std_logic_vector( 15 downto 0 );	
		mode2		: out std_logic_vector( 15 downto 0 );	
		mode3		: out std_logic_vector( 15 downto 0 );	
		sflag		: out std_logic_vector( 15 downto 0 );
		fdiv		: out std_logic_vector( 15 downto 0 );
		fdiv_we		: out std_logic;						-- 1 - в регистре FDIV новое значение
		fmode		: out std_logic_vector( 15 downto 0 );
		stmode		: out std_logic_vector( 15 downto 0 );
		cnt0		: out std_logic_vector( 15 downto 0 );
		cnt1		: out std_logic_vector( 15 downto 0 );
		cnt2		: out std_logic_vector( 15 downto 0 );
		rst			: out std_logic;						-- 0 - сброс тетрады
		fifo_rst	: out std_logic							-- 0 - сброс FIFO
	);
end component;

end cl_chn_v3_pkg;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

use work.adm2_pkg.all; 

entity cl_chn_v3 is	  
	generic (					 
	  -- 2 - out - для тетрады вывода
	  -- 1 - in  - для тетрады ввода
	  chn_type : integer 
	);

	port(
		reset: in std_logic;				-- 0 - общий сброс
		clk: in std_logic;					-- тактовая частота
		
		-- Флаги
		cmd_rdy		: in std_logic;		  	-- 1 - готовность тетрады
		rdy			: in std_logic;			-- 1 - готовность FIFO
		fifo_flag	: in bl_fifo_flag;		-- флаги FIFO
		st9			: in std_logic:='0';	-- Разряды регистры STATUS
		st10		: in std_logic:='0';
		st11		: in std_logic:='0';
		st12		: in std_logic:='0';
		st13		: in std_logic:='0';
		st14		: in std_logic:='0';
		st15		: in std_logic:='0';
		
		-- Тетрада	
		data_in		: in std_logic_vector( 15 downto 0 );	-- шина данных
		cmd			: in bl_cmd;							-- команда
		bx_irq		: out std_logic;					  	-- 1 - прерывание от тетрады
		bx_drq		: out bl_drq;							-- запрос DMA
		
		status		: out std_logic_vector( 15 downto 0 );	-- регистр STATUS
				
		-- Управление
		mode0		: out std_logic_vector( 15 downto 0 );	-- регистры тетрады
		mode1		: out std_logic_vector( 15 downto 0 );	
		mode2		: out std_logic_vector( 15 downto 0 );	
		mode3		: out std_logic_vector( 15 downto 0 );	
		sflag		: out std_logic_vector( 15 downto 0 );
		fdiv		: out std_logic_vector( 15 downto 0 );
		fdiv_we		: out std_logic;						-- 1 - в регистре FDIV новое значение
		fmode		: out std_logic_vector( 15 downto 0 );
		stmode		: out std_logic_vector( 15 downto 0 );
		cnt0		: out std_logic_vector( 15 downto 0 );
		cnt1		: out std_logic_vector( 15 downto 0 );
		cnt2		: out std_logic_vector( 15 downto 0 );
		rst			: out std_logic;						-- 0 - сброс тетрады
		fifo_rst	: out std_logic							-- 0 - сброс FIFO
	);
end cl_chn_v3;

architecture cl_chn_v3 of cl_chn_v3 is
  
signal  c_mode0, c_mode1, c_mode2, c_mode3		: std_logic_vector( 15 downto 0 );
signal  c_mask, c_inv, c_sflag, c_flag, c_irq 	: std_logic_vector( 15 downto 0 );
signal  c_fmode, c_fdiv, c_stmode, c_cnt0, c_cnt1, c_cnt2: std_logic_vector( 15 downto 0 );
signal	c_status: std_logic_vector( 15 downto 0 );
signal  c_drq_en: std_logic;	 
signal  c_rst: std_logic; 	-- 0 - сброс тетрады


begin

	
	
mode0<=c_mode0;
mode1<=c_mode1;
mode2<=c_mode2;
mode3<=c_mode3;	
sflag<=c_sflag;
status<=c_status;
fmode<=c_fmode;
fdiv<=c_fdiv; 
stmode<=c_stmode;
cnt0<=c_cnt0;
cnt1<=c_cnt1;
cnt2<=c_cnt2;


pr_mode0: process( reset, clk ) begin
	if( reset='0' ) then
		c_mode0<=(others=>'0');
	elsif( rising_edge( clk ) ) then
		if( cmd.cmd_data_we='1' ) then
			if( cmd.adr(9)='0' and cmd.adr(8)='0' ) then
			  case cmd.adr( 3 downto 0 ) is
				  when "0000" => c_mode0<=data_in;
				  when others=>null;
			  end case;
			end if;
		end if;
	end if;
end process;


pr_reg: process( c_rst, clk ) 
 variable v: std_logic;
begin
	if( c_rst='0' ) then
		c_mode1<=(others=>'0');
		c_mode2<=(others=>'0');
		c_mode3<=(others=>'0');
		c_sflag<=(others=>'0');
		c_mask<=(others=>'0');
		c_inv<=(others=>'0'); 
		c_fmode<=(others=>'0');
		c_fdiv <=(others=>'0'); 
		c_stmode<=(others=>'0'); 
		c_cnt0<=(others=>'0'); 
		c_cnt1<=(others=>'0'); 
		c_cnt2<=(others=>'0'); 
		fdiv_we<='0';
	elsif( rising_edge( clk ) ) then
		v:='0';
		if( cmd.cmd_data_we='1' ) then
			if( cmd.adr(9)='0' and cmd.adr(8)='0' ) then
			  case cmd.adr( 3 downto 0 ) is
				  when x"1" => c_mask<=data_in;
				  when x"2" => c_inv<=data_in;
				  when x"3" => c_fmode<=data_in; 
				  when x"4" => c_fdiv<=data_in; v:='1';
				  when x"5" => c_stmode<=data_in;
				  when x"6" => c_cnt0<=data_in;
				  when x"7" => c_cnt1<=data_in;
				  when x"8" => c_cnt2<=data_in;
				  when x"9" => c_mode1<=data_in;
				  when x"a" => c_mode2<=data_in;
				  when x"b" => c_mode3<=data_in;
				  when x"c" => c_sflag<=data_in;
				  when others=>null;
			  end case;
			end if;
		end if;
		fdiv_we<=v;
	end if;
end process;

pr_status: process( clk ) begin
	if( rising_edge( clk ) ) then
		c_status(0)<=cmd_rdy;
		c_status(1)<=rdy;
		c_status(2)<=fifo_flag.ef;
		c_status(3)<=fifo_flag.pae;
		c_status(4)<=fifo_flag.hf;
		c_status(5)<=fifo_flag.paf;
		c_status(6)<=fifo_flag.ff;  
		c_status(7)<=fifo_flag.ovr;
		c_status(8)<=fifo_flag.und;
		c_status(9)<=st9;
		c_status(10)<=st10;
		c_status(11)<=st11;
		c_status(12)<=st12;
		c_status(13)<=st13;
		c_status(14)<=st14;
		c_status(15)<=st15;
	end if;
end process; 

c_flag<=c_status xor c_inv;
c_irq<= c_flag and c_mask;

pr_irq: process( c_irq, clk ) 
 variable v: std_logic;
begin	
	v:='0';
	for i in 0 to 15 loop
		v:=v or c_irq( i );
	end loop;
	if( rising_edge( clk ) ) then
		bx_irq<=v and c_mode0(2);
	end if;
end process;


c_rst<=reset and ( not c_mode0(0) );
rst <= c_rst  after 1 ns when rising_edge( clk );

fifo_rst<=reset and ( not c_mode0(0) ) and ( not c_mode0(1) )  after 1 ns when rising_edge( clk );

c_drq_en<=c_mode0( 3 );

bx_drq.en<=c_drq_en;

gen_out: if chn_type=2 generate

pr_bx_drq: process( c_mode0, fifo_flag, c_drq_en, rdy ) 

begin
	case c_mode0( 13 downto 12 )  is
		when "00" => bx_drq.req <= fifo_flag.paf and c_drq_en; -- PAF = 1 
		when "01" => bx_drq.req <= rdy and c_drq_en; 		   -- RDY = 1
		when "10" => bx_drq.req <= fifo_flag.hf and c_drq_en; -- HF  = 1
		when others => bx_drq.req<='0';
	end case;
end process;	
	
	bx_drq.ack <= cmd.data_we and c_drq_en;
	
end generate;

gen_in: if chn_type=1 generate

pr_bx_drq: process( c_mode0, fifo_flag, c_drq_en, rdy )

begin
	case c_mode0( 13 downto 12 ) is
		when "00" => bx_drq.req <= fifo_flag.pae and c_drq_en; -- PAE = 1 
		when "01" => bx_drq.req <= rdy and c_drq_en; 		   -- RDY = 1
		when "10" => bx_drq.req <= ( not fifo_flag.hf ) and c_drq_en; -- HF  = 0
		when others => bx_drq.req<='0';
	end case;
end process;

	bx_drq.ack <= ( not cmd.data_cs )  and c_drq_en;
	
end generate;	
			   		       
end cl_chn_v3;

