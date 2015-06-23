-------------------------------------------------------------------------------
--
-- Title       : core64_rx_engine
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.0
--
-------------------------------------------------------------------------------
--
-- Description : Обработчик входящих пакетов 
--
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

use work.core64_type_pkg.all;

package core64_rx_engine_pkg is

component core64_rx_engine is	 
	port(
	
		--- General ---
		rstp			: in std_logic;		--! 1 - сброс 
		clk				: in std_logic;		--! тактовая частота ядра - 250 MHz 
		
		trn_rx			: in  type_trn_rx;			--! приём пакета
		trn_rx_back		: out type_trn_rx_back;		--! готовность к приёму пакета

		reg_access		: out type_reg_access;		--! запрос на доступ к регистрам 
		
		rx_tx_engine	: out type_rx_tx_engine;	--! обмен RX->TX 
		tx_rx_engine	: in  type_tx_rx_engine;	--! обмен TX->RX 
		
		rx_ext_fifo		: out type_rx_ext_fifo		--! обмен RX->EXT_FIFO 
		
		
		
	);
end component;

end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.core64_type_pkg.all;

entity core64_rx_engine is	 
	port(
	
		--- General ---
		rstp			: in std_logic;		--! 1 - сброс 
		clk				: in std_logic;		--! тактовая частота ядра - 250 MHz 
		
		trn_rx			: in  type_trn_rx;			--! приём пакета
		trn_rx_back		: out type_trn_rx_back;		--! готовность к приёму пакета

		reg_access		: out type_reg_access;		--! запрос на доступ к регистрам 
		
		rx_tx_engine	: out type_rx_tx_engine;	--! обмен RX->TX 
		tx_rx_engine	: in  type_tx_rx_engine;	--! обмен TX->RX 
		
		rx_ext_fifo		: out type_rx_ext_fifo		--! обмен RX->EXT_FIFO 
		
		
		
	);
end core64_rx_engine;


architecture core64_rx_engine of core64_rx_engine is

component ctrl_fifo64x70st is
  port (
    clk 		: in std_logic;
    rst 		: in std_logic;
    din 		: in std_logic_vector(69 downto 0);
    wr_en 		: in std_logic;
    rd_en 		: in std_logic;
    dout 		: out std_logic_vector(69 downto 0);
    full 		: out std_logic;
    empty 		: out std_logic;
    valid 		: out std_logic;
    prog_full 	: out std_logic;
    prog_empty 	: out std_logic
  );
end component;


signal	rstpz			: std_logic;

type	stp_type		is ( s0, s1, s2, s3, s31, s32, s4, s5 );
signal	stp				: stp_type;

type	stf_type		is ( s0, s1, s2, s3, s4, s5, s6 );
signal	stf				: stf_type;

signal  trn_rdst_rdy_n 			: std_logic;
signal  trn_rnp_ok_n 			: std_logic;
signal  trn_rcpl_streaming_n    : std_logic;

signal	tlp_dw0					: std_logic_vector( 31 downto 0 );
signal	tlp_dw1					: std_logic_vector( 31 downto 0 );
signal	tlp_dw2					: std_logic_vector( 31 downto 0 );
signal	tlp_dw3					: std_logic_vector( 31 downto 0 );

signal	trn_data				: std_logic_vector( 63 downto 0 );
signal	trn_data_we				: std_logic;

signal	tlp_cnt					: std_logic_vector( 5 downto 0 );

signal	request_reg_wr			: std_logic;		  
signal	request_reg_rd			: std_logic;
signal	tlp_complete			: std_logic;	
signal	bar						: std_logic_vector( 1 downto 0 );

signal	fifo_wr					: std_logic;
signal	fifo_wr_z				: std_logic;
signal	fifo_din				: std_logic_vector( 69 downto 0 );

signal	fifo0_wr				: std_logic;
signal	fifo0_wr_en				: std_logic;
signal	fifo0_wr_en_z			: std_logic;
signal	fifo0_rd				: std_logic;
signal	fifo0_full				: std_logic;
signal	fifo0_empty				: std_logic;
signal	fifo0_valid				: std_logic;
signal	fifo0_paf				: std_logic;
signal	fifo0_pae				: std_logic;
signal	fifo0_dout				: std_logic_vector( 69 downto 0 );

