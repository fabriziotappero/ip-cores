
-----------------------------------------------------------------------------
-- NoCem -- Network on Chip Emulation Tool for System on Chip Research 
-- and Implementations
-- 
-- Copyright (C) 2006  Graham Schelle, Dirk Grunwald
-- 
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  
-- 02110-1301, USA.
-- 
-- The authors can be contacted by email: <schelleg,grunwald>@cs.colorado.edu 
-- 
-- or by mail: Campus Box 430, Department of Computer Science,
-- University of Colorado at Boulder, Boulder, Colorado 80309
-------------------------------------------------------------------------------- 


-- 
-- Filename: vc_node.vhd
-- 
-- Description: vc_node toplevel instantiation
-- 




--A Virtual Channel node is connected to Virtual Channels on its input and output ports.  
--This node will do normal data switching, but will also manage allocation 
--of the virtual channels themselves.

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


use work.pkg_nocem.all;

entity vc_node is

    Port ( 
		local_arb_addr : std_logic_vector(NOCEM_AW-1 downto 0);

	   n_datain : in data_word;
	   n_pkt_cntrl_in : in pkt_cntrl_word;

	   n_dataout : out data_word;
	   n_pkt_cntrl_out : out pkt_cntrl_word;

	   n_channel_cntrl_in  : in channel_cntrl_word;
	   n_channel_cntrl_out : out channel_cntrl_word;

	   s_datain : in data_word;
	   s_pkt_cntrl_in : in pkt_cntrl_word;

	   s_dataout : out data_word;
	   s_pkt_cntrl_out : out pkt_cntrl_word;

	   s_channel_cntrl_in  : in channel_cntrl_word;
	   s_channel_cntrl_out : out channel_cntrl_word;


	   e_datain : in data_word;
	   e_pkt_cntrl_in : in pkt_cntrl_word;

	   e_dataout : out data_word;
	   e_pkt_cntrl_out : out pkt_cntrl_word;

	   e_channel_cntrl_in  : in channel_cntrl_word;
	   e_channel_cntrl_out : out channel_cntrl_word;


	   w_datain : in data_word;
	   w_pkt_cntrl_in : in pkt_cntrl_word;

	   w_dataout : out data_word;
	   w_pkt_cntrl_out : out pkt_cntrl_word;

	   w_channel_cntrl_in  : in channel_cntrl_word;
	   w_channel_cntrl_out : out channel_cntrl_word;

	   ap_datain : in data_word;
	   ap_pkt_cntrl_in : in pkt_cntrl_word;

	   ap_dataout : out data_word;
	   ap_pkt_cntrl_out : out pkt_cntrl_word;

	   ap_channel_cntrl_in  : in channel_cntrl_word;
	   ap_channel_cntrl_out : out channel_cntrl_word;
	 
	   clk : in std_logic;
      rst : in std_logic
		
		);
end vc_node;

architecture Behavioral of vc_node is

-- lots of signals, but needed for the various blocks that write channel control words
signal n_channel_cntrl_out_vcalloc_n  : channel_cntrl_word;
signal n_channel_cntrl_out_vcalloc_s  : channel_cntrl_word;
signal n_channel_cntrl_out_vcalloc_e  : channel_cntrl_word;
signal n_channel_cntrl_out_vcalloc_w  : channel_cntrl_word;
signal n_channel_cntrl_out_vcalloc_ap : channel_cntrl_word;

signal s_channel_cntrl_out_vcalloc_n  : channel_cntrl_word;
signal s_channel_cntrl_out_vcalloc_s  : channel_cntrl_word;
signal s_channel_cntrl_out_vcalloc_e  : channel_cntrl_word;
signal s_channel_cntrl_out_vcalloc_w  : channel_cntrl_word;
signal s_channel_cntrl_out_vcalloc_ap : channel_cntrl_word;

signal e_channel_cntrl_out_vcalloc_n  : channel_cntrl_word;
signal e_channel_cntrl_out_vcalloc_s  : channel_cntrl_word;
signal e_channel_cntrl_out_vcalloc_e  : channel_cntrl_word;
signal e_channel_cntrl_out_vcalloc_w  : channel_cntrl_word;
signal e_channel_cntrl_out_vcalloc_ap : channel_cntrl_word;

