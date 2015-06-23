--------------------------------------------------------------------------------
-- This file is part of the project	 avs_aes
-- see: http://opencores.org/project,avs_aes
--
-- description: hardware keyexpansion core.
-------------------------------------------------------------------------------
-- Generates all roundkeys for the AES algorithm. in each round on key is used
-- to XOR with the round data, e.g. the state. because this is for encryption
-- of multiple plaintext blocks always the same roundkey sequence the keys are
-- stored until a new key is provided.
-- Starting from an initial 128, 192 or 256 Bit key (table of 4,6 or eight
-- columns = i) the sucessive roundkeys are calculated in the following way:
-- 1.) The 1st round is done with the initial key with the dwords dw[0] to
-- dw[i-1]
-- 2.) dw[n*i] is build through rotating dw[i-1] 1 left, Substituting its
-- contents with the Sbox function, the result then is XORed with
-- roundconstant[n] and it is again XORed with dw[(n-1)i].
-------------------------------------------------------------------------------
-- TODO: Implement another copy of this as wrapper to RAM to enable software
-- keyexpanion	
--
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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library avs_aes_lib;
use avs_aes_lib.avs_aes_pkg.all;

entity keyexpansionV2 is
	generic (
		KEYLENGTH : NATURAL := 128	-- Size of keyblock (128, 192, 256 Bits)   
		);
	port (
		clk			  : in	STD_LOGIC;	-- system clock
		keyword		  : in	DWORD;		-- word of original userkey
		keywordaddr	  : in	STD_LOGIC_VECTOR(2 downto 0);  -- keyword register address
		w_ena_keyword : in	STD_LOGIC;	-- write enable of keyword to wordaddr
		key_stable	  : in	STD_LOGIC;	-- key is completa and valid, start expansion
		-- key_stable=0-> invalidate key
		roundkey_idx  : in	NIBBLE;		-- index for selecting roundkey
		roundkey	  : out KEYBLOCK;	-- key for each round
		ready		  : out STD_LOGIC	-- expansion done, roundkeys ready
		);
	-- number of rounds, needed for looping
	constant NO_ROUNDS	: NATURAL := lookupRounds(KEYLENGTH);
	-- Number of columns in user key: 4,6, or 8
	constant Nk			: NATURAL := KEYLENGTH/DWORD_WIDTH;
	-- Number of interations
	constant LOOP_BOUND : NATURAL := 4*NO_ROUNDS;
end entity keyexpansionV2;


