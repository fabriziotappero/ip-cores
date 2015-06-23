-------------------------------------------------------------------------------
--
-- Title       : ctrl_ram_cmd
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.4
--
-------------------------------------------------------------------------------
--
-- Description : 	Узел управления памятью
--
-------------------------------------------------------------------------------
--
--  Version 1.4  09.04.2012
--				 Исправлено формирование 
--                               ch0_next_block, ch1_next_block
--
-------------------------------------------------------------------------------
--
--  Version 1.3  06.12.2011
--				 Добавлен local_adr_we
--
-------------------------------------------------------------------------------
--
--  Version 1.2  05.04.2010
--				 Добавлен параметр is_dsp48 - разрешение использования
--				 блоков DSP48
--
-------------------------------------------------------------------------------
--
--  Version 1.1   02.09.2009
--					Исправлен сброс ch1_adr_hi
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;				  

package ctrl_ram_cmd_pkg is

component ctrl_ram_cmd is				  
	generic(
		is_dsp48			: in integer:=1		-- 1 - использовать DSP48, 0 - не использовать DSP48
	);
	port(
		---- Global ----
		reset				: in std_logic;	-- 0 - сброс
		clk					: in std_logic;		--! Тактовая частота ядра - 250 МГц
		aclk				: in std_logic;		--! Тактовая частота локальной шины - 266 МГц
		
		---- Picoblaze ----
		dma_chn				: in std_logic;							-- номер канала DMA	  
		reg_ch0_ctrl		: in std_logic_vector( 7 downto 0 );	-- регистр управления
		reg_ch1_ctrl		: in std_logic_vector( 7 downto 0 );	-- регистр управления
		reg_write_E0		: in std_logic;		-- 1 - смена блока памяти
		dma0_transfer_rdy	: out  std_logic;	-- 1 - блок памяти готов к обмену
		dma1_transfer_rdy	: out  std_logic;	-- 1 - блок памяти готов к обмену
		loc_adr_we			: in std_logic;	-- 1 - запись локального адреса
		
		---- PLB_BUS ----			  
		dmar0				: in  std_logic;	-- 1 - запрос DMA 0
		dmar1				: in  std_logic;	-- 1 - запрос DMA 1	  
		request_wr			: out std_logic;	--! 1 - запрос на запись в регистр 
		request_rd			: out std_logic;	--! 1 - запрос на чтение из регистра 
		allow_wr			: in  std_logic;	--! 1 - разрешение записи 
		pb_complete			: in  std_logic;	--! 1 - завершение обмена по шине PLD_BUS
		
		
		pf_repack_we		: in  std_logic;	-- 1 - запись в память
		pf_ram_rd_out		: out std_logic;	-- 1 - чтение из памяти
		
		---- Память ----	   
		ram_adra_a9			: out std_logic;	-- разряд 9 адреса памяти
		ram_adrb			: out std_logic_vector( 10 downto 0 )
	
	);
	
end component;

end package;


library ieee;
use ieee.std_logic_1164.all;				  
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;		

library unisim;
use unisim.vcomponents.all;


use work.ctrl_ram_cmd_pb_pkg.all;

entity ctrl_ram_cmd is				  
	generic(
		is_dsp48			: in integer:=1		-- 1 - использовать DSP48, 0 - не использовать DSP48
	);
	port(
		---- Global ----
		reset				: in std_logic;	-- 0 - сброс
		clk					: in std_logic;		--! Тактовая частота ядра - 250 МГц
		aclk				: in std_logic;		--! Тактовая частота локальной шины - 266 МГц
		
		---- Picoblaze ----
		dma_chn				: in std_logic;							-- номер канала DMA	  
		reg_ch0_ctrl		: in std_logic_vector( 7 downto 0 );	-- регистр управления
		reg_ch1_ctrl		: in std_logic_vector( 7 downto 0 );	-- регистр управления
		reg_write_E0		: in std_logic;		-- 1 - смена блока памяти
		dma0_transfer_rdy	: out  std_logic;	-- 1 - блок памяти готов к обмену
		dma1_transfer_rdy	: out  std_logic;	-- 1 - блок памяти готов к обмену
		loc_adr_we			: in std_logic;	-- 1 - запись локального адреса
		
		---- PLB_BUS ----			  
		dmar0				: in  std_logic;	-- 1 - запрос DMA 0
		dmar1				: in  std_logic;	-- 1 - запрос DMA 1
		request_wr			: out std_logic;	--! 1 - запрос на запись в регистр 
		request_rd			: out std_logic;	--! 1 - запрос на чтение из регистра 
		allow_wr			: in  std_logic;	--! 1 - разрешение записи 
		pb_complete			: in  std_logic;	--! 1 - завершение обмена по шине PLD_BUS
		
		pf_repack_we		: in  std_logic;	-- 1 - запись в память
		pf_ram_rd_out		: out std_logic;	-- 1 - чтение из памяти
		
		---- Память ----	   
		ram_adra_a9			: out std_logic;	-- разряд 9 адреса памяти
		ram_adrb			: out std_logic_vector( 10 downto 0 )
	
	);
	
