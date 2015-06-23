--------------------------------------------------------------------------------
-- This file is part of the project	 avs_aes
-- see: http://opencores.org/project,avs_aes
--
-- description:
-- Simple testbench for the avalon interface avs_aes together with aes_core.
--
-- Todo:  a lot! make it look nicer, more generic, maybe read data from file
--
-- Author(s):
--	   Thomas Ruschival -- ruschi@opencores.org (www.ruschival.de)
--
--------------------------------------------------------------------------------
-- Copyright (c) 2009, Thomas Ruschival
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without modification,
-- are permitted provided that the following conditions are met:
--	  * Redistributions of source code must retain the above copyright notice,
--	  this list of conditions and the following disclaimer.
--	  * Redistributions in binary form must reproduce the above copyright notice,
--	  this list of conditions and the following disclaimer in the documentation
--	  and/or other materials provided with the distribution.
--	  * Neither the name of the	 nor the names of its contributors
--	  may be used to endorse or promote products derived from this software without
--	  specific prior written permission.
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
-- OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
-- THE POSSIBILITY OF SUCH DAMAGE
-------------------------------------------------------------------------------
-- version management:
-- $Author$
-- $Date$
-- $Revision$			
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library avs_aes_lib;
use avs_aes_lib.avs_aes_pkg.all;

-------------------------------------------------------------------------------

entity avs_aes_tb is
end entity avs_aes_tb;

-------------------------------------------------------------------------------

architecture arch1 of avs_aes_tb is

	-- component ports
	signal clk				  : STD_LOGIC					  := '0';  -- avalon bus clock
	signal reset			  : STD_LOGIC					  := '0';  -- avalon bus reset
	signal writedata		  : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');  -- data write port
	signal address			  : STD_LOGIC_VECTOR(4 downto 0)  := (others => '0');  -- slave address space offset
	signal write			  : STD_LOGIC					  := '0';  -- write enable
	signal read				  : STD_LOGIC					  := '0';  -- read request form avalon
	signal irq				  : STD_LOGIC;	-- interrupt to signal completion
	signal readdata			  : STD_LOGIC_VECTOR(31 downto 0);	-- result read port
	signal chipselect		  : STD_LOGIC;	-- enable component
	signal keyexp_done		  : STD_LOGIC;
	signal avs_s1_waitrequest : STD_LOGIC;

-------------------------------------------------------------------------------
-- test setup
-------------------------------------------------------------------------------
    constant TESTKEYSIZE : NATURAL := 128;
	constant KEYWORDS : NATURAL := TESTKEYSIZE/32;

	-- Signals for comparison
    signal testresult : DWORDARRAY(0 to 3);
    signal expected : DWORDARRAY(0 to 3);
    ---------------------------------------------------------------------------
	-- 1st Test: KeySetup +Encryption
	-- encrypt data_1 using key_1
    -- KEY:  	603DEB1015CA71BE2B73AEF0857D77811F352C073B6108D72D9810A30914DFF4
	-- DATA: 	AA221133114411551166117721212121
	---------------------------------------------------------------------------
	-- key(0) is most significant word
	signal key_1 : DWORDARRAY(0 to 7) := (
		0 => X"603DEB10", 1 => X"15CA71BE",
		2 => X"2B73AEF0", 3 => X"857D7781",
		4 => X"1F352C07", 5 => X"3B6108D7",
		6 => X"2D9810A3", 7 => X"0914DFF4") ;
	signal data_1 : DWORDARRAY(0 to 3) := (
		0 => X"AA221133", 1 => X"11441155",
		2 => X"11661177", 3 => X"21212121");

	-- Expected result
	-- RESULT(encrypt):
	signal result256_1 : DWORDARRAY(0 to 3) := (
		0 => X"D7C71AF7", 1 => X"76F04439",
		2 => X"1A07623A", 3 => X"8E6E197B");

	signal result192_1 : DWORDARRAY(0 to 3) := (
		0 => X"87870FD6", 1 => X"C27D944F",
		2 => X"C83EBA16", 3 => X"C5DB0D63");

	signal result128_1 : DWORDARRAY(0 to 3) := (
		0 => X"5A287C9F", 1 => X"CDBC6D35",
		2 => X"F3D2679C", 3 => X"4CB2F5B0");

 ------------------------------------------------------------------------------
 -- 2nd test: Decrypt
 -- Treat data_1 as cyphertext and perform decryption
 -- under given key_1
 ------------------------------------------------------------------------------
	signal result256_2 : DWORDARRAY(0 to 3) := (
		0 => X"63B72B79", 1 => X"EA1F444B",
		2 => X"8A1AD035", 3 => X"CAE6B024");

	signal result192_2 : DWORDARRAY(0 to 3) := (
		0 => X"4343EB7A", 1 => X"79A14922",
		2 => X"CC18A1D6", 3 => X"C5D00B70");
	
	signal result128_2 : DWORDARRAY(0 to 3) := (
		0 => X"02985DF8", 1 => X"8209EAA2",
		2 => X"652E4125", 3 => X"11C98F9F");