architecture ach1 of keyexpansionV2 is

	-- Round constants for XOR i/Nk is max 10 for Nk=4
	constant GF_ROUNDCONSTANTS_4_6 : BYTEARRAY(0 to 10) :=
		(X"01", X"02", X"04", X"08", X"10", X"20", X"40", X"80", X"1B", X"36", X"6C");
	-- keep quartus from complaining about "index not wide enough for all
	-- elements in the array" i/Nk is max 7 for Nk=8
	constant GF_ROUNDCONSTANTS_8 : BYTEARRAY(0 to 7) :=
		(X"01", X"02", X"04", X"08", X"10", X"20", X"40", X"80");
	signal roundconstant : BYTE;

	-- memory for roundkeys
	type   MEMORY_128 is array (0 to 15) of STD_LOGIC_VECTOR(127 downto 0);
	signal KEYMEM : MEMORY_128;

	-- key memory signals
	signal mem_in		: STD_LOGIC_VECTOR(127 downto 0);  -- in port for keymemory
	signal mem_out		: STD_LOGIC_VECTOR(127 downto 0);  -- out port of keymemory
	signal keymem_addr	: UNSIGNED(3 downto 0);	 -- address of RAM
	signal w_ena_keymem : STD_LOGIC;	-- write enable to keymemory
	-- write address for keymemory
	signal w_addr		: UNSIGNED(3 downto 0);	 -- register
	signal next_w_addr	: UNSIGNED(3 downto 0);	 -- combinational next value

	-- Interconnect for shiftregister
	signal keyshiftreg_in  : DWORDARRAY(Nk-1 downto 0);	 -- input from multiplexers
	signal keyshiftreg_out : DWORDARRAY(Nk-1 downto 0);	 -- output
	signal keyshiftreg_ena : STD_LOGIC_VECTOR(7 downto 0);	-- enable of single registers
	-- Selector for Load multiplexer, only select keyword to be written to
	-- shiftreg if key_stable is deasserted loadmux_sel <= not key_stable
	signal loadmux_sel	   : STD_LOGIC;

	---------------------------------------------------------------------------
	-- datapath expansion algorithm
	---------------------------------------------------------------------------
	signal exp_in			: DWORD;	-- in for expansion logic (w[i-1])
	signal rot_out			: DWORD;	-- rotated column (in to sbox)
	signal to_sbox			: DWORD;  -- substituted key column (out from sbox)
	signal from_sbox		: DWORD;  -- substituted key column (out from sbox)
	signal delayed_col		: DWORD;  -- delayed unprocessed key column w[i-1] | imod4/=0
	signal XorRcon_out		: DWORD;  -- rotated,substituted,XORed with Rcon column w[i-1]|imod4=0
	signal mux_processed	: DWORD;  -- multiplexed delayed_col or XorRcon_out
	signal Xor_lastblock_in : DWORD;	-- input for w[i-1] XOR w[i-Nk]
	signal last_word		: DWORD;  -- result of expansion w[i] --> w[i-1] for next round

	---------------------------------------------------------------------------
	-- Controller signals
	---------------------------------------------------------------------------
	signal first_round	 : STD_LOGIC;  -- selector Mux_input only '0' in first round
	signal shift_ena	 : STD_LOGIC;  -- enable shift of register bank w[i-1] to w[i-Nk]
	signal imodNk0		 : STD_LOGIC;  -- mux selector delayed_col or XorRcon_out if imodNk=0
	-- Special logic for Nk=8 256 Bit key
	signal imod84		 : STD_LOGIC;  -- mux selector around Rotate to substitute if imod8=4
	-- Statemachine
	type   KEYEXPANSIONSTATES is (INIT, SUBSTITUTE, SHIFT, WRITELAST, DONE);
	signal expState		 : KEYEXPANSIONSTATES;	  -- register value
	signal next_expState : KEYEXPANSIONSTATES;	  -- combinational next value
	-- counter for expanded keywords (max Nk*(Nr+1)=4*(14+1))
	signal i			 : UNSIGNED(5 downto 0);  -- register
	signal next_i		 : UNSIGNED(5 downto 0);  -- combinational next value
	
begin  -- architecture ach1

-------------------------------------------------------------------------------
-- Key load and shift register datapath
-------------------------------------------------------------------------------
	loadmux_sel <= not key_stable;

	Shiftreg : for i in 0 to Nk-1 generate
		-- ordinary words are regular shift registers
		rest_of_shiftreg : if i /= Nk-1 generate
			loadmux : Mux2
				generic map (
					IOwidth => DWORD_WIDTH)
				port map (
					inport_a => keyshiftreg_out(i+1),
					inport_b => keyword,
					selector => loadmux_sel,
					outport	 => keyshiftreg_in(i));
			keywordregister : memory_word
				generic map (
					IOwidth => DWORD_WIDTH)
				port map (
					data_in	 => keyshiftreg_in(i),
					data_out => keyshiftreg_out(i),
					res_n	 => '1',
					clk		 => clk,
					ena		 => keyshiftreg_ena(i));
		end generate;
		-- last word is different: here result from last expansion round is
		-- shifted in 
		lastDWORD : if i = Nk-1 generate
			lastw_loadmux : Mux2
				generic map (
					IOwidth => DWORD_WIDTH)
				port map (
					inport_a => last_word,	-- loopback form expansion logic
					inport_b => keyword,
					selector => loadmux_sel,
					outport	 => keyshiftreg_in(i));

			last_keywordreg : memory_word
				generic map (
					IOwidth => DWORD_WIDTH)
				port map (
					data_in	 => keyshiftreg_in(i),
					data_out => keyshiftreg_out(i),
					res_n	 => '1',
					clk		 => clk,
					ena		 => keyshiftreg_ena(i));
		end generate lastDWORD;
	end generate Shiftreg;

	-- Lower 4 Keywords will be written to key ram
	mem_in <= keyshiftreg_out(0) &keyshiftreg_out(1) & keyshiftreg_out(2) & keyshiftreg_out(3);
	-- map memory port to a nice state
	roundkey <= (0 => mem_out(127 downto 96),
				 1 => mem_out(95 downto 64),
				 2 => mem_out(63 downto 32),
				 3 => mem_out(31 downto 0));

	-- purpose: represent ram for storage of roundkeys (DP ram should be inferred)
	-- type	  : sequential
	-- inputs : clk, res_n
	-- outputs: mem_out
	keymemory : process (clk) is
	begin  -- process keymemory
		if rising_edge(clk) then		-- rising clock edge
			if w_ena_keymem = '1' then
				KEYMEM(to_integer(w_addr)) <= mem_in;
			end if;
			mem_out <= KEYMEM(to_integer(UNSIGNED(roundkey_idx)));
		end if;
	end process keymemory;


	-- purpose: set the respective enable bits for each register if either registes must be shifted
	-- right. only enable external write if key_stable='0'
	-- or are loaded with userkey
	-- type	  : combinational
	-- inputs : w_ena_keyword, shift_ena,keywordaddr
	-- outpukeyshiftreg_ena
	enableRegs : process (key_stable, keywordaddr, shift_ena, w_ena_keyword) is
	begin  -- process enableRegs
		-- default: freeze the registers
		keyshiftreg_ena <= (others => '0');
		-- if words are loaded externally only enable register for respective address
		-- words must only be written if key_stable is not asserted and
		-- therefore the FSM is in INIT state
		if w_ena_keyword = '1' and key_stable = '0' then
			keyshiftreg_ena(to_integer(UNSIGNED(keywordaddr))) <= '1';
			-- if register shall be shifted, enable all
		elsif shift_ena = '1' then
			keyshiftreg_ena <= (others => '1');
		end if;
	end process enableRegs;

	-- purpose: write combinational next_write address to register
	-- type	  : sequential
	-- inputs : clk, next_w_addr
	-- outputs: w_addr
	address_incr : process (clk) is
	begin  -- process address_incr
		if rising_edge(clk) then		-- rising clock edge
			w_addr <= next_w_addr;
		end if;
	end process address_incr;


