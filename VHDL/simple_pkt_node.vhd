
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
-- Filename: simple_pkt_node.vhd
-- 
-- Description: toplevel node for nonVC designs
-- 


--
--
--	 A node in a packet switched NoC consists of arbitration and switching logic....
--
--
--
--



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.pkg_nocem.all;




entity simple_pkt_node is



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
end simple_pkt_node;

architecture Behavioral of simple_pkt_node is


		signal arb_grant_output : arb_decision_array(4 downto 0);

		-- the arbiter may be able to write the pkt_cntrl word before it gets
		-- muxed out to the output ports, therefore need internal signal
		signal n_pkt_cntrl_out_i : pkt_cntrl_word;
		signal s_pkt_cntrl_out_i : pkt_cntrl_word;
		signal e_pkt_cntrl_out_i : pkt_cntrl_word;
	   signal w_pkt_cntrl_out_i : pkt_cntrl_word;
	   signal ap_pkt_cntrl_out_i : pkt_cntrl_word;

begin



	I_local_arb : simple_pkt_local_arb PORT MAP(
		local_arb_addr => local_arb_addr,
		arb_grant_output => arb_grant_output,
		n_pkt_cntrl_in => n_pkt_cntrl_in,
		n_pkt_cntrl_out => n_pkt_cntrl_out_i,
		n_channel_cntrl_in => n_channel_cntrl_in,
		n_channel_cntrl_out => n_channel_cntrl_out,
		s_pkt_cntrl_in => s_pkt_cntrl_in,
		s_pkt_cntrl_out => s_pkt_cntrl_out_i,
		s_channel_cntrl_in => s_channel_cntrl_in,
		s_channel_cntrl_out => s_channel_cntrl_out,
		e_pkt_cntrl_in => e_pkt_cntrl_in,
		e_pkt_cntrl_out => e_pkt_cntrl_out_i,
		e_channel_cntrl_in => e_channel_cntrl_in,
		e_channel_cntrl_out => e_channel_cntrl_out,
		w_pkt_cntrl_in => w_pkt_cntrl_in,
		w_pkt_cntrl_out => w_pkt_cntrl_out_i,
		w_channel_cntrl_in => w_channel_cntrl_in,
		w_channel_cntrl_out => w_channel_cntrl_out,
		ap_pkt_cntrl_in => ap_pkt_cntrl_in,
		ap_pkt_cntrl_out => ap_pkt_cntrl_out_i,
		ap_channel_cntrl_in => ap_channel_cntrl_in,
		ap_channel_cntrl_out => ap_channel_cntrl_out,
		clk => clk,
		rst => rst 
	);


	I_local_switch : simple_pkt_local_switch PORT MAP(
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
		n_pkt_cntrl_in => n_pkt_cntrl_out_i,
		n_pkt_cntrl_out => n_pkt_cntrl_out,
		s_pkt_cntrl_in => s_pkt_cntrl_out_i,
		s_pkt_cntrl_out => s_pkt_cntrl_out,
		e_pkt_cntrl_in => e_pkt_cntrl_out_i,
		e_pkt_cntrl_out => e_pkt_cntrl_out,
		w_pkt_cntrl_in => w_pkt_cntrl_out_i,
		w_pkt_cntrl_out => w_pkt_cntrl_out,
		ap_pkt_cntrl_in => ap_pkt_cntrl_out_i,
		ap_pkt_cntrl_out => ap_pkt_cntrl_out,
		clk => clk,
		rst =>  rst
	);


end Behavioral;