signal	fifo1_wr				: std_logic;
signal	fifo1_wr_en				: std_logic;
signal	fifo1_wr_en_z			: std_logic;
signal	fifo1_rd				: std_logic;
signal	fifo1_rd_x				: std_logic;
signal	fifo1_full				: std_logic;
signal	fifo1_empty				: std_logic;
signal	fifo1_valid				: std_logic;
signal	fifo1_paf				: std_logic;
signal	fifo1_pae				: std_logic;
signal	fifo1_dout				: std_logic_vector( 69 downto 0 );

signal	data_rx					: std_logic_vector( 63 downto 0 );
signal	data_rx_we				: std_logic;
signal	data_rx_we_en			: std_logic;
signal	data_lrx				: std_logic_vector( 31 downto 0 );
signal	data_hrx				: std_logic_vector( 31 downto 0 );

signal	tlp_cp_dw0				: std_logic_vector( 31 downto 0 );
signal	tlp_cp_dw1				: std_logic_vector( 31 downto 0 );
signal	tlp_cp_dw2				: std_logic_vector( 31 downto 0 );
signal	tlp_cp_dw3				: std_logic_vector( 31 downto 0 );

signal	adr_rx					: std_logic_vector( 8 downto 0 );
signal	adr_cnt					: std_logic_vector( 3 downto 0 );	

signal	byte_count				: std_logic_vector( 2 downto 0 );

begin
	
rstpz <= rstp after 1 ns when rising_edge( clk );	

trn_rx_back.trn_rdst_rdy_n 			  <= trn_rdst_rdy_n;
trn_rx_back.trn_rnp_ok_n 			  <= trn_rnp_ok_n; 			
trn_rx_back.trn_rcpl_streaming_n      <= trn_rcpl_streaming_n;    

trn_rnp_ok_n <= '0';
trn_rcpl_streaming_n <= '0';

trn_rdst_rdy_n <= fifo0_paf or fifo1_paf;

fifo_wr <= not ( trn_rx.trn_rsrc_rdy_n or trn_rdst_rdy_n );
fifo_wr_z <= fifo_wr after 1 ns when rising_edge( clk );

fifo_din  <= not trn_rx.trn_rbar_hit_n(1) & not trn_rx.trn_rbar_hit_n(0) & 
				  trn_rx.trn_rerrfwd_n & trn_rx.trn_rrem_n(0) & trn_rx.trn_reof_n & trn_rx.trn_rsof_n & 
				  trn_rx.trn_rd after 1 ns when rising_edge( clk );

pr_fifo0_wr: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( rstpz='1' or (fifo_wr='1' and trn_rx.trn_reof_n='0' ) ) then
			fifo0_wr_en <= '0' after 1 ns;
		elsif( fifo_wr='1' and  trn_rx.trn_rd(63)='0' and trn_rx.trn_rd(61 downto 57)="00000" and trn_rx.trn_rsof_n='0' ) then
			fifo0_wr_en <= '1' after 1 ns;
		end if;
	end if;
end process;

fifo0_wr_en_z <= fifo0_wr_en after 1 ns when rising_edge( clk );

fifo0_wr <= fifo_wr_z and (fifo0_wr_en or fifo0_wr_en_z);

fifo0_reg: ctrl_fifo64x70st 
  port map(
    clk 		=> clk,
    rst 		=> rstpz,
    din 		=> fifo_din, 
    wr_en 		=> fifo0_wr,
    rd_en 		=> fifo0_rd,
    dout 		=> fifo0_dout, 
    full 		=> fifo0_full,
    empty 		=> fifo0_empty,
    valid 		=> fifo0_valid,
    prog_full 	=> fifo0_paf,
    prog_empty 	=> fifo0_pae
  );
  
  
pr_fifo1_wr: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( rstpz='1' or (fifo_wr='1' and trn_rx.trn_reof_n='0' ) ) then
			fifo1_wr_en <= '0' after 1 ns;
		elsif( fifo_wr='1' and  trn_rx.trn_rd(63 downto 57)="0100101" and trn_rx.trn_rsof_n='0' ) then
			fifo1_wr_en <= '1' after 1 ns;
		end if;
	end if;
end process;

fifo1_wr_en_z <= fifo1_wr_en after 1 ns when rising_edge( clk );

fifo1_wr <= fifo_wr_z and (fifo1_wr_en or fifo1_wr_en_z);