signal w_channel_cntrl_out_vcalloc_n  : channel_cntrl_word;
signal w_channel_cntrl_out_vcalloc_s  : channel_cntrl_word;
signal w_channel_cntrl_out_vcalloc_e  : channel_cntrl_word;
signal w_channel_cntrl_out_vcalloc_w  : channel_cntrl_word;
signal w_channel_cntrl_out_vcalloc_ap : channel_cntrl_word;

signal ap_channel_cntrl_out_vcalloc_n  : channel_cntrl_word;
signal ap_channel_cntrl_out_vcalloc_s  : channel_cntrl_word;
signal ap_channel_cntrl_out_vcalloc_e  : channel_cntrl_word;
signal ap_channel_cntrl_out_vcalloc_w  : channel_cntrl_word;
signal ap_channel_cntrl_out_vcalloc_ap : channel_cntrl_word;


signal n_channel_cntrl_out_ch_arb   : channel_cntrl_word;
signal s_channel_cntrl_out_ch_arb   : channel_cntrl_word;
signal e_channel_cntrl_out_ch_arb   : channel_cntrl_word;
signal w_channel_cntrl_out_ch_arb   : channel_cntrl_word;
signal ap_channel_cntrl_out_ch_arb  : channel_cntrl_word;


signal arb_grant_output : arb_decision_array(4 downto 0);


signal local_ch_addr_converted : std_logic_vector(4 downto 0);

signal channel_word_z  : channel_cntrl_word;



begin