-------------------------------------------------------------------------------
-- Expansion Datapath
------------------------------------------------------------------------------- 

	---------------------------------------------------------------------------
	-- Rotate left the key column a1,a2,a3,a4 --> a2,a3,4,a1
	---------------------------------------------------------------------------
	rot_out <= keyshiftreg_out(Nk-1)(23 downto 0) & keyshiftreg_out(Nk-1)(31 downto 24);

	---------------------------------------------------------------------------
	-- Special datapath for 256Bit key (Nk=8) if imodNk=4 to
	-- substitute w[i-1]
	---------------------------------------------------------------------------
	NK8_sboxin : if KEYLENGTH = 256 generate
		Nk8_sboxmux : mux2
			generic map (
				IOwidth => 32)
			port map (
				inport_a => rot_out,
				inport_b => keyshiftreg_out(Nk-1),
				selector => imod84,
				outport	 => to_sbox);

		-- Logic to switch the multiplexer
		imod84 <= '1' when (i mod 8 = 4) else '0';
	end generate NK8_sboxin;


	regular_sboxin : if KEYLENGTH /= 256 generate
		to_sbox <= rot_out;
	end generate regular_sboxin;

	---------------------------------------------------------------------------
	-- Keygenerate gets its own sboxes to substitute columns to define clear
	-- interface and increase f_max as this was on the critical path while
	-- shared with aes_core_encrypt
	---------------------------------------------------------------------------
	HighWord : sbox
		generic map (
			INVERSE => false)
		port map (
			clk		  => clk,
			address_a => to_sbox(31 downto 24),
			address_b => to_sbox(23 downto 16),
			q_a		  => from_sbox(31 downto 24),
			q_b		  => from_sbox(23 downto 16));
	LowWord : sbox
		generic map (
			INVERSE => false)
		port map (
			clk		  => clk,
			address_a => to_sbox(15 downto 8),
			address_b => to_sbox(7 downto 0),
			q_a		  => from_sbox(15 downto 8),
			q_b		  => from_sbox(7 downto 0));		

	---------------------------------------------------------------------------
	-- Xor column with Roundconstant[i/Nk], make it 32 BIT
	---------------------------------------------------------------------------
	XorRcon_out <= from_sbox xor (roundconstant & X"000000");

	---------------------------------------------------------------------------
	-- select intermediate result of processed w[i-1] either direct or
	-- processed with Sub(Rot(W[i-1]) XOR roundconstant if i mod Nk = 0
	---------------------------------------------------------------------------
	Mux_wi_1 : mux2
		generic map (
			IOwidth => DWORD_WIDTH)
		port map (
			inport_a => keyshiftreg_out(Nk-1),
			inport_b => XorRcon_out,
			selector => imodNk0,
			outport	 => mux_processed);
	-- Logic to switch the multiplexer
	imodNk0 <= '1' when (i mod Nk = 0) else '0';

	---------------------------------------------------------------------------
	-- Special datapath for 256Bit key (Nk=8) if imodNk=4 to
	-- substitute w[i-1]
	---------------------------------------------------------------------------
	NK8_wi_1 : if KEYLENGTH = 256 generate
		Nk8_mux_wi_1 : mux2
			generic map (
				IOwidth => 32)
			port map (
				inport_a => mux_processed,
				inport_b => from_sbox,
				selector => imod84,
				outport	 => Xor_lastblock_in);
	end generate NK8_wi_1;


	regular_wi_1 : if KEYLENGTH /= 256 generate
		Xor_lastblock_in <= mux_processed;
	end generate regular_wi_1;

	---------------------------------------------------------------------------
	-- Xor currently processed column w[i-1] with w[i-Nk]
	---------------------------------------------------------------------------
	last_word <= Xor_lastblock_in xor keyshiftreg_out(0);


-------------------------------------------------------------------------------
-- Controller for keyexpansion algorithm 
------------------------------------------------------------------------------- 

	-- purpose: Compute the next state of keyexpansion FSM
	-- type	  : combinational
	-- inputs : expState, i, key_stable
	-- outputs: next_expState
	nextState : process (expState, i, key_stable) is
	begin
		-- Save defaults to avoid latches
		next_expState <= expState;
		-- FSM
		case expState is
			when INIT =>
				if key_stable = '1' then
					next_expState <= SUBSTITUTE;
				end if;
			when SUBSTITUTE =>
				next_expState <= SHIFT;
			when SHIFT =>
				if i = LOOP_BOUND then
					next_expState <= DONE;
				else
					next_expState <= SUBSTITUTE;
				end if;
			when WRITELAST =>
				next_expState <= DONE;
			when DONE =>
				-- just stay
				next_expState <= expState;
		end case;
		-- reset the process whenever key is invalid
		if key_stable = '0' then
			next_expState <= INIT;
		end if;
	end process nextState;

	-- purpose: assign signals according to input and current state
	-- type	  : combinational
	-- inputs : expState, i
	-- outputs: shift_ena, next_i, ready	
	stateToOutput : process (expState, i, w_addr) is
	begin
		-- Save defaults to avoid latches
		shift_ena	 <= '0';
		next_i		 <= i;
		ready		 <= '0';
		w_ena_keymem <= '0';
		next_w_addr	 <= w_addr;
		case expState is
			when INIT =>
				-- reset all variables to defined state
				next_i		<= (others => '0');
				next_w_addr <= (others => '0');
			when SUBSTITUTE =>
				-- Substitute is a mere wait state for 1 cycle until SBOX has done
				-- the lookup
				null;
			when SHIFT =>
				next_i	  <= i+1;
				shift_ena <= '1';
				if (i mod 4 = 0) then
					w_ena_keymem <= '1';
					next_w_addr	 <= w_addr+1;
				end if;
			when WRITELAST =>
				w_ena_keymem <= '1';
				next_w_addr	 <= w_addr+1;
			when DONE =>
				ready <= '1';
			when others => null;
		end case;
	end process stateToOutput;

	-- purpose: write state and variables to registers
	-- type	  : sequential
	-- inputs : clk, res_n
	-- outputs: 
	registeredFSMsignals : process (clk) is
	begin  -- process registeredFSMsignals
		if rising_edge(clk) then		-- rising clock edge
			i		 <= next_i;
			expState <= next_expState;
			if Nk = 8 then
				roundconstant <= GF_ROUNDCONSTANTS_8(to_integer(i)/Nk);
			else
-- TODO : avoid divide operator, error when compiling with Nk=6 anx ISE 10.1
				roundconstant <= GF_ROUNDCONSTANTS_4_6(to_integer(i)/Nk);
			end if;
		end if;
	end process registeredFSMsignals;

end architecture ach1;
