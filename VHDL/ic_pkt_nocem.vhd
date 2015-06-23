
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
-- Filename: ic_pkt_nocem.vhd
-- 
-- Description: the standard interconnect for pkts
-- 


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


use work.pkg_nocem.all;



entity ic_pkt_nocem is

    Port ( 

		-- arbitration lines (usage depends on underlying network)
		arb_req         : in  std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		arb_cntrl_in   : in  arb_cntrl_array(NOCEM_NUM_AP-1 downto 0);

		arb_grant         : out std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		arb_cntrl_out   : out  arb_cntrl_array(NOCEM_NUM_AP-1 downto 0);

	 
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
end ic_pkt_nocem;

architecture Behavioral of ic_pkt_nocem is





	-- for type conversion of x,y coordinates to std_logic_vector
	signal local_arb_addr_converted : node_addr_array(NOCEM_NUM_AP-1 downto 0);


	-- an aggregration of the data lines, should help in looping to create necessary signals
	signal n_to_fifo_data : data_array(NOCEM_NUM_AP-1 downto 0);
	signal fifo_to_s_data : data_array(NOCEM_NUM_AP-1 downto 0);

	signal s_to_fifo_data : data_array(NOCEM_NUM_AP-1 downto 0);
	signal fifo_to_n_data : data_array(NOCEM_NUM_AP-1 downto 0);

	signal e_to_fifo_data : data_array(NOCEM_NUM_AP-1 downto 0);
	signal fifo_to_w_data : data_array(NOCEM_NUM_AP-1 downto 0);

	signal w_to_fifo_data : data_array(NOCEM_NUM_AP-1 downto 0);
	signal fifo_to_e_data : data_array(NOCEM_NUM_AP-1 downto 0);

	signal ap_to_fifo_data   : data_array(NOCEM_NUM_AP-1 downto 0);
	signal fifo_to_node_data : data_array(NOCEM_NUM_AP-1 downto 0);

	signal node_to_fifo_data : data_array(NOCEM_NUM_AP-1 downto 0);
	signal fifo_to_ap_data   : data_array(NOCEM_NUM_AP-1 downto 0);


	-- an aggregration of the pkt_cntrls, should help in looping to create necessary signals
	signal n_to_fifo_pkt_cntrl : pkt_cntrl_array(NOCEM_NUM_AP-1 downto 0);
	signal fifo_to_s_pkt_cntrl : pkt_cntrl_array(NOCEM_NUM_AP-1 downto 0);

	signal s_to_fifo_pkt_cntrl : pkt_cntrl_array(NOCEM_NUM_AP-1 downto 0);
	signal fifo_to_n_pkt_cntrl : pkt_cntrl_array(NOCEM_NUM_AP-1 downto 0);

	signal e_to_fifo_pkt_cntrl : pkt_cntrl_array(NOCEM_NUM_AP-1 downto 0);
	signal fifo_to_w_pkt_cntrl : pkt_cntrl_array(NOCEM_NUM_AP-1 downto 0);

	signal w_to_fifo_pkt_cntrl : pkt_cntrl_array(NOCEM_NUM_AP-1 downto 0);
	signal fifo_to_e_pkt_cntrl : pkt_cntrl_array(NOCEM_NUM_AP-1 downto 0);

	signal ap_to_fifo_pkt_cntrl   : pkt_cntrl_array(NOCEM_NUM_AP-1 downto 0);
	signal fifo_to_node_pkt_cntrl : pkt_cntrl_array(NOCEM_NUM_AP-1 downto 0);

	signal node_to_fifo_pkt_cntrl : pkt_cntrl_array(NOCEM_NUM_AP-1 downto 0);
	signal fifo_to_ap_pkt_cntrl   : pkt_cntrl_array(NOCEM_NUM_AP-1 downto 0);




	-- an aggregration of the channel_cntrls, should help in looping to create necessary signals
	-- naming convention is : <direction from node> _ fifo channel	control
	--								  fifo _ <direction from node> channel control

	-- example n_fifo_ch_cntrl: from node channel of node to fifo below
	--			  fifo_e_ch_cntrl: from fifo to east channel of node

	signal n_fifo_ch_cntrl : channel_cntrl_array(NOCEM_NUM_AP-1 downto 0);
	signal fifo_n_ch_cntrl : channel_cntrl_array(NOCEM_NUM_AP-1 downto 0);

	signal s_fifo_ch_cntrl : channel_cntrl_array(NOCEM_NUM_AP-1 downto 0);
	signal fifo_s_ch_cntrl : channel_cntrl_array(NOCEM_NUM_AP-1 downto 0);

	signal e_fifo_ch_cntrl : channel_cntrl_array(NOCEM_NUM_AP-1 downto 0);
	signal fifo_e_ch_cntrl : channel_cntrl_array(NOCEM_NUM_AP-1 downto 0);

	signal w_fifo_ch_cntrl : channel_cntrl_array(NOCEM_NUM_AP-1 downto 0);
	signal fifo_w_ch_cntrl : channel_cntrl_array(NOCEM_NUM_AP-1 downto 0);

	signal ap_fifo_ch_cntrl   : channel_cntrl_array(NOCEM_NUM_AP-1 downto 0);
	signal fifo_ap_ch_cntrl   : channel_cntrl_array(NOCEM_NUM_AP-1 downto 0);
	
	-- node: the actual PE, fifo connecting node to NoC switch
	signal fifo_node_ch_cntrl   : channel_cntrl_array(NOCEM_NUM_AP-1 downto 0);
	signal node_fifo_ch_cntrl   : channel_cntrl_array(NOCEM_NUM_AP-1 downto 0);


	-- signals that will be tied to (others => '0');
	signal data_z : data_word;
	signal pkt_cntrl_z  : pkt_cntrl_word;
	signal ch_cntrl_z	  : channel_cntrl_word;






begin


	data_z 	   <= (others => '0');
	pkt_cntrl_z	<= (others => '0');
	ch_cntrl_z	<= (others => '0');





--instantiate nodes, fifos
g1: for I in NOCEM_NUM_AP-1 downto 0 generate

	local_arb_addr_converted(I) <= addr_gen(I,NOCEM_NUM_ROWS,NOCEM_NUM_COLS,NOCEM_AW);



	g11: if NOCEM_TYPE = NOCEM_VC_TYPE	generate 
		I_vc_node : vc_node PORT MAP(
			local_arb_addr => local_arb_addr_converted(I),

			n_datain => fifo_to_n_data(I),
			n_pkt_cntrl_in => fifo_to_n_pkt_cntrl(I),
			n_dataout => n_to_fifo_data(I),
			n_pkt_cntrl_out => n_to_fifo_pkt_cntrl(I),
			n_channel_cntrl_in => fifo_n_ch_cntrl(I),
			n_channel_cntrl_out => n_fifo_ch_cntrl(I),

			s_datain => fifo_to_s_data(I),
			s_pkt_cntrl_in => fifo_to_s_pkt_cntrl(I),
			s_dataout => s_to_fifo_data(I),
			s_pkt_cntrl_out => s_to_fifo_pkt_cntrl(I),
			s_channel_cntrl_in => fifo_s_ch_cntrl(I),
			s_channel_cntrl_out => s_fifo_ch_cntrl(I),

			e_datain => fifo_to_e_data(I),
			e_pkt_cntrl_in => fifo_to_e_pkt_cntrl(I),
			e_dataout => e_to_fifo_data(I),
			e_pkt_cntrl_out => e_to_fifo_pkt_cntrl(I),
			e_channel_cntrl_in => fifo_e_ch_cntrl(I),
			e_channel_cntrl_out => e_fifo_ch_cntrl(I),

			w_datain => fifo_to_w_data(I),
			w_pkt_cntrl_in => fifo_to_w_pkt_cntrl(I),
			w_dataout => w_to_fifo_data(I),
			w_pkt_cntrl_out => w_to_fifo_pkt_cntrl(I),
			w_channel_cntrl_in => fifo_w_ch_cntrl(I),
			w_channel_cntrl_out => w_fifo_ch_cntrl(I),

			ap_datain => fifo_to_ap_data(I),
			ap_pkt_cntrl_in => fifo_to_ap_pkt_cntrl(I),
			ap_dataout => ap_to_fifo_data(I),
			ap_pkt_cntrl_out => ap_to_fifo_pkt_cntrl(I),
			ap_channel_cntrl_in => fifo_ap_ch_cntrl(I),
			ap_channel_cntrl_out => ap_fifo_ch_cntrl(I),

			clk => clk,
			rst => rst
		);			
   end generate;
		
							
	g12: if NOCEM_TYPE = NOCEM_SIMPLE_PKT_TYPE	generate 
		I_simple_pkt_node : simple_pkt_node PORT MAP(
			local_arb_addr => local_arb_addr_converted(I),

			n_datain => fifo_to_n_data(I),
			n_pkt_cntrl_in => fifo_to_n_pkt_cntrl(I),
			n_dataout => n_to_fifo_data(I),
			n_pkt_cntrl_out => n_to_fifo_pkt_cntrl(I),
			n_channel_cntrl_in => fifo_n_ch_cntrl(I),
			n_channel_cntrl_out => n_fifo_ch_cntrl(I),

			s_datain => fifo_to_s_data(I),
			s_pkt_cntrl_in => fifo_to_s_pkt_cntrl(I),
			s_dataout => s_to_fifo_data(I),
			s_pkt_cntrl_out => s_to_fifo_pkt_cntrl(I),
			s_channel_cntrl_in => fifo_s_ch_cntrl(I),
			s_channel_cntrl_out => s_fifo_ch_cntrl(I),

			e_datain => fifo_to_e_data(I),
			e_pkt_cntrl_in => fifo_to_e_pkt_cntrl(I),
			e_dataout => e_to_fifo_data(I),
			e_pkt_cntrl_out => e_to_fifo_pkt_cntrl(I),
			e_channel_cntrl_in => fifo_e_ch_cntrl(I),
			e_channel_cntrl_out => e_fifo_ch_cntrl(I),

			w_datain => fifo_to_w_data(I),
			w_pkt_cntrl_in => fifo_to_w_pkt_cntrl(I),
			w_dataout => w_to_fifo_data(I),
			w_pkt_cntrl_out => w_to_fifo_pkt_cntrl(I),
			w_channel_cntrl_in => fifo_w_ch_cntrl(I),
			w_channel_cntrl_out => w_fifo_ch_cntrl(I),

			ap_datain => fifo_to_ap_data(I),
			ap_pkt_cntrl_in => fifo_to_ap_pkt_cntrl(I),
			ap_dataout => ap_to_fifo_data(I),
			ap_pkt_cntrl_out => ap_to_fifo_pkt_cntrl(I),
			ap_channel_cntrl_in => fifo_ap_ch_cntrl(I),
			ap_channel_cntrl_out => ap_fifo_ch_cntrl(I),

			clk => clk,
			rst => rst
		);
	end generate;

end generate;

	-- generate the fifos on outgoing paths
	g2 : for I in NOCEM_NUM_AP-1 downto 0 generate


---------------------------------------------------------------
------               TOPLVEL WIRING                        ----            
---------------------------------------------------------------

		channel_cntrl_handling : process (arb_cntrl_in,node_fifo_ch_cntrl,datain_valid, arb_req, fifo_node_ch_cntrl, pkt_cntrl_in_valid, dataout_recvd, pkt_cntrl_out_recvd)
		begin
	
			arb_cntrl_out(I) <= (others => '0');

			-- first set control all to zeroes, let following statements overwrite values
			node_fifo_ch_cntrl(I) <= (others => '0');

			-- WE gets set when request comes in and the FIFO is not full
			if NOCEM_TYPE = NOCEM_VC_TYPE then
				-- with VCs, things are a little simpler....
				node_fifo_ch_cntrl(I)(NOCEM_CHFIFO_DATA_WE_IX)  <=  arb_req(I) and datain_valid(I);
				node_fifo_ch_cntrl(I)(NOCEM_CHFIFO_CNTRL_WE_IX) <=  arb_req(I) and pkt_cntrl_in_valid(I);

				-- grant occurs when a write enable is allowed (see lines above)
				arb_grant(I)    <= node_fifo_ch_cntrl(I)(NOCEM_CHFIFO_DATA_WE_IX) or node_fifo_ch_cntrl(I)(NOCEM_CHFIFO_CNTRL_WE_IX);

				datain_recvd(I) <= node_fifo_ch_cntrl(I)(NOCEM_CHFIFO_DATA_WE_IX);
				pkt_cntrl_in_recvd(I) <= node_fifo_ch_cntrl(I)(NOCEM_CHFIFO_CNTRL_WE_IX);


				-- handling dataout valid, recvd signals
				-- for VCs, the state of dataout is controlled by user watching for full packets
				dataout_valid(I) <= '1';
				node_fifo_ch_cntrl(I)(NOCEM_CHFIFO_DATA_RE_IX) <= dataout_recvd(I);

				pkt_cntrl_out_valid(I) <= '1';
				node_fifo_ch_cntrl(I)(NOCEM_CHFIFO_CNTRL_RE_IX) <= pkt_cntrl_out_recvd(I);
				node_fifo_ch_cntrl(I)(NOCEM_CHFIFO_VC_RD_ADDR_HIX downto NOCEM_CHFIFO_VC_RD_ADDR_LIX) <= arb_cntrl_in(I)(NOCEM_ARB_CNTRL_VC_MUX_RD_HIX downto NOCEM_ARB_CNTRL_VC_MUX_RD_LIX);

		   else
				node_fifo_ch_cntrl(I)(NOCEM_CHFIFO_DATA_WE_IX)  <=  arb_req(I) and datain_valid(I) and fifo_node_ch_cntrl(I)(NOCEM_CHFIFO_DATA_FULL_N_IX);
				node_fifo_ch_cntrl(I)(NOCEM_CHFIFO_CNTRL_WE_IX) <=  arb_req(I) and pkt_cntrl_in_valid(I) and fifo_node_ch_cntrl(I)(NOCEM_CHFIFO_CNTRL_FULL_N_IX);

				-- grant occurs when a write enable is allowed (see lines above)
				arb_grant(I)    <= node_fifo_ch_cntrl(I)(NOCEM_CHFIFO_DATA_WE_IX) or node_fifo_ch_cntrl(I)(NOCEM_CHFIFO_CNTRL_WE_IX);

				datain_recvd(I) <= node_fifo_ch_cntrl(I)(NOCEM_CHFIFO_DATA_WE_IX);
				pkt_cntrl_in_recvd(I) <= node_fifo_ch_cntrl(I)(NOCEM_CHFIFO_CNTRL_WE_IX);

				-- handling dataout valid, recvd signals
				dataout_valid(I) <= fifo_node_ch_cntrl(I)(NOCEM_CHFIFO_DATA_EMPTY_N_IX);
				node_fifo_ch_cntrl(I)(NOCEM_CHFIFO_DATA_RE_IX) <= dataout_recvd(I);

				pkt_cntrl_out_valid(I) <= fifo_node_ch_cntrl(I)(NOCEM_CHFIFO_CNTRL_EMPTY_N_IX);
				node_fifo_ch_cntrl(I)(NOCEM_CHFIFO_CNTRL_RE_IX) <= pkt_cntrl_out_recvd(I);

			end if;



			-- VC signalling to/from node
			node_fifo_ch_cntrl(I)(NOCEM_CHFIFO_VC_WR_ADDR_HIX downto NOCEM_CHFIFO_VC_WR_ADDR_LIX) <= arb_cntrl_in(I)(NOCEM_ARB_CNTRL_VC_MUX_WR_HIX downto NOCEM_ARB_CNTRL_VC_MUX_WR_LIX);
			arb_cntrl_out(I)(NOCEM_ARB_CNTRL_VC_EOP_WR_HIX downto NOCEM_ARB_CNTRL_VC_EOP_WR_LIX) <= fifo_node_ch_cntrl(I)(NOCEM_CHFIFO_VC_EOP_WR_HIX downto NOCEM_CHFIFO_VC_EOP_WR_LIX);	
			arb_cntrl_out(I)(NOCEM_ARB_CNTRL_VC_EOP_RD_HIX downto NOCEM_ARB_CNTRL_VC_EOP_RD_LIX) <= fifo_node_ch_cntrl(I)(NOCEM_CHFIFO_VC_EOP_RD_HIX downto NOCEM_CHFIFO_VC_EOP_RD_LIX);	

--constant NOCEM_ARB_CNTRL_VC_EOP_RD_LIX  	  : integer 		:= NOCEM_ARB_CNTRL_VC_MUX_RD_HIX+1;	--8
--constant NOCEM_ARB_CNTRL_VC_EOP_RD_HIX 	  : integer 		:= NOCEM_ARB_CNTRL_VC_EOP_RD_LIX+NOCEM_NUM_VC-1;
--
--constant NOCEM_ARB_CNTRL_VC_EOP_WR_LIX  	  : integer 		:= NOCEM_ARB_CNTRL_VC_EOP_RD_HIX+1;	--12
--constant NOCEM_ARB_CNTRL_VC_EOP_WR_HIX 	  : integer 		:= NOCEM_ARB_CNTRL_VC_EOP_WR_LIX+NOCEM_NUM_VC-1;
--

		end process;


---------------------------------------------------------------
---------------------------------------------------------------
------               ACCESS POINT FIFOs                    ----            
---------------------------------------------------------------
---------------------------------------------------------------

	channel_ap_noc : channel_fifo 	
	generic map(
	  P0_NODE_ADDR	=> I,
	  P1_NODE_ADDR =>	I,
	  IS_AN_ACCESS_POINT_CHANNEL => TRUE
	)
	PORT MAP(
		p0_datain => datain(I),
		p0_pkt_cntrl_in => pkt_cntrl_in(I),
		p0_dataout => dataout(I),
		p0_pkt_cntrl_out => pkt_cntrl_out(I),
		p0_channel_cntrl_in => node_fifo_ch_cntrl(I),
		p0_channel_cntrl_out => fifo_node_ch_cntrl(I),
		p1_datain => ap_to_fifo_data(I),
		p1_pkt_cntrl_in => ap_to_fifo_pkt_cntrl(I),
		p1_dataout => fifo_to_ap_data(I),
		p1_pkt_cntrl_out => fifo_to_ap_pkt_cntrl(I),
		p1_channel_cntrl_in => ap_fifo_ch_cntrl(I),
		p1_channel_cntrl_out => fifo_ap_ch_cntrl(I),
		clk => clk,
		rst => rst
	);



---------------------------------------------------------------
---------------------------------------------------------------
------               NORTH / SOUTH FIFOs                   ----            
---------------------------------------------------------------
---------------------------------------------------------------

-- top:				top of chip, with ap's below it
--	middle:  		middle of chip, ap's above and beloe
--	bottom:  		bottom of chip, with ap's above it
--	single row: 	no need for north south fifos


		-- top of chip
	 	g3: if (I+NOCEM_NUM_COLS) / NOCEM_NUM_COLS = NOCEM_NUM_ROWS and NOCEM_NUM_ROWS /= 1 generate





			g33: if NOCEM_TOPOLOGY_TYPE = NOCEM_TOPOLOGY_TORUS or 
			        NOCEM_TOPOLOGY_TYPE = NOCEM_TOPOLOGY_DTORUS generate
	
				channel_ns_tdt : channel_fifo 
				generic map(
				  P0_NODE_ADDR	=> I,
				  P1_NODE_ADDR =>	I mod NOCEM_NUM_COLS,
	  			  IS_AN_ACCESS_POINT_CHANNEL => FALSE
				)
				PORT MAP(
					p0_datain => n_to_fifo_data(I),
					p0_pkt_cntrl_in => n_to_fifo_pkt_cntrl(I),
					p0_dataout => fifo_to_n_data(I),
					p0_pkt_cntrl_out => fifo_to_n_pkt_cntrl(I),
					p0_channel_cntrl_in => n_fifo_ch_cntrl(I),
					p0_channel_cntrl_out => fifo_n_ch_cntrl(I),
					p1_datain => s_to_fifo_data(I mod NOCEM_NUM_COLS),
					p1_pkt_cntrl_in => s_to_fifo_pkt_cntrl(I mod NOCEM_NUM_COLS),
					p1_dataout => fifo_to_s_data(I mod NOCEM_NUM_COLS),
					p1_pkt_cntrl_out => fifo_to_s_pkt_cntrl(I mod NOCEM_NUM_COLS),
					p1_channel_cntrl_in => s_fifo_ch_cntrl(I mod NOCEM_NUM_COLS),
					p1_channel_cntrl_out => fifo_s_ch_cntrl(I mod NOCEM_NUM_COLS),
					clk => clk,
					rst => rst
				);	
	
	
	
			end generate;


		  g34: if NOCEM_TOPOLOGY_TYPE = NOCEM_TOPOLOGY_MESH generate
				

				-- leave here just in case....
--				channel_ns_mesh : channel_fifo PORT MAP(
--					p0_datain => data_z,
--					p0_pkt_cntrl_in => pkt_cntrl_z,
--					p0_dataout => open,
--					p0_pkt_cntrl_out => open,
--					p0_channel_cntrl_in => ch_cntrl_z,
--					p0_channel_cntrl_out => open,
--					p1_datain => data_z,
--					p1_pkt_cntrl_in => pkt_cntrl_z,
--					p1_dataout => open,
--					p1_pkt_cntrl_out => open,
--					p1_channel_cntrl_in => ch_cntrl_z,
--					p1_channel_cntrl_out => open,
--					clk => clk,
--					rst => rst
--				);

			end generate;


		end generate;




		
		-- bottom of chip
	 	g4: if I / NOCEM_NUM_COLS = 0 and NOCEM_NUM_ROWS /= 1 generate



		channel_ns : channel_fifo 
		generic map(
				P0_NODE_ADDR => I,
				P1_NODE_ADDR => I+NOCEM_NUM_COLS,
	  			IS_AN_ACCESS_POINT_CHANNEL => FALSE
				)				
		PORT MAP(
			p0_datain => n_to_fifo_data(I),
			p0_pkt_cntrl_in => n_to_fifo_pkt_cntrl(I),
			p0_dataout => fifo_to_n_data(I),
			p0_pkt_cntrl_out => fifo_to_n_pkt_cntrl(I),
			p0_channel_cntrl_in => n_fifo_ch_cntrl(I),
			p0_channel_cntrl_out => fifo_n_ch_cntrl(I),

			p1_datain => s_to_fifo_data(I+NOCEM_NUM_COLS),
			p1_pkt_cntrl_in => s_to_fifo_pkt_cntrl(I+NOCEM_NUM_COLS),
			p1_dataout => fifo_to_s_data(I+NOCEM_NUM_COLS),
			p1_pkt_cntrl_out => fifo_to_s_pkt_cntrl(I+NOCEM_NUM_COLS),
			p1_channel_cntrl_in => s_fifo_ch_cntrl(I+NOCEM_NUM_COLS),
			p1_channel_cntrl_out => fifo_s_ch_cntrl(I+NOCEM_NUM_COLS),

			clk => clk,
			rst => rst
		);








		end generate;
		
		-- middle of chip
	 	g5: if I / NOCEM_NUM_COLS /= 0 and (I+NOCEM_NUM_COLS) / NOCEM_NUM_COLS /= NOCEM_NUM_ROWS and NOCEM_NUM_ROWS /= 1 generate


		channel_ns : channel_fifo 
		generic map(
			P0_NODE_ADDR => I,
			P1_NODE_ADDR => I+NOCEM_NUM_COLS,
	  		IS_AN_ACCESS_POINT_CHANNEL => FALSE
		)		
		PORT MAP(
			p0_datain => n_to_fifo_data(I),
			p0_pkt_cntrl_in => n_to_fifo_pkt_cntrl(I),
			p0_dataout => fifo_to_n_data(I),
			p0_pkt_cntrl_out => fifo_to_n_pkt_cntrl(I),
			p0_channel_cntrl_in => n_fifo_ch_cntrl(I),
			p0_channel_cntrl_out => fifo_n_ch_cntrl(I),

			p1_datain => s_to_fifo_data(I+NOCEM_NUM_COLS),
			p1_pkt_cntrl_in => s_to_fifo_pkt_cntrl(I+NOCEM_NUM_COLS),
			p1_dataout => fifo_to_s_data(I+NOCEM_NUM_COLS),
			p1_pkt_cntrl_out => fifo_to_s_pkt_cntrl(I+NOCEM_NUM_COLS),
			p1_channel_cntrl_in => s_fifo_ch_cntrl(I+NOCEM_NUM_COLS),
			p1_channel_cntrl_out => fifo_s_ch_cntrl(I+NOCEM_NUM_COLS),

			clk => clk,
			rst => rst
		);







		end generate;				

		-- single row
		g6: if NOCEM_NUM_ROWS = 1 generate

		end generate;



---------------------------------------------------------------
---------------------------------------------------------------
------               EAST / WEST FIFOs                     ----            
---------------------------------------------------------------
---------------------------------------------------------------

	 
	 -- left side of chip
	 g7: if I mod NOCEM_NUM_COLS = 0 and NOCEM_NUM_COLS /= 1 generate








		channel_ew : channel_fifo 
		generic map(
			P0_NODE_ADDR => I,
			P1_NODE_ADDR => I+1,
	  		IS_AN_ACCESS_POINT_CHANNEL => FALSE
		)				
		PORT MAP(
			p0_datain => e_to_fifo_data(I),
			p0_pkt_cntrl_in => e_to_fifo_pkt_cntrl(I),
			p0_dataout => fifo_to_e_data(I),
			p0_pkt_cntrl_out => fifo_to_e_pkt_cntrl(I),
			p0_channel_cntrl_in => e_fifo_ch_cntrl(I),
			p0_channel_cntrl_out => fifo_e_ch_cntrl(I),

			p1_datain => w_to_fifo_data(I+1),
			p1_pkt_cntrl_in => w_to_fifo_pkt_cntrl(I+1),
			p1_dataout => fifo_to_w_data(I+1),
			p1_pkt_cntrl_out => fifo_to_w_pkt_cntrl(I+1),
			p1_channel_cntrl_in => w_fifo_ch_cntrl(I+1),
			p1_channel_cntrl_out => fifo_w_ch_cntrl(I+1),

			clk => clk,
			rst => rst
		);








	  end generate;
	  

	  -- right side of chip
	  g8: if I mod NOCEM_NUM_COLS = NOCEM_NUM_COLS-1 and NOCEM_NUM_COLS /= 1 generate

			-- only do this on double torus
			g81: if NOCEM_TOPOLOGY_TYPE = NOCEM_TOPOLOGY_DTORUS generate
	
					channel_ew_dt : channel_fifo 
					generic map(
						P0_NODE_ADDR => I,
						P1_NODE_ADDR => I-NOCEM_NUM_COLS+1,
	  			  		IS_AN_ACCESS_POINT_CHANNEL => FALSE
					)					
					PORT MAP(
						p0_datain => e_to_fifo_data(I),
						p0_pkt_cntrl_in => e_to_fifo_pkt_cntrl(I),
						p0_dataout => fifo_to_e_data(I),
						p0_pkt_cntrl_out => fifo_to_e_pkt_cntrl(I),
						p0_channel_cntrl_in => e_fifo_ch_cntrl(I),
						p0_channel_cntrl_out => fifo_e_ch_cntrl(I),

						p1_datain => w_to_fifo_data(I-NOCEM_NUM_COLS+1),
						p1_pkt_cntrl_in => w_to_fifo_pkt_cntrl(I-NOCEM_NUM_COLS+1),
						p1_dataout => fifo_to_w_data(I-NOCEM_NUM_COLS+1),
						p1_pkt_cntrl_out => fifo_to_w_pkt_cntrl(I-NOCEM_NUM_COLS+1),
						p1_channel_cntrl_in => w_fifo_ch_cntrl(I-NOCEM_NUM_COLS+1),
						p1_channel_cntrl_out => fifo_w_ch_cntrl(I-NOCEM_NUM_COLS+1),

						clk => clk,
						rst => rst
					);
		
			end generate;


			g82: if NOCEM_TOPOLOGY_TYPE = NOCEM_TOPOLOGY_MESH generate

--					channel_ew_mesht : channel_fifo PORT MAP(
--						p0_datain => data_z,
--						p0_pkt_cntrl_in => pkt_cntrl_z,
--						p0_dataout => open,
--						p0_pkt_cntrl_out => open,
--						p0_channel_cntrl_in => ch_cntrl_z,
--						p0_channel_cntrl_out => open,
--						p1_datain => data_z,
--						p1_pkt_cntrl_in => pkt_cntrl_z,
--						p1_dataout => open,
--						p1_pkt_cntrl_out => open,
--						p1_channel_cntrl_in => ch_cntrl_z,
--						p1_channel_cntrl_out => open,
--						clk => clk,
--						rst => rst
--					);
--	  
			end generate;

	  end generate;


	  -- middle of chip (in terms of columns)
	  g9: if I mod NOCEM_NUM_COLS /= NOCEM_NUM_COLS-1 and I mod NOCEM_NUM_COLS /= 0 and NOCEM_NUM_COLS /= 1 generate


		channel_ew : channel_fifo 
		generic map(
			P0_NODE_ADDR => I,
			P1_NODE_ADDR => I+1,
	  		IS_AN_ACCESS_POINT_CHANNEL => FALSE
		)
		
		PORT MAP(
			p0_datain => e_to_fifo_data(I),
			p0_pkt_cntrl_in => e_to_fifo_pkt_cntrl(I),
			p0_dataout => fifo_to_e_data(I),
			p0_pkt_cntrl_out => fifo_to_e_pkt_cntrl(I),
			p0_channel_cntrl_in => e_fifo_ch_cntrl(I),
			p0_channel_cntrl_out => fifo_e_ch_cntrl(I),

			p1_datain => w_to_fifo_data(I+1),
			p1_pkt_cntrl_in => w_to_fifo_pkt_cntrl(I+1),
			p1_dataout => fifo_to_w_data(I+1),
			p1_pkt_cntrl_out => fifo_to_w_pkt_cntrl(I+1),
			p1_channel_cntrl_in => w_fifo_ch_cntrl(I+1),
			p1_channel_cntrl_out => fifo_w_ch_cntrl(I+1),

			clk => clk,
			rst => rst
		);




	  end generate;


	  -- single column
	  g10: if NOCEM_NUM_COLS = 1 generate



	  end generate;



	end generate;
	


end Behavioral;
