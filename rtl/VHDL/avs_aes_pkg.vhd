-------------------------------------------------------------------------------
-- This file is part of the project  avs_aes
-- see: http://opencores.org/project,avs_aes
--
-- description:
-- Central file for definition of types and global functions for handling of
-- datatypes and generics. All components are defined here.
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
--    * Redistributions of source code must retain the above copyright notice,
--    this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright notice,
--    this list of conditions and the following disclaimer in the documentation
--    and/or other materials provided with the distribution.
--    * Neither the name of the  nor the names of its contributors
--    may be used to endorse or promote products derived from this software without
--    specific prior written permission.
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

package avs_aes_pkg is
	-- tiny 4 bit value
	constant NIBBLE_WIDTH : NATURAL := 4;
	subtype NIBBLE_RANGE is NATURAL range NIBBLE_WIDTH-1 downto 0;
	subtype NIBBLE is STD_LOGIC_VECTOR(NIBBLE_RANGE);
	
	-- type definition byte: 8 bit = byte (cell of the
	-- state)
	constant BYTE_WIDTH : NATURAL := 8;
	subtype	 BYTE_RANGE is NATURAL range BYTE_WIDTH-1 downto 0;
	subtype	 BYTE is STD_LOGIC_VECTOR(BYTE_RANGE);

	-- Type definition word: 16 bit = word 
	constant WORD_WIDTH : NATURAL := 16;
	subtype	 WORD_RANGE is NATURAL range WORD_WIDTH-1 downto 0;
	subtype	 WORD is STD_LOGIC_VECTOR(WORD_RANGE);	-- storage type "word"

	-- type definition Dword: 32 bit = dword 
	constant DWORD_WIDTH : NATURAL := 32;
	subtype	 DWORD_RANGE is NATURAL range DWORD_WIDTH-1 downto 0;
	subtype	 DWORD is STD_LOGIC_VECTOR(DWORD_RANGE);

	-- type definition Qword: 64 bit = qword 
	constant QWORD_WIDTH : NATURAL := 64;
	subtype	 QWORD_RANGE is NATURAL range QWORD_WIDTH-1 downto 0;
	subtype	 QWORD is STD_LOGIC_VECTOR(QWORD_RANGE);


	---------------------------------------------------------------------------
	-- aggregates of Signals
	---------------------------------------------------------------------------
	-- array of 64 bit words
	type QWORDARRAY is array (NATURAL range <>) of QWORD;
	-- array of 32 bit words
	type DWORDARRAY is array (NATURAL range <>) of DWORD;
	-- array of 16 bit words
	type WORDARRAY is array (NATURAL range <>) of WORD;
	-- array of 8 bit words
	type BYTEARRAY is array (NATURAL range <>) of BYTE;
	-- array of NATURALS
	type NATURALARRAY is array (NATURAL range <>) of NATURAL;
	-- array of integers
	type INTEGERARRAY is array (NATURAL range <>) of INTEGER;

	-- Byte Matrix
	type BYTEMATRIX is array (NATURAL range <>, NATURAL range <>) of BYTE;



	---------------------------------------------------------------------------
	-- types for signal mnemonics
	---------------------------------------------------------------------------
	type ACCESS_MODE is (W , R);		-- Modes how memory can be accessed
	type CRYPTODIRECTION is (encrypt, decrypt);	 -- Switch to encrypt or decrypt

	---------------------------------------------------------------------------
	-- constants for convienience
	---------------------------------------------------------------------------
	constant NULL_QWORD : QWORD := (others => '0');	 -- Qword to clear memory
	constant NULL_DWORD : DWORD := (others => '0');	 -- Dword to clear memory
	constant NULL_WORD	: WORD	:= (others => '0');	 -- word to clear memory
	constant NULL_BYTE	: BYTE	:= (others => '0');	 -- byte to clear memory




	
	-- The state type is the matrix unfolded into a linear representation
	-- the length of a column is always fixed so every 32 Bit of this vector
	-- represents a column of the state
	--
	-- once and for all: THE COLUMNS STAND WITH THE MSB (Bit 31) AT THE TOP!!
	--					=> cell0, cell4, cell8... are byte0 of the column
	-- 
	-- state:		==>		BYTEARRAY (0 to (BLOCKLENGTH/8)-1);
	--				cell0 cell4 ...
	--				cell1 cell5 ...	 ==> cell0,cell1,cell2,cell3,cell4,cell5.... 
	--				cell2 cell6 ...		 ^	   ^-bit[8]
	--				cell3  ...	...		 ^-bit[0] 
	subtype STATE is DWORDARRAY (0 to 3);
--	alias KEYBLOCK is STATE;
-- DUMB xilinx compiler does not know aliases for subtypes.....
	subtype KEYBLOCK is DWORDARRAY (0 to 3);


	-- Round constants for XOR in Keygenerator
	constant ROUNDCONSTANTS : BYTEARRAY(0 to 15) := (X"00", X"01", X"02", X"04", X"08", X"10", X"20", X"40",
													 X"80", X"1B", X"36", X"6C", X"D8", X"AB", X"4D", X"9A");

