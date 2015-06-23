
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
-- Filename: testbench.vhd
-- 
-- Description: 
-- 


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.pkg_nocem.all;



entity testbench is
end testbench;

architecture Behavioral of testbench is


		signal clk,rst : std_logic;


		-- arbitration lines (usage depends on underlying network)
		signal arb_req         : std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		signal arb_cntrl_noc2proc   : arb_cntrl_array(NOCEM_NUM_AP-1 downto 0);
		signal arb_grant         : std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		signal arb_cntrl_proc2noc   : arb_cntrl_array(NOCEM_NUM_AP-1 downto 0);
		signal noc_node_data        :   data_array(NOCEM_NUM_AP-1 downto 0);
		signal noc_node_data_valid  :   std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		signal noc_node_data_recvd  :  std_logic_vector(NOCEM_NUM_AP-1 downto 0);

		signal node_noc_data       : data_array(NOCEM_NUM_AP-1 downto 0);
		signal node_noc_data_valid : std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		signal node_noc_data_recvd :  std_logic_vector(NOCEM_NUM_AP-1 downto 0);

		signal noc_node_pkt_cntrl        :   pkt_cntrl_array(NOCEM_NUM_AP-1 downto 0);
		signal noc_node_pkt_cntrl_valid  :   std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		signal noc_node_pkt_cntrl_recvd  :  std_logic_vector(NOCEM_NUM_AP-1 downto 0);      
             
		signal node_noc_pkt_cntrl       : pkt_cntrl_array(NOCEM_NUM_AP-1 downto 0);
		signal node_noc_pkt_cntrl_valid : std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		signal node_noc_pkt_cntrl_recvd :  std_logic_vector(NOCEM_NUM_AP-1 downto 0);

		signal test_val0,test_val1,test_val2,test_val3 : integer;


		type int_array  is array(natural range <>) of integer;
		--constant DATAOUT_INTERVAL : int_array(NOCEM_NUM_AP-1 downto 0) := (60000,60000,32,16);
		constant DATAOUT_INTERVAL : int_array(NOCEM_NUM_AP-1 downto 0) := (48,16,32,16);

begin




	test_val0 <= DATAOUT_INTERVAL(0);
	test_val1 <= DATAOUT_INTERVAL(1);
	test_val2 <= DATAOUT_INTERVAL(2);
	test_val3 <= DATAOUT_INTERVAL(3);


	I_noc: nocem PORT MAP(
		arb_req => arb_req,
		arb_cntrl_in => arb_cntrl_proc2noc,
		arb_grant => arb_grant,
		arb_cntrl_out => arb_cntrl_noc2proc,
		datain => node_noc_data,
		datain_valid => node_noc_data_valid,
		datain_recvd => noc_node_data_recvd,
		dataout => noc_node_data,
		dataout_valid => noc_node_data_valid,
		dataout_recvd => node_noc_data_recvd,
		pkt_cntrl_in => node_noc_pkt_cntrl,
		pkt_cntrl_in_valid => node_noc_pkt_cntrl_valid,
		pkt_cntrl_in_recvd => noc_node_pkt_cntrl_recvd,
		pkt_cntrl_out => noc_node_pkt_cntrl,
		pkt_cntrl_out_valid => noc_node_pkt_cntrl_valid,
		pkt_cntrl_out_recvd => node_noc_pkt_cntrl_recvd,
		clk => clk,
		rst => rst
	);





	
   g1: for I in NOCEM_NUM_AP-1 downto 0 generate



		g11: if NOCEM_TYPE = NOCEM_VC_TYPE generate
			I_ap_ex: ap_exerciser_vc 
		
		   Generic map(
				DELAY_START_COUNTER_WIDTH => 8,
				DELAY_START_CYCLES  => 10+I*8,
				INTERVAL_COUNTER_WIDTH  => 16,
				PKT_LENGTH  => 4+I,
				INIT_DEST_ADDR => (I+1) mod NOCEM_NUM_AP,
				MY_ADDR => I,
				DATA_OUT_INTERVAL  => DATAOUT_INTERVAL(I)
			)		
		
			PORT MAP(
				arb_req => arb_req(I),
				arb_cntrl_in => arb_cntrl_noc2proc(I),
				arb_grant => arb_grant(I),
				arb_cntrl_out => arb_cntrl_proc2noc(I),
				dataout => node_noc_data(I),
				dataout_valid => node_noc_data_valid(I),
				dataout_recvd => noc_node_data_recvd(I),
				datain => noc_node_data(I),
				datain_valid => noc_node_data_valid(I),
				datain_recvd => node_noc_data_recvd(I),
				pkt_cntrl_out => node_noc_pkt_cntrl(I),
				pkt_cntrl_out_valid => node_noc_pkt_cntrl_valid(I),
				pkt_cntrl_out_recvd => noc_node_pkt_cntrl_recvd(I),
				pkt_cntrl_in => noc_node_pkt_cntrl(I),
				pkt_cntrl_in_valid => noc_node_pkt_cntrl_valid(I),
				pkt_cntrl_in_recvd => node_noc_pkt_cntrl_recvd(I),
				clk => clk,
				rst => rst
			);		
		end generate;
		
		g12: if NOCEM_TYPE = NOCEM_SIMPLE_PKT_TYPE generate		

			I_ap_ex: access_point_exerciser 
		
		   Generic map(
				DELAY_START_COUNTER_WIDTH => 8,
				DELAY_START_CYCLES  => 10+I*8,
				INIT_DATA_OUT  => CONV_STD_LOGIC_VECTOR(I+1+2**I,NOCEM_DW),
				INTERVAL_COUNTER_WIDTH  => 16,
				BURST_LENGTH  => 1,
				INIT_DEST_ADDR => (I+1) mod NOCEM_NUM_AP,

				DATA_OUT_INTERVAL  => 15
			)		
		
			PORT MAP(
				arb_req => arb_req(I),
				arb_cntrl_in => arb_cntrl_noc2proc(I),
				arb_grant => arb_grant(I),
				arb_cntrl_out => arb_cntrl_proc2noc(I),
				dataout => node_noc_data(I),
				dataout_valid => node_noc_data_valid(I),
				dataout_recvd => noc_node_data_recvd(I),
				datain => noc_node_data(I),
				datain_valid => noc_node_data_valid(I),
				datain_recvd => node_noc_data_recvd(I),
				pkt_cntrl_out => node_noc_pkt_cntrl(I),
				pkt_cntrl_out_valid => node_noc_pkt_cntrl_valid(I),
				pkt_cntrl_out_recvd => noc_node_pkt_cntrl_recvd(I),
				pkt_cntrl_in => noc_node_pkt_cntrl(I),
				pkt_cntrl_in_valid => noc_node_pkt_cntrl_valid(I),
				pkt_cntrl_in_recvd => node_noc_pkt_cntrl_recvd(I),
				clk => clk,
				rst => rst
			);
		end generate;
	end generate;




  P_STIMULUS: process
  begin  -- process P_STIMULUS
    rst <= '1';
    wait for 250 ns;
    rst <= '0';
	wait for 1000 ms;               -- forever!
  end process P_STIMULUS;

p_clk : process                    -- drives clk 
  begin
    clk <= '0';
    wait for 2 ns;
    loop
      wait for 4 ns;
      clk <= '1';
      wait for 4 ns;
      clk <= '0';
    end loop;
  end process p_clk;



end Behavioral;
