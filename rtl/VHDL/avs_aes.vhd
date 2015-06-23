--------------------------------------------------------------------------------
-- This file is part of the project	 avs_aes
-- see: http://opencores.org/project,avs_aes
--
-- description:
--	Avalon Slave bus interface for aes_core. Top level component to integrate
--	into SoC
--	
-- Memory address offsets:
-- 0 - 7	key
-- 8 - 11	input data if write='1', result of operation if read='1'
-- 12- 14	result of operation
-- 31		command word
--
-- Command word bit offsets meanings:
-- Byte 3-1 reserved
--
-- Byte 0:
-- Bit 7  key valid --> run key expansion
-- Bit 6  interrupt enabled
-- Bit 5-2 reserved
-- Bit 1  input data valid interpret as cypher text	  --> run decrypt mode
-- Bit 0  input data valid interpret as clear text	 --> run encrypt mode
--
-- All other bits are regarded as "reserved". The bits in one byte of the
-- command word are mutually exclusive. the behavior of the core is not
-- specified if more than one bit is set.
--
-- Author(s):
--	   Thomas Ruschival -- ruschi@opencores.org (www.ruschival.de)
--
--------------------------------------------------------------------------------
-- Copyright (c) 2009, Authors and opencores.org
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without modification,
-- are permitted provided that the following conditions are met:
--	  * Redistributions of source code must retain the above copyright notice,
--	  this list of conditions and the following disclaimer.
--	  * Redistributions in binary form must reproduce the above copyright notice,
--	  this list of conditions and the following disclaimer in the documentation
--	  and/or other materials provided with the distribution.
--	  * Neither the name of the organization nor the names of its contributors
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
-- $Author::                                         $
-- $Date::                                           $
-- $Revision::                                       $
-------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library avs_aes_lib;
use avs_aes_lib.avs_aes_pkg.all;

entity avs_AES is
	generic (
		KEYLENGTH  : NATURAL := 256;	-- AES key length
		DECRYPTION : BOOLEAN := true);	-- With decrypt or encrypt only
	port (
		-- Avalon global
		clk				   : in	 STD_LOGIC;	 -- avalon bus clock
		reset			   : in	 STD_LOGIC;	 -- avalon bus reset
		-- Interface specific
		avs_s1_chipselect  : in	 STD_LOGIC;	 -- enable component
		avs_s1_writedata   : in	 STD_LOGIC_VECTOR(31 downto 0);	 -- data write port
		avs_s1_address	   : in	 STD_LOGIC_VECTOR(4 downto 0);	-- slave address space offset
		avs_s1_write	   : in	 STD_LOGIC;	 -- write enable
		avs_s1_read		   : in	 STD_LOGIC;	 -- read request form avalon
		avs_s1_irq		   : out STD_LOGIC;	 -- interrupt to signal completion
		avs_s1_waitrequest : out STD_LOGIC;	 -- slave not ready, request master
											 -- to retry later
		avs_s1_readdata	   : out STD_LOGIC_VECTOR(31 downto 0)	-- result read port
		);
end entity avs_AES;

architecture arch1 of avs_aes is
-- Signals interfacing the AES core
	signal data_stable : STD_LOGIC;	 -- input data is valid --> process it
	signal data_in	   : STATE;			-- register for input data of core

	signal w_ena_keyword : STD_LOGIC;	-- write enable of keyword to wordaddr
	signal key_stable	 : STD_LOGIC;  -- key is complete and valid, start expansion

	signal decrypt_mode : STD_LOGIC;	-- decrypt='1',encrypt='0'
	signal result		: STATE;		-- output
	signal finished		: STD_LOGIC;	-- output valid

-- internal logic
	signal result_reg : STATE;			-- register for result
	signal ctrl_reg	  : DWORD;			-- control register
	signal irq		  : STD_LOGIC;	-- internal interrupt request (register)
	signal irq_i	  : STD_LOGIC;		-- combinational value for interrupt

	signal irq_ena : STD_LOGIC;			-- alias for ctrl_reg(6)

	signal w_ena_data_in  : STD_LOGIC;	-- write enable of data_in register
	signal w_ena_ctrl_reg : STD_LOGIC;	-- write enable of control register
	signal keyexp_done	  : STD_LOGIC;	-- signal to create waitrequests if new key is written while previous is still in
										-- expansion 
