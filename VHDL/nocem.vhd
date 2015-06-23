
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
-- Filename: nocem.vhd
-- 
-- Description: toplevel nocem entity
-- 


---------------------------------------
--
--	NOCEM toplevel: defines generics and input interfaces
--						 for this NoC Emulator
--
---------------------------------------



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--library UNISIM;
--use UNISIM.VComponents.all;

use work.pkg_nocem.all;

entity nocem is
   Port( 

		-- arbitration lines (usage depends on underlying network)
		arb_req         : in  std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		arb_cntrl_in    : in  arb_cntrl_array(NOCEM_NUM_AP-1 downto 0);

		arb_grant         : out std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		arb_cntrl_out     : out  arb_cntrl_array(NOCEM_NUM_AP-1 downto 0);

		--data and control incoming/outgoing line (usage depends on underlying network)
		datain        : in   data_array(NOCEM_NUM_AP-1 downto 0);
		datain_valid  : in   std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		datain_recvd  : out  std_logic_vector(NOCEM_NUM_AP-1 downto 0);

		dataout       : out data_array(NOCEM_NUM_AP-1 downto 0);
		dataout_valid : out std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		dataout_recvd : in  std_logic_vector(NOCEM_NUM_AP-1 downto 0);

		pkt_cntrl_in        : in   pkt_cntrl_array(NOCEM_NUM_AP-1 downto 0);
		pkt_cntrl_in_valid  : in   std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		pkt_cntrl_in_recvd  : out  std_logic_vector(NOCEM_NUM_AP-1 downto 0);      
             
		pkt_cntrl_out       : out pkt_cntrl_array(NOCEM_NUM_AP-1 downto 0);
		pkt_cntrl_out_valid : out std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		pkt_cntrl_out_recvd : in  std_logic_vector(NOCEM_NUM_AP-1 downto 0);

		clk : in std_logic;
      rst : in std_logic
		
	);


end nocem;




architecture Behavioral of nocem is


signal arb_grant_i :  std_logic_vector(NOCEM_NUM_AP-1 downto 0);
signal vcc_num_ap : std_logic_vector( NOCEM_NUM_AP-1 downto 0);

begin


	vcc_num_ap <= (others => '1');


---------------------------------------------------------------
--	BUS TYPE: only for legacy testing of bus architectures	---
--	not specifically a NoC												---
---------------------------------------------------------------

	g1 : if NOCEM_TYPE = NOCEM_BUS_TYPE generate 

		arb_grant <= arb_grant_i;
  	
		-- bus arbitration logic goes here
		I_arb_bus_nocem: arb_bus_nocem 
			PORT MAP(
				arb_req => arb_req,
				arb_grant => arb_grant_i,
				clk => clk,
				rst => rst
			);

	-- bus interconnect logic goes here
	I_ic_bus_nocem: ic_bus_nocem 
		PORT MAP(
			arb_grant => arb_grant_i,
			datain => datain,
			dataout => dataout,
			dataout_valid => dataout_valid,
			addrin => pkt_cntrl_in,
			addrout => pkt_cntrl_out,
			addrout_valid => pkt_cntrl_out_valid,
			clk => clk,
			rst => rst
	);


	end generate;


-------------------------------------------------------------------------
--	PACKET BASED: packet based noc (i.e. not a BUS!)						 ---
-------------------------------------------------------------------------
	g2 : if NOCEM_TYPE = NOCEM_SIMPLE_PKT_TYPE or NOCEM_TYPE = NOCEM_VC_TYPE generate


	I_ic_nocem : ic_pkt_nocem 
	PORT MAP(
		arb_req => arb_req,
		arb_cntrl_in => arb_cntrl_in,
		arb_grant => arb_grant,
		arb_cntrl_out => arb_cntrl_out,
		datain => datain,
		datain_valid => datain_valid,
		datain_recvd => datain_recvd,
		dataout => dataout,
		dataout_valid => dataout_valid,
		dataout_recvd => dataout_recvd,
		pkt_cntrl_in => pkt_cntrl_in,
		pkt_cntrl_in_valid => pkt_cntrl_in_valid,
		pkt_cntrl_in_recvd => pkt_cntrl_in_recvd,
		pkt_cntrl_out => pkt_cntrl_out,
		pkt_cntrl_out_valid => pkt_cntrl_out_valid,
		pkt_cntrl_out_recvd => pkt_cntrl_out_recvd,
   	clk => clk,
   	rst => rst 
	);
	end generate;



end Behavioral;