end ctrl_ram_cmd;


architecture ctrl_ram_cmd of ctrl_ram_cmd is				 

signal	pb_current_block: std_logic_vector( 1 downto 0 );
signal	flag_data		: std_logic_vector( 3 downto 0 );

signal	cb				: std_logic;

signal	pb_flag_set		: std_logic_vector( 3 downto 0 );
signal	pb_flag_clr		: std_logic_vector( 3 downto 0 );

signal	pf_flag_set		: std_logic_vector( 3 downto 0 );
signal	pf_flag_clr		: std_logic_vector( 3 downto 0 );

signal	pb_fclr			: std_logic;
signal	pb_fset			: std_logic;

signal	reg_write_E0_z	: std_logic;
signal	reg_write_E0_z1	: std_logic;

signal	pf_chn			: std_logic;
signal	pf0_act			: std_logic;
signal	pf0_rdy			: std_logic;
signal	pf1_act			: std_logic;
signal	pf1_rdy			: std_logic;

type stp_type is ( s0, s1, s2, s3 );
signal	stp		: stp_type;

signal	rst_p			: std_logic;		
signal	rst_p0			: std_logic;

signal	pf0_cb			: std_logic;
signal	pf0_dma_wr_rdy	: std_logic;
signal	pf0_dma_rd_rdy	: std_logic;

signal	pf1_cb			: std_logic;
signal	pf1_dma_wr_rdy	: std_logic;
signal	pf1_dma_rd_rdy	: std_logic;

signal	ram0_transfer_rdy	: std_logic;
signal	ram1_transfer_rdy	: std_logic;	

signal	port_a		: std_logic_vector( 17 downto 0 );
signal	port_b		: std_logic_vector( 17 downto 0 );
signal	port_c		: std_logic_vector( 47 downto 0 );
signal	port_p		: std_logic_vector( 47 downto 0 );
signal  opmode		: std_logic_vector( 6 downto 0 );
signal	carry		: std_logic;
signal	cnt_rstp	: std_logic;		 

signal	ch0_adr_hi		: std_logic_vector( 1 downto 0 );
signal	ch1_adr_hi		: std_logic_vector( 1 downto 0 );
signal	ch0_next_block	: std_logic;
signal	ch1_next_block	: std_logic;
signal	ch0_adr_hi_wr	: std_logic;
signal	ch1_adr_hi_wr	: std_logic;

signal	pf_ram_rd		: std_logic;		  
signal	pf_dma_wr_rdy	: std_logic;
signal	pf_dma_rd_rdy	: std_logic;

signal	pf_stop_rd		: std_logic;

signal	loc_adr_ch0_we	: std_logic;
signal	loc_adr_ch1_we	: std_logic;


begin

cb <= pb_current_block( conv_integer( dma_chn ) );	 
ram_adra_a9 <= cb;

reg_write_E0_z <= reg_write_E0 after 1 ns when rising_edge( clk );
reg_write_E0_z1 <= reg_write_E0_z after 1 ns when rising_edge( clk );

	
pb_flag_clr(0) <= reg_ch0_ctrl(4) or ( reg_write_E0_z and reg_ch0_ctrl(2) and not dma_chn and not pb_current_block(0) ) after 1 ns when rising_edge( clk );	
pb_flag_clr(1) <= reg_ch0_ctrl(4) or ( reg_write_E0_z and reg_ch0_ctrl(2) and not dma_chn and     pb_current_block(0) ) after 1 ns when rising_edge( clk );	
pb_flag_clr(2) <= reg_ch1_ctrl(4) or ( reg_write_E0_z and reg_ch1_ctrl(2) and     dma_chn and not pb_current_block(1) ) after 1 ns when rising_edge( clk );	
pb_flag_clr(3) <= reg_ch1_ctrl(4) or ( reg_write_E0_z and reg_ch1_ctrl(2) and     dma_chn and     pb_current_block(1) ) after 1 ns when rising_edge( clk );	