-------------------------------------------------------------------------------
-- 3rd TestCase: Same as Testcase1 whitout loading key
-- to see if any internal state was kept
-------------------------------------------------------------------------------
	-- Expected result
	signal result256_3 : DWORDARRAY(0 to 3) := (
		0 => X"D7C71AF7", 1 => X"76F04439",
		2 => X"1A07623A", 3 => X"8E6E197B");

	signal result192_3 : DWORDARRAY(0 to 3) := (
		0 => X"87870FD6", 1 => X"C27D944F",
		2 => X"C83EBA16", 3 => X"C5DB0D63");

	signal result128_3 : DWORDARRAY(0 to 3) := (
		0 => X"5A287C9F", 1 => X"CDBC6D35",
		2 => X"F3D2679C", 3 => X"4CB2F5B0");

-------------------------------------------------------------------------------
-- 4th TestCase: encrypt new Data, same key
-- DATA: AA2211CC 11440055 11001177 2121BBBB
-------------------------------------------------------------------------------	
	signal data_4 : DWORDARRAY(0 to 3) := (
		0 => X"AA2211CC", 1 => X"11440055",
		2 => X"11001177", 3 => X"2121BBBB");
	-- Expected result
	signal result256_4 : DWORDARRAY(0 to 3) := (
		0 => X"0F500ECC", 1 => X"5B802E90",
		2 => X"D7D39EE4", 3 => X"78900016");
 
	signal result192_4 : DWORDARRAY(0 to 3) := (
		0 => X"1A38FE60", 1 => X"FDEC5D46",
		2 => X"3F1B068F", 3 => X"93133736");

	signal result128_4 : DWORDARRAY(0 to 3) := (
		0 => X"CED4DE60", 1 => X"CE678AF7",
		2 => X"8B479AE5", 3 => X"A6090EA7");


-------------------------------------------------------------------------------
-- 5th TestCase: Same Data as in 4, new key, encrypt
-------------------------------------------------------------------------------	
	signal key_5 : DWORDARRAY(0 to 7) := (
		0 => X"01234567", 1 => X"89ABCDEF",
		2 => X"01234567", 3 => X"89ABCDEF",
		4 => X"AAAAAAAA", 5 => X"BBBBBBBB",
		6 => X"55555555", 7 => X"77777777") ;

	-- Expected result	
	signal result256_5 : DWORDARRAY(0 to 3) := (
		0 => X"9405DA5A", 1 => X"448324CF",
		2 => X"05E71527", 3 => X"91F5975A");

	signal result192_5 : DWORDARRAY(0 to 3) := (
		0 => X"F94DD5F8", 1 => X"93FD66AC",
		2 => X"7E96025B", 3 => X"3278C352");

	signal result128_5 : DWORDARRAY(0 to 3) := (
		0 => X"B0C9CB1E", 1 => X"EEFA22D5",
		2 => X"B81AD39B", 3 => X"BBAD3530");

	
	
	
	
 ------------------------------------------------------------------------------
 -- Testbench begin
 ------------------------------------------------------------------------------  
begin  -- architecture arch1
	avs_aes_1 : entity avs_aes_lib.avs_aes
		generic map (
			KEYLENGTH  => TESTKEYSIZE,			-- AES key length
			DECRYPTION => true)			-- With decrypt or encrypt only
		port map (
			clk				   => clk,	-- avalon bus clock
			reset			   => reset,	-- avalon bus reset
			avs_s1_chipselect  => chipselect,		   -- enable component
			avs_s1_writedata   => writedata,		   -- data write port
			avs_s1_address	   => address,	-- slave address space offset
			avs_s1_write	   => write,	-- write enable
			avs_s1_read		   => read,		-- read request form avalon
			avs_s1_irq		   => irq,	-- interrupt to signal completion
			avs_s1_waitrequest => avs_s1_waitrequest,  -- stall operations
			avs_s1_readdata	   => readdata);		   -- result read port

	-- clock generation
	Clk <= not Clk after 10 ns;

	-- waveform generation
	WaveGen_Proc : process
	begin
		-- insert signal assignments here
		reset	   <= '1';
		write	   <= '0';
		read	   <= '0';
		wait for 25 ns;
		reset	   <= '0';
		chipselect <= '1';
		wait until clk = '1';

