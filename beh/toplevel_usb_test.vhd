------------------------------------------------------------------
-- Universal dongle board source code
-- 
-- Copyright (C) 2006 Artec Design <jyrit@artecdesign.ee>
-- 
-- This source code is free hardware; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
-- 
-- This source code is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
-- 
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
-- 
-- 
-- The complete text of the GNU Lesser General Public License can be found in 
-- the file 'lesser.txt'.
--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:17:32 09/28/2006
-- Design Name:   design_top
-- Module Name:   C:/projects/USB_dongle/beh/toplevel_usb_test.vhd
-- Project Name:  simulation
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: design_top
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

ENTITY toplevel_usb_test_vhd IS
END toplevel_usb_test_vhd;

ARCHITECTURE behavior OF toplevel_usb_test_vhd IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT design_top
	PORT(
		sys_clk : IN std_logic;
		resetn : IN std_logic;
		hdr : OUT std_logic_vector(10 downto 0);
		alt_clk : IN std_logic;
		mode : IN std_logic_vector(1 downto 0);
		lreset_n : IN std_logic;
		lclk : IN std_logic;
		fl_sts : IN std_logic;
		usb_txe_n : IN std_logic;
		usb_rxf_n : IN std_logic;    
		lad : INOUT std_logic_vector(3 downto 0);
		lframe_n : INOUT std_logic;
		fl_data : INOUT std_logic_vector(15 downto 0);
		usb_bd : INOUT std_logic_vector(7 downto 0);      
		seg_out : OUT std_logic_vector(7 downto 0);
		scn_seg : OUT std_logic_vector(3 downto 0);
		led_green : OUT std_logic;
		led_red : OUT std_logic;
		fl_addr : OUT std_logic_vector(23 downto 0);
		fl_ce_n : OUT std_logic;
		fl_oe_n : OUT std_logic;
		fl_we_n : OUT std_logic;
		fl_rp_n : OUT std_logic;
		usb_rd_n : OUT std_logic;
		usb_wr : OUT std_logic
		);
	END COMPONENT;

	--Inputs
	SIGNAL sys_clk :  std_logic := '0';
	SIGNAL resetn :  std_logic := '0';
	SIGNAL alt_clk :  std_logic := '0';
	SIGNAL lreset_n :  std_logic := '0';
	SIGNAL lclk :  std_logic := '0';
	SIGNAL fl_sts :  std_logic := '0';
	SIGNAL usb_txe_n :  std_logic := '0';
	SIGNAL usb_rxf_n :  std_logic := '0';
	SIGNAL hdr :  std_logic_vector(10 downto 0);
	SIGNAL mode :  std_logic_vector(1 downto 0) := (others=>'0');

	--BiDirs
	SIGNAL lad :  std_logic_vector(3 downto 0);
	SIGNAL lframe_n :  std_logic;
	SIGNAL fl_data :  std_logic_vector(15 downto 0);
	SIGNAL usb_bd :  std_logic_vector(7 downto 0);

	--Outputs
	SIGNAL seg_out :  std_logic_vector(7 downto 0);
	SIGNAL scn_seg :  std_logic_vector(3 downto 0);
	SIGNAL led_green :  std_logic;
	SIGNAL led_red :  std_logic;
	SIGNAL fl_addr :  std_logic_vector(23 downto 0);
	SIGNAL fl_ce_n :  std_logic;
	SIGNAL fl_oe_n :  std_logic;
	SIGNAL fl_we_n :  std_logic;
	SIGNAL fl_rp_n :  std_logic;
	SIGNAL usb_rd_n :  std_logic;
	SIGNAL usb_wr :  std_logic;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: design_top PORT MAP(
		sys_clk => sys_clk,
		resetn => resetn,
		hdr => hdr,
		alt_clk => alt_clk,
		mode => mode,
		lad => lad,
		lframe_n => lframe_n,
		lreset_n => lreset_n,
		lclk => lclk,
		seg_out => seg_out,
		scn_seg => scn_seg,
		led_green => led_green,
		led_red => led_red,
		fl_addr => fl_addr,
		fl_ce_n => fl_ce_n,
		fl_oe_n => fl_oe_n,
		fl_we_n => fl_we_n,
		fl_data => fl_data,
		fl_rp_n => fl_rp_n,
		fl_sts => fl_sts,
		usb_rd_n => usb_rd_n,
		usb_wr => usb_wr,
		usb_txe_n => usb_txe_n,
		usb_rxf_n => usb_rxf_n,
		usb_bd => usb_bd
	);

 clocker : process is
  begin
    wait for 17 ns;
    lclk <=not (lclk);
  end process clocker;
  
  clocker2 : process is
  begin
    wait for 20 ns;
    sys_clk <=not (sys_clk);
  end process clocker2;


	tb : PROCESS
	BEGIN

		-- Wait 100 ns for global reset to finish
		wait for 100 ns;
		resetn <='1';
		lreset_n <='1';
		-- Status check COMMAND
		usb_rxf_n <='0';
		usb_bd <=x"00";
		wait until usb_rd_n='0'; --wait to go low --first read
		wait until usb_rd_n='1'; --wait to go low
		wait for 20 ns;
		usb_bd <=x"C5";
		wait until usb_rd_n='0'; --wait to go low --second read
		wait until usb_rd_n='1'; --wait to go low
		usb_bd <=(others=>'Z');
		usb_rxf_n <='1';
		-- END A1 COMMAND 
		wait for 800 ns;		

		-- A0 COMMAND
		usb_rxf_n <='0';
		usb_bd <=x"02";
		wait until usb_rd_n='0'; --wait to go low --first read
		wait until usb_rd_n='1'; --wait to go low
		wait for 20 ns;
		usb_bd <=x"A0";
		wait until usb_rd_n='0'; --wait to go low --second read
		wait until usb_rd_n='1'; --wait to go low
		usb_bd <=(others=>'Z');
		usb_rxf_n <='1';
		-- END A0 COMMAND 
		wait for 800 ns;		

		-- A1 COMMAND
		usb_rxf_n <='0';
		usb_bd <=x"00";
		wait until usb_rd_n='0'; --wait to go low --first read
		wait until usb_rd_n='1'; --wait to go low
		wait for 20 ns;
		usb_bd <=x"A1";
		wait until usb_rd_n='0'; --wait to go low --second read
		wait until usb_rd_n='1'; --wait to go low
		usb_bd <=(others=>'Z');
		usb_rxf_n <='1';
		-- END A1 COMMAND 
		wait for 800 ns;		

		-- A2 COMMAND
		usb_rxf_n <='0';
		usb_bd <=x"00";
		wait until usb_rd_n='0'; --wait to go low --first read
		wait until usb_rd_n='1'; --wait to go low
		wait for 20 ns;
		usb_bd <=x"A2";
		wait until usb_rd_n='0'; --wait to go low --second read
		wait until usb_rd_n='1'; --wait to go low
		usb_bd <=(others=>'Z');
		usb_rxf_n <='1';
		-- END A2 COMMAND 
		wait for 800 ns;				

		-- 98 COMMAND
		usb_rxf_n <='0';
		usb_bd <=x"00";
		wait until usb_rd_n='0'; --wait to go low --first read
		wait until usb_rd_n='1'; --wait to go low
		wait for 20 ns;
		usb_bd <=x"98";
		wait until usb_rd_n='0'; --wait to go low --second read
		wait until usb_rd_n='1'; --wait to go low
		usb_bd <=(others=>'Z');
		usb_rxf_n <='1';
		-- END A2 COMMAND 
		wait for 800 ns;				
		
		-- CD COMMAND
		usb_rxf_n <='0';
		usb_bd <=x"01";
		wait until usb_rd_n='0'; --wait to go low --first read
		wait until usb_rd_n='1'; --wait to go low
		wait for 20 ns;
		usb_bd <=x"CD";
		wait until usb_rd_n='0'; --wait to go low --second read
		wait until usb_rd_n='1'; --wait to go low
		usb_bd <=(others=>'Z');
		usb_rxf_n <='1';
		-- END CD COMMAND 
		wait for 800 ns;				

		-- E8 COMMAND
		usb_rxf_n <='0';
		usb_bd <=x"01";  --this should mean 2 word to write
		wait until usb_rd_n='0'; --wait to go low --first read
		wait until usb_rd_n='1'; --wait to go low
		wait for 20 ns;
		usb_bd <=x"E8";
		wait until usb_rd_n='0'; --wait to go low --second read
		wait until usb_rd_n='1'; --wait to go low
		usb_bd <=(others=>'Z');
		usb_rxf_n <='1';
		-- END E8 COMMAND 
		wait for 2000 ns;		
		
		-- SEND Data count to flash COMMAND
		usb_rxf_n <='0';
		usb_bd <=x"01";  --this should mean 2 word to write
		wait until usb_rd_n='0'; --wait to go low --first read
		wait until usb_rd_n='1'; --wait to go low
		wait for 20 ns;
		usb_bd <=x"00";  --count 00 means 1 word
		wait until usb_rd_n='0'; --wait to go low --second read
		wait until usb_rd_n='1'; --wait to go low
		usb_bd <=(others=>'Z');
		usb_rxf_n <='1';
		-- END COMMAND 
		wait for 800 ns;		

		-- SEND raw Data
		usb_rxf_n <='0';
		usb_bd <=x"CA";  --this should mean 1 word to write
		wait until usb_rd_n='0'; --wait to go low --first read
		wait until usb_rd_n='1'; --wait to go low
		wait for 20 ns;
		usb_bd <=x"FE";  --count 00 means 1 word
		wait until usb_rd_n='0'; --wait to go low --second read
		wait until usb_rd_n='1'; --wait to go low
		usb_bd <=(others=>'Z');
		usb_rxf_n <='1';
		-- END send data
		wait for 800 ns;				
		
		-- SEND raw Data
		usb_rxf_n <='0';
		usb_bd <=x"BE";  --this should mean 1 word to write
		wait until usb_rd_n='0'; --wait to go low --first read
		wait until usb_rd_n='1'; --wait to go low
		wait for 20 ns;
		usb_bd <=x"CD";  --count 00 means 1 word
		wait until usb_rd_n='0'; --wait to go low --second read
		wait until usb_rd_n='1'; --wait to go low
		usb_bd <=(others=>'Z');
		usb_rxf_n <='1';
		-- END send data
		wait for 800 ns;			
	
		wait; -- will wait forever
	END PROCESS;

END;
