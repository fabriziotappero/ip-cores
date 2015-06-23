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
--
--  Version 1.1 (25.10.2011) Kuzmi4
--      Description: add couple of simple tests for test WB stuff, let "test_num_1" unchanged.
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
use work.wb_block_pkg.all;

package test_pkg is
	
--! Initialising
procedure test_init(
		fname: in string 	--! file name for report
	);
	
--! Finished
procedure test_close;						
	

--! Read registers
procedure test_read_reg (
		signal  cmd:	out bh_cmd; --! command
		signal  ret:	in  bh_ret  --! answer
		);
	
--! Start DMA with incorrect descriptor
procedure test_dsc_incorrect (
		signal  cmd:	out bh_cmd; --! command
		signal  ret:	in  bh_ret  --! answer
		);

--! Start DMA for one block 4 kB
procedure test_read_4kb (
		signal  cmd:	out bh_cmd; --! command
		signal  ret:	in  bh_ret  --! answer
		);

				
--! Read block_test_check 8 kB
procedure test_adm_read_8kb (
		signal  cmd:	out bh_cmd; --! command
		signal  ret:	in  bh_ret  --! answer
		);

----! Проверка обращений к блоку MAIN 
--procedure test_block_main (
--		signal  cmd:	out bh_cmd; --! command
--		signal  ret:	in  bh_ret  --! answer
--		);
--		
----! Чтение 16 кБ с использованием двух блоков дескрипторов
--procedure test_adm_read_16kb (
--		signal  cmd:	out bh_cmd; --! command
--		signal  ret:	in  bh_ret  --! answer
--		);
--		
--! Запись 16 кБ с использованием двух блоков дескрипторов
procedure test_adm_write_16kb (
		signal  cmd:	out bh_cmd; --! command
		signal  ret:	in  bh_ret  --! answer
		);		
---------------------------------------------------------------------------------------------------
--
-- 
--
procedure test_num_1(
                            signal  cmd:    out bh_cmd; --! command
                            signal  ret:    in  bh_ret  --! answer
                    );
procedure test_num_2(
                            signal  cmd:    out bh_cmd; --! command
                            signal  ret:    in  bh_ret  --! answer
                    );
-- ==> TEST_CHECK.WB_CFG_SLAVE
procedure test_wb_1(
                            signal  cmd:    out bh_cmd; --! command
                            signal  ret:    in  bh_ret  --! answer
                    );
-- ==> TEST_GEN.WB_CFG_SLAVE
procedure test_wb_2(
                            signal  cmd:    out bh_cmd; --! command
                            signal  ret:    in  bh_ret  --! answer
                    );
