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
-- Create Date:   10:19:29 09/28/2006
-- Design Name:   usb2mem
-- Module Name:   C:/projects/USB_dongle/beh/usb_mem_test.vhd
-- Project Name:  simulation
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: usb2mem
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

ENTITY usb_mem_test_vhd IS
END usb_mem_test_vhd;

ARCHITECTURE behavior OF usb_mem_test_vhd IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT usb2mem
	PORT(
		clk25 : IN std_logic;
		reset_n : IN std_logic;
		mem_di : IN std_logic_vector(15 downto 0);
		mem_ack : IN std_logic;
		usb_txe_n : IN std_logic;
		usb_rxf_n : IN std_logic;    
		usb_bd : INOUT std_logic_vector(7 downto 0);      
		mem_addr : OUT std_logic_vector(23 downto 0);
		mem_do : OUT std_logic_vector(15 downto 0);
		mem_wr : OUT std_logic;
		mem_val : OUT std_logic;
		mem_cmd : OUT std_logic;
		usb_rd_n : OUT std_logic;
		usb_wr : OUT std_logic
		);
	END COMPONENT;

	--Inputs
	SIGNAL clk25 :  std_logic := '0';
	SIGNAL reset_n :  std_logic := '0';
	SIGNAL mem_ack :  std_logic := '0';
	SIGNAL usb_txe_n :  std_logic := '0';
	SIGNAL usb_rxf_n :  std_logic := '1';
	SIGNAL mem_di :  std_logic_vector(15 downto 0) := x"3210";

	--BiDirs
	SIGNAL usb_bd :  std_logic_vector(7 downto 0);

	--Outputs
	SIGNAL mem_addr :  std_logic_vector(23 downto 0);
	SIGNAL mem_do :  std_logic_vector(15 downto 0);
	SIGNAL mem_wr :  std_logic;
	SIGNAL mem_val :  std_logic;
	SIGNAL mem_cmd :  std_logic;
	SIGNAL usb_rd_n :  std_logic;
	SIGNAL usb_wr :  std_logic;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: usb2mem PORT MAP(
		clk25 => clk25,
		reset_n => reset_n,
		mem_addr => mem_addr,
		mem_do => mem_do,
		mem_di => mem_di,
		mem_wr => mem_wr,
		mem_val => mem_val,
		mem_ack => mem_ack,
		mem_cmd => mem_cmd,
		usb_rd_n => usb_rd_n,
		usb_wr => usb_wr,
		usb_txe_n => usb_txe_n,
		usb_rxf_n => usb_rxf_n,
		usb_bd => usb_bd
	);

  clocker : process is
  begin
    wait for 20 ns;
    clk25 <=not (clk25);
  end process clocker;


 VCI_ACK : process is
  begin
    wait until mem_val='1';
	 wait for 100 ns;
	 mem_ack <='1';
	 wait until mem_val='0';
	 mem_ack <='0';
  end process VCI_ACK;


	tb : PROCESS
	BEGIN

		-- Wait 100 ns for global reset to finish
		wait for 100 ns;
		reset_n <='1';
		
		-- STATUS CHECK COMMAND
		usb_rxf_n <='0';
		usb_bd <=x"C5";
		wait until usb_rd_n='0'; --wait to go low --first read
		wait until usb_rd_n='1'; --wait to go low
		wait until usb_rd_n='0'; --wait to go low --second read
		wait until usb_rd_n='1'; --wait to go low
		usb_bd <=(others=>'Z');
		usb_rxf_n <='1';
		-- END STATUS CHECK COMMAND 
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
