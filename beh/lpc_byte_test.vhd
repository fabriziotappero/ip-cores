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
-- Create Date:   17:35:11 10/09/2006
-- Design Name:   lpc_iow
-- Module Name:   C:/projects/USB_dongle/beh/lpc_byte_test.vhd
-- Project Name:  simulation
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: lpc_iow
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

ENTITY lpc_byte_test_vhd IS
END lpc_byte_test_vhd;

ARCHITECTURE behavior OF lpc_byte_test_vhd IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT lpc_iow
	PORT(
		lreset_n : IN std_logic;
		lclk : IN std_logic;
      lena_mem_r : in  std_logic;  --enable lpc regular memory read cycles also (default is only LPC firmware read)
	   lena_reads : in  std_logic;  --enable read capabilities      
		lad_i : IN std_logic_vector(3 downto 0);
		lframe_n : IN std_logic;
		lpc_data_i : IN std_logic_vector(7 downto 0);
		lpc_ack : IN std_logic;          
		lad_o : OUT std_logic_vector(3 downto 0);
		lad_oe : OUT std_logic;
		lpc_addr : OUT std_logic_vector(23 downto 0);
		lpc_wr : OUT std_logic;
		lpc_data_o : OUT std_logic_vector(7 downto 0);
		lpc_val : OUT std_logic
		);
	END COMPONENT;

	--Inputs
	SIGNAL lreset_n :  std_logic := '0';
	SIGNAL lclk :  std_logic := '0';
   
   SIGNAL   lena_mem_r : std_logic:='1';  --enable lpc regular memory read cycles also (default is only LPC firmware read)
	SIGNAL   lena_reads : std_logic:='1';  --enable read capabilities      
      
	SIGNAL lframe_n :  std_logic := '1';
	SIGNAL lpc_ack :  std_logic := '0';
	SIGNAL lad_i :  std_logic_vector(3 downto 0) := (others=>'0');
	SIGNAL lpc_data_i :  std_logic_vector(7 downto 0) := (others=>'0');

	--Outputs
	SIGNAL lad_o :  std_logic_vector(3 downto 0);
	SIGNAL lad_oe :  std_logic;
	SIGNAL lpc_addr :  std_logic_vector(23 downto 0);
	SIGNAL lpc_wr :  std_logic;
	SIGNAL lpc_data_o :  std_logic_vector(7 downto 0);
	SIGNAL lpc_val :  std_logic;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: lpc_iow PORT MAP(
		lreset_n => lreset_n,
		lclk => lclk,
      lena_mem_r=> lena_mem_r,
      lena_reads => lena_reads,
		lad_i => lad_i,
		lad_o => lad_o,
		lad_oe => lad_oe,
		lframe_n => lframe_n,
		lpc_addr => lpc_addr,
		lpc_wr => lpc_wr,
		lpc_data_i => lpc_data_i,
		lpc_data_o => lpc_data_o,
		lpc_val => lpc_val,
		lpc_ack => lpc_ack
	);


 clocker : process is
  begin
    wait for 15 ns;
    lclk <=not (lclk);
  end process clocker;


 VCI_ACK : process is
  begin
    wait until lpc_val='1';
	 wait for 100 ns;
	 lpc_ack <='1';
	 wait until lpc_val='0';
	 lpc_ack <='0';
  end process VCI_ACK;


	tb : PROCESS
	BEGIN

		-- Wait 100 ns for global reset to finish
		wait for 500 ns;
			lreset_n <='1';
		-- Place stimulus here
		wait until lclk='0'; --cycle 1
		wait until lclk='1';		
		lad_i <="0000";
		lframe_n <='0';
		wait until lclk='0'; --cycle 2
		wait until lclk='1';				
		lad_i <="0010";      --LPC IO write
		lframe_n <='1';
		wait until lclk='0'; --cycle 3
		wait until lclk='1';				
		lad_i <=x"0";			--address nibble 1
		wait until lclk='0'; --cycle 4
		wait until lclk='1';				
		lad_i <=x"0";			--address nibble 2
		wait until lclk='0'; --cycle 5
		wait until lclk='1';				
		lad_i <=x"8";			--address nibble 3		
		wait until lclk='0'; --cycle 6
		wait until lclk='1';				
		lad_i <=x"0";			--address nibble 4
		wait until lclk='0'; --cycle 7
		wait until lclk='1';				
		lad_i <=x"A";			--data nibble 1				
		wait until lclk='0'; --cycle 8
		wait until lclk='1';				
		lad_i <=x"5";			--data nibble 2
		wait until lclk='0'; --cycle 9
		wait until lclk='1';				
		lad_i <=x"F";			--TAR	1
		wait until lclk='0'; --cycle 10
		wait until lclk='1';				
		if lad_oe='0' then  --TAR 2
		else
			report "LPC error found on TAR cycle no 0xF on lad_o";
			lframe_n <='0';
		end if;
		wait until lclk='0'; --cycle 11
		wait until lclk='1';
      wait until lad_o=x"6";
      while(lad_o=x"6") loop
         wait until lclk='0'; --cycle 11
         wait until lclk='1';     
      end loop;
		if (lad_o=x"0") and lad_oe='1' then --SYNC
		else
			report "LPC error found on SYNC cycle no 0x0 on lad_o";
			lframe_n <='0';
		end if;
		wait until lclk='0'; --cycle 12
		wait until lclk='1';		
		if (lad_o=x"F") and lad_oe='1' then --TARL 1
		else
			report "LPC error found on TAR_L cycle no 0xF on lad_o";
			lframe_n <='0';
		end if;		
		wait until lclk='0'; --cycle 13
		wait until lclk='1';				
		lad_i <=x"F";			--TARL 2	
		lframe_n <='1';
		wait; -- will wait forever
	END PROCESS;

END;