end package	test_pkg;
---------------------------------------------------------------------------------------------------
package body test_pkg is
	
	FILE   log: text;
	
	shared variable cnt_ok, cnt_error: integer;
	
	-- Initialising
	procedure test_init(
		fname: in string 					
		) is
	begin
		
		file_open( log, fname, WRITE_MODE );
		cnt_ok:=0;
		cnt_error:=0;
		
	end test_init;	
	
	--! Finished
	procedure test_close is		
		variable str : LINE;		-- pointer to string
	begin					  	
		
		std.textio.write( str, string'(" " ));
		writeline( log, str );		
		writeline( log, str );		
		
		write( str, string'("check completed" ));
		writeline( log, str );		
		write( str, string'("the number of successful tests:  " ));
		write( str, cnt_ok );
		writeline( log, str );		
		write( str, string'("the number of false test: " ));
		write( str, cnt_error );
		writeline( log, str );		
		
		
		file_close( log ); 
		
		if( cnt_ok>0 and cnt_error=0 ) then
			write( str, string'("TEST finished successfully") );
			writeline( output, str );		
		else
			write( str, string'("TEST finished with ERR") );
			writeline( output, str );		
			
		end if;
		
	end test_close;	
	
	
--! Read registers
procedure test_read_reg (
		signal  cmd:	out bh_cmd; --! command
		signal  ret:	in  bh_ret  --! answer
		)
is

variable	adr		: std_logic_vector( 31 downto 0 );
variable	data1	: std_logic_vector( 31 downto 0 );
variable	data2	: std_logic_vector( 31 downto 0 );
variable	str		: line;	  
variable	error	: integer:=0;
begin
		
	write( str, string'("TEST_READ_REG" ));
	writeline( log, str );		   
	
	block_write( cmd, ret, 0, 8, x"0000000F" );		-- BRD_MODE, reset off 
	wait for 100 ns;
	
	
	--block_read( cmd, ret, 4, 23, x"0000A400" );	-- LOCAL_ADR 
	wb_block_gen_read( cmd, ret, 	REG_BLOCK_ID, data1 ); -- read block id
	wb_block_check_read( cmd, ret, 	REG_BLOCK_ID, data2 ); -- read block id
	
	write( str, string'("BLOCK 0 ID: " )); hwrite( str, data1( 15 downto 0 ) );
	writeline( log, str );	
	
	write( str, string'("BLOCK 1 ID: " )); hwrite( str, data2( 15 downto 0 ) );
	writeline( log, str );	
	
--	wb_read( cmd, ret, 16#1000#, data1 );
--	
--	wb_read( cmd, ret, 16#3000#, data1 );
--
--	write( str, string'("0x1000: " )); hwrite( str, data1( 15 downto 0 ) );
--	writeline( log, str );	
--	
--	write( str, string'("0x3000: " )); hwrite( str, data2( 15 downto 0 ) );
--	writeline( log, str );	
	
	block_write( cmd, ret, 0, 8, x"00000000" );		-- BRD_MODE 
	wait for 100 ns;
	block_write( cmd, ret, 0, 8, x"0000000F" );		-- BRD_MODE 
	wait for 100 ns;

	wb_block_gen_read( cmd, ret, 	REG_BLOCK_ID, data1 ); -- read block id
	wb_block_check_read( cmd, ret, 	REG_BLOCK_ID, data2 ); -- read block id
	
	write( str, string'("BLOCK 0 ID: " )); hwrite( str, data1( 15 downto 0 ) );
	
	if( data1( 15 downto 0 )=x"001B" ) then
		write( str, string'(" - Ok" ));	
	else
		write( str, string'(" - Error" ));
		error := error + 1;
	end if;
	
	writeline( log, str );	
	
	write( str, string'("BLOCK 1 ID: " )); hwrite( str, data2( 15 downto 0 ) );

	if( data2( 15 downto 0 )=x"001A" ) then
		write( str, string'(" - Ok" ));	
	else
		write( str, string'(" - Error" ));
		error := error + 1;
	end if;
	writeline( log, str );	
	
	if( error=0 ) then
		write( str, string'("Test read_reg - Ok" ));	
		cnt_ok := cnt_ok + 1;
	else
		write( str, string'("Test read_reg - Error" ));
		cnt_error := cnt_error + 1;
	end if;		  
	
end test_read_reg;
	
		
		
	
	
--! Start DMA with incorrect descriptor
procedure test_dsc_incorrect (
		signal  cmd:	out bh_cmd; --! command
		signal  ret:	in  bh_ret  --! answer
		) 
is

variable	adr		: std_logic_vector( 31 downto 0 );
variable	data	: std_logic_vector( 31 downto 0 );
variable	str		: line;
begin
		
	write( str, string'("TEST_DSC_INCORRECT" ));
	writeline( log, str );	
	
	block_write( cmd, ret, 0, 8, x"0000000F" );		-- BRD_MODE, reset off 
	wait for 100 ns;
	
	---- Init block of descriptor ---
	for ii in 0 to 127 loop
		adr:= x"00100000";
		adr:=adr + ii*4;
		int_mem_write( cmd, ret, adr,  x"00000000" );
	end loop;										 
	
	int_mem_write( cmd, ret, x"00100000",  x"03020100" );
	int_mem_write( cmd, ret, x"001001FC",  x"FF00AA00" );
	
	---- DMA program ----
	block_write( cmd, ret, 4, 8, x"00000027" );		-- DMA_MODE 
	block_write( cmd, ret, 4, 9, x"00000010" );		-- DMA_CTRL - RESET FIFO 
	
	block_write( cmd, ret, 4, 20, x"00100000" );	-- PCI_ADRL 
	block_write( cmd, ret, 4, 21, x"00100000" );	-- PCI_ADRH  
	block_write( cmd, ret, 4, 23, x"0000A400" );	-- LOCAL_ADR 
	
	block_write( cmd, ret, 4, 9, x"00000001" );		-- DMA_CTRL - START 
	
	wait for 20 us;
	
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
	

--! Start DMA for one block 4 kB
procedure test_read_4kb (
		signal  cmd:	out bh_cmd; --! command
		signal  ret:	in  bh_ret  --! answer
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
	
	block_write( cmd, ret, 0, 8, x"0000000F" );		-- BRD_MODE, reset off 
	wait for 100 ns;
	
	
	---- Init block of descriptor ---
	for ii in 0 to 127 loop
		adr:= x"00100000";
		adr:=adr + ii*4;
		int_mem_write( cmd, ret, adr,  x"00000000" );
	end loop;										 
	
	int_mem_write( cmd, ret, x"00100000",  x"00008000" );
	int_mem_write( cmd, ret, x"00100004",  x"00000100" );

	
	int_mem_write( cmd, ret, x"001001F8",  x"00000000" );
	int_mem_write( cmd, ret, x"001001FC",  x"762C4953" );
	
	--wb_block_gen_write( cmd, ret, REG_TEST_GEN_CTRL, x"00000001" ); -- reset
	wb_block_gen_write( cmd, ret, REG_TEST_GEN_CTRL, x"00000000" ); 
	wb_block_gen_read( cmd, ret, REG_BLOCK_ID, data ); -- read block id
	write( str, string'("BLOCK TEST_GEN  ID: " ));
	hwrite( str, data );
	writeline( log, str );	
	
	wb_block_gen_write( cmd, ret, REG_TEST_GEN_SIZE, x"00000001" ); -- size of block = 4 kByte
	

	---- DMA program ----
	block_write( cmd, ret, 4, 8, x"00000025" );		-- DMA_MODE - without request
	block_write( cmd, ret, 4, 9, x"00000010" );		-- DMA_CTRL - RESET FIFO 
	
	block_write( cmd, ret, 4, 20, x"00100000" );	-- PCI_ADRL 
	block_write( cmd, ret, 4, 21, x"00100000" );	-- PCI_ADRH  
	block_write( cmd, ret, 4, 23, TEST_GEN_WB_BURST_SLAVE );	-- LOCAL_ADR 

	wb_block_gen_write( cmd, ret, REG_TEST_GEN_CTRL, x"000006A0" ); -- start test sequence

	wait for 1 us;
	
	block_write( cmd, ret, 4, 9, x"00000001" );		-- DMA_CTRL - START 
	
	
	--wb_block_gen_write( cmd, ret, REG_TEST_GEN_CTRL, x"000006A2" );
	
	wait for 20 us;
	
	block_read( cmd, ret, 4, 16, data );			-- STATUS 
	
	write( str, string'("STATUS: " )); hwrite( str, data( 15 downto 0 ) );
	if( data( 8 )='1' ) then
		write( str, string'(" - descriptor is correct" ));	
	else
		write( str, string'(" - descriptor is incorrect" ));
		error := error + 1;
	end if;
	
	writeline( log, str );	
	
	if( error=0 ) then
		
		---- Wait for DMA finished ----
		dma_complete := 0;
		for ii in 0 to 100 loop
			
		block_read( cmd, ret, 4, 16, data );			-- STATUS 
		write( str, string'("STATUS: " )); hwrite( str, data( 15 downto 0 ) );
			if( data(5)='1' ) then
				write( str, string'(" - DMA finished " ));
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
			write( str, string'("Error - DMA not finished" ));
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
	
	write( str, string'(" Read: " ));
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
		write( str, string'("Test is correct" ));
		cnt_ok := cnt_ok + 1;
	else
		write( str, string'("Test have ERRORS" ));
		cnt_error := cnt_error + 1;
	end if;
	writeline( log, str );	
	writeline( log, str );		

end test_read_4kb;


--! Read block_test_check 8 kB
procedure test_adm_read_8kb (
		signal  cmd:	out bh_cmd; --! command
		signal  ret:	in  bh_ret  --! answer
		)
is

variable	adr				: std_logic_vector( 31 downto 0 );
variable	data			: std_logic_vector( 31 downto 0 );
variable	str				: line;			   

variable	error			: integer:=0;
variable	dma_complete	: integer;	   	

variable	status			: std_logic_vector( 31 downto 0 );
variable	reg_block_wr	: std_logic_vector( 31 downto 0 );

begin
		
	write( str, string'("TEST_ADM_READ_8KB" ));
	writeline( log, str );	
	
	block_write( cmd, ret, 0, 8, x"0000000F" );		-- BRD_MODE, reset off 
	wait for 100 ns;
	
	---- Init block of descriptor ---
	for ii in 0 to 127 loop
		adr:= x"00100000";
		adr:=adr + ii*4;
		int_mem_write( cmd, ret, adr,  x"00000000" );
	end loop;										 
	
	--- Desctriptor 0 ---
	int_mem_write( cmd, ret, x"00100000",  x"00008000" ); 
	int_mem_write( cmd, ret, x"00100004",  x"00000111" );  	-- jump to next descriptor

	--- Desctriptor 1 ---
	int_mem_write( cmd, ret, x"00100008",  x"00008010" ); 
	int_mem_write( cmd, ret, x"0010000C",  x"00000110" );  	-- stop
	
	
	int_mem_write( cmd, ret, x"001001F8",  x"00000000" );
	int_mem_write( cmd, ret, x"001001FC",  x"D6644953" ); 
	
	
	---- Программирование канала DMA ----
	block_write( cmd, ret, 5, 8, x"00000027" );		-- DMA_MODE 
	block_write( cmd, ret, 5, 9, x"00000010" );		-- DMA_CTRL - RESET FIFO 
	
	block_write( cmd, ret, 5, 20, x"00100000" );	-- PCI_ADRL 
	block_write( cmd, ret, 5, 21, x"00100000" );	-- PCI_ADRH  
	block_write( cmd, ret, 5, 23, TEST_GEN_WB_BURST_SLAVE );	-- LOCAL_ADR 
	
	
	wb_block_gen_write( cmd, ret, REG_TEST_GEN_CTRL, x"00000001" ); -- reset
	wb_block_gen_write( cmd, ret, REG_TEST_GEN_CTRL, x"00000000" ); 
	wb_block_gen_read( cmd, ret, REG_BLOCK_ID, data ); -- read block id
	write( str, string'("BLOCK TEST_GEN  ID: " ));
	hwrite( str, data );
	writeline( log, str );	
	
	wb_block_gen_write( cmd, ret, REG_TEST_GEN_SIZE, x"00000001" ); -- size of block = 4 kByte

	block_write( cmd, ret, 5, 9, x"00000001" );		-- DMA_CTRL - START 
	
	wb_block_gen_read( cmd, ret, REG_TEST_GEN_STATUS, status ); 		-- read status
	write( str, string'("WB_GEN_STATUS: " )); hwrite( str, status( 31 downto 0 ) ); writeline( log, str );	
	wb_block_gen_read( cmd, ret, REG_TEST_GEN_BL_WR,  reg_block_wr ); 	-- read block_wr
	write( str, string'("WB_GEN_BL_WR:  " )); hwrite( str, reg_block_wr( 31 downto 0 ) ); writeline( log, str );	
	
	
	wb_block_gen_write( cmd, ret, REG_TEST_GEN_CTRL, x"000006A0" ); -- start test sequence	
	
	wait for 20 us;
	
	block_read( cmd, ret, 5, 16, data );			-- STATUS 
	
	write( str, string'("STATUS: " )); hwrite( str, data( 15 downto 0 ) );
	if( data( 8 )='1' ) then
		write( str, string'(" - descriptor is correct" ));	
	else
		write( str, string'(" - descriptor is incorrect" ));
		error := error + 1;
	end if;
	
	writeline( log, str );	
	
	if( error=0 ) then
		
		---- Ожидание завершения DMA ----
		dma_complete := 0;
		for ii in 0 to 100 loop
			
		block_read( cmd, ret, 5, 16, data );			-- STATUS 
		write( str, string'("STATUS: " )); hwrite( str, data( 15 downto 0 ) );
			if( data(5)='1' ) then
				write( str, string'(" - DMA finished " ));
				dma_complete := 1;	
				
				block_write( cmd, ret, 5, 16#11#, x"00000010" );		-- FLAG_CLR - reset EOT 
				
			end if;
			writeline( log, str );			
			
			if( dma_complete=1 ) then
				exit;
			end if;		   
			
			wait for 1 us;
			
		end loop;
	
		writeline( log, str );			
		
		if( dma_complete=0 ) then
			write( str, string'("Error - DMA not finished " ));
			writeline( log, str );			
			error:=error+1;
		end if;

	end if; 	   
	
	wb_block_gen_read( cmd, ret, REG_TEST_GEN_STATUS, status ); 		-- read status
	write( str, string'("WB_GEN_STATUS: " )); hwrite( str, status( 31 downto 0 ) ); writeline( log, str );	
	wb_block_gen_read( cmd, ret, REG_TEST_GEN_BL_WR,  reg_block_wr ); 	-- read block_wr
	write( str, string'("WB_GEN_BL_WR:  " )); hwrite( str, reg_block_wr( 31 downto 0 ) ); writeline( log, str );	
	
	
	for ii in 0 to 3 loop
			
		block_read( cmd, ret, 5, 16, data );			-- STATUS 
		write( str, string'("STATUS: " )); hwrite( str, data( 15 downto 0 ) );
		writeline( log, str );			
		wait for 500 ns;
		
	end loop;
	
	
	block_write( cmd, ret, 5, 9, x"00000000" );		-- DMA_CTRL - STOP  	
	
	write( str, string'(" Block 0 - read: " ));
	writeline( log, str );		
	
	for ii in 0 to 15 loop

		adr:= x"00800000";
		adr:=adr + ii*4;
		int_mem_read( cmd, ret, adr,  data );
		
		write( str, ii ); write( str, string'("   " )); hwrite( str, data );
		writeline( log, str );		
		
	end loop;

	writeline( log, str );		
	
	write( str, string'(" Block 1 - read: " ));
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
		write( str, string'(" Test is correct " ));
		cnt_ok := cnt_ok + 1;
	else
		write( str, string'(" Test have ERRORS " ));
		cnt_error := cnt_error + 1;
	end if;
	writeline( log, str );	
	writeline( log, str );		

end test_adm_read_8kb;
--
--
----! Проверка обращений к блоку MAIN 
--procedure test_block_main (
--		signal  cmd:	out bh_cmd; --! command
--		signal  ret:	in  bh_ret  --! answer
--		)
--is
--
--variable	adr				: std_logic_vector( 31 downto 0 );
--variable	data			: std_logic_vector( 31 downto 0 );
--variable	str				: line;			   
--
--variable	error			: integer:=0;
--variable	dma_complete	: integer;
--
--begin
--		
--	write( str, string'("TEST_BLOCK_MAIN" ));
--	writeline( log, str );	
--
--	block_read( cmd, ret, 4, 16#00#, data );			
--	write( str,  string'("БЛОК 4: " )); hwrite( str, data ); writeline( log, str );	
--
--	wait for 10 us;
--	
----	write( str, "Константы:" );
----	writeline( log, str );	
----	for ii in 0 to 5 loop
----		write( str, "Блок " );
----		write( str, ii );
----		for jj in 0 to 7 loop
----			block_read( cmd, ret, ii, jj, data );			
----			write( str, "   " );
----			hwrite( str, data );
----		end loop;
----		writeline( log, str );		
----	end loop;
----		
----	
----	writeline( log, str );							
----	
----	block_read( cmd, ret, 0, 16#10#, data );			
----	write( str,  "STATUS: " ); hwrite( str, data ); writeline( log, str );	
----	
----	block_write( cmd, ret, 80, 16#08#, x"00000100" );			
----	
----	block_read( cmd, ret, 0, 16#10#, data );			
----	write( str, "STATUS: " ); hwrite( str, data ); writeline( log, str );	
----	
----	block_write( cmd, ret, 80, 16#08#, x"00000200" );			
----	
----	block_read( cmd, ret, 0, 16#10#, data );			
----	write( str, "STATUS: " ); hwrite( str, data ); writeline( log, str );	
----	
----	
----	writeline( log, str );		
----	if( error=0 ) then
----		write( str, " Тест завершён успешно " );
----		cnt_ok := cnt_ok + 1;
----	else
----		write( str, " Тест не выполнен " );
----		cnt_error := cnt_error + 1;
----	end if;
--
--	for ii in 0 to 127 loop
--	
--		block_write( cmd, ret, 4, 16#08#, x"0000AA55" );				
--		block_read( cmd, ret, 4, 8, data );
--		write( str, string'("READ: " )); hwrite( str, data( 15 downto 0 ) ); writeline( log, str );		
--		if( data/=x"0000AA55" ) then
--			error:=error+1;
--		end if;
--	
--	end loop;
--	
--	
--
--
--	writeline( log, str );	
--	writeline( log, str );		
--
--end test_block_main;
--			
--
--
--
----! Чтение 16 кБ с использованием двух блоков дескрипторов
--procedure test_adm_read_16kb (
--		signal  cmd:	out bh_cmd; --! command
--		signal  ret:	in  bh_ret  --! answer
--		)
--is
--
--variable	adr				: std_logic_vector( 31 downto 0 );
--variable	data			: std_logic_vector( 31 downto 0 );
--variable	str				: line;			   
--
--variable	error			: integer:=0;
--variable	dma_complete	: integer; 
--variable	kk				: integer;	 
--variable	status			: std_logic_vector( 15 downto 0 );
--
--begin
--		
--	write( str, string'("TEST_ADM_READ_16KB" ));
--	writeline( log, str );	
--	
--	---- Формирование блока дескрипторов ---
--	for ii in 0 to 256 loop
--		adr:= x"00100000";
--		adr:=adr + ii*4;
--		int_mem_write( cmd, ret, adr,  x"00000000" );
--	end loop;										 
--	
--	--- Блок 0 ---
--	
--	--- Дескриптор 0 ---
--	int_mem_write( cmd, ret, x"00100000",  x"00008000" ); 
--	int_mem_write( cmd, ret, x"00100004",  x"00000111" );  	-- переход к следующему дескриптору 
--
--	--- Дескриптор 1 ---
--	int_mem_write( cmd, ret, x"00100008",  x"00008010" ); 
--	int_mem_write( cmd, ret, x"0010000C",  x"00000112" );  	-- переход к следующему блоку 
--
--	--- Дескриптор 2 ---
--	int_mem_write( cmd, ret, x"00100010",  x"00001002" ); 	-- адрес следующего дескриптора 
--	int_mem_write( cmd, ret, x"00100014",  x"00000000" );  	
--	
--	
--	int_mem_write( cmd, ret, x"001001F8",  x"00000000" );
--	int_mem_write( cmd, ret, x"001001FC",  x"14644953" );	   
--	
--
--	--- Блок 1 ---
--	
--	--- Дескриптор 0 ---
--	int_mem_write( cmd, ret, x"00100200",  x"00008020" ); 
--	int_mem_write( cmd, ret, x"00100204",  x"00000111" );  	-- переход к следующему дескриптору 
--
--	--- Дескриптор 1 ---
--	int_mem_write( cmd, ret, x"00100208",  x"00008030" ); 
--	int_mem_write( cmd, ret, x"0010020C",  x"00000110" );  	-- остановка
--	
--	
--	int_mem_write( cmd, ret, x"001003F8",  x"00000000" );
--	int_mem_write( cmd, ret, x"001003FC",  x"D67C4953" );	   
--	
--	
--	
--	---- Программирование канала DMA ----
--	block_write( cmd, ret, 4, 8, x"00000027" );		-- DMA_MODE 
--	block_write( cmd, ret, 4, 9, x"00000010" );		-- DMA_CTRL - RESET FIFO 
--	
--	block_write( cmd, ret, 4, 20, x"00100000" );	-- PCI_ADRL 
--	block_write( cmd, ret, 4, 21, x"00100000" );	-- PCI_ADRH  
--	block_write( cmd, ret, 4, 23, x"00019000" );	-- LOCAL_ADR 
--	
--	
--	---- Подготовка тетрады ----
--	trd_test_mode( cmd, ret, 0 );	-- переход в рабочий режим --
--	trd_wait_cmd( cmd, ret, 0, 16, x"1600" );		-- DMAR0 - от тетрады 6 --
--
--	trd_wait_cmd( cmd, ret, 1, 16#1F#, x"0001" );	-- Размер блока = 4 кБ --
--
--	block_write( cmd, ret, 4, 9, x"00000001" );		-- DMA_CTRL - START 
--
--	trd_wait_cmd( cmd, ret, 1, 16#0F#, x"0001" );	-- Подключение выхода генератора к DIO_IN --
--	
--	trd_wait_cmd( cmd, ret, 6, 	0, x"2038" );		-- запуск тетрады DIO_IN
--	
--	trd_wait_cmd( cmd, ret, 1, 16#1E#, x"0020" );	-- Запуск тестовой последовательности --
--	
--	wait for 20 us;
--	
--	block_read( cmd, ret, 4, 16, data );			-- STATUS 
--	
--	write( str, string'("STATUS: " )); hwrite( str, data( 15 downto 0 ) );
--	if( data( 8 )='1' ) then
--		write( str, string'(" - Дескриптор правильный" ));	
--	else
--		write( str, string'(" - Ошибка чтения дескриптора" ));
--		error := error + 1;
--	end if;
--	
--	writeline( log, str );	
--	
--	if( error=0 ) then		   
--		
--		kk:=0;
--		loop
--			
--		trd_status( cmd, ret, 6, status );
--		write( str, string'("TRD_STATUS: " )); hwrite( str, status );
--			
--		block_read( cmd, ret, 4, 16, data );			-- STATUS 
--		write( str, string'("    STATUS: " )); hwrite( str, data( 15 downto 0 ) );
--		
--			if( data(4)='1' ) then
--				write( str, string'(" - завершено чтение блока " ));
--				block_write( cmd, ret, 4, 16#11#, x"00000010" );		-- FLAG_CLR - сброс EOT 
--				kk:=kk+1;
--				if( kk=4 ) then
--					exit;
--				end if;
--			end if;
--			writeline( log, str );			
--			
--			wait for 500 ns;
--			
--			
--		end loop;
--		
--		---- Ожидание завершения DMA ----
--		dma_complete := 0;
--		for ii in 0 to 100 loop
--			
--		block_read( cmd, ret, 4, 16, data );			-- STATUS 
--		write( str, string'("STATUS: " )); hwrite( str, data( 15 downto 0 ) );
--			if( data(5)='1' ) then
--				write( str, string'(" - DMA завершён " ));
--				dma_complete := 1;	
--				
--				block_write( cmd, ret, 4, 16#11#, x"00000010" );		-- FLAG_CLR - сброс EOT 
--				
--			end if;
--			writeline( log, str );			
--			
--			if( dma_complete=1 ) then
--				exit;
--			end if;		   
--			
--			wait for 1 us;
--			
--		end loop;
--	
--		writeline( log, str );			
--		
--		if( dma_complete=0 ) then
--			write( str, string'("Ошибка - DMA не завершён " ));
--			writeline( log, str );			
--			error:=error+1;
--		end if;
--
--	end if; 
--	
--	for ii in 0 to 3 loop
--			
--		block_read( cmd, ret, 4, 16, data );			-- STATUS 
--		write( str, string'("STATUS: " )); hwrite( str, data( 15 downto 0 ) );
--		writeline( log, str );			
--		wait for 500 ns;
--		
--	end loop;
--	
--	
--	block_write( cmd, ret, 4, 9, x"00000000" );		-- DMA_CTRL - STOP  	
--	
--	write( str, string'(" Блок 0 - прочитано: " ));
--	writeline( log, str );		
--	
--	for ii in 0 to 15 loop
--
--		adr:= x"00800000";
--		adr:=adr + ii*4;
--		int_mem_read( cmd, ret, adr,  data );
--		
--		write( str, ii ); write( str, string'("   " )); hwrite( str, data );
--		writeline( log, str );		
--		
--	end loop;
--
--	writeline( log, str );		
--	
--	write( str, string'(" Блок 1 - прочитано: " ));
--	writeline( log, str );		
--	
--	for ii in 0 to 15 loop
--
--		adr:= x"00801000";
--		adr:=adr + ii*4;
--		int_mem_read( cmd, ret, adr,  data );
--		
--		write( str, ii ); write( str, string'("   " )); hwrite( str, data );
--		writeline( log, str );		
--		
--	end loop;
--
--	write( str, string'(" Блок 2 - прочитано: " ));
--	writeline( log, str );		
--	
--	for ii in 0 to 15 loop
--
--		adr:= x"00802000";
--		adr:=adr + ii*4;
--		int_mem_read( cmd, ret, adr,  data );
--		
--		write( str, ii ); write( str, string'("   " )); hwrite( str, data );
--		writeline( log, str );		
--		
--	end loop;
--		
--	
--	write( str, string'(" Блок 3 - прочитано: " ));
--	writeline( log, str );		
--	
--	for ii in 0 to 15 loop
--
--		adr:= x"00803000";
--		adr:=adr + ii*4;
--		int_mem_read( cmd, ret, adr,  data );
--		
--		write( str, ii ); write( str, string'("   " )); hwrite( str, data );
--		writeline( log, str );		
--		
--	end loop;
--		
----	block_write( cmd, ret, 4, 9, x"00000010" );		-- DMA_CTRL - RESET FIFO 
----	block_write( cmd, ret, 4, 9, x"00000000" );		-- DMA_CTRL 
----	block_write( cmd, ret, 4, 9, x"00000001" );		-- DMA_CTRL - START  	
--	
--	
--	writeline( log, str );		
--	if( error=0 ) then
--		write( str, string'(" Тест завершён успешно " ));
--		cnt_ok := cnt_ok + 1;
--	else
--		write( str, string'(" Тест не выполнен " ));
--		cnt_error := cnt_error + 1;
--	end if;
--	writeline( log, str );	
--	writeline( log, str );		
--
--end test_adm_read_16kb;
--
--
--
--
--! Запись 16 кБ с использованием двух блоков дескрипторов
procedure test_adm_write_16kb (
		signal  cmd:	out bh_cmd; --! command
		signal  ret:	in  bh_ret  --! answer
		)
is

variable	adr				: std_logic_vector( 31 downto 0 );
variable	data			: std_logic_vector( 31 downto 0 );
variable	str				: line;			   

variable	error			: integer:=0;
variable	dma_complete	: integer; 
variable	kk				: integer;	 
variable	status			: std_logic_vector( 15 downto 0 );

variable	data64			: std_logic_vector( 63 downto 0 );
variable	data64n			: std_logic_vector( 63 downto 0 );

begin
		
	write( str, string'("TEST_ADM_WRITE_16KB" ));
	writeline( log, str );	
	
	block_write( cmd, ret, 0, 8, x"0000000F" );		-- BRD_MODE, reset off 
	wait for 100 ns;
	
	---- Формирование блока дескрипторов ---
	for ii in 0 to 256 loop
		adr:= x"00100000";
		adr:=adr + ii*4;
		int_mem_write( cmd, ret, adr,  x"00000000" );
	end loop;										 
	

	data64 :=x"0000000000000000";
	data64n := not data64;
	
	---- Заполнение блока 0 ----
	adr:= x"00800000";
    data:=x"A5A50123";
	int_mem_write( cmd, ret, adr,  data );
	adr:=adr + 4;
	
	data:=x"00000000";
	int_mem_write( cmd, ret, adr,  data );
	adr:=adr + 4;
	
	int_mem_write( cmd, ret, adr,  data64n( 31 downto 0 ) );
	adr:=adr + 4;

	int_mem_write( cmd, ret, adr,  data64n( 63 downto 32 ) );
	adr:=adr + 4;

	data64:=data64 + 1;
	data64n := not data64;
	
	for ii in 0 to 254 loop
		int_mem_write( cmd, ret, adr,  data64( 31 downto 0 ) );
		adr:=adr + 4;
		int_mem_write( cmd, ret, adr,  data64( 63 downto 32 ) );
		adr:=adr + 4;

		int_mem_write( cmd, ret, adr,  data64n( 31 downto 0 ) );
		adr:=adr + 4;
		int_mem_write( cmd, ret, adr,  data64n( 63 downto 32 ) );
		adr:=adr + 4;

		data64:=data64 + 1;
		data64n := not data64;
		
	end loop;	
	
	---- Заполнение блока 1 ----
	adr:= x"00801000";
    data:=x"A5A50123";
	int_mem_write( cmd, ret, adr,  data );
	adr:=adr + 4;
	
	data:=x"00000001";
	int_mem_write( cmd, ret, adr,  data );
	adr:=adr + 4;
	
	int_mem_write( cmd, ret, adr,  data64n( 31 downto 0 ) );
	adr:=adr + 4;

	int_mem_write( cmd, ret, adr,  data64n( 63 downto 32 ) );
	adr:=adr + 4;

	data64:=data64 + 1;
	data64n := not data64;
	
	for ii in 0 to 254 loop
		int_mem_write( cmd, ret, adr,  data64( 31 downto 0 ) );
		adr:=adr + 4;
		int_mem_write( cmd, ret, adr,  data64( 63 downto 32 ) );
		adr:=adr + 4;

		int_mem_write( cmd, ret, adr,  data64n( 31 downto 0 ) );
		adr:=adr + 4;
		int_mem_write( cmd, ret, adr,  data64n( 63 downto 32 ) );
		adr:=adr + 4;

		data64:=data64 + 1;
		data64n := not data64;
		
	end loop;		
	
	---- Заполнение блока 2 ----
	adr:= x"00802000";
    data:=x"A5A50123";
	int_mem_write( cmd, ret, adr,  data );
	adr:=adr + 4;
	
	data:=x"00000002";
	int_mem_write( cmd, ret, adr,  data );
	adr:=adr + 4;
	
	int_mem_write( cmd, ret, adr,  data64n( 31 downto 0 ) );
	adr:=adr + 4;

	int_mem_write( cmd, ret, adr,  data64n( 63 downto 32 ) );
	adr:=adr + 4;

	data64:=data64 + 1;
	data64n := not data64;
	
	for ii in 0 to 254 loop
		int_mem_write( cmd, ret, adr,  data64( 31 downto 0 ) );
		adr:=adr + 4;
		int_mem_write( cmd, ret, adr,  data64( 63 downto 32 ) );
		adr:=adr + 4;

		int_mem_write( cmd, ret, adr,  data64n( 31 downto 0 ) );
		adr:=adr + 4;
		int_mem_write( cmd, ret, adr,  data64n( 63 downto 32 ) );
		adr:=adr + 4;

		data64:=data64 + 1;
		data64n := not data64;
		
	end loop;	
	
	---- Заполнение блока 3 ----
	adr:= x"00803000";
    data:=x"A5A50123";
	int_mem_write( cmd, ret, adr,  data );
	adr:=adr + 4;
	
	data:=x"00000003";
	int_mem_write( cmd, ret, adr,  data );
	adr:=adr + 4;
	
	int_mem_write( cmd, ret, adr,  data64n( 31 downto 0 ) );
	adr:=adr + 4;

	int_mem_write( cmd, ret, adr,  data64n( 63 downto 32 ) );
	adr:=adr + 4;

	data64:=data64 + 1;
	data64n := not data64;
	
	for ii in 0 to 254 loop
		int_mem_write( cmd, ret, adr,  data64( 31 downto 0 ) );
		adr:=adr + 4;
		int_mem_write( cmd, ret, adr,  data64( 63 downto 32 ) );
		adr:=adr + 4;

		int_mem_write( cmd, ret, adr,  data64n( 31 downto 0 ) );
		adr:=adr + 4;
		int_mem_write( cmd, ret, adr,  data64n( 63 downto 32 ) );
		adr:=adr + 4;

		data64:=data64 + 1;
		data64n := not data64;
		
	end loop;		
--	for ii in 0 to 256 loop
--		adr:= x"00802000";
--		adr:=adr + ii*4;
--		data:=x"00A20000";
--		data:=data + ii;
--		int_mem_write( cmd, ret, adr,  data );
--	end loop;	
--
--	for ii in 0 to 256 loop
--		adr:= x"00803000";
--		adr:=adr + ii*4;
--		data:=x"00A30000";
--		data:=data + ii;
--		int_mem_write( cmd, ret, adr,  data );
--	end loop;	
	
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
	block_write( cmd, ret, 5, 8, x"00000023" );		-- DMA_MODE  - с запросами 
	--block_write( cmd, ret, 5, 8, x"00000021" );		-- DMA_MODE - без запросов
	block_write( cmd, ret, 5, 9, x"00000010" );		-- DMA_CTRL - RESET FIFO 
	
	block_write( cmd, ret, 5, 20, x"00100000" );	-- PCI_ADRL 
	block_write( cmd, ret, 5, 21, x"00100000" );	-- PCI_ADRH  
	block_write( cmd, ret, 5, 23, x"00001000" );	-- LOCAL_ADR 
	
	
	---- Подготовка тетрады ----
--	trd_test_mode( cmd, ret, 0 );	-- переход в рабочий режим --
--	trd_wait_cmd( cmd, ret, 0, 16, x"1700" );		-- DMAR0 - от тетрады 7 --
--
--	trd_wait_cmd( cmd, ret, 1, 16#1D#, x"0001" );	-- Размер блока = 4 кБ --

	wb_block_check_write( cmd, ret, REG_TEST_CHECK_CTRL, x"00000001" ); -- сброс
	wb_block_check_write( cmd, ret, REG_TEST_CHECK_CTRL, x"00000000" ); 
	wb_block_check_read( cmd, ret, REG_BLOCK_ID, data ); -- чтение идентификатора блока
	write( str, string'("BLOCK TEST_CHECK  ID: " ));
	hwrite( str, data );
	writeline( log, str );	
	
	wb_block_check_write( cmd, ret, REG_TEST_CHECK_SIZE, x"00000001" ); -- размер блока - 1 килобайт
	
	wb_block_check_write( cmd, ret, REG_TEST_CHECK_CTRL, x"000006A0" ); -- запуск тестовой последовательности	
	--
        --
        --
        data:=wb_block_check_burst_ctrl_build('1', 40, 473);
        wb_block_check_write( cmd, ret, REG_TEST_CHECK_WBS_BURST_CTRL, data);
	--
        --
        --
	block_write( cmd, ret, 5, 9, x"00000001" );		-- DMA_CTRL - START 

--	trd_wait_cmd( cmd, ret, 1, 16#0F#, x"0001" );	-- Подключение выхода генератора к DIO_IN --
--	
--	trd_wait_cmd( cmd, ret, 7, 	0, x"2038" );		-- запуск тетрады DIO_OUT 
--	
--	trd_wait_cmd( cmd, ret, 1, 16#1C#, x"0020" );	-- Запуск тестовой последовательности --
	
	wait for 20 us;
	
	
	for ii in 0 to 20 loop
		block_read( cmd, ret, 5, 16, data );			-- STATUS 
		
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
			
--		trd_status( cmd, ret, 6, status );
--		write( str, string'("TRD_STATUS: " )); hwrite( str, status );
			
		block_read( cmd, ret, 5, 16, data );			-- STATUS 
		write( str, string'("    STATUS: " )); hwrite( str, data( 15 downto 0 ) );
		
			if( data(4)='1' ) then
				write( str, string'(" - завершена передача блока " ));
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
			
		block_read( cmd, ret, 5, 16, data );			-- STATUS 
		write( str, string'("STATUS: " )); hwrite( str, data( 15 downto 0 ) );
		
			if( data(4)='1' ) then
				write( str, string'(" - завершёна передача блока " ));
				
				block_write( cmd, ret, 5, 16#11#, x"00000010" );		-- FLAG_CLR - сброс EOT 
				
			end if;
			writeline( log, str );			
			
		
			if( data(5)='1' ) then
				write( str, string'(" - DMA завершён " ));
				dma_complete := 1;	
				
				block_write( cmd, ret, 5, 16#11#, x"00000010" );		-- FLAG_CLR - сброс EOT 
				
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
			
		block_read( cmd, ret, 5, 16, data );			-- STATUS 
		write( str, string'("STATUS: " )); hwrite( str, data( 15 downto 0 ) );
		writeline( log, str );			
		wait for 500 ns;
		
	end loop;
	
	wait for 10 us;
	
	wb_block_check_read( cmd, ret, REG_TEST_CHECK_BL_RD, data ); 
	write( str, string'( "Принято блоков: " ) );
	hwrite( str, data );
	kk := conv_integer( data );
	if( 4/=kk ) then
		write( str, string'( " - Ошибка" ) );
		error := error + 1;				  
	else
		write( str, string'( " - Ok" ) );
	end if;
	writeline( log, str );			
		
	wb_block_check_read( cmd, ret, REG_TEST_CHECK_BL_OK, data ); 
	write( str, string'( "TEST_CHECK_BL_OK: " ) );
	hwrite( str, data );
	kk := conv_integer( data );
	if( 3/=kk ) then
		write( str, string'( " - Ошибка" ) );
		error := error + 1;				  
	else
		write( str, string'( " - Ok" ) );
	end if;
	writeline( log, str );			
		
	wb_block_check_read( cmd, ret, REG_TEST_CHECK_BL_ERROR, data ); 
	write( str, string'( "TEST_CHECK_BL_ERROR: " ) );
	hwrite( str, data );
	kk := conv_integer( data );
	if( 0/=kk ) then
		write( str, string'( " - Ошибка" ) );
		error := error + 1;				  
	else
		write( str, string'( " - Ok" ) );
	end if;
	writeline( log, str );			
		
	
	
	block_write( cmd, ret, 5, 9, x"00000000" );		-- DMA_CTRL - STOP  	
	
		
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
---------------------------------------------------------------------------------------------------
--
-- My procedure for test Updated Design (test_read_4kb like refenernce)
--
procedure test_num_1 (
                            signal  cmd:    out bh_cmd; --! command
                            signal  ret:    in  bh_ret  --! answer
                        ) is
    
    variable    adr             : std_logic_vector( 31 downto 0 );
    variable    data            : std_logic_vector( 31 downto 0 );
    variable    str             : line;
    
    variable    error           : integer:=0;
    variable    dma_complete    : integer:=0;
    
begin
    -- Init Header
    write( str, string'("TEST#1: simple test of WB CORSS logic - read from empty place" ));
    writeline( log, str );
    --
    ---- Формирование блока дескрипторов ---
    for ii in 0 to 127 loop
        adr:= x"00100000";
        adr:=adr + ii*4;
        int_mem_write( cmd, ret, adr,  x"00000000" );
    end loop;
    -- HOST MEM Writes:
    int_mem_write( cmd, ret, x"00100000",  x"00008000" );   -- 
    int_mem_write( cmd, ret, x"00100004",  x"00000100" );   -- 
    
    int_mem_write( cmd, ret, x"001001F8",  x"00000000" );   -- 
    int_mem_write( cmd, ret, x"001001FC",  x"762C4953" );   -- 
    --
    ---- Программирование канала DMA ---- PE_EXT_FIFO module: have bug in PE_EXT_FIFO, for check WB we will make a trick:
    block_write( cmd, ret, 4, 8, x"00000027" );     -- DMA_MODE - DEMAND_MODE==ON 
    block_write( cmd, ret, 4, 9, x"00000010" );     -- DMA_CTRL - RESET FIFO 
    
    block_write( cmd, ret, 4, 20, x"00100000" );    -- PCI_ADRL
    block_write( cmd, ret, 4, 21, x"00100000" );    -- PCI_ADRH
    block_write( cmd, ret, 4, 23, x"0000A400" );    -- LOCAL_ADR : xA400 addr - check WB CROSS logic, rx value must be EQU to p_TEST_DATA_64BIT in current design
    
    block_write( cmd, ret, 4, 9, x"00000001" );     -- DMA_CTRL - START
    --
    -- Delay for design: trick for afoid bug in PE_EXT_FIFO --> Ошибка #24
    wait for 1 us;
    block_write( cmd, ret, 4, 8, x"00000025" );     -- DMA_MODE - DEMAND_MODE==OFF 
    --
    -- Delay for design
    wait for 20 us;
    --
    -- Read STATUS 
    block_read( cmd, ret, 4, 16, data );
    -- Construct LOG MSG in accordance to STATUS value and update ERR counter
    write( str, string'(" STATUS: " )); hwrite( str, data( 15 downto 0 ) );
    if( data( 8 )='1' ) then
        write( str, string'(" - Descriptor==OK" ));
    else
        write( str, string'(" - Descriptor RD ERR" ));
        error := error + 1;
    end if;
    writeline( log, str );  -- upd LOGFILE
    --
    -- Deal with STATUS Results:
    if( error=0 ) then  -- w8ing for DMA final
        dma_complete := 0;
        for ii in 0 to 100 loop -- 100 loop cycles of STATUS-process with 1us delay after
            -- Read STATUS 
            block_read( cmd, ret, 4, 16, data );
            -- Construct LOG MSG in accordance to STATUS value and update "dma_complete"
            write( str, string'(" STATUS: " )); hwrite( str, data( 15 downto 0 ) );
            if( data(5)='1' ) then
                write( str, string'(" - DMA finished" ));
                dma_complete := 1;
            end if;
            writeline( log, str );
            -- Check "dma_complete"
            if( dma_complete=1 ) then
                exit;           -- EXIT Loop on FINAL
            else
                wait for 1 us;  -- DELAY in other case
            end if;
        end loop;
        writeline( log, str );  -- upd LOGFILE
        
        if( dma_complete=0 ) then   -- check "dma_complete" after all
            write( str, string'("ERR - DMA not finished " ));
            writeline( log, str );
            error:=error+1;
        end if;
        
    end if; 
    --
    -- Print STATUS now
    for ii in 0 to 3 loop   -- print STATUS value 4 times with 0.5us delay after
        -- Read STATUS
        block_read( cmd, ret, 4, 16, data );
        -- Construct LOG MSG in accordance to STATUS value
        write( str, string'(" STATUS: " )); hwrite( str, data( 15 downto 0 ) );
        -- upd LOGFILE
        writeline( log, str );  
        wait for 500 ns;
    end loop;
    --
    -- Now STOP Design
    block_write( cmd, ret, 4, 9, x"00000000" );     -- DMA_CTRL - STOP
    --
    -- Now print RX values:
    --
    -- Construct Header:
    writeline( log, str );
    write( str, string'("PRINT 1st 15 RX values: " ));
    writeline( log, str );
    -- Get first 15 DATA values and print it:
    for ii in 0 to 15 loop
        adr:= x"00800000";                      -- init ADDR value
        adr:=adr + ii*4;                        -- upd addr to curr idx
        int_mem_read( cmd, ret, adr,  data );   -- HOST MEM Read
        -- Construct LOG MSG in accordance to HOST MEM Read value
        --write( str, ii ); write( str, string'("   " )); hwrite( str, data );
        hwrite( str, CONV_STD_LOGIC_VECTOR(ii, 8) );write( str, string'(" - " )); hwrite( str, data );
        writeline( log, str );  -- upd LOGFILE
    end loop;
    writeline( log, str );      -- upd LOGFILE
    --
    -- Final CHECK errors:
    if( error=0 ) then
        write( str, string'("SUCCSESSFULL FINAL " ));
        cnt_ok := cnt_ok + 1;
    else
        write( str, string'("FAILED FINAL " ));
        cnt_error := cnt_error + 1;
    end if;
    writeline( log, str );  -- upd LOGFILE
    writeline( log, str );  -- upd LOGFILE
    --
    -- END
end test_num_1;
--
--
--
procedure test_num_2 (
                            signal  cmd:    out bh_cmd; --! command
                            signal  ret:    in  bh_ret  --! answer
                        ) is
    
    variable    adr             : std_logic_vector( 31 downto 0 );
    variable    data            : std_logic_vector( 31 downto 0 );
    variable    data64          : std_logic_vector( 63 downto 0 );
    variable    str             : line;
    
    variable    error           : integer:=0;
    variable    dma_complete    : integer:=0;
    
begin
    -- Init Header
    write( str, string'("TEST#2: Get data from TEST_GEN.WB_BURST_SLAVE" ));
    writeline( log, str );
    --
    ---- Формирование блока дескрипторов ---
    for ii in 0 to 127 loop
        adr:= x"00100000";
        adr:=adr + ii*4;
        int_mem_write( cmd, ret, adr,  x"00000000" );
    end loop;
    -- HOST MEM Writes:
    int_mem_write( cmd, ret, x"00100000",  x"00008000" );   -- 
    int_mem_write( cmd, ret, x"00100004",  x"00000100" );   -- 
    
    int_mem_write( cmd, ret, x"001001F8",  x"00000000" );   -- 
    int_mem_write( cmd, ret, x"001001FC",  x"762C4953" );   -- 
    --
    -- TEST_GEN.WB_CFG_SLAVE: config TEST_GEN
    adr     :=x"20002048";              --  TEST_GEN.WB_CFG_SLAVE.TEST_GEN_SIZE
    data64  :=x"0000000000000001";      --  TEST_GEN_SIZE=x01
    data_write64(cmd, ret, adr, data64);--  PCIE WR
    
    adr     :=x"20002040";              --  TEST_GEN.WB_CFG_SLAVE.TEST_GEN_CTRL
    data64  :=x"0000000000000022";      --  TEST_GEN_CTRL=x22 (START=1, TEST_GEN.di_start=1)
    data_write64(cmd, ret, adr, data64);--  PCIE WR
    
    -- PE_EXT_FIFO module config: --> have a bug in PE_EXT_FIFO, for check WB we will make a trick:
    block_write( cmd, ret, 4, 8, x"00000027" );     -- DMA_MODE - DEMAND_MODE==ON 
    block_write( cmd, ret, 4, 9, x"00000010" );     -- DMA_CTRL - RESET FIFO 
    
    block_write( cmd, ret, 4, 20, x"00100000" );    -- PCI_ADRL 
    block_write( cmd, ret, 4, 21, x"00100000" );    -- PCI_ADRH  
    block_write( cmd, ret, 4, 23, x"00003000" );    -- LOCAL_ADR: TEST_GEN.WB_BURST_SLAVE
    
    block_write( cmd, ret, 4, 9, x"00000001" );     -- DMA_CTRL - START
    --
    -- Delay for design: trick for afoid bug in PE_EXT_FIFO --> Ошибка #24
    wait for 1 us;
    block_write( cmd, ret, 4, 8, x"00000025" );     -- DMA_MODE - DEMAND_MODE==OFF 
    --
    -- Delay for design
    wait for 20 us;
    --
    -- Read STATUS (check RD DESCR status):
    block_read( cmd, ret, 4, 16, data );
    -- Construct LOG MSG in accordance to STATUS value and update ERR counter
    write( str, string'(" STATUS: " )); hwrite( str, data( 15 downto 0 ) );
    if( data( 8 )='1' ) then
        write( str, string'(" - Descriptor==OK" ));
    else
        write( str, string'(" - Descriptor RD ERR" ));
        error := error + 1;
    end if;
    writeline( log, str );  -- upd LOGFILE
    --
    -- W8ing for DMA finish:
    if( error=0 ) then  -- w8ing for DMA final
        dma_complete := 0;
        for ii in 0 to 100 loop -- 100 loop cycles of STATUS-process with 1us delay after
            -- Read STATUS 
            block_read( cmd, ret, 4, 16, data );
            -- Construct LOG MSG in accordance to STATUS value and update "dma_complete"
            write( str, string'(" STATUS: " )); hwrite( str, data( 15 downto 0 ) );
            if( data(5)='1' ) then
                write( str, string'(" - DMA finished" ));
                dma_complete := 1;
            end if;
            writeline( log, str );
            -- Check "dma_complete"
            if( dma_complete=1 ) then
                exit;           -- EXIT Loop on FINAL
            else
                wait for 1 us;  -- DELAY in other case
            end if;
        end loop;
        writeline( log, str );  -- upd LOGFILE
        
        if( dma_complete=0 ) then   -- check "dma_complete" after all
            write( str, string'("ERR - DMA not finished " ));
            writeline( log, str );
            error:=error+1;
        end if;
        
    end if; 
    --
    -- Print STATUS in ERR
    if (error /= 0 ) then 
        for ii in 0 to 3 loop   -- print STATUS value 4 times with 0.5us delay after
            -- Read STATUS
            block_read( cmd, ret, 4, 16, data );
            -- Construct LOG MSG in accordance to STATUS value
            write( str, string'(" STATUS: " )); hwrite( str, data( 15 downto 0 ) );
            -- upd LOGFILE
            writeline( log, str );  
            wait for 500 ns;
        end loop;
    end if;
    --
    -- Now STOP Design
    block_write( cmd, ret, 4, 9, x"00000000" );     -- DMA_CTRL - STOP
    --
    -- Now print RX values:
    --
    -- Construct Header:
    writeline( log, str );
    write( str, string'("PRINT 1st 15 RX values: " ));
    writeline( log, str );
    -- Get first 15 DATA values and print it:
    for ii in 0 to 15 loop
        adr:= x"00800000";                      -- init ADDR value
        adr:=adr + ii*4;                        -- upd addr to curr idx
        int_mem_read( cmd, ret, adr,  data );   -- HOST MEM Read
        -- Construct LOG MSG in accordance to HOST MEM Read value
        --write( str, ii ); write( str, string'("   " )); hwrite( str, data );
        hwrite( str, CONV_STD_LOGIC_VECTOR(ii, 8) );write( str, string'(" - " )); hwrite( str, data );
        writeline( log, str );  -- upd LOGFILE
    end loop;
    writeline( log, str );      -- upd LOGFILE
    --
    -- Final CHECK errors:
    if( error=0 ) then
        write( str, string'(" stb SUCCSESSFULL FINAL " ));
        cnt_ok := cnt_ok + 1;
    else
        write( str, string'(" stb FAILED FINAL " ));
        cnt_error := cnt_error + 1;
    end if;
    writeline( log, str );  -- upd LOGFILE
    writeline( log, str );  -- upd LOGFILE
    --
    -- END
end test_num_2;
---------------------------------------------------------------------------------------------------
--
-- My procedure for test WB stuff in Design:
--  ==> TEST_CHECK.WB_CFG_SLAVE
--
procedure test_wb_1 (
                            signal  cmd:    out bh_cmd; --! command
                            signal  ret:    in  bh_ret  --! answer
                    ) is
    
    variable    adr             : std_logic_vector( 31 downto 0 );
    variable    data32          : std_logic_vector( 31 downto 0 );
    variable    data64          : std_logic_vector( 63 downto 0 );
    variable    str             : line;
    
    variable    error           : integer:=0;
    variable    dma_complete    : integer:=0;
    
    --
    -- 
    type wb_cfg_slave_value is array (natural range<>) of std_logic_vector( 63 downto 0 );
    type wb_cfg_slave_data is record
        const   :   wb_cfg_slave_value(7 downto 0);
        cmd     :   wb_cfg_slave_value(7 downto 0);
        sts     :   wb_cfg_slave_value(7 downto 0);
    end record;
    --
    -- 
    variable    st_wb_cfg_slave_data_0  :   wb_cfg_slave_data;
    variable    st_wb_cfg_slave_data_1  :   wb_cfg_slave_data;
    variable    st_wb_cfg_slave_data_2  :   wb_cfg_slave_data;
    
    
begin
    -- Init Header
    write( str, string'("START TEST_WB#1: TEST_CHECK.WB_CFG_SLAVE"));
    writeline( log, str );
    --
    -- Read "TEST_CHECK.WB_CFG_SLAVE" 
    write( str, string'("1) Read 'TEST_CHECK.WB_CFG_SLAVE'"));
    writeline( log, str );
    adr     := x"20000000";
    
    TEST_CHECK_WB_CFG_SLAVE_RD_00   :   for i in 0 to 2 loop
        TEST_CHECK_WB_CFG_SLAVE_RD_01   :   for j in 0 to 7 loop
            -- PCIE RD
            data_read64(cmd, ret, adr, data64);
            -- Put RD_Value to apropriate holder
            if (i=0) then       -- const
                st_wb_cfg_slave_data_0.const(j) := data64;
            elsif (i=1) then    -- cmd
                st_wb_cfg_slave_data_0.cmd(j)   := data64;
            else                -- sts
                st_wb_cfg_slave_data_0.sts(j)   := data64;
            end if;
            -- Incr ADDR
            adr := adr + x"00000008";
            -- Print RD_Value
            hwrite( str, data64); write( str, string'(" ==> ADDR=")); hwrite( str, (adr - x"00000008"));
            writeline( log, str );
            
        end loop TEST_CHECK_WB_CFG_SLAVE_RD_01;
    end loop TEST_CHECK_WB_CFG_SLAVE_RD_00;
    
    --
    -- Write
    write( str, string'("2) Write 'TEST_CHECK.WB_CFG_SLAVE'"));
    writeline( log, str );
    adr     := x"20000000";
    
    TEST_CHECK_WB_CFG_SLAVE_WR_00   :   for i in 0 to 2 loop
        TEST_CHECK_WB_CFG_SLAVE_WR_01   :   for j in 0 to 7 loop
            -- Prepare WR_Value
            data64 := conv_std_logic_vector(i*100+j*10+5, 64);
            -- PCIE WR
            data_write64(cmd, ret, adr, data64);
            -- Put WR_Value to apropriate holder
            if (i=0) then       -- const
                st_wb_cfg_slave_data_1.const(j) := data64;
            elsif (i=1) then    -- cmd
                st_wb_cfg_slave_data_1.cmd(j)   := data64;
            else                -- sts
                st_wb_cfg_slave_data_1.sts(j)   := data64;
            end if;
            -- Incr ADDR
            adr := adr + x"00000008";
            -- Print WR_Value
            hwrite( str, data64); write( str, string'(" ==> ADDR=")); hwrite( str, (adr - x"00000008"));
            writeline( log, str );
            
        end loop TEST_CHECK_WB_CFG_SLAVE_WR_01;
    end loop TEST_CHECK_WB_CFG_SLAVE_WR_00;
    
    --
    -- Read
    write( str, string'("3) Read 'TEST_CHECK.WB_CFG_SLAVE'"));
    writeline( log, str );
    adr     := x"20000000";
    
    TEST_CHECK_WB_CFG_SLAVE_RD_10   :   for i in 0 to 2 loop
        TEST_CHECK_WB_CFG_SLAVE_RD_11   :   for j in 0 to 7 loop
            -- PCIE RD
            data_read64(cmd, ret, adr, data64);
            -- Put RD_Value to apropriate holder
            if (i=0) then       -- const
                st_wb_cfg_slave_data_2.const(j) := data64;
            elsif (i=1) then    -- cmd
                st_wb_cfg_slave_data_2.cmd(j)   := data64;
            else                -- sts
                st_wb_cfg_slave_data_2.sts(j)   := data64;
            end if;
            -- Incr ADDR
            adr := adr + x"00000008";
            -- Print RD_Value
            hwrite( str, data64); write( str, string'(" ==> ADDR=")); hwrite( str, (adr - x"00000008"));
            writeline( log, str );
            
        end loop TEST_CHECK_WB_CFG_SLAVE_RD_11;
    end loop TEST_CHECK_WB_CFG_SLAVE_RD_10;
    
    --
    -- Compare results
    write( str, string'("4) Process Results:"));
    writeline( log, str );
    --  cmp#0 - constants
    CMP_CONST   :   for i in 0 to 7 loop
        if (st_wb_cfg_slave_data_0.const(i) /= st_wb_cfg_slave_data_2.const(i) ) then   -- before WR and afetr WR must be EQU (RO)
            write( str, string'("   ==> CONST ERR, idx = ")); hwrite( str, CONV_STD_LOGIC_VECTOR(i, 8));
            writeline( log, str );
            error := error + 1;
        end if;
    end loop CMP_CONST;
    --  cmp#1 - commands
    CMP_CMD     :   for i in 0 to 7 loop
        if  ( st_wb_cfg_slave_data_1.cmd(i) /= st_wb_cfg_slave_data_2.cmd(i) ) then     -- WR value and RD value must be EQU (RW)
            write( str, string'("   ==> CMD ERR, idx = ")); hwrite( str, CONV_STD_LOGIC_VECTOR(i, 8));
            writeline( log, str );
            error := error + 1;
        end if;
    end loop CMP_CMD;
    --  cmp#2 - status
    CMP_STATUS  :   for i in 0 to 7 loop
        if (st_wb_cfg_slave_data_0.sts(i) /= st_wb_cfg_slave_data_2.sts(i) ) then       -- before WR and afetr WR must be EQU (RO)
            write( str, string'("   ==> STATUS ERR, idx = ")); hwrite( str, CONV_STD_LOGIC_VECTOR(i, 8));
            writeline( log, str );
            error := error + 1;
        end if;
    end loop CMP_STATUS;
    --  print OK
    if (error = 0) then
        write( str, string'("   Results==OK"));
        writeline( log, str );
        cnt_ok := cnt_ok + 1;
    else
        cnt_error := cnt_error + 1;
    end if;
    
    -- Final Header
    write( str, string'("STOP TEST_WB#1: TEST_CHECK.WB_CFG_SLAVE" ));
    writeline( log, str );  -- upd LOGFILE
    --
    -- END
end test_wb_1;
---------------------------------------------------------------------------------------------------
--
-- My procedure for test WB stuff in Design:
--  ==> TEST_GEN.WB_CFG_SLAVE
--
procedure test_wb_2 (
                            signal  cmd:    out bh_cmd; --! command
                            signal  ret:    in  bh_ret  --! answer
                    ) is
    
    variable    adr             : std_logic_vector( 31 downto 0 );
    variable    data32          : std_logic_vector( 31 downto 0 );
    variable    data64          : std_logic_vector( 63 downto 0 );
    variable    str             : line;
    
    variable    error           : integer:=0;
    variable    dma_complete    : integer:=0;
    
    --
    -- 
    type wb_cfg_slave_value is array (natural range<>) of std_logic_vector( 63 downto 0 );
    type wb_cfg_slave_data is record
        const   :   wb_cfg_slave_value(7 downto 0);
        cmd     :   wb_cfg_slave_value(7 downto 0);
        sts     :   wb_cfg_slave_value(7 downto 0);
    end record;
    --
    -- 
    variable    st_wb_cfg_slave_data_0  :   wb_cfg_slave_data;
    variable    st_wb_cfg_slave_data_1  :   wb_cfg_slave_data;
    variable    st_wb_cfg_slave_data_2  :   wb_cfg_slave_data;
    
    
begin
    -- Init Header
    write( str, string'("START TEST_WB#2: TEST_GEN.WB_CFG_SLAVE"));
    writeline( log, str );
    --
    -- Read "TEST_CHECK.WB_CFG_SLAVE" 
    write( str, string'("1) Read 'TEST_GEN.WB_CFG_SLAVE'"));
    writeline( log, str );
    adr     := x"20002000";
    
    TEST_CHECK_WB_CFG_SLAVE_RD_00   :   for i in 0 to 2 loop
        TEST_CHECK_WB_CFG_SLAVE_RD_01   :   for j in 0 to 7 loop
            -- PCIE RD
            data_read64(cmd, ret, adr, data64);
            -- Put RD_Value to apropriate holder
            if (i=0) then       -- const
                st_wb_cfg_slave_data_0.const(j) := data64;
            elsif (i=1) then    -- cmd
                st_wb_cfg_slave_data_0.cmd(j)   := data64;
            else                -- sts
                st_wb_cfg_slave_data_0.sts(j)   := data64;
            end if;
            -- Incr ADDR
            adr := adr + x"00000008";
            -- Print RD_Value
            hwrite( str, data64); write( str, string'(" ==> ADDR=")); hwrite( str, (adr - x"00000008"));
            writeline( log, str );
            
        end loop TEST_CHECK_WB_CFG_SLAVE_RD_01;
    end loop TEST_CHECK_WB_CFG_SLAVE_RD_00;
    
    --
    -- Write
    write( str, string'("2) Write 'TEST_GEN.WB_CFG_SLAVE'"));
    writeline( log, str );
    adr     := x"20002000";
    
    TEST_GEN_WB_CFG_SLAVE_WR_00   :   for i in 0 to 2 loop
        TEST_GEN_WB_CFG_SLAVE_WR_01   :   for j in 0 to 7 loop
            -- Prepare WR_Value
            data64 := conv_std_logic_vector(i*100+j*10+5, 64);
            -- PCIE WR
            data_write64(cmd, ret, adr, data64);
            -- Put WR_Value to apropriate holder
            if (i=0) then       -- const
                st_wb_cfg_slave_data_1.const(j) := data64;
            elsif (i=1) then    -- cmd
                st_wb_cfg_slave_data_1.cmd(j)   := data64;
            else                -- sts
                st_wb_cfg_slave_data_1.sts(j)   := data64;
            end if;
            -- Incr ADDR
            adr := adr + x"00000008";
            -- Print WR_Value
            hwrite( str, data64); write( str, string'(" ==> ADDR=")); hwrite( str, (adr - x"00000008"));
            writeline( log, str );
            
        end loop TEST_GEN_WB_CFG_SLAVE_WR_01;
    end loop TEST_GEN_WB_CFG_SLAVE_WR_00;
    
    --
    -- Read
    write( str, string'("3) Read 'TEST_GEN.WB_CFG_SLAVE'"));
    writeline( log, str );
    adr     := x"20002000";
    
    TEST_GEN_WB_CFG_SLAVE_RD_10   :   for i in 0 to 2 loop
        TEST_GEN_WB_CFG_SLAVE_RD_11   :   for j in 0 to 7 loop
            -- PCIE RD
            data_read64(cmd, ret, adr, data64);
            -- Put RD_Value to apropriate holder
            if (i=0) then       -- const
                st_wb_cfg_slave_data_2.const(j) := data64;
            elsif (i=1) then    -- cmd
                st_wb_cfg_slave_data_2.cmd(j)   := data64;
            else                -- sts
                st_wb_cfg_slave_data_2.sts(j)   := data64;
            end if;
            -- Incr ADDR
            adr := adr + x"00000008";
            -- Print RD_Value
            hwrite( str, data64); write( str, string'(" ==> ADDR=")); hwrite( str, (adr - x"00000008"));
            writeline( log, str );
            
        end loop TEST_GEN_WB_CFG_SLAVE_RD_11;
    end loop TEST_GEN_WB_CFG_SLAVE_RD_10;
    
    --
    -- Compare results
    write( str, string'("4) Process Results:"));
    writeline( log, str );
    --  cmp#0 - constants
    CMP_CONST   :   for i in 0 to 7 loop
        if (st_wb_cfg_slave_data_0.const(i) /= st_wb_cfg_slave_data_2.const(i) ) then   -- before WR and afetr WR must be EQU (RO)
            write( str, string'("   ==> CONST ERR, idx = ")); hwrite( str, CONV_STD_LOGIC_VECTOR(i, 8));
            writeline( log, str );
            error := error + 1;
        end if;
    end loop CMP_CONST;
    --  cmp#1 - commands
    CMP_CMD     :   for i in 0 to 7 loop
        if  ( st_wb_cfg_slave_data_1.cmd(i) /= st_wb_cfg_slave_data_2.cmd(i) ) then     -- WR value and RD value must be EQU (RW)
            write( str, string'("   ==> CMD ERR, idx = ")); hwrite( str, CONV_STD_LOGIC_VECTOR(i, 8));
            writeline( log, str );
            error := error + 1;
        end if;
    end loop CMP_CMD;
    --  cmp#2 - status
    CMP_STATUS  :   for i in 0 to 7 loop
        if (st_wb_cfg_slave_data_0.sts(i) /= st_wb_cfg_slave_data_2.sts(i) ) then       -- before WR and afetr WR must be EQU (RO)
            write( str, string'("   ==> STATUS ERR, idx = ")); hwrite( str, CONV_STD_LOGIC_VECTOR(i, 8));
            writeline( log, str );
            error := error + 1;
        end if;
    end loop CMP_STATUS;
    --  print OK
    if (error = 0) then
        write( str, string'("   Results==OK"));
        writeline( log, str );
        cnt_ok := cnt_ok + 1;
    else
        cnt_error := cnt_error + 1;
    end if;
    
    -- Final Header
    write( str, string'("STOP TEST_WB#2: TEST_GEN.WB_CFG_SLAVE" ));
    writeline( log, str );  -- upd LOGFILE
    --
    -- END
end test_wb_2;
---------------------------------------------------------------------------------------------------
end package	body test_pkg;
