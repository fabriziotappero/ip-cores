---------------------------------------------------------------------------------------------------
--
-- Title       : wb_block_pkg.vhd
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems 
-- E-mail      : dsmv@insys.ru 
--	
-- Version	   : 1.0
---------------------------------------------------------------------------------------------------
--
-- Description : Набор функций для доступа к блокам управления на шине WISHBONE 
--
---------------------------------------------------------------------------------------------------
--					
--  Version 1.0  01.11.2011
--				  Создан из trd_pkg.vhd v1.0
--
---------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;		
use ieee.std_logic_arith.all;  
use ieee.std_logic_textio.all;
use ieee.std_logic_unsigned.all;

library work;
use work.cmd_sim_pkg.all;

use std.textio.all;
use std.textio;

---------------------------------------------------------------------------------------------------
package wb_block_pkg is
	
--
-- Define TEST_CHECK reg id (addr in 64b cells)
--		
constant REG_BLOCK_ID			: integer:=0;
constant REG_BLOCK_VER			: integer:=1;

constant REG_TEST_CHECK_CTRL		: integer:=8;
constant REG_TEST_CHECK_SIZE		: integer:=9;
constant REG_TEST_CHECK_ERR_ADR		: integer:=16#0A#;
constant REG_TEST_CHECK_WBS_BURST_CTRL  : integer:=16#0B#;

constant REG_TEST_CHECK_BL_RD		: integer:=16#10#;
constant REG_TEST_CHECK_BL_OK		: integer:=16#11#;
constant REG_TEST_CHECK_BL_ERROR	: integer:=16#12#;
constant REG_TEST_CHECK_TOTAL_ERROR	: integer:=16#13#;
constant REG_TEST_CHECK_ERR_DATA	: integer:=16#14#;
--
-- Define TEST_GEN reg id (addr in 64b cells)
--
constant REG_TEST_GEN_CTRL		: integer:=8;
constant REG_TEST_GEN_SIZE		: integer:=9;
constant REG_TEST_GEN_CNT1		: integer:=16#0A#;
constant REG_TEST_GEN_CNT2		: integer:=16#0B#;
constant REG_TEST_GEN_STATUS	: integer:=16#10#;
constant REG_TEST_GEN_BL_WR		: integer:=16#11#;
--
-- Define SoPC ADDR (must be EQU to: ...\src\top\sp605_lx45t_wishbone_sopc_wb.vhd)
--
constant TEST_CHECK_WB_CFG_SLAVE   : std_logic_vector( 31 downto 0) := x"20000000";
constant TEST_CHECK_WB_BURST_SLAVE : std_logic_vector( 31 downto 0) := x"20001000"; -- check data: write-only
constant TEST_GEN_WB_CFG_SLAVE     : std_logic_vector( 31 downto 0) := x"20002000";
constant TEST_GEN_WB_BURST_SLAVE   : std_logic_vector( 31 downto 0) := x"20003000"; -- generate data: read-only
	
---- Write to wishbone ----		
procedure wb_write (
		signal  cmd:	out bh_cmd; -- команда 
		signal  ret:	in  bh_ret; -- ответ 
		adr:			in integer; -- номер регистра
		data:			in std_logic_vector( 31 downto 0 ) -- данные
		);
	
---- Read from wishbone ----		
procedure wb_read (
		signal  cmd:	out bh_cmd; -- команда для ADSP
		signal  ret:	in  bh_ret; -- ответ ADSP
		adr:			in integer; -- номер регистра
		data:			out std_logic_vector( 31 downto 0 ) -- данные
		);	
		
---- Запись в регистр блока TEST_CHECK.WB_CFG_SLAVE  ----		
procedure wb_block_check_write (
		signal  cmd:	out bh_cmd; -- команда 
		signal  ret:	in  bh_ret; -- ответ 
		reg:			in integer; -- номер регистра
		data:			in std_logic_vector( 31 downto 0 ) -- данные
		);

		
---- Чтение из регистра блока TEST_CHECK.WB_CFG_SLAVE ----		
procedure wb_block_check_read (
		signal  cmd:	out bh_cmd; -- команда для ADSP
		signal  ret:	in  bh_ret; -- ответ ADSP
		reg:			in integer; -- номер регистра
		data:			out std_logic_vector( 31 downto 0 ) -- данные
		);	

---- Запись в регистр блока TEST_GEN.WB_CFG_SLAVE  ----		
procedure wb_block_gen_write (
		signal  cmd:	out bh_cmd; -- команда 
		signal  ret:	in  bh_ret; -- ответ 
		reg:			in integer; -- номер регистра
		data:			in std_logic_vector( 31 downto 0 ) -- данные
		);

		