-------------------------------------------------------------------------------
-- General (useful)  Components
-------------------------------------------------------------------------------
	---------------------------------------------------------------------------
	-- register word with variable width
	---------------------------------------------------------------------------
	component memory_word
		generic (
			IOwidth : POSITIVE := 1		-- width of register
			);
		port (
			data_in	 : in  STD_LOGIC_VECTOR (IOwidth-1 downto 0);  -- input
			data_out : out STD_LOGIC_VECTOR (IOwidth-1 downto 0);  -- output
			res_n	 : in  STD_LOGIC;	-- system reset active low
			ena		 : in  STD_LOGIC;	-- enable write
			clk		 : in  STD_LOGIC	-- system clock
			);
	end component;


	---------------------------------------------------------------------------
	--	 2:1 STD_LOGIC_VECTOR  multiplexer
	---------------------------------------------------------------------------
	component mux2
		generic (
			IOwidth : POSITIVE := 1		-- width of I/O ports
			);
		port (
			inport_a : in  STD_LOGIC_VECTOR (IOwidth-1 downto 0);  -- port 1
			inport_b : in  STD_LOGIC_VECTOR (IOwidth-1 downto 0);  -- port 2
			selector : in  STD_LOGIC;	-- switch TO select ports
			outport	 : out STD_LOGIC_VECTOR (IOwidth-1 downto 0)   -- output
			);
	end component;
	
	---------------------------------------------------------------------------
	--	 3:1 multiplexer
	---------------------------------------------------------------------------
	component mux3
		generic (
			IOwidth : POSITIVE := 1		-- width of I/O ports
			);
		port (
			inport_a : in  STD_LOGIC_VECTOR (IOwidth-1 downto 0);  -- port 1
			inport_b : in  STD_LOGIC_VECTOR (IOwidth-1 downto 0);  -- port 2
			inport_c : in  STD_LOGIC_VECTOR (IOwidth-1 downto 0);  -- port 3
			selector : in  STD_LOGIC_VECTOR(1 downto 0); -- switch TO select ports
			outport	 : out STD_LOGIC_VECTOR (IOwidth-1 downto 0)   -- output
			);
	end component;

	
