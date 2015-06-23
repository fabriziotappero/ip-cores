-------------------------------------------------------------------------------
--
-- (c) Copyright 2009-2011 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
-------------------------------------------------------------------------------
-- Project    : Virtex-6 Integrated Block for PCI Express
-- File       : pci_exp_usrapp_tx_m2.vhd
-- Version    : 2.3
-- Filename: pci_exp_usrapp_tx_m2.vhd
--
-- Description:  PCI Express dsport Tx interface.
--
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library work;
use work.cmd_sim_pkg.all;

package pci_exp_usrapp_tx_m2_pkg is

component pci_exp_usrapp_tx_m2 is

port (

  trn_td                   : out std_logic_vector (63 downto 0 );
  trn_trem_n               : out std_logic_vector (7 downto 0 );
  trn_tsof_n               : out std_logic;
  trn_teof_n               : out std_logic;
  trn_terrfwd_n	           : out std_logic;
  trn_tsrc_rdy_n           : out std_logic;
  trn_tsrc_dsc_n           : out std_logic;
  trn_clk                  : in std_logic;
  trn_reset_n              : in std_logic;
  trn_lnk_up_n             : in std_logic;
  trn_tdst_rdy_n           : in std_logic;
  trn_tdst_dsc_n           : in std_logic;
  trn_tbuf_av              : in std_logic_vector (5 downto 0);
  speed_change_done_n      : in std_logic;
  rx_tx_read_data          : in std_logic_vector(31 downto 0);
  rx_tx_read_data_valid    : in std_logic;
  tx_rx_read_data_valid    : out std_logic;
  
		---- Test ----
  cmd					   : in  bh_cmd; 	-- команда
  ret					   : out bh_ret 	-- ответ  

);

end component;

end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;

library work;
use work.cmd_sim_pkg.all;		  
use work.test_interface.all;	  
use work.root_memory_pkg.all;


entity pci_exp_usrapp_tx_m2 is

port (

  trn_td                   : out std_logic_vector (63 downto 0 );
  trn_trem_n               : out std_logic_vector (7 downto 0 );
  trn_tsof_n               : out std_logic;
  trn_teof_n               : out std_logic;
  trn_terrfwd_n	           : out std_logic;
  trn_tsrc_rdy_n           : out std_logic;
  trn_tsrc_dsc_n           : out std_logic;
  trn_clk                  : in std_logic;
  trn_reset_n              : in std_logic;
  trn_lnk_up_n             : in std_logic;
  trn_tdst_rdy_n           : in std_logic;
  trn_tdst_dsc_n           : in std_logic;
  trn_tbuf_av              : in std_logic_vector (5 downto 0);
  speed_change_done_n      : in std_logic;
  rx_tx_read_data          : in std_logic_vector(31 downto 0);
  rx_tx_read_data_valid    : in std_logic;
  tx_rx_read_data_valid    : out std_logic;
  
		---- Test ----
  cmd					   : in  bh_cmd; 	-- команда
  ret					   : out bh_ret 	-- ответ  

);

end pci_exp_usrapp_tx_m2;

architecture rtl of pci_exp_usrapp_tx_m2 is




begin

	   

trn_td <= trn_td_c;
trn_trem_n <= trn_trem_n_c;
  
pr_main: process 									 

variable vret: bh_ret:=(0, (others=>(others=>'0')) );

variable	byte_count		: std_logic_vector( 11 downto 0 );
variable	adr				: integer;
variable	data			: std_logic_vector( 31 downto 0 );

variable 	mem64r			: type_memory_request_item;
variable	mem64r_ready	: integer;
variable	size			: integer;			   
variable	completion_cnt	: integer;	
variable	completion_size	: integer;	   
variable	completion_adr	: std_logic_vector( 6 downto 0 );
variable	index			: integer;

variable	flag_pass		: integer:=0;

