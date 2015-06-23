-------------------------------------------------------------------------------
-- This file is part of the project	 avs_aes
-- see: http://opencores.org/project,avs_aes
--
-- description:
-- Complete structural description of the AES core. No processes or protocol
-- handling is done at this level. This component is entirely depending on the
-- underlying elements.
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
-- $Author:: ruschi                                  $
-- $Date:: 2011-05-15 13:37:43 +0200 (Sun, 15 May 20#$
-- $Revision:: 20                                    $
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library avs_aes_lib;
use avs_aes_lib.avs_aes_pkg.all;

entity AES_CORE is
	generic (
		KEYLENGTH  : NATURAL := 128;  -- Size of keyblock (128, 192, 256 Bits)
		DECRYPTION : BOOLEAN := false	-- include decrypt datapath
		);
	port(
		clk			  : in	STD_LOGIC;	-- system clock
		data_in		  : in	STATE;		-- payload to encrypt
		data_stable	  : in	STD_LOGIC;	-- flag valid payload
		keyword		  : in	DWORD;		-- word of original userkey
		keywordaddr	  : in	STD_LOGIC_VECTOR(2 downto 0);  -- keyword register address
		w_ena_keyword : in	STD_LOGIC;	-- write enable of keyword to wordaddr
		key_stable	  : in	STD_LOGIC;	-- key is complete and valid, start expansion
		decrypt_mode  : in	STD_LOGIC;	-- decrypt='1',encrypt='0'
		keyexp_done	  : out STD_LOGIC;	-- keyprocessing is done
		result		  : out STATE;		-- output
		finished	  : out STD_LOGIC	-- output valid
		);
	-- number of rounds 10, 12 or 14, needed for looping
	constant NO_ROUNDS : NATURAL := lookupRounds(KEYLENGTH);
end AES_CORE;


architecture arch1 of AES_CORE is
	---------------------------------------------------------------------------
	-- signal for encrypt datapath
	---------------------------------------------------------------------------
	signal addkey_in_enc	: STATE;	-- State for this round
	signal mixcol_out_enc	: STATE;	-- State with mixed Colums
	signal sbox_out_enc		: STATE;	-- 4 columns output form ROM
	signal shiftrow_out_enc : STATE;	-- shifted state
	signal addkey_out_enc	: STATE;	-- result of add key
	-- control signals
	signal roundkey_idx_enc : NIBBLE;	-- index for selecting roundkey
	signal round_type_enc	: STD_LOGIC_VECTOR(1 downto 0);	 -- switch to select ports
	signal finished_enc		: STD_LOGIC;  -- encryption has terminated	  
	signal ena_encrypt		: STD_LOGIC;  -- enable encryption fsm only if not
										  -- decryption is running
										  -- (data_stable AND not decrypt_mode='1') 
	---------------------------------------------------------------------------
	-- Signals for decrypt datapath
	---------------------------------------------------------------------------
	signal addkey_in_dec	: STATE;	-- input for addkey
	signal addkey_out_dec	: STATE;	-- output of addkey
	signal mixcol_out_dec	: STATE;	-- State with mixed Colums
	signal sbox_out_dec		: STATE;	-- 4 columns output form ROM
	signal shiftrow_in_dec	: STATE;	-- multiplexer output for shiftrow
	signal shiftrow_out_dec : STATE;	-- shifted state
	-- control signals
	signal round_type_dec	: STD_LOGIC_VECTOR(1 downto 0);	 -- switch to select ports
	signal roundkey_idx_dec : NIBBLE;	-- index for selecting roundkey
	signal finished_dec		: STD_LOGIC;  -- decryption has terminated
	signal ena_decrypt		: STD_LOGIC;  -- enable encryption fsm only if not
										  -- decryption is running
										-- (data_stable AND decrypt_mode='1') 
	---------------------------------------------------------------------------
	-- Common signals encrypt and decrypt
	---------------------------------------------------------------------------
	signal roundkey_idx		: NIBBLE;	-- multiplexed round index
	signal key_ready		: STD_LOGIC;  -- ouput of keyexpansion
	signal roundkey			: KEYBLOCK;	  -- Roundkey

begin  -- architecture arch1
	---------------------------------------------------------------------------
	-- Multiplexers for switching encrypt and decrypt controller
	-- only needed if decryption datapath is enabled
	---------------------------------------------------------------------------
	decryption_result_mux : if DECRYPTION generate
		-- Multiplexed result port
		ResultMux : for i in 0 to 3 generate
			Multiplex : mux2
				generic map (
					IOwidth => DWORD_WIDTH)
				port map (
					inport_a => addkey_out_enc(i),
					inport_b => addkey_out_dec(i),
					selector => decrypt_mode,  -- decrypt='1',encrypt='0'
					outport	 => Result(i));
		end generate ResultMux;

		-- Multiplexed control over key index
		keyindexMux : mux2
			generic map (
				IOwidth => NIBBLE_WIDTH)
			port map (
				inport_a => roundkey_idx_enc,
				inport_b => roundkey_idx_dec,
				selector => decrypt_mode,  -- decrypt='1',encrypt='0'
				outport	 => roundkey_idx);

		-- Multiplexed finished signal
		finished <= finished_enc when decrypt_mode = '0' else finished_dec;
	end generate decryption_result_mux;

	---------------------------------------------------------------------------
	-- No DECRYPTION MODE --> multiplexers not needed
	---------------------------------------------------------------------------
	ecryption_only : if not DECRYPTION generate
		-- result:
		result		 <= addkey_out_enc;
		--finished flag
		finished	 <= finished_enc;
		-- key index:
		roundkey_idx <= roundkey_idx_enc;
	end generate ecryption_only;


	---------------------------------------------------------------------------
	-- Key generator for roundkeys (decrypt and encrypt)
	---------------------------------------------------------------------------
	roundkey_generator : keyexpansionV2
		generic map (
			KEYLENGTH => KEYLENGTH)	 -- Size of keyblock (128, 192, 256 Bits)
		port map (
			clk			  => clk,		-- system clock
			keyword		  => keyword,	-- word of original userkey
			keywordaddr	  => keywordaddr,	 -- keyword register address
			w_ena_keyword => w_ena_keyword,	 -- write enable of keyword to wordaddr
			key_stable	  => key_stable,  -- key is completa and valid, start expansion
			roundkey_idx  => roundkey_idx,	 -- index for selecting roundkey
			roundkey	  => roundkey,	-- key for each round
			ready		  => key_ready);  -- expansion done, roundkeys ready

	-- Signal to the top level instance for availability of key
	-- maybe used to create avalon waitrequests if key is written to keyaddress
	-- range while other key is still in processing
	keyexp_done <= key_ready;

-------------------------------------------------------------------------------
-- Encrypt datapath (always included)
-------------------------------------------------------------------------------

	---------------------------------------------------------------------------
	--	encryption FSM is always needed
	---------------------------------------------------------------------------
	ena_encrypt <= data_stable and not decrypt_mode;

	-- Controller for encrypt
	FSM_ENC : AES_FSM_ENCRYPT
		generic map (
			NO_ROUNDS => NO_ROUNDS)
		port map (
			clk				=> clk,
			data_stable		=> ena_encrypt,
			key_ready		=> key_ready,
			round_index_out => roundkey_idx_enc,
			finished		=> finished_enc,
			round_type_sel	=> round_type_enc
			);

	---------------------------------------------------------------------------
	-- 4 SboxBlocks of 2 SboxM4K each for the single columns
	---------------------------------------------------------------------------
	sboxROMs_enc : for i in 0 to 3 generate
		HighWord : sbox
			generic map (
				INVERSE => false)
			port map (
				clk		  => clk,
				address_a => addkey_out_enc(i)(31 downto 24),
				address_b => addkey_out_enc(i)(23 downto 16),
				q_a		  => sbox_out_enc(i)(31 downto 24),
				q_b		  => sbox_out_enc(i)(23 downto 16));
		LowWord : sbox
			generic map (
				INVERSE => false)
			port map (
				clk		  => clk,
				address_a => addkey_out_enc(i)(15 downto 8),
				address_b => addkey_out_enc(i)(7 downto 0),
				q_a		  => sbox_out_enc(i)(15 downto 8),
				q_b		  => sbox_out_enc(i)(7 downto 0));																	   
	end generate sboxROMs_enc;


	---------------------------------------------------------------------------
	-- Shiftrow step (encryption datapath)
	---------------------------------------------------------------------------
	shiftrow_enc : entity avs_aes_lib.Shiftrow(fwd)
		port map (
			state_in  => sbox_out_enc,
			state_out => shiftrow_out_enc
			);

	---------------------------------------------------------------------------
	-- mix column step
	---------------------------------------------------------------------------
	MixColArray_enc : for i in 0 to 3 generate
		mix_column_enc : entity avs_aes_lib.Mixcol(fwd)
			port map (
				col_in	=> shiftrow_out_enc(i),
				col_out => mixcol_out_enc(i));					 
	end generate MixColArray_enc;

	---------------------------------------------------------------------------
	-- Multiplexer for input to AddRoundKey, depending on round_type
	-- Initial round  "00":		directly feed data_in (data block)
	-- regular round  "01":		feed result from mix_column
	-- final round	  "10":		skip mixcolumn and feed result from shiftrow
	---------------------------------------------------------------------------
	AddKeyMuxArray_enc : for i in 0 to 3 generate
		AddKeyMux : mux3
			generic map (
				IOwidth => DWORD_WIDTH)
			port map (
				inport_a => data_in(i),
				inport_b => mixcol_out_enc(i),
				inport_c => shiftrow_out_enc(i),
				selector => round_type_enc,
				outport	 => addkey_in_enc(i));
	end generate AddKeyMuxArray_enc;

	---------------------------------------------------------------------------
	-- key addition (encrypt datapath)
	---------------------------------------------------------------------------
	Keyadder_enc : AddRoundKey
		port map (
			roundkey	=> roundkey,
			cypherblock => addkey_in_enc,
			result		=> addkey_out_enc
			);

---------------------------------------------------------------------------
-- Decrypt datapath
---------------------------------------------------------------------------
	decrypt_datapath : if DECRYPTION generate
		---------------------------------------------------------------------------
		--	Decryption FSM
		---------------------------------------------------------------------------
		ena_decrypt <= data_stable and decrypt_mode;

		FSM_DEC : AES_FSM_DECRYPT
			generic map (
				NO_ROUNDS => NO_ROUNDS)
			port map (
				clk				=> clk,
				data_stable		=> ena_decrypt,
				key_ready		=> key_ready,
				round_index_out => roundkey_idx_dec,
				finished		=> finished_dec,
				round_type_sel	=> round_type_dec
				);

		---------------------------------------------------------------------------
		-- key addition (Decrypt datapath)
		-- Multiplexed input on addkey (data_in or feedback)
		---------------------------------------------------------------------------
		AKinputMux : for i in 0 to 3 generate
			mux : Mux2
				generic map (
					IOwidth => DWORD_WIDTH)
				port map (
					inport_a => data_in(i),
					inport_b => sbox_out_dec(i),
					selector => round_type_dec(0),
					outport	 => addkey_in_dec(i));
		end generate AKinputMux;

		Keyadder_dec : AddRoundKey
			port map (
				roundkey	=> roundkey,
				cypherblock => addkey_in_dec,
				result		=> addkey_out_dec
				);
		---------------------------------------------------------------------------
		-- Inverse mixcolumn 
		---------------------------------------------------------------------------
		InverseMixCol : for i in 0 to 3 generate
			mix_column_dec : entity avs_aes_lib.Mixcol(inv)
				port map (
					col_in	=> addkey_out_dec(i),
					col_out => mixcol_out_dec(i));
		end generate InverseMixCol;

		---------------------------------------------------------------------------
		-- Inverse Shiftrow
		-- multiplexed input form either addkey_out_dec during loop or mixcol_out_dec
		-- when exiting loop
		---------------------------------------------------------------------------
		SRinputMux : for i in 0 to 3 generate
			mux : Mux2
				generic map (
					IOwidth => 32)
				port map (
					inport_a => addkey_out_dec(i),
					inport_b => mixcol_out_dec(i),
					selector => round_type_dec(0),
					outport	 => shiftrow_in_dec(i));
		end generate SRinputMux;

		Shiftrow_dec : entity avs_aes_lib.Shiftrow(inv)
			port map (
				state_in  => shiftrow_in_dec,
				state_out => shiftrow_out_dec
				);

		---------------------------------------------------------------------------
		-- 4 INVERSE SboxBlocks of 2 SboxM4K each for the single columns
		---------------------------------------------------------------------------
		sboxROMs_dec : for i in 0 to 3 generate
			HighWord : sbox
				generic map (
					INVERSE => true)
				port map (
					clk		  => clk,
					address_a => shiftrow_out_dec(i)(31 downto 24),
					address_b => shiftrow_out_dec(i)(23 downto 16),
					q_a		  => sbox_out_dec(i)(31 downto 24),
					q_b		  => sbox_out_dec(i)(23 downto 16));
			LowWord : sbox
				generic map (
					INVERSE => true)
				port map (
					clk		  => clk,
					address_a => shiftrow_out_dec(i)(15 downto 8),
					address_b => shiftrow_out_dec(i)(7 downto 0),
					q_a		  => sbox_out_dec(i)(15 downto 8),
					q_b		  => sbox_out_dec(i)(7 downto 0));
		end generate sboxROMs_dec;
	end generate decrypt_datapath;

end architecture arch1;