pb_flag_set(0) <= reg_write_E0_z and not reg_ch0_ctrl(2) and not dma_chn and not pb_current_block(0) after 1 ns when rising_edge( clk );	
pb_flag_set(1) <= reg_write_E0_z and not reg_ch0_ctrl(2) and not dma_chn and     pb_current_block(0) after 1 ns when rising_edge( clk );	
pb_flag_set(2) <= reg_write_E0_z and not reg_ch1_ctrl(2) and     dma_chn and not pb_current_block(1) after 1 ns when rising_edge( clk );	
pb_flag_set(3) <= reg_write_E0_z and not reg_ch1_ctrl(2) and     dma_chn and     pb_current_block(1) after 1 ns when rising_edge( clk );	


pr_current_block0: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( reg_ch0_ctrl(4)='1' ) then
			pb_current_block(0) <= '0' after  1 ns;
		elsif( reg_write_E0_z1='1' and dma_chn='0' ) then
			pb_current_block(0) <= not pb_current_block(0) after 1 ns;
		end if;
	end if;
end process;

pr_current_block1: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( reg_ch1_ctrl(4)='1' ) then
			pb_current_block(1) <= '0' after  1 ns;
		elsif( reg_write_E0_z1='1' and dma_chn='1' ) then
			pb_current_block(1) <= not pb_current_block(1) after 1 ns;
		end if;
	end if;
end process;

			

gen_flag: for ii in 0 to 3 generate

process( clk ) begin
	if( rising_edge( clk ) ) then
		if( pb_flag_clr(ii)='1' or pf_flag_clr(ii)='1' or rst_p='1' ) then
			flag_data(ii) <= '0' after  1 ns;
		elsif( pb_flag_set(ii)='1' or pf_flag_set(ii)='1' ) then
			flag_data(ii) <= '1' after 1 ns;
		end if;
	end if;
end process;
	
			
end generate;			


---- Формирование готовности блока к обмену ----
pr0_transfer_rdy: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( reg_ch0_ctrl(2)='1' and flag_data( conv_integer(pb_current_block(0)) )='1' ) then
			ram0_transfer_rdy <= reg_ch0_ctrl(0) and not reg_ch0_ctrl(3) after 1 ns;
		elsif( reg_ch0_ctrl(2)='0' and flag_data( conv_integer(pb_current_block(0)) )='0' ) then
			ram0_transfer_rdy <= reg_ch0_ctrl(0) and not reg_ch0_ctrl(3)  after 1 ns;
		else
			ram0_transfer_rdy <= '0' after 1 ns;
		end if;
	end if;
end process;

pr1_transfer_rdy: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( reg_ch1_ctrl(2)='1' and flag_data( 2+conv_integer(pb_current_block(1)) )='1' ) then
			ram1_transfer_rdy <= reg_ch1_ctrl(0)  and not reg_ch1_ctrl(3) after 1 ns;
		elsif( reg_ch1_ctrl(2)='0' and flag_data( 2+conv_integer(pb_current_block(1)) )='0' ) then
			ram1_transfer_rdy <= reg_ch1_ctrl(0)  and not reg_ch1_ctrl(3) after 1 ns;
		else
			ram1_transfer_rdy <= '0' after 1 ns;
		end if;
	end if;
end process;			 

dma0_transfer_rdy <= ram0_transfer_rdy;
dma1_transfer_rdy <= ram1_transfer_rdy;


--ram_transfer_rdy <= (ram0_transfer_rdy and not dma_chn) or (ram1_transfer_rdy and dma_chn) after 1 ns
--				     when rising_edge( clk );

---- Перебор каналов DMA ----

rst_p0 <= not reset after 1 ns when rising_edge( aclk );
rst_p  <= rst_p0  after 1 ns when rising_edge( aclk );

pr_state: process( aclk ) begin
	if( rising_edge( aclk ) ) then

		case( stp ) is
			when s0 =>		  			
				cnt_rstp <= '0' after 1 ns;
				pf_chn <= '0' after 1 ns;
				pf0_act <= '1' after  1 ns;
				pf1_act <= '0' after  1 ns;
				if( pf0_rdy='1' ) then
					stp <= s1 after 1 ns;  
				end if;
				
			when s1 =>
				cnt_rstp <= '1' after 1 ns;
				pf0_act <= '0' after  1 ns;
				if( pf0_rdy='0' ) then
					stp <= s2 after 1 ns;
				end if;
				
			when s2 =>		  
				cnt_rstp <= '0' after 1 ns;
				pf_chn <= '1' after 1 ns;
				pf1_act <= '1' after  1 ns;
				if( pf1_rdy='1' ) then
					stp <= s3 after 1 ns;
				end if;
				
			when s3 =>		  
				cnt_rstp <= '1' after 1 ns;
				pf1_act <= '0' after  1 ns;
				if( pf1_rdy='0' ) then
					stp <= s0 after 1 ns;
				end if;
				
		end case;
		
		if( rst_p='1' ) then
			stp <= s0 after 1 ns; 
			pf0_act <= '0' after 1 ns;			
			cnt_rstp <= '1' after 1 ns;		
			
		end if;
		
	end if;