begin
	
      pio_check_design := true; -- By default check to make sure that the core has been configured
                                                -- appropriately for the PIO Design (see user guide for details)
      NUMBER_OF_IO_BARS := 0;
      NUMBER_OF_MEM32_BARS := 0;
      NUMBER_OF_MEM64_BARS :=0;

      frame_store_tx_idx := 0;
      success := true;

      trn_tsof_n <= '1';
      trn_teof_n <= '1';
      trn_terrfwd_n <= '1';
      trn_tsrc_rdy_n <= '1';
      trn_tsrc_dsc_n <= '1';
      trn_td_c <= (others => '0');
      tx_rx_read_data_valid <= '0';
	  
	
	wait for 1 us;
	
      writeNowToScreen(String'("Init start"));

      PROC_SYSTEM_INITIALIZATION(trn_reset_n, trn_lnk_up_n, speed_change_done_n);

      PROC_BAR_INIT (tx_rx_read_data_valid, rx_tx_read_data_valid, rx_tx_read_data, trn_td_c,
        trn_tsof_n, trn_teof_n, trn_trem_n_c, trn_tsrc_rdy_n, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);
		
      PROC_TX_CLK_EAT(300, trn_clk);
	  
	  writeNowToScreen(String'("BUS Master Enable "));		
	  
      PROC_READ_CFG_DW(conv_std_logic_vector(1, 10), cfg_rdwr_int);
      PROC_WRITE_CFG_DW(conv_std_logic_vector(1, 10), x"00000007", "1110", cfg_rdwr_int);
      PROC_READ_CFG_DW(conv_std_logic_vector(1, 10), cfg_rdwr_int);	
	
	  wait for 5 us;
	
	
      writeNowToScreen(String'("Init complete"));

	  loop
		  
		wait for 10 ns;
		
--		wait until cmd'event or mem64r_request'event;
--		loop
--			if( cmd'event and cmd.cmd/=0 ) then
--				exit;
--			end if;

			memory_request_read( mem64r_ready, mem64r );

			if( mem64r_ready=1 ) then
				
				adr:=conv_integer( mem64r.adr_low( 31 downto 0 ) );
				size:=mem64r.size;
				
				-- определение числа ответов 
				completion_cnt := size/memory_request_completion_size;
				
				completion_adr:=(others=>'0');
				
				flag_pass:=0;
				
				for cpl_ii in 0 to completion_cnt-1 loop
					if( size>memory_request_completion_size ) then
						completion_size:=memory_request_completion_size;
					else
						completion_size:=size;
					end if;

					if( adr>=16#100000# and adr<=16#10FFFF# ) then
						index:=adr-16#100000#;
						index:=index/4;
						for ii in 0 to completion_size loop
							data:=conv_std_logic_vector( root_mem_0x10(index+ii), 32 );
							DATA_STORE(ii*4+0)	:= data( 7 downto 0 );
							DATA_STORE(ii*4+1)	:= data( 15 downto 8 );
							DATA_STORE(ii*4+2)	:= data( 23 downto 16 );
							DATA_STORE(ii*4+3)	:= data( 31 downto 24 );
						end loop;
						
--						if( now>200 us and now<260 us and adr=16#00100080# ) then
--							flag_pass:=1;
--						end if;
							
						
					elsif( adr>=16#800000# and adr<=16#80FFFF# ) then
						index:=adr-16#800000#;
						index:=index/4;
						for ii in 0 to completion_size loop
							data:=conv_std_logic_vector( root_mem_0x80(index+ii), 32 );
							DATA_STORE(ii*4+0)	:= data( 7 downto 0 );
							DATA_STORE(ii*4+1)	:= data( 15 downto 8 );
							DATA_STORE(ii*4+2)	:= data( 23 downto 16 );
							DATA_STORE(ii*4+3)	:= data( 31 downto 24 );
						end loop;	
						
--						if( now>300 us and now<360 us  ) then
--							flag_pass:=1;
--						end if;
						
					else
						for ii in 0 to completion_size loop
							DATA_STORE(ii*4+0):=x"FF";
							DATA_STORE(ii*4+1):=x"FF";
							DATA_STORE(ii*4+2):=x"FF";
							DATA_STORE(ii*4+3):=x"FF";
						end loop;
						
					end if;		
					
					
					
					--DATA_STORE(0):=x"AA";
					
					
					
					byte_count( 11 downto 2 ) := conv_std_logic_vector( completion_size, 10 );
					byte_count( 1 downto 0 )  := "00";
					
					if( flag_pass=0 ) then
						
					 PROC_TX_COMPLETION_DATA (
					
						mem64r.tag,	--tag                      : in std_logic_vector (7 downto 0);
						"000",	--tc                       : in std_logic_vector (2 downto 0);
						byte_count( 11 downto 2 ),	--len                      : in std_logic_vector (9 downto 0);
						byte_count,					--byte_count               : in std_logic_vector (11 downto 0);
						completion_adr,				--lower_addr               : in std_logic_vector (6 downto 0);
						"000",	--comp_status              : in std_logic_vector (2 downto 0);
						'0',	--ep                       : in std_logic;
						trn_td_c, trn_tsof_n, trn_teof_n , trn_trem_n_c, trn_tsrc_rdy_n, trn_terrfwd_n, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk
					  );	
					end if;
					
					completion_adr := completion_adr + completion_size*4;
					size:= size - completion_size;			   
					adr:=adr+completion_size*4;		 
					
					
				end loop;
			end if;
			
			
			
		if( cmd.cmd/=0 ) then
		
			case( cmd.cmd ) is
				when 1 => -- data_read --
				
		            PROC_TX_MEMORY_READ_32 (
		              X"03", "000", "0000000001", cmd.adr(0), X"0", X"F",
		              trn_td_c, trn_tsof_n, trn_teof_n , trn_trem_n_c, trn_tsrc_rdy_n, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);
					  
		            PROC_WAIT_FOR_READ_DATA (tx_rx_read_data_valid, rx_tx_read_data_valid, rx_tx_read_data, trn_clk);
		
					  vret.data(0)(  31 downto 0 )  := P_READ_DATA;
					  
					  vret.ret:=1; 
					  
						wait for 1 ns;
						ret<=vret;
						wait until cmd'event and cmd.cmd=0;
						vret.ret:=0;
						ret<=vret;		  
					  
				
				when 2 => -- data_write --
				
				
		            DATA_STORE(3) := cmd.data(0)( 31 downto 24 );
		            DATA_STORE(2) := cmd.data(0)( 23 downto 16 );
		            DATA_STORE(1) := cmd.data(0)( 15 downto 8 );
		            DATA_STORE(0) := cmd.data(0)( 7 downto 0 );
					
					
		            PROC_TX_MEMORY_WRITE_32 (
					  X"02", "000", "0000000001", cmd.adr(0), X"0", X"F",'0',
					
		              trn_td_c, trn_tsof_n, trn_teof_n , trn_trem_n_c, trn_tsrc_rdy_n, trn_terrfwd_n,
		              trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);			
					  
					  vret.ret:=1;	 
					  
						wait for 1 ns;
						ret<=vret;
						wait until cmd'event and cmd.cmd=0;
						vret.ret:=0;
						ret<=vret;		  
					  
				  
				when 20 => -- int_mem_write --
					adr:=conv_integer( cmd.adr(0)( 31 downto 0 ) );
					if( adr>=16#100000# and adr<=16#10FFFF# ) then
						index:=adr-16#100000#;
						index:=index/4;
						root_mem_0x10(index):= conv_integer( cmd.data(0)(31 downto 0) );
					elsif( adr>=16#800000# and adr<=16#80FFFF# ) then
						index:=adr-16#800000#;
						index:=index/4;
						root_mem_0x80(index):= conv_integer( cmd.data(0)(31 downto 0) );
					end if;		
					vret.ret:=1;  
					
					wait for 1 ns;
					ret<=vret;
					wait until cmd'event and cmd.cmd=0;
					vret.ret:=0;
					ret<=vret;		  
					
				
				when 21 => -- int_mem_read --
				
					data:=x"FFFFFFFF";				
					adr:=conv_integer( cmd.adr(0)( 31 downto 0 ) );
					if( adr>=16#100000# and adr<=16#10FFFF# ) then
						index:=adr-16#100000#;
						index:=index/4;
						data:=conv_std_logic_vector( root_mem_0x10(index), 32 );
					elsif( adr>=16#800000# and adr<=16#80FFFF# ) then
						index:=adr-16#800000#;
						index:=index/4;
						data:=conv_std_logic_vector( root_mem_0x80(index), 32 );
					end if;		
					vret.ret:=1;	  
					vret.data(0)(  31 downto 0 ):=data;
					
					wait for 1 ns;
					ret<=vret;
					wait until cmd'event and cmd.cmd=0;
					vret.ret:=0;
					ret<=vret;		  
					
				when others=>
					null;
				
			end case;
		

	  end if;
		  
	  end loop;
	  
	  wait;
	  
	  
	
	
end process;	


end; -- pci_exp_usrapp_tx_m2