channel_word_z <= (others => '0');


 
 
 local_ch_addr_converted <= CONV_STD_LOGIC_VECTOR(2**NOCEM_NORTH_IX,5);


	-- VC ALLOCATION BLOCKS (one per outgoing channel)
	I_vc_alloc_n: vc_node_vc_allocator PORT MAP(
		local_ch_addr => ARB_NORTH,
		outoing_vc_status => n_channel_cntrl_in(NOCEM_CHFIFO_VC_EOP_RD_HIX downto NOCEM_CHFIFO_VC_EOP_RD_LIX),
		n_channel_cntrl_in => channel_word_z, --n_channel_cntrl_in,
		n_channel_cntrl_out => open, --n_channel_cntrl_out_vcalloc_n,
		s_channel_cntrl_in => s_channel_cntrl_in,
		s_channel_cntrl_out => s_channel_cntrl_out_vcalloc_n,
		e_channel_cntrl_in => e_channel_cntrl_in,
		e_channel_cntrl_out => e_channel_cntrl_out_vcalloc_n,
		w_channel_cntrl_in => w_channel_cntrl_in,
		w_channel_cntrl_out => w_channel_cntrl_out_vcalloc_n,
		ap_channel_cntrl_in => ap_channel_cntrl_in,
		ap_channel_cntrl_out => ap_channel_cntrl_out_vcalloc_n,
		clk => clk,
		rst => rst
	);

	I_vc_alloc_s: vc_node_vc_allocator PORT MAP(
		local_ch_addr => ARB_SOUTH,
		outoing_vc_status => s_channel_cntrl_in(NOCEM_CHFIFO_VC_EOP_RD_HIX downto NOCEM_CHFIFO_VC_EOP_RD_LIX),
		n_channel_cntrl_in => n_channel_cntrl_in,
		n_channel_cntrl_out => n_channel_cntrl_out_vcalloc_s,
		s_channel_cntrl_in => channel_word_z, --s_channel_cntrl_in,
		s_channel_cntrl_out => open, --s_channel_cntrl_out_vcalloc_s,
		e_channel_cntrl_in => e_channel_cntrl_in,
		e_channel_cntrl_out => e_channel_cntrl_out_vcalloc_s,
		w_channel_cntrl_in => w_channel_cntrl_in,
		w_channel_cntrl_out => w_channel_cntrl_out_vcalloc_s,
		ap_channel_cntrl_in => ap_channel_cntrl_in,
		ap_channel_cntrl_out => ap_channel_cntrl_out_vcalloc_s,
		clk => clk,
		rst => rst
	);

	I_vc_alloc_e: vc_node_vc_allocator PORT MAP(
		local_ch_addr => ARB_EAST,
		outoing_vc_status => e_channel_cntrl_in(NOCEM_CHFIFO_VC_EOP_RD_HIX downto NOCEM_CHFIFO_VC_EOP_RD_LIX),
		n_channel_cntrl_in => n_channel_cntrl_in,
		n_channel_cntrl_out => n_channel_cntrl_out_vcalloc_e,
		s_channel_cntrl_in => s_channel_cntrl_in,
		s_channel_cntrl_out => s_channel_cntrl_out_vcalloc_e,
		e_channel_cntrl_in => channel_word_z, --e_channel_cntrl_in,
		e_channel_cntrl_out => open, --e_channel_cntrl_out_vcalloc_e,
		w_channel_cntrl_in => w_channel_cntrl_in,
		w_channel_cntrl_out => w_channel_cntrl_out_vcalloc_e,
		ap_channel_cntrl_in => ap_channel_cntrl_in,
		ap_channel_cntrl_out => ap_channel_cntrl_out_vcalloc_e,
		clk => clk,
		rst => rst
	);

	I_vc_alloc_w: vc_node_vc_allocator PORT MAP(
		local_ch_addr => ARB_WEST,
		outoing_vc_status => w_channel_cntrl_in(NOCEM_CHFIFO_VC_EOP_RD_HIX downto NOCEM_CHFIFO_VC_EOP_RD_LIX),
		n_channel_cntrl_in => n_channel_cntrl_in,
		n_channel_cntrl_out => n_channel_cntrl_out_vcalloc_w,
		s_channel_cntrl_in => s_channel_cntrl_in,
		s_channel_cntrl_out => s_channel_cntrl_out_vcalloc_w,
		e_channel_cntrl_in => e_channel_cntrl_in,
		e_channel_cntrl_out => e_channel_cntrl_out_vcalloc_w,
		w_channel_cntrl_in => channel_word_z, --w_channel_cntrl_in,
		w_channel_cntrl_out => open, --w_channel_cntrl_out_vcalloc_w,
		ap_channel_cntrl_in => ap_channel_cntrl_in,
		ap_channel_cntrl_out => ap_channel_cntrl_out_vcalloc_w,
		clk => clk,
		rst => rst
	);

	I_vc_alloc_ap: vc_node_vc_allocator PORT MAP(
		local_ch_addr => ARB_AP,
		outoing_vc_status => ap_channel_cntrl_in(NOCEM_CHFIFO_VC_EOP_RD_HIX downto NOCEM_CHFIFO_VC_EOP_RD_LIX),
		n_channel_cntrl_in => n_channel_cntrl_in,
		n_channel_cntrl_out => n_channel_cntrl_out_vcalloc_ap,
		s_channel_cntrl_in => s_channel_cntrl_in,
		s_channel_cntrl_out => s_channel_cntrl_out_vcalloc_ap,
		e_channel_cntrl_in => e_channel_cntrl_in,
		e_channel_cntrl_out => e_channel_cntrl_out_vcalloc_ap,
		w_channel_cntrl_in => w_channel_cntrl_in,
		w_channel_cntrl_out => w_channel_cntrl_out_vcalloc_ap,
		ap_channel_cntrl_in => channel_word_z, --ap_channel_cntrl_in,
		ap_channel_cntrl_out => open, --ap_channel_cntrl_out_vcalloc_ap,
		clk => clk,
		rst => rst
	);

	-- ROUTER / PHYSICAL CHANNEL ARBITER
	I_ch_arbiter: vc_node_ch_arbiter PORT MAP(
		arb_grant_output => arb_grant_output,
		n_channel_cntrl_in => n_channel_cntrl_in,
		n_channel_cntrl_out => n_channel_cntrl_out_ch_arb,
		s_channel_cntrl_in => s_channel_cntrl_in,
		s_channel_cntrl_out => s_channel_cntrl_out_ch_arb,
		e_channel_cntrl_in => e_channel_cntrl_in,
		e_channel_cntrl_out => e_channel_cntrl_out_ch_arb,
		w_channel_cntrl_in => w_channel_cntrl_in,
		w_channel_cntrl_out => w_channel_cntrl_out_ch_arb,
		ap_channel_cntrl_in => ap_channel_cntrl_in,
		ap_channel_cntrl_out => ap_channel_cntrl_out_ch_arb,
		clk => clk,
		rst => rst
	);	


	-- THE SWITCH ITSELF
	I_vc_switch : simple_pkt_local_switch PORT MAP(
		arb_grant_output => arb_grant_output,
		ap_datain => ap_datain,
		ap_dataout => ap_dataout,
		n_datain => n_datain,
		n_dataout => n_dataout,
		s_datain => s_datain,
		s_dataout => s_dataout,
		e_datain => e_datain,
		e_dataout => e_dataout,
		w_datain => w_datain,
		w_dataout => w_dataout,
		n_pkt_cntrl_in => n_pkt_cntrl_in,
		n_pkt_cntrl_out => n_pkt_cntrl_out,
		s_pkt_cntrl_in => s_pkt_cntrl_in,
		s_pkt_cntrl_out => s_pkt_cntrl_out,
		e_pkt_cntrl_in => e_pkt_cntrl_in,
		e_pkt_cntrl_out => e_pkt_cntrl_out,
		w_pkt_cntrl_in => w_pkt_cntrl_in,
		w_pkt_cntrl_out => w_pkt_cntrl_out,
		ap_pkt_cntrl_in => ap_pkt_cntrl_in,
		ap_pkt_cntrl_out => ap_pkt_cntrl_out,
		clk => clk,
		rst =>  rst
	);