---------------------------------------------------------------------------
-- Components relevant for AVS_AES
---------------------------------------------------------------------------
	component AddRoundKey
		port (
			roundkey	: in  KEYBLOCK;	 -- Roundkey
			cypherblock : in  STATE;	 -- State for this round
			result		: out STATE
			);
	end component;

	---------------------------------------------------------------------------
	-- FSM that controls the dataflow of AES_ECB encryption
	---------------------------------------------------------------------------
	component AES_FSM_ENCRYPT is
		generic (
			NO_ROUNDS : NATURAL := 10);		  -- number of rounds
		port (
			clk				: in  STD_LOGIC;  -- System clock
			data_stable		: in  STD_LOGIC;  -- flag valid data/activate the process 
			-- interface for keygenerator
			key_ready		: in  STD_LOGIC;  -- flag valid roundkeys
			round_index_out : out NIBBLE;	  -- address for roundkeys memory
			-- Result of Process
			finished		: out STD_LOGIC;  -- flag valid result
			-- Control ports for the Core
			round_type_sel	: out STD_LOGIC_VECTOR(1 downto 0)	-- selector for mux around mixcols
			);
	end component;

	---------------------------------------------------------------------------
	-- FSM that controls the dataflow of AES_ECB decryption
	---------------------------------------------------------------------------
	component AES_FSM_DECRYPT is
		generic (
			NO_ROUNDS : NATURAL := 10);		  -- number of rounds
		port (
			clk				: in  STD_LOGIC;  -- System clock
			data_stable		: in  STD_LOGIC;  -- flag valid data/activate the process 
			-- interface for keygenerator
			key_ready		: in  STD_LOGIC;  -- flag valid roundkeys
			round_index_out : out NIBBLE;	  -- address for roundkeys memory
			-- Result of Process
			finished		: out STD_LOGIC;  -- flag valid result
			-- Control ports for the Core
			round_type_sel	: out STD_LOGIC_VECTOR(1 downto 0)	-- selector for mux around mixcols
			);
	end component;


	---------------------------------------------------------------------------
	-- Mixcolumn component
	-- (has 2 architectures inverse and forward)
	---------------------------------------------------------------------------
	component Mixcol is
		port (
			col_in	: in  DWORD;		-- one column of the state
			col_out : out DWORD);		-- output column
	end component Mixcol;

	---------------------------------------------------------------------------
	-- Sbox component
	-- The interface is 2x8Bit because Altera megafunction is supposed to be at max
	-- 8Bit dual port ROM  (and I relied on a altera quartus generated component
	-- before) see architecture m4k
	-------------------------------------------------------------------------------
	component sbox is
		generic (
			INVERSE : BOOLEAN);			-- is this the inverse or the forward
										-- lookup table.
										-- TRUE -> inverse sbox
										-- FALSE -> forward sbox
		port (
			clk		  : in	STD_LOGIC;	-- system clock
			address_a : in	STD_LOGIC_VECTOR (7 downto 0);	-- 1st byte
			address_b : in	STD_LOGIC_VECTOR (7 downto 0);	-- 2nd byte
			q_a		  : out STD_LOGIC_VECTOR (7 downto 0);	-- substituted 1st byte
			q_b		  : out STD_LOGIC_VECTOR (7 downto 0));	 -- substituted 2nd byte
	end component sbox;

	
	---------------------------------------------------------------------------
	-- Encrypt version of Shiftrow component
	-- (has 2 architectures inverse and forward)
	---------------------------------------------------------------------------
	component Shiftrow
		port (
			state_in  : in	STATE;		-- Raw input data TO be shifted
			state_out : out STATE		-- shifted result
			);
	end component;

	---------------------------------------------------------------------------
	-- Keykenerator for roundkeys
	---------------------------------------------------------------------------
	component keyexpansionV2 is
		generic (
			KEYLENGTH : NATURAL);  -- Size of keyblock (128, 192, 256 Bits)
		port (
			clk			  : in	STD_LOGIC;	-- system clock
			keyword		  : in	DWORD;	-- word of original userkey
			keywordaddr	  : in	STD_LOGIC_VECTOR(2 downto 0);  -- keyword register address
			w_ena_keyword : in	STD_LOGIC;	-- write enable of keyword to wordaddr
			key_stable	  : in	STD_LOGIC;	-- key is completa and valid, start expansion
			roundkey_idx  : in	NIBBLE;		-- index for selecting roundkey
			roundkey	  : out KEYBLOCK;	-- key for each round
			ready		  : out STD_LOGIC);	 -- expansion done, roundkeys ready
	end component keyexpansionV2;


	---------------------------------------------------------------------------
	-- Keykenerator for roundkeys
	---------------------------------------------------------------------------
	component keygenerator is
		generic (
			KEYLENGTH : NATURAL := 128;	 -- Size of keyblock (128, 192, 256 Bits)
			NO_ROUNDS : NATURAL := 10	-- how many rounds
			);
		port (
			clk		   : in	 STD_LOGIC;	 -- system clock
			initialkey : in	 KEYBLOCK;	-- original userkey
			key_stable : in	 STD_LOGIC;	 -- signal for enabling write of initial
										 -- key and signal valid key
										 -- ena=0->blank_key
			round	   : in	 NIBBLE;	-- index for selecting roundkey
			roundkey   : out KEYBLOCK;	-- key for each round
			ready	   : out STD_LOGIC
			);
	end component;



	---------------------------------------------------------------------------
	-- Complete Core implementation
	---------------------------------------------------------------------------
	component AES_CORE is
		generic (
			KEYLENGTH  : NATURAL;  -- Size of keyblock (128, 192, 256 Bits)
			DECRYPTION : BOOLEAN);		-- include decrypt datapath
		port (
			clk			  : in	STD_LOGIC;	-- system clock
			data_in		  : in	STATE;	-- payload to encrypt
			data_stable	  : in	STD_LOGIC;	-- flag valid payload
			keyword		  : in	DWORD;	-- word of original userkey
			keywordaddr	  : in	STD_LOGIC_VECTOR(2 downto 0);  -- keyword register address
			w_ena_keyword : in	STD_LOGIC;	-- write enable of keyword to wordaddr
			key_stable	  : in	STD_LOGIC;	-- key is complete and valid, start expansion
			decrypt_mode  : in	STD_LOGIC;	-- decrypt='1',encrypt='0'
			keyexp_done   : out STD_LOGIC;	-- keyprocessing is done
			result		  : out STATE;	-- output
			finished	  : out STD_LOGIC);					   -- output valid
	end component AES_CORE;
	---------------------------------------------------------------------------
	-- function to calculate number of rounds based on keylength, returns
	-- either 10,12 or 14
	---------------------------------------------------------------------------
	function lookupRounds (keylen : in NATURAL) return NATURAL;

	---------------------------------------------------------------------------
	-- Functions for convinience
	---------------------------------------------------------------------------
	-- modulo additon DWORD+DWORD=DWORD
	function "+" (left, right : in DWORD) return DWORD;

end package avs_aes_pkg;

package body avs_aes_pkg is

	---------------------------------------------------------------------------
	-- function to calculate number of rounds based on keylength, returns
	-- either 10,12 or 14
	---------------------------------------------------------------------------
	function lookupRounds(keylen : in NATURAL) return NATURAL is
	begin
		assert (keylen = 128 or keylen = 192 or keylen = 256)
			report "Wrong KEYLENGTH parameter" severity failure;
		if keylen = 128 then
			return 10;
		elsif keylen = 192 then
			return 12;
		elsif keylen = 256 then
			return 14;
		else
			return 0;	
		end if;
	end;

	-- modulo additon DWORD+DWORD=DWORD
	function "+" (left, right : in DWORD) return DWORD
	is
		variable result : UNSIGNED(DWORD_RANGE);
	begin
		result := UNSIGNED(left) + UNSIGNED(right);
		return STD_LOGIC_VECTOR(result);
	end function;

end package body avs_aes_pkg;