fifo1_cmpl: ctrl_fifo64x70st 
  port map(
    clk 		=> clk,
    rst 		=> rstpz,
    din 		=> fifo_din, 
    wr_en 		=> fifo1_wr,
    rd_en 		=> fifo1_rd_x,
    dout 		=> fifo1_dout, 
    full 		=> fifo1_full,
    empty 		=> fifo1_empty,
    valid 		=> fifo1_valid,
    prog_full 	=> fifo1_paf,
    prog_empty 	=> fifo1_pae
  );
  


fifo1_rd_x <= fifo1_rd and ( not ( data_rx_we_en  and not fifo1_dout(65) ) );

reg_access.adr <= tlp_dw2;

reg_access.data( 7 downto 0 )   <= tlp_dw3( 31 downto 24 );
reg_access.data( 15 downto 8 )  <= tlp_dw3( 23 downto 16 );
reg_access.data( 23 downto 16 ) <= tlp_dw3( 15 downto 8 );
reg_access.data( 31 downto 24 ) <= tlp_dw3( 7 downto 0 );

reg_access.req_wr(0) <=request_reg_wr and bar(0);
reg_access.req_wr(1) <=request_reg_wr and bar(1);
reg_access.req_rd(0) <=request_reg_rd and ( bar(0) or ( not (bar(0) or bar(1)) ) );
reg_access.req_rd(1) <=request_reg_rd and bar(1);

bar(0) <= fifo0_dout(68);
bar(1) <= fifo0_dout(69);

rx_tx_engine.request_reg_wr <= request_reg_wr;
rx_tx_engine.request_reg_rd <= request_reg_rd;
rx_tx_engine.request_tag <= tlp_dw1( 15 downto 8 );
rx_tx_engine.request_tc  <= tlp_dw0( 22 downto 20 );
rx_tx_engine.request_attr <= tlp_dw0( 7 downto 4 );
rx_tx_engine.request_id <= tlp_dw1( 31 downto 16 );
rx_tx_engine.lower_adr <= tlp_dw2( 6 downto 2 );   
rx_tx_engine.byte_count <= byte_count after 1 ns when rising_edge( clk );

byte_count <= "000" when request_reg_rd='0' else
			  "100" when tlp_dw1( 3 downto 0 )="1111" else
			  "010" when tlp_dw1( 3 downto 0 )="0011" or tlp_dw1( 3 downto 0 )="0110" or tlp_dw1( 3 downto 0 )="1100" else
			  "001";-- when tlp_dw1( 3 downto 0 )="0001" or tlp_dw1( 3 downto 0 )="0010" or tlp_dw1( 3 downto 0 )="0100" or tlp_dw1( 3 downto 0 )="1000" 
				  

pr_stp: process( clk ) begin
	if( rising_edge( clk ) ) then
		
		case( stp ) is
			when s0 =>
				if( fifo0_empty='0' ) then
					stp <= s1 after 1 ns;
				end if;				
				request_reg_wr <= '0' after 1 ns;
				request_reg_rd <= '0' after 1 ns;
				fifo0_rd <= '0' after 1 ns;
				
			when s1 => 
					stp <= s2 after 1 ns;
					fifo0_rd <= '1' after 1 ns;
					
			when s2 =>	
					stp <= s3 after 1 ns;
					fifo0_rd <= '0' after 1 ns;
			
			when s3 =>					  
					tlp_dw0 <= fifo0_dout( 63 downto 32 ) after 1 ns;
					tlp_dw1 <= fifo0_dout( 31 downto 0 ) after 1 ns; 
					if( fifo0_empty='0' ) then
						stp <= s31 after 1 ns;
					end if;
					
			when s31 =>
					fifo0_rd <= '1' after 1 ns;
					stp <= s32 after 1 ns;	  
					
			when s32 =>
					fifo0_rd <= '0' after 1 ns;
					stp <= s4 after 1 ns;	  
					
			when s4 => 
					tlp_dw2 <= fifo0_dout( 63 downto 32 ) after 1 ns;
					tlp_dw3 <= fifo0_dout( 31 downto 0 ) after 1 ns; 
					
					if( tlp_dw0(30)='1' ) then
						request_reg_wr <= '1' after 1 ns;
					else
						request_reg_rd <= '1' after 1 ns;
					end if;
					stp <= s5 after 1 ns;
					
			when s5 =>
					if( tx_rx_engine.complete_reg='1' ) then
						stp <= s0 after 1 ns;
					end if;
			
		end case;
		
		
		
		if( rstpz='1' ) then
			stp <= s0 after 1 ns;
		end if;
		
	end if;