begin  -- architecture arch1

	-- map internal irq to avalon interface
	avs_s1_irq <= irq;

	-- rename signals for better debugging, will be optimized away in synthesis
	key_stable <= ctrl_reg(7);
	irq_ena	   <= ctrl_reg(6);

	---------------------------------------------------------------------------
	-- depending on generic enable decrypt_mode signal or permanently disable
	-- it 
	---------------------------------------------------------------------------
	enable_decrypt_mode : if DECRYPTION generate
		decrypt_mode <= ctrl_reg(1);
		data_stable	 <= ctrl_reg(0) or ctrl_reg(1);
	end generate enable_decrypt_mode;

	disable_decrypt_mode : if not DECRYPTION generate
		decrypt_mode <= '0';
		data_stable	 <= ctrl_reg(0);
	end generate disable_decrypt_mode;


	-- purpose: write input data to registers
	-- type	  : sequential
	-- inputs : clk
	-- outputs: ctrl_reg, irq, avs_s1_readdata, key, data
	write_inputs : process (clk) is
	begin  -- process write_inputs
		if rising_edge(clk) then
			-- synchronous reset
			if reset = '1' then
				irq		 <= '0';
				ctrl_reg <= (others => '0');
			end if;
			-- DFF for IRQ
			irq <= irq_i;
			-- write control register
			if w_ena_ctrl_reg = '1' then
				ctrl_reg <= avs_s1_writedata;
			end if;
			-- write input to data register
			if w_ena_data_in = '1' then
				data_in(to_integer(UNSIGNED(avs_s1_address(1 downto 0)))) <= avs_s1_writedata;
			end if;

			-- signalling the outside world about the terminiation of the
			-- computation by blanking the data_stable register bits
			if finished = '1' then
				-- Work is done - reset ENC and DEC
				ctrl_reg(1 downto 0) <= "00";
			end if;
		end if;
	end process write_inputs;



	-- purpose: set/reset interrupt request flag
	-- type	  : combinational
	-- inputs : finished, avs_s1_read, irq, irq_ena
	-- outputs: irq_i
	IRQhandling : process (avs_s1_read, finished, irq, irq_ena) is
	begin  -- process IRQhandling

		-- Set the interrupt if enabed and process finished
		if irq_ena = '1' and finished = '1' then
			irq_i <= '1';
		elsif irq_ena = '0' or avs_s1_read = '1' then
			-- any read operation resets the interrupt
			irq_i <= '0';
		else
			irq_i <= irq;				-- just keep the way it is 
		end if;

	end process IRQhandling;


	-- purpose: decode the write operation to the address ranges and map it to the
	-- registers - any other write address range
	-- e.g. avs_s1_address(4 downto 3) = "10" (result)	is illegal
	-- type	  : combinational
	decode_write : process (avs_s1_address, avs_s1_write, key_stable,
							keyexp_done) is
	begin
		-- safe default to avoid latching
		w_ena_data_in	   <= '0';
		w_ena_ctrl_reg	   <= '0';
		w_ena_keyword	   <= '0';
		avs_s1_waitrequest <= '0';
		-- only do something if chipselect is asserted and write operation
		-- requested 
		if avs_s1_write = '1' then
			if avs_s1_address(4 downto 3) = "00" then
				-- write of keywords	
				w_ena_keyword	   <= '1';
				-- stall the write process if old key is still in processing
				-- the user can interrupt the expansion by deasserting key_stable
				avs_s1_waitrequest <= key_stable and not keyexp_done;
			elsif avs_s1_address(4 downto 3) = "01" then
				-- write of data
				w_ena_data_in <= '1';
			elsif avs_s1_address(4 downto 3) = "11" then
				-- write of control register
				w_ena_ctrl_reg <= '1';
			end if;
		end if;
	end process decode_write;


	-- purpose: assign read data
	-- type	  : 
	-- inputs : 
	-- outputs: read_data
	decode_read : process (avs_s1_address, avs_s1_read, ctrl_reg, result_reg) is
	begin
		-- only address 0x10 to 0x1F are for read, thus address bit 4
		-- is always set when reading			
		if avs_s1_read = '1' and avs_s1_address(3) = '0' then
			-- address looks something like 10xxx which corresponds to
			-- 0x10 to 0x17, however result has only 4 words thus
			-- address bits 1 and 0 are sufficient for decoding
			avs_s1_readdata <= result_reg(to_integer(UNSIGNED(avs_s1_address(1 downto 0))));
		else
			-- address looks something like 11xxx which corresponds to
			-- 0x18 to 0x1F, in this case always map control register,
			-- we have plenty of address space so currently no exact
			-- addressation needed.
			-- save default, if nothing else is addressed show control register
			avs_s1_readdata <= ctrl_reg;
		end if;
	end process decode_read;



	-- purpose: store the combinational output of the AES core to a register
	-- type	  : sequential
	-- inputs : clk, res_n
	-- outputs: result
	store_result : process (clk) is
	begin  -- process store_result
		if rising_edge(clk) then		-- rising clock edge
			-- Core has terminated, store the result and reset the 
			if finished = '1' then
				result_reg <= result;
			end if;
		end if;
	end process store_result;


	---------------------------------------------------------------------------
	-- Instance of the core
	---------------------------------------------------------------------------
	AES_CORE_1 : AES_CORE
		generic map (
			KEYLENGTH  => KEYLENGTH,  -- Size of keyblock (128, 192, 256 Bits)
			DECRYPTION => DECRYPTION)	-- include decrypt datapath
		port map (
			clk			  => clk,		-- system clock
			data_in		  => data_in,	-- payload to encrypt
			data_stable	  => data_stable,	 -- flag valid payload
			keyword		  => avs_s1_writedata,	-- word of original userkey
			keywordaddr	  => avs_s1_address(2 downto 0),  -- keyword register address
			w_ena_keyword => w_ena_keyword,	 -- write enable of keyword to wordaddr
			key_stable	  => key_stable,  -- key is complete and valid, start expansion
			decrypt_mode  => decrypt_mode,	 -- decrypt='1',encrypt='0'
			keyexp_done	  => keyexp_done,	 -- key is completely expanded
			result		  => result,	-- output
			finished	  => finished);	  -- output valid

end architecture arch1;
