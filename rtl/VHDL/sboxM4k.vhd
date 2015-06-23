--------------------------------------------------------------------------------
-- This file is part of the project	 avs_aes
-- see: http://opencores.org/project,avs_aes
--
-- description:
-- instantiation of an Altera M4K blockram as dual port ROM
-- they have the nice feature of allowing an initialization file. with the
-- generic rominitfile it is possible to select the encryption or decryption
-- version sbox.hex and sbox_inv.hex
-- Only 8-Bit dual port was supported on CyloneII... this is why we need a lot
-- of blockrams in aes_core.vhd AND keyexpansionV2.vhd
--
-------------------------------------------------------------------------------
-- Todo:
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

library altera_mf;
use altera_mf.all;
library avs_aes_lib;
use avs_aes_lib.avs_aes_pkg.all;



architecture M4k of sbox is
	---------------------------------------------------------------------------
	-- Altera Stuff
	-- ( I don't want this in avs_aes_pkg because it is vendor specific)
	---------------------------------------------------------------------------
	component altsyncram
		generic (
			ADDRESS_REG_B			  : STRING;
			CLOCK_ENABLE_INPUT_A	  : STRING;
			CLOCK_ENABLE_INPUT_B	  : STRING;
			CLOCK_ENABLE_OUTPUT_A	  : STRING;
			CLOCK_ENABLE_OUTPUT_B	  : STRING;
			INDATA_REG_B			  : STRING;
			INIT_FILE				  : STRING;
			INTENDED_DEVICE_FAMILY	  : STRING;
			LPM_TYPE				  : STRING;
			NUMWORDS_A				  : NATURAL;
			NUMWORDS_B				  : NATURAL;
			OPERATION_MODE			  : STRING;
			OUTDATA_ACLR_A			  : STRING;
			OUTDATA_ACLR_B			  : STRING;
			OUTDATA_REG_A			  : STRING;
			OUTDATA_REG_B			  : STRING;
			POWER_UP_UNINITIALIZED	  : STRING;
			WIDTHAD_A				  : NATURAL;
			WIDTHAD_B				  : NATURAL;
			WIDTH_A					  : NATURAL;
			WIDTH_B					  : NATURAL;
			WIDTH_BYTEENA_A			  : NATURAL;
			WIDTH_BYTEENA_B			  : NATURAL;
			WRCONTROL_WRADDRESS_REG_B : STRING
			);
		port (
			wren_a	  : in	STD_LOGIC;
			wren_b	  : in	STD_LOGIC;
			clock0	  : in	STD_LOGIC;
			address_a : in	STD_LOGIC_VECTOR (7 downto 0);
			address_b : in	STD_LOGIC_VECTOR (7 downto 0);
			q_a		  : out STD_LOGIC_VECTOR (7 downto 0);
			q_b		  : out STD_LOGIC_VECTOR (7 downto 0);
			data_a	  : in	STD_LOGIC_VECTOR (7 downto 0);
			data_b	  : in	STD_LOGIC_VECTOR (7 downto 0)
			);
	end component;
	
begin

	assign_inverse : if INVERSE generate
		m4kblock_inv : altsyncram
			generic map (
				address_reg_b			  => "CLOCK0",
				clock_enable_input_a	  => "BYPASS",
				clock_enable_input_b	  => "BYPASS",
				clock_enable_output_a	  => "BYPASS",
				clock_enable_output_b	  => "BYPASS",
				indata_reg_b			  => "CLOCK0",
				init_file				  => "sbox_inv.hex",
				intended_device_family	  => "Cyclone II",
				lpm_type				  => "altsyncram",
				numwords_a				  => 256,
				numwords_b				  => 256,
				operation_mode			  => "BIDIR_DUAL_PORT",
				outdata_aclr_a			  => "NONE",
				outdata_aclr_b			  => "NONE",
				outdata_reg_a			  => "UNREGISTERED",  -- IMPORTANT not CLOCK0!!!
				outdata_reg_b			  => "UNREGISTERED",  -- IMPORTANT not CLOCK0!!!
				power_up_uninitialized	  => "FALSE",
				widthad_a				  => 8,
				widthad_b				  => 8,
				width_a					  => 8,
				width_b					  => 8,
				width_byteena_a			  => 1,
				width_byteena_b			  => 1,
				wrcontrol_wraddress_reg_b => "CLOCK0"
				)
			port map (
				wren_a	  => '0',		-- we don't write to ROM
				wren_b	  => '0',		-- we don't write to ROM
				clock0	  => clk,
				data_a	  => (others => '0'),  -- dumb compiler wants it anyway
				data_b	  => (others => '0'),  -- dumb compiler wants it anyway
				address_a => address_a,
				address_b => address_b,
				q_a		  => q_a,
				q_b		  => q_b
				);	
	end generate assign_inverse;

	assign_encrypt : if not INVERSE generate
		m4kblock_fwd : altsyncram
			generic map (
				address_reg_b			  => "CLOCK0",
				clock_enable_input_a	  => "BYPASS",
				clock_enable_input_b	  => "BYPASS",
				clock_enable_output_a	  => "BYPASS",
				clock_enable_output_b	  => "BYPASS",
				indata_reg_b			  => "CLOCK0",
				init_file				  => "sbox.hex",
				intended_device_family	  => "Cyclone II",
				lpm_type				  => "altsyncram",
				numwords_a				  => 256,
				numwords_b				  => 256,
				operation_mode			  => "BIDIR_DUAL_PORT",
				outdata_aclr_a			  => "NONE",
				outdata_aclr_b			  => "NONE",
				outdata_reg_a			  => "UNREGISTERED",  -- IMPORTANT not CLOCK0!!!
				outdata_reg_b			  => "UNREGISTERED",  -- IMPORTANT not CLOCK0!!!
				power_up_uninitialized	  => "FALSE",
				widthad_a				  => 8,
				widthad_b				  => 8,
				width_a					  => 8,
				width_b					  => 8,
				width_byteena_a			  => 1,
				width_byteena_b			  => 1,
				wrcontrol_wraddress_reg_b => "CLOCK0"
				)
			port map (
				wren_a	  => '0',		-- we don't write to ROM
				wren_b	  => '0',		-- we don't write to ROM
				clock0	  => clk,
				data_a	  => (others => '0'),  -- dumb compiler wants it anyway
				data_b	  => (others => '0'),  -- dumb compiler wants it anyway
				address_a => address_a,
				address_b => address_b,
				q_a		  => q_a,
				q_b		  => q_b
				);	
	end generate assign_encrypt;
end M4k;