------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- OR TOGETHER THE CHANNEL CONTROL OUT SINGALS (JUST FOR SYNTACTICAL 	 -----
-- PURPOSES, "TRIM LOGIC" WILL EAT MOST IF NOT ALL OF THESE OR'D SIGNALS -----
------------------------------------------------------------------------------
------------------------------------------------------------------------------

ap_channel_cntrl_out	 <= ap_channel_cntrl_out_ch_arb or 
								 ap_channel_cntrl_out_vcalloc_n or 
								 ap_channel_cntrl_out_vcalloc_s or 
								 ap_channel_cntrl_out_vcalloc_e or 
								 ap_channel_cntrl_out_vcalloc_w;-- or 
								 --ap_channel_cntrl_out_vcalloc_ap;

n_channel_cntrl_out	 <= n_channel_cntrl_out_ch_arb or 
								 --n_channel_cntrl_out_vcalloc_n or 
								 n_channel_cntrl_out_vcalloc_s or 
								 n_channel_cntrl_out_vcalloc_e or 
								 n_channel_cntrl_out_vcalloc_w or 
								 n_channel_cntrl_out_vcalloc_ap;

s_channel_cntrl_out	 <= s_channel_cntrl_out_ch_arb or 
								 s_channel_cntrl_out_vcalloc_n or 
								 --s_channel_cntrl_out_vcalloc_s or 
								 s_channel_cntrl_out_vcalloc_e or 
								 s_channel_cntrl_out_vcalloc_w or 
								 s_channel_cntrl_out_vcalloc_ap;

e_channel_cntrl_out	 <= e_channel_cntrl_out_ch_arb or 
								 e_channel_cntrl_out_vcalloc_n or 
								 e_channel_cntrl_out_vcalloc_s or 
								 --e_channel_cntrl_out_vcalloc_e or 
								 e_channel_cntrl_out_vcalloc_w or 
								 e_channel_cntrl_out_vcalloc_ap;

w_channel_cntrl_out	 <= w_channel_cntrl_out_ch_arb or 
								 w_channel_cntrl_out_vcalloc_n or 
								 w_channel_cntrl_out_vcalloc_s or 
								 w_channel_cntrl_out_vcalloc_e or 
								 --w_channel_cntrl_out_vcalloc_w or 
								 w_channel_cntrl_out_vcalloc_ap;



end Behavioral;