end process;				



cmd0: ctrl_ram_cmd_pb 
	port map(
		---- Global ----
		reset			=> reset,			-- 0 - сброс
		clk				=> clk,				-- тактовая частота 250 МГц 
		aclk			=> aclk,			-- тактовая частота 266 МГц 
		
		act				=> pf0_act,			-- 1 - разрешение цикла обработки
		rdy				=> pf0_rdy,			-- 1 - завершение цикла обработки
		
		loc_adr_we		=> loc_adr_ch0_we,			-- 1 - запись локального адреса
		flag_data		=> flag_data( 1 downto 0 ),		-- 1 - наличие данных в блоке
		
		flag_set		=> pf_flag_set( 1 downto 0 ),	-- 1 - установка флага наличия данных
		flag_clr		=> pf_flag_clr( 1 downto 0 ),	-- 1 - сброс флага наличия данных
		next_block		=> ch0_next_block,	-- 1 - признак достижения блока 4 килобайта
		adr_hi_wr		=> ch0_adr_hi_wr,	-- 1 - увеличение старших разрядов адреса для блока
		
		reg_ctrl		=> reg_ch0_ctrl( 7 downto 0 ),	 -- регистр управления
		
		dmar			=> dmar0,	-- 1 - запрос DMA					  
		
		pf_cb			=> pf0_cb,			-- номер текущего блока для обмена с шиной
		pf_dma_wr_rdy	=> pf0_dma_wr_rdy,	-- 1 - готовность передать 128 слов
		pf_dma_rd_rdy	=> pf0_dma_rd_rdy,	-- 1 - готовность принять 128 слов
		
		pf_ram_rd		=> pf_ram_rd,		-- 1 - чтение данных из памяти
		pf_repack_we	=> pf_repack_we		-- 1 - запись в память
	);
	
cmd1: ctrl_ram_cmd_pb 
	port map(
		---- Global ----
		reset			=> reset,			-- 0 - сброс
		clk				=> clk,				-- тактовая частота 250 МГц 
		aclk			=> aclk,			-- тактовая частота 266 МГц 
		
		act				=> pf1_act,			-- 1 - разрешение цикла обработки
		rdy				=> pf1_rdy,			-- 1 - завершение цикла обработки
		
		loc_adr_we		=> loc_adr_ch1_we,			-- 1 - запись локального адреса
		flag_data		=> flag_data( 3 downto 2 ),		-- 1 - наличие данных в блоке
		
		flag_set		=> pf_flag_set( 3 downto 2 ),	-- 1 - установка флага наличия данных
		flag_clr		=> pf_flag_clr( 3 downto 2 ),	-- 1 - сброс флага наличия данных
		next_block		=> ch1_next_block,	-- 1 - признак достижения блока 4 килобайта
		adr_hi_wr		=> ch1_adr_hi_wr,	-- 1 - увеличение старших разрядов адреса для блока
		
		reg_ctrl		=> reg_ch1_ctrl( 7 downto 0 ),	 -- регистр управления
		
		dmar			=> dmar1,	-- 1 - запрос DMA					  
		
		pf_cb			=> pf1_cb,			-- номер текущего блока для обмена с шиной
		pf_dma_wr_rdy	=> pf1_dma_wr_rdy,	-- 1 - готовность передать 128 слов
		pf_dma_rd_rdy	=> pf1_dma_rd_rdy,	-- 1 - готовность принять 128 слов
		
		pf_ram_rd		=> pf_ram_rd,		-- 1 - чтение данных из памяти
		pf_repack_we	=> pf_repack_we		-- 1 - запись в память
	);
	
pf_dma_wr_rdy <= pf0_dma_wr_rdy or pf1_dma_wr_rdy;
pf_dma_rd_rdy <= pf0_dma_rd_rdy or pf1_dma_rd_rdy;

request_wr <= pf_dma_wr_rdy;
request_rd <= pf_dma_rd_rdy;

ram_adrb(10) <= pf_chn;
ram_adrb(9) <= pf0_cb when pf_chn='0' else pf1_cb;		

