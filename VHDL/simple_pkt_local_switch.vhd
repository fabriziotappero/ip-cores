
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
-- Filename: simple_pkt_local_switch.vhd
-- 
-- Description: simple switch design
-- 


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.pkg_nocem.all;



entity simple_pkt_local_switch is
    Port ( 
	 

	   -- the arbitration logic controls the switches of data
		arb_grant_output : in arb_decision_array(4 downto 0);
		--arb_grant_input  : in std_logic_vector(4 downto 0);	 
	 
	 
	 	ap_datain        				: in  data_word;
		ap_dataout       				: out data_word;
	 	n_datain              	   : in  data_word;
		n_dataout              		: out data_word;
	 	s_datain               		: in  data_word;
		s_dataout              		: out data_word;
	 	e_datain                	: in  data_word;
		e_dataout               	: out data_word;
	 	w_datain                	: in  data_word;
		w_dataout               	: out data_word;	 
	 
		n_pkt_cntrl_in  : in pkt_cntrl_word;	 
		n_pkt_cntrl_out : out pkt_cntrl_word;	 

		s_pkt_cntrl_in  : in pkt_cntrl_word;	 
		s_pkt_cntrl_out : out pkt_cntrl_word;	 

		e_pkt_cntrl_in  : in pkt_cntrl_word;	 
		e_pkt_cntrl_out : out pkt_cntrl_word;	 

		w_pkt_cntrl_in  : in pkt_cntrl_word;	 
		w_pkt_cntrl_out : out pkt_cntrl_word;	 

		ap_pkt_cntrl_in  : in pkt_cntrl_word;	 
		ap_pkt_cntrl_out : out pkt_cntrl_word;	 

	 
	 	clk : in std_logic;
      rst : in std_logic
			  
	);
end simple_pkt_local_switch;

architecture Behavioral of simple_pkt_local_switch is





begin

switch_gen_process : process (ap_pkt_cntrl_in, n_pkt_cntrl_in, s_pkt_cntrl_in, e_pkt_cntrl_in, w_pkt_cntrl_in,arb_grant_output, ap_datain, n_datain, s_datain, e_datain, w_datain)


begin

   ----------------------------------------------
	---------- do output arbitration -------------
   ----------------------------------------------


--	 	ap_dataout_valid <= '0';	 
--	 	n_dataout_valid        <= '0';
--	 	south_dataout_valid        <= '0';
--	 	east_dataout_valid         <= '0';
--	 	west_dataout_valid         <= '0';


		ap_dataout   		  <= (others => '0');
		n_dataout           <= (others => '0');
		s_dataout           <= (others => '0');
		e_dataout           <= (others => '0');
		w_dataout           <= (others => '0');


  		ap_pkt_cntrl_out    <= (others => '0');
 		n_pkt_cntrl_out     <= (others => '0');
  		s_pkt_cntrl_out	  <= (others => '0');
  		e_pkt_cntrl_out	  <= (others => '0');
  		w_pkt_cntrl_out	  <= (others => '0');


		

	-- foreach output line, simply mux in the incoming lines
	-- based on arbitration decision
	--	arb_grant_output(4) : NORTH
	--	arb_grant_output(3) : SOUTH
	--	arb_grant_output(2) : EAST
	-- arb_grant_output(1) : WEST
	--	arb_grant_output(0) : AP


	case arb_grant_output(NOCEM_AP_IX) is
		when ARB_AP =>
			 ap_dataout <= ap_datain;
			 ap_pkt_cntrl_out	<= ap_pkt_cntrl_in;
		when ARB_NORTH => 
			 ap_dataout <= n_datain;
			 ap_pkt_cntrl_out	<= n_pkt_cntrl_in;
		when ARB_SOUTH => 
			 ap_dataout <= s_datain;
			 ap_pkt_cntrl_out	<= s_pkt_cntrl_in;
		when ARB_EAST => 
			 ap_dataout <= e_datain;
			 ap_pkt_cntrl_out	<= e_pkt_cntrl_in;
		when ARB_WEST => 
			 ap_dataout <= w_datain;
			 ap_pkt_cntrl_out	<= w_pkt_cntrl_in;
		when others =>
			null;
	end case;



	case arb_grant_output(NOCEM_NORTH_IX) is
		when ARB_AP =>
			 n_dataout <= ap_datain;
			 n_pkt_cntrl_out	<= ap_pkt_cntrl_in;
		when ARB_NORTH => 
			 n_dataout <= n_datain;
			 n_pkt_cntrl_out	<= n_pkt_cntrl_in;
		when ARB_SOUTH => 
			 n_dataout <= s_datain;
			 n_pkt_cntrl_out	<= s_pkt_cntrl_in;
		when ARB_EAST => 
			 n_dataout <= e_datain;
			 n_pkt_cntrl_out	<= e_pkt_cntrl_in;
		when ARB_WEST => 
			 n_dataout <= w_datain;
			 n_pkt_cntrl_out	<= w_pkt_cntrl_in;
		when others =>
			null;
	end case;

	case arb_grant_output(NOCEM_SOUTH_IX) is
		when ARB_AP =>
			 s_dataout <= ap_datain;
			 s_pkt_cntrl_out	<= ap_pkt_cntrl_in;
		when ARB_NORTH => 
			 s_dataout <= n_datain;
			 s_pkt_cntrl_out	<= n_pkt_cntrl_in;
		when ARB_SOUTH => 
			 s_dataout <= s_datain;
			 s_pkt_cntrl_out	<= s_pkt_cntrl_in;
		when ARB_EAST => 
			 s_dataout <= e_datain;
			 s_pkt_cntrl_out	<= e_pkt_cntrl_in;
		when ARB_WEST => 
			 s_dataout <= w_datain;
			 s_pkt_cntrl_out	<= w_pkt_cntrl_in;
		when others =>
			null;
	end case;


	case arb_grant_output(NOCEM_EAST_IX) is
		when ARB_AP =>
			 e_dataout <= ap_datain;
			 e_pkt_cntrl_out	<= ap_pkt_cntrl_in;
		when ARB_NORTH => 
			 e_dataout <= n_datain;
			 e_pkt_cntrl_out	<= n_pkt_cntrl_in;
		when ARB_SOUTH => 
			 e_dataout <= s_datain;
			 e_pkt_cntrl_out	<= s_pkt_cntrl_in;
		when ARB_EAST => 
			 e_dataout <= e_datain;
			 e_pkt_cntrl_out	<= e_pkt_cntrl_in;
		when ARB_WEST => 
			 e_dataout <= w_datain;
			 e_pkt_cntrl_out	<= w_pkt_cntrl_in;
		when others =>
			null;
	end case;

	case arb_grant_output(NOCEM_WEST_IX) is
		when ARB_AP =>
			 w_dataout <= ap_datain;
			 w_pkt_cntrl_out	<= ap_pkt_cntrl_in;
		when ARB_NORTH => 
			 w_dataout <= n_datain;
			 w_pkt_cntrl_out	<= n_pkt_cntrl_in;
		when ARB_SOUTH => 
			 w_dataout <= s_datain;
			 w_pkt_cntrl_out	<= s_pkt_cntrl_in;
		when ARB_EAST => 
			 w_dataout <= e_datain;
			 w_pkt_cntrl_out	<= e_pkt_cntrl_in;
		when ARB_WEST => 
			 w_dataout <= w_datain;
			 w_pkt_cntrl_out	<= w_pkt_cntrl_in;
		when others =>
			null;
	end case;


   ----------------------------------------------
	---------- END do output arbitration ---------
   ----------------------------------------------

	


	


end process;




end Behavioral;