-----------------------------------------------------------------------
-- Test1
-----------------------------------------------------------------------
		if TESTKEYSIZE = 256 then
			expected <= result256_1;
		elsif TESTKEYSIZE = 192 then
			expected <= result192_1;
		elsif TESTKEYSIZE = 128 then
			expected <= result128_1;
		else
			report "wrong testkeysize" severity FAILURE;
		end if;

		-----------------------------------------------------------------------
		-- Setup key1
		-----------------------------------------------------------------------
		for cnt in 0 to KEYWORDS-1 loop
			write <= '1';
			address <= STD_LOGIC_VECTOR(to_unsigned(cnt,5));
			writedata <= key_1(cnt);
			wait until clk='1';
		end loop;  -- cnt
		-----------------------------------------------------------------------
		-- Send data
		-----------------------------------------------------------------------
		for cnt in 0 to 3 loop
			write <= '1';
			address <= STD_LOGIC_VECTOR(to_unsigned(8+cnt,5));
			writedata <= data_1(cnt);
			wait until clk='1';
		end loop;  -- cnt
		
		-- write control
		-- data stable, key_stable irq_ena
		wait until clk = '1';
		write	  <= '1';
		address	  <= STD_LOGIC_VECTOR(to_unsigned(31, 5));
		writedata <= X"000000C1";
		wait until clk = '1';
		write	  <= '0';
		-- do the calc
		wait until irq = '1';
		wait until clk = '1';
		-----------------------------------------------------------------------
		--retrieve and check result
		-----------------------------------------------------------------------
		for cnt in 0 to 3 loop
			read <= '1';
			address <= STD_LOGIC_VECTOR(to_unsigned(16+cnt,5));
			wait until clk = '1';
			testresult(cnt) <= readdata;
		end loop;  -- cnt

		wait until clk = '1';

		if testresult /= expected then
			report "RESULT MISMATCH! Test1 failed" severity ERROR;
		else
			report "Test case 1 successful" severity note;	
		end if;


-------------------------------------------------------------------------------
--  Test2: decrypt the the same data under the given key
-------------------------------------------------------------------------------
		if TESTKEYSIZE = 256 then
			expected <= result256_2;
		elsif TESTKEYSIZE = 192 then
			expected <= result192_2;
		elsif TESTKEYSIZE = 128 then
			expected <= result128_2;
		else
			report "wrong testkeysize test2" severity FAILURE;
		end if;
		
		wait until clk = '1';
		write	  	 <= '1';
		address	  <= STD_LOGIC_VECTOR(to_unsigned(31, 5));
		writedata <= X"000000C2";
		wait until clk = '1';
		write	  <= '0';
		-- do the calc
		wait until irq = '1';
		wait until clk = '1';
		-----------------------------------------------------------------------
		--retrieve and check result
		-----------------------------------------------------------------------
		for cnt in 0 to 3 loop
			read <= '1';
			address <= STD_LOGIC_VECTOR(to_unsigned(16+cnt,5));
			wait until clk = '1';
			testresult(cnt) <= readdata;
		end loop;  -- cnt

		wait until clk = '1';

		if testresult /= expected then
			report "RESULT MISMATCH! Test 2 failed" severity ERROR;
		else
			report "Test case 2 successful" severity note;	
		end if;


-------------------------------------------------------------------------------
-- TestCase3:  Encrypt again without changing anything
--  should yield the same result as TestCase1
-------------------------------------------------------------------------------
		if TESTKEYSIZE = 256 then
			expected <= result256_1;
		elsif TESTKEYSIZE = 192 then
			expected <= result192_1;
		elsif TESTKEYSIZE = 128 then
			expected <= result128_1;
		else
			report "wrong testkeysize" severity FAILURE;
		end if;

		-- write control
		wait until clk = '1';
		write	  <= '1';
		address	  <= STD_LOGIC_VECTOR(to_unsigned(31, 5));