--ram_adrb( 8 downto 7 ) <= ch0_adr_hi when pf_chn='0' else ch1_adr_hi;	
--	
--ram_adrb( 6 downto 0 ) <= port_p( 6 downto 0 ) after 1 ns;

ram_adrb( 8 downto 0 ) <= port_p( 8 downto 0 ) after 1 ns;
	
opmode <= "0100000";
carry <= pf_repack_we or pf_ram_rd;

pr_pf_ram_rd: process( aclk ) begin
	if( rising_edge( aclk ) ) then
		if( cnt_rstp='1' or port_p( 8 downto 0 )="111111111" ) or pf_stop_rd='1' or allow_wr='0' then
			pf_ram_rd <= '0' after 1 ns;
		elsif( 	pf_dma_wr_rdy='1' and allow_wr='1' ) then
			pf_ram_rd <= '1' after 1 ns;
		end if;
	end if;
end process;		

pr_stop_rd: process( aclk ) begin
	if( rising_edge( aclk ) ) then
		if( cnt_rstp='1' ) then
			pf_stop_rd <= '0' after 1 ns;
		elsif( port_p( 8 downto 0 )="111111111" ) then
			pf_stop_rd <= '1' after 1 ns;
		end if;
	end if;
end process;

--pf_ram_rd_out <= pf_ram_rd;
pf_ram_rd_out <= pf_ram_rd and allow_wr;
			

port_b <= x"0000" & "00";
port_a <= x"0000" & "00";		  

port_c <= port_p;


gen_dsp48: if( is_dsp48=1 ) generate
	
dsp: DSP48 
  generic map(

        AREG            => 1,
        B_INPUT         => "DIRECT",
        BREG            => 1,
        CARRYINREG      => 0,
        CARRYINSELREG   => 1,
        CREG            => 1,
        LEGACY_MODE     => "NONE",
        MREG            => 1,
        OPMODEREG       => 1,
        PREG            => 1,
        SUBTRACTREG     => 0
        )

  port map(
        --BCOUT                   : out std_logic_vector(17 downto 0);
        P                       => port_p,
        --PCOUT                   : out std_logic_vector(47 downto 0);

        A                       => port_a,
        B                       => port_b,
        BCIN                    => (others=>'0'),
        C                       => port_c,
        CARRYIN                 => carry,
        CARRYINSEL              => "00",
        CEA                     => '1',
        CEB                     => '1',
        CEC                     => '1',
        CECARRYIN               => '1',
        CECINSUB                => '1',
        CECTRL                  => '1',
        CEM                     => '1',
        CEP                     => '1',
        CLK                     => aclk,
        OPMODE                  => opmode,
        PCIN                    => (others=>'0'),
        RSTA                    => '0',
        RSTB                    => '0',
        RSTC                    => '0',
        RSTCARRYIN              => '0',
        RSTCTRL                 => '0',
        RSTM                    => '0',
        RSTP                    => cnt_rstp,
        SUBTRACT                => '0'
      );
  
end generate;

gen_ndsp48: if( is_dsp48=0 ) generate
	
port_p( 47 downto 9 ) <= (others=>'0');

pr_dsp: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( cnt_rstp='1' ) then
			port_p( 8 downto 0 ) <= (others=>'0' ) after  1 ns;
		elsif( carry='1' ) then
			port_p( 8 downto 0 ) <= port_p( 8 downto 0 ) + 1 after  1 ns;
		end if;
	end if;
end process;
	
end generate;	


pr_ch0_adr_hi: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( reset='0' or reg_ch0_ctrl(4)='1' ) then
			ch0_adr_hi <= "00" after 1 ns;
		elsif( ch0_adr_hi_wr='1' ) then
			ch0_adr_hi <= ch0_adr_hi + 1 after  1 ns;
		end if;
	end if;
end process;

pr_ch1_adr_hi: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( reset='0' or reg_ch1_ctrl(4)='1' ) then
			ch1_adr_hi <= "00" after 1 ns;
		elsif( ch1_adr_hi_wr='1' ) then
			ch1_adr_hi <= ch1_adr_hi + 1 after  1 ns;
		end if;
	end if;
end process;

--ch0_next_block <= ch0_adr_hi(0) and  ch0_adr_hi(1);
--ch1_next_block <= ch1_adr_hi(0) and  ch1_adr_hi(1);

--ch0_next_block <= '1';
--ch1_next_block <= '1';
			
ch0_next_block <= pb_complete and pf0_act;
ch1_next_block <= pb_complete and pf1_act;

loc_adr_ch0_we <= loc_adr_we and not dma_chn;
loc_adr_ch1_we <= loc_adr_we and dma_chn;


end ctrl_ram_cmd;