---- Чтение из регистра блока TEST_GEN.WB_CFG_SLAVE ----		
procedure wb_block_gen_read (
		signal  cmd:	out bh_cmd; -- команда для ADSP
		signal  ret:	in  bh_ret; -- ответ ADSP
		reg:			in integer; -- номер регистра
		data:			out std_logic_vector( 31 downto 0 ) -- данные
		);	
		
		
-- Construct value for REG_TEST_CHECK_WBS_BURST_CTRL
function wb_block_check_burst_ctrl_build (i_ena : in std_logic; ii_ack_dly : in integer; ii_dly_pos : in integer) return std_logic_vector;

end package	wb_block_pkg;
---------------------------------------------------------------------------------------------------
package body wb_block_pkg is
	
	
---- Write to wishbone ----		
procedure wb_write (
		signal  cmd:	out bh_cmd; -- команда 
		signal  ret:	in  bh_ret; -- ответ 
		adr:			in integer; -- номер регистра
		data:			in std_logic_vector( 31 downto 0 ) -- данные
		) is 
begin										
	data_write( cmd, ret, TEST_CHECK_WB_CFG_SLAVE+conv_std_logic_vector(adr, 32), data ); 
end;		
	
---- Read from wishbone ----		
procedure wb_read (
		signal  cmd:	out bh_cmd; -- команда для ADSP
		signal  ret:	in  bh_ret; -- ответ ADSP
		adr:			in integer; -- номер регистра
		data:			out std_logic_vector( 31 downto 0 ) -- данные
		) is 
begin										
	data_read( cmd, ret, TEST_CHECK_WB_CFG_SLAVE+conv_std_logic_vector(adr, 32), data ); 
end;		

---- Запись в регистр блока TEST_CHECK.WB_CFG_SLAVE  ----		
procedure wb_block_check_write (
		signal  cmd:	out bh_cmd; -- команда 
		signal  ret:	in  bh_ret; -- ответ 
		reg:			in integer; -- номер регистра
		data:			in std_logic_vector( 31 downto 0 ) -- данные
		) is 
begin										
	data_write( cmd, ret, TEST_CHECK_WB_CFG_SLAVE+conv_std_logic_vector(reg*8+0, 32), data ); 
end;

		
---- Чтение из регистра блока TEST_CHECK ----		
procedure wb_block_check_read (
		signal  cmd:	out bh_cmd; -- команда для ADSP
		signal  ret:	in  bh_ret; -- ответ ADSP
		reg:			in integer; -- номер регистра
		data:			out std_logic_vector( 31 downto 0 ) -- данные
		) is 
begin										
	data_read( cmd, ret, TEST_CHECK_WB_CFG_SLAVE+conv_std_logic_vector(reg*8+0, 32), data ); 
end;	

---- Запись в регистр блока TEST_GEN.WB_CFG_SLAVE  ----		
procedure wb_block_gen_write (
		signal  cmd:	out bh_cmd; -- команда 
		signal  ret:	in  bh_ret; -- ответ 
		reg:			in integer; -- номер регистра
		data:			in std_logic_vector( 31 downto 0 ) -- данные
		) is 
begin										
	data_write( cmd, ret, TEST_GEN_WB_CFG_SLAVE+conv_std_logic_vector(reg*8+0, 32), data ); 
end;

		
---- Чтение из регистра блока TEST_GEN.WB_CFG_SLAVE ----		
procedure wb_block_gen_read (
		signal  cmd:	out bh_cmd; -- команда для ADSP
		signal  ret:	in  bh_ret; -- ответ ADSP
		reg:			in integer; -- номер регистра
		data:			out std_logic_vector( 31 downto 0 ) -- данные
		) is 
begin										
	data_read( cmd, ret, TEST_GEN_WB_CFG_SLAVE+conv_std_logic_vector(reg*8+0, 32), data ); 
end;		
	

-- Construct value for REG_TEST_CHECK_WBS_BURST_CTRL
function wb_block_check_burst_ctrl_build (i_ena : in std_logic; ii_ack_dly : in integer; ii_dly_pos : in integer) return std_logic_vector is
variable iv_ret : std_logic_vector(31 downto 0):=(others => '0');
begin
 iv_ret:= x"0000" & i_ena & conv_std_logic_vector( ii_ack_dly, 6) & conv_std_logic_vector( ii_dly_pos, 9);
 return iv_ret;
end wb_block_check_burst_ctrl_build;


end package	body wb_block_pkg;