-- data stable, key_stable irq_ena
		writedata <= X"000000C1";
		wait until clk = '1';
		write	  <= '0';
-- do the calc
		wait until irq = '1';
		wait until clk = '1';
		-----------------------------------------------------------------------
		--retrieve and check result
		-----------------------------------------------------------------------
		for cnt in 0 to 3 loop
			read <= '1';
			address <= STD_LOGIC_VECTOR(to_unsigned(16+cnt,5));
			wait until clk = '1';
			testresult(cnt) <= readdata;
		end loop;  -- cnt

		wait until clk = '1';

		if testresult /= expected then
			report "RESULT MISMATCH! Test 3 failed" severity ERROR;
  		else
			report "Test case 3 successful" severity note;
		end if;


-------------------------------------------------------------------------------
-- TestCase4: new data, same key 
-------------------------------------------------------------------------------
		if TESTKEYSIZE = 256 then
			expected <= result256_4;
		elsif TESTKEYSIZE = 192 then
			expected <= result192_4;
		elsif TESTKEYSIZE = 128 then
			expected <= result128_4;
		else
			report "wrong testkeysize" severity FAILURE;
		end if;
		-----------------------------------------------------------------------
		-- Send data
		-----------------------------------------------------------------------
		for cnt in 0 to 3 loop
			write <= '1';
			address <= STD_LOGIC_VECTOR(to_unsigned(8+cnt,5));
			writedata <= data_4(cnt);
			wait until clk='1';
		end loop;  -- cnt
		
		-- write control
		-- data stable, key_stable irq_ena
		wait until clk = '1';
		write	  <= '1';
		address	  <= STD_LOGIC_VECTOR(to_unsigned(31, 5));
		writedata <= X"000000C1";
		wait until clk = '1';
		write	  <= '0';
		-- do the calc
		wait until irq = '1';
		wait until clk = '1';
		-----------------------------------------------------------------------
		--retrieve and check result
		-----------------------------------------------------------------------
		for cnt in 0 to 3 loop
			read <= '1';
			address <= STD_LOGIC_VECTOR(to_unsigned(16+cnt,5));
			wait until clk = '1';
			testresult(cnt) <= readdata;
		end loop;  -- cnt

		wait until clk = '1';

		if testresult /= expected then
			report "RESULT MISMATCH! Test 4 failed" severity ERROR; 
		else
			report "Test case 4 successful" severity note;
		end if;

-------------------------------------------------------------------------------
-- 5th TestCase: Same Data, new key, encrypt
-------------------------------------------------------------------------------	
		if TESTKEYSIZE = 256 then
			expected <= result256_5;
		elsif TESTKEYSIZE = 192 then
			expected <= result192_5;
		elsif TESTKEYSIZE = 128 then
			expected <= result128_5;
		else
			report "wrong testkeysize" severity FAILURE;
		end if;

		-----------------------------------------------------------------------
		-- Setup key5
		-----------------------------------------------------------------------
		-- invalidate old key:
		wait until clk = '1';
		write	  <= '1';
		address	  <= STD_LOGIC_VECTOR(to_unsigned(31, 5));
		writedata <= X"00000000";
		wait until clk = '1';
		
		for cnt in 0 to KEYWORDS-1 loop
			write <= '1';
			address <= STD_LOGIC_VECTOR(to_unsigned(cnt,5));
			writedata <= key_5(cnt);
			wait until clk='1';
		end loop;  -- cnt
		
		-- write control
		-- data stable, key_stable irq_ena
		wait until clk = '1';
		write	  <= '1';
		address	  <= STD_LOGIC_VECTOR(to_unsigned(31, 5));
		writedata <= X"000000C1";
		wait until clk = '1';
		write	  <= '0';
		-- do the calc
		wait until irq = '1';
		wait until clk = '1';
		-----------------------------------------------------------------------
		--retrieve and check result
		-----------------------------------------------------------------------
		for cnt in 0 to 3 loop
			read <= '1';
			address <= STD_LOGIC_VECTOR(to_unsigned(16+cnt,5));
			wait until clk = '1';
			testresult(cnt) <= readdata;
		end loop;  -- cnt

		wait until clk = '1';

		if testresult /= expected then
			report "RESULT MISMATCH! Test 5 failed" severity ERROR;
		else
			report "Test case 5 successful" severity note;
		end if;


		wait;
	end process WaveGen_Proc;

	

end architecture arch1;