end process;


pr_stf: process( clk ) begin

	if( rising_edge( clk ) ) then

		case( stf ) is
			
			when s0 => 
			--if( fifo1_empty='0' ) then
				if( fifo1_pae='0' ) then
					stf <= s1 after 1 ns;
				end if;
				fifo1_rd <= '0' after 1 ns;		
				data_rx_we_en	<= '0' after 1 ns;
				
			when s1 =>
				fifo1_rd <= '1' after 1 ns;
				stf <= s2 after 1 ns;
				
			when s2 => 
				stf <= s3 after 1 ns;
				
			when s3 =>					  
					tlp_cp_dw0   <= fifo1_dout( 63 downto 32 ) after 1 ns;
					tlp_cp_dw1 <= fifo1_dout( 31 downto 0 ) after 1 ns; 
					fifo1_rd <= '0' after 1 ns;
					stf <= s4 after 1 ns;	  
					
			when s4 =>					
					tlp_cp_dw2 <= fifo1_dout( 63 downto 32 ) after 1 ns;
					tlp_cp_dw3 <= fifo1_dout( 31 downto 0 ) after 1 ns; 
					if( tlp_cp_dw0( 30 )='1' ) then
						stf <= s5 after 1 ns;	-- есть данные --
					else
						stf <= s6 after 1 ns;	-- нет данных --
					end if;
						
					
			when s5 =>
			
					if( fifo1_dout(65)='0' and fifo1_valid='1' ) then
						stf <= s6 after 1 ns;  
						fifo1_rd <= '0' after 1 ns;		  
						data_rx_we_en	<= '0' after 1 ns;
					else
						fifo1_rd <= '1' after 1 ns;
						data_rx_we_en	<= '1' after 1 ns;
					end if;
					
			when s6 => 
					stf <= s0 after 1 ns;
					
					

		end case;
		
		if( rstpz='1' ) then
			stf <= s0 after 1 ns;
		end if;
		
	end if;
	
	
end process;

data_rx_we <= fifo1_valid and data_rx_we_en;

data_lrx <= fifo1_dout( 31 downto 0 ) after 1 ns when rising_edge( clk ) and fifo1_valid='1';
data_hrx <= fifo1_dout( 63 downto 32 );

data_rx( 32+31 downto 32+24 )  <= data_hrx( 7 downto 0 ); 
data_rx( 32+23 downto 32+16 )  <= data_hrx( 15 downto 8 ); 
data_rx( 32+15 downto 32+8 )   <= data_hrx( 23 downto 16 ); 
data_rx( 32+7 downto 32+0 )    <= data_hrx( 31 downto 24 ); 


data_rx( 31 downto 24 )  <= data_lrx( 7 downto 0 ); 
data_rx( 23 downto 16 )  <= data_lrx( 15 downto 8 ); 
data_rx( 15 downto 8 )   <= data_lrx( 23 downto 16 ); 
data_rx( 7 downto 0 )    <= data_lrx( 31 downto 24 ); 

pr_adr_cnt: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( stf/=s5 ) then
			adr_cnt <= "0000" after 1 ns;
		elsif( data_rx_we='1' ) then
			adr_cnt( 2 downto 0 ) <= adr_cnt( 2 downto 0 ) + 1 after 1 ns;
			if( adr_cnt( 2 downto 0 )="111" ) then
				adr_cnt( 3 ) <= '1' after 1 ns;
			end if;
		end if;
	end if;
end process;	

adr_rx( 2 downto 0 ) <= adr_cnt( 2 downto 0 );
adr_rx( 3 ) <=  tlp_cp_dw2(6) or adr_cnt( 3 );
adr_rx( 8 downto 4 ) <= tlp_cp_dw2( 12 downto 8 );

rx_ext_fifo.adr <= adr_rx after 1 ns when rising_edge( clk );
rx_ext_fifo.data <= data_rx after 1 ns when rising_edge( clk );
rx_ext_fifo.data_we <= data_rx_we after 1 ns when rising_edge( clk );

rx_tx_engine.complete_we <= data_rx_we after 1 ns when rising_edge( clk );

end core64_rx_engine;
