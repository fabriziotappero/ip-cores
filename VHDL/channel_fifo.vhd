
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
-- Filename: channel_fifo.vhd
-- 
-- Description: toplevel entity for channel fifo
-- 


--Use two channels for a bidirectional channel.  This 
--will allow a node to connect to the fifo with both 
--enqueueing and dequeuing capabilities.  This will 
--make connections easier as well.
--



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.pkg_nocem.all;

entity channel_fifo is
	generic (
	  P0_NODE_ADDR : integer := 0;
	  P1_NODE_ADDR : integer := 0;
	  IS_AN_ACCESS_POINT_CHANNEL : boolean	:= FALSE
	);
	port (


	   p0_datain : in data_word;
	   p0_pkt_cntrl_in : in pkt_cntrl_word;

	   p0_dataout : out data_word;
	   p0_pkt_cntrl_out : out pkt_cntrl_word;

	   p0_channel_cntrl_in  : in channel_cntrl_word;
	   p0_channel_cntrl_out : out channel_cntrl_word;



	   p1_datain : in data_word;
	   p1_pkt_cntrl_in : in pkt_cntrl_word;

	   p1_dataout : out data_word;
	   p1_pkt_cntrl_out : out pkt_cntrl_word;

	   p1_channel_cntrl_in  : in channel_cntrl_word;
	   p1_channel_cntrl_out : out channel_cntrl_word;



   
   
	clk: IN std_logic;   
	rst: IN std_logic   
   
   );




end channel_fifo;

architecture Behavioral of channel_fifo is



--std16,register signals
	-- port 0 signals
--signal p0_datain_pad,  : std_logic_vector(255 downto 0);
--signal p0_cntrl_in_pad,  : std_logic_vector(255 downto 0);

signal p0_data_re,p0_data_we,p0_data_full,p0_data_empty : std_logic;
signal p0_cntrl_re,p0_cntrl_we,p0_cntrl_full,p0_cntrl_empty : std_logic;

	-- port 1 signals
--signal p1_datain_pad,  : std_logic_vector(255 downto 0);
--signal p1_cntrl_in_pad,  : std_logic_vector(255 downto 0);
--
signal p1_data_re,p1_data_we,p1_data_full,p1_data_empty : std_logic;
signal p1_cntrl_re,p1_cntrl_we,p1_cntrl_full,p1_cntrl_empty : std_logic;

	-- for Modelsim purposes
signal p0_addr_conv,p1_addr_conv : std_logic_vector(NOCEM_AW-1 downto 0);


--register signals



begin

	-- for Modelsim purposes, do some signal re-typing here
	p0_addr_conv <= addr_gen(P0_NODE_ADDR,NOCEM_NUM_ROWS,NOCEM_NUM_COLS,NOCEM_AW); 
	p1_addr_conv <= addr_gen(P1_NODE_ADDR,NOCEM_NUM_ROWS,NOCEM_NUM_COLS,NOCEM_AW);




	gvc_procs: if NOCEM_TYPE = NOCEM_VC_TYPE generate


	-- wrapping these constant assignments to make simulator actually work...
	p0_handling_vc : process (p0_channel_cntrl_in, p0_data_full, p0_data_empty, p0_datain, p0_cntrl_full, p0_cntrl_empty, p0_pkt_cntrl_in )
	begin

		p0_data_re <= p0_channel_cntrl_in(NOCEM_CHFIFO_DATA_RE_IX);
		p0_data_we <= p0_channel_cntrl_in(NOCEM_CHFIFO_DATA_WE_IX);

		p0_channel_cntrl_out(NOCEM_CHFIFO_DATA_FULL_N_IX)  <= not p0_data_full;
		p0_channel_cntrl_out(NOCEM_CHFIFO_DATA_EMPTY_N_IX) <= not p0_data_empty;

		p0_data_full  <= '0';
		p0_data_empty <= '0';
		p0_cntrl_full <= '0';
		p0_cntrl_empty <= '0';

		p0_channel_cntrl_out(NOCEM_CHFIFO_VC_WR_ADDR_HIX downto NOCEM_CHFIFO_VC_WR_ADDR_LIX) <= (others => '0');
		p0_channel_cntrl_out(NOCEM_CHFIFO_CNTRL_RE_IX) <= '0';
		p0_channel_cntrl_out(NOCEM_CHFIFO_CNTRL_WE_IX) <= '0'; 
		p0_channel_cntrl_out(NOCEM_CHFIFO_DATA_RE_IX)  <= '0';
		p0_channel_cntrl_out(NOCEM_CHFIFO_DATA_WE_IX)  <= '0';
		p0_channel_cntrl_out(NOCEM_CHFIFO_VC_ALLOC_FROMNODE_HIX downto NOCEM_CHFIFO_VC_ALLOC_FROMNODE_LIX) <= (others => '0');
		p0_channel_cntrl_out(NOCEM_CHFIFO_VC_REQER_FROMNODE_HIX downto NOCEM_CHFIFO_VC_REQER_FROMNODE_LIX) <= (others => '0');
		p0_channel_cntrl_out(NOCEM_CHFIFO_VC_RD_ADDR_HIX downto NOCEM_CHFIFO_VC_RD_ADDR_LIX) <= (others => '0'); 

		p0_cntrl_re <= p0_channel_cntrl_in(NOCEM_CHFIFO_CNTRL_RE_IX);
		p0_cntrl_we <= p0_channel_cntrl_in(NOCEM_CHFIFO_CNTRL_WE_IX);

		p0_channel_cntrl_out(NOCEM_CHFIFO_CNTRL_FULL_N_IX)  <= not p0_cntrl_full;
		p0_channel_cntrl_out(NOCEM_CHFIFO_CNTRL_EMPTY_N_IX) <= not p0_cntrl_empty;

	end process;

	-- wrapping these constant assignments to make simulator actually work...
	p1_handling_vc : process (p1_channel_cntrl_in,p1_data_full, p1_data_empty, p1_datain, p1_cntrl_full, p1_cntrl_empty, p1_pkt_cntrl_in  )
	begin

		p1_data_re <= p1_channel_cntrl_in(NOCEM_CHFIFO_DATA_RE_IX);
		p1_data_we <= p1_channel_cntrl_in(NOCEM_CHFIFO_DATA_WE_IX);

		p1_channel_cntrl_out(NOCEM_CHFIFO_DATA_FULL_N_IX)  <= not p1_data_full;
		p1_channel_cntrl_out(NOCEM_CHFIFO_DATA_EMPTY_N_IX) <= not p1_data_empty;


		p1_data_full  <= '0';
		p1_data_empty <= '0';
		p1_cntrl_full <= '0';
		p1_cntrl_empty <= '0';

		p1_channel_cntrl_out(NOCEM_CHFIFO_VC_WR_ADDR_HIX downto NOCEM_CHFIFO_VC_WR_ADDR_LIX) <= (others => '0');
		p1_channel_cntrl_out(NOCEM_CHFIFO_CNTRL_RE_IX) <= '0';
		p1_channel_cntrl_out(NOCEM_CHFIFO_CNTRL_WE_IX) <= '0'; 
		p1_channel_cntrl_out(NOCEM_CHFIFO_DATA_RE_IX)  <= '0';
		p1_channel_cntrl_out(NOCEM_CHFIFO_DATA_WE_IX)  <= '0';
		p1_channel_cntrl_out(NOCEM_CHFIFO_VC_ALLOC_FROMNODE_HIX downto NOCEM_CHFIFO_VC_ALLOC_FROMNODE_LIX) <= (others => '0');
		p1_channel_cntrl_out(NOCEM_CHFIFO_VC_REQER_FROMNODE_HIX downto NOCEM_CHFIFO_VC_REQER_FROMNODE_LIX) <= (others => '0');
		p1_channel_cntrl_out(NOCEM_CHFIFO_VC_RD_ADDR_HIX downto NOCEM_CHFIFO_VC_RD_ADDR_LIX) <= (others => '0'); 

		p1_cntrl_re <= p1_channel_cntrl_in(NOCEM_CHFIFO_CNTRL_RE_IX);
		p1_cntrl_we <= p1_channel_cntrl_in(NOCEM_CHFIFO_CNTRL_WE_IX);

		p1_channel_cntrl_out(NOCEM_CHFIFO_CNTRL_FULL_N_IX)  <= not p1_cntrl_full;
		p1_channel_cntrl_out(NOCEM_CHFIFO_CNTRL_EMPTY_N_IX) <= not p1_cntrl_empty;
 
	 end process;

	end generate;	  -- end VC handling processes


	gnovc_procs: if NOCEM_TYPE /= NOCEM_VC_TYPE generate


		-- wrapping these constant assignments to make simulator actually work...
		p0_handling_no_vc : process (p0_channel_cntrl_in, p0_data_full, p0_data_empty, p0_datain, p0_cntrl_full, p0_cntrl_empty, p0_pkt_cntrl_in )
		begin

			p0_data_re <= p0_channel_cntrl_in(NOCEM_CHFIFO_DATA_RE_IX);
			p0_data_we <= p0_channel_cntrl_in(NOCEM_CHFIFO_DATA_WE_IX);

			p0_channel_cntrl_out(NOCEM_CHFIFO_DATA_FULL_N_IX)  <= not p0_data_full;
			p0_channel_cntrl_out(NOCEM_CHFIFO_DATA_EMPTY_N_IX) <= not p0_data_empty;

			p0_cntrl_re <= p0_channel_cntrl_in(NOCEM_CHFIFO_CNTRL_RE_IX);
			p0_cntrl_we <= p0_channel_cntrl_in(NOCEM_CHFIFO_CNTRL_WE_IX);

			p0_channel_cntrl_out(NOCEM_CHFIFO_CNTRL_FULL_N_IX)  <= not p0_cntrl_full;
			p0_channel_cntrl_out(NOCEM_CHFIFO_CNTRL_EMPTY_N_IX) <= not p0_cntrl_empty;

		end process;

		-- wrapping these constant assignments to make simulator actually work...
		p1_handling_no_vc : process (p1_channel_cntrl_in,p1_data_full, p1_data_empty, p1_datain, p1_cntrl_full, p1_cntrl_empty, p1_pkt_cntrl_in )
		begin

			p1_data_re <= p1_channel_cntrl_in(NOCEM_CHFIFO_DATA_RE_IX);
			p1_data_we <= p1_channel_cntrl_in(NOCEM_CHFIFO_DATA_WE_IX);

			p1_channel_cntrl_out(NOCEM_CHFIFO_DATA_FULL_N_IX)  <= not p1_data_full;
			p1_channel_cntrl_out(NOCEM_CHFIFO_DATA_EMPTY_N_IX) <= not p1_data_empty;

			p1_cntrl_re <= p1_channel_cntrl_in(NOCEM_CHFIFO_CNTRL_RE_IX);
			p1_cntrl_we <= p1_channel_cntrl_in(NOCEM_CHFIFO_CNTRL_WE_IX);

			p1_channel_cntrl_out(NOCEM_CHFIFO_CNTRL_FULL_N_IX)  <= not p1_cntrl_full;
			p1_channel_cntrl_out(NOCEM_CHFIFO_CNTRL_EMPTY_N_IX) <= not p1_cntrl_empty;
		 
		end process;

	end generate;	  -- end no VC handling processes






g3: if NOCEM_CHFIFO_TYPE = NOCEM_CHFIFO_VC_TYPE generate


	p01_vc : vc_channel 
	Generic map (IS_AN_ACCESS_POINT_CHANNEL => IS_AN_ACCESS_POINT_CHANNEL)
	PORT MAP(
		rd_pkt_cntrl => 					p1_pkt_cntrl_out,
		rd_pkt_data => 					p1_dataout,

		node_dest_id => 					p1_addr_conv,
		vc_mux_wr => 						p0_channel_cntrl_in(NOCEM_CHFIFO_VC_WR_ADDR_HIX downto NOCEM_CHFIFO_VC_WR_ADDR_LIX),
		vc_mux_rd =>						p1_channel_cntrl_in(NOCEM_CHFIFO_VC_RD_ADDR_HIX downto NOCEM_CHFIFO_VC_RD_ADDR_LIX),
		wr_pkt_cntrl => 					p0_pkt_cntrl_in,
		wr_pkt_data => 					p0_datain,

		rd_pkt_chdest => 					p1_channel_cntrl_out(NOCEM_CHFIFO_VC_CHDEST_HIX downto NOCEM_CHFIFO_VC_CHDEST_LIX),
		rd_pkt_vcdest => 					p1_channel_cntrl_out(NOCEM_CHFIFO_VC_VCDEST_HIX downto NOCEM_CHFIFO_VC_VCDEST_LIX),
		rd_pkt_vcsrc  =>					p1_channel_cntrl_out(NOCEM_CHFIFO_VC_VCSRC_HIX downto NOCEM_CHFIFO_VC_VCSRC_LIX),
		vc_eop_rd_status => 				p0_channel_cntrl_out(NOCEM_CHFIFO_VC_EOP_RD_HIX downto NOCEM_CHFIFO_VC_EOP_RD_LIX),
		vc_eop_wr_status => 				p1_channel_cntrl_out(NOCEM_CHFIFO_VC_EOP_WR_HIX downto NOCEM_CHFIFO_VC_EOP_WR_LIX),
		vc_allocate_from_node => 		p1_channel_cntrl_in(NOCEM_CHFIFO_VC_ALLOC_FROMNODE_HIX downto NOCEM_CHFIFO_VC_ALLOC_FROMNODE_LIX),
		vc_requester_from_node => 		p1_channel_cntrl_in(NOCEM_CHFIFO_VC_REQER_FROMNODE_HIX downto NOCEM_CHFIFO_VC_REQER_FROMNODE_LIX),
		vc_allocate_destch_to_node => p1_channel_cntrl_out(NOCEM_CHFIFO_VC_REQER_DEST_CH_HIX downto NOCEM_CHFIFO_VC_REQER_DEST_CH_LIX),

		--vc_allocate_destch_to_node--

		vc_requester_to_node => 		p1_channel_cntrl_out(NOCEM_CHFIFO_VC_REQER_VCID_HIX downto NOCEM_CHFIFO_VC_REQER_VCID_LIX),
		vc_empty => 						p1_channel_cntrl_out(NOCEM_CHFIFO_VC_EMPTY_HIX downto NOCEM_CHFIFO_VC_EMPTY_LIX),
		vc_full => 						   p0_channel_cntrl_out(NOCEM_CHFIFO_VC_FULL_HIX downto NOCEM_CHFIFO_VC_FULL_LIX),
		RE => 								p1_data_re,
		WE => 								p0_data_we,
		clk => clk,
		rst => rst
	);


	g31: if IS_AN_ACCESS_POINT_CHANNEL = false generate

		p10_vc_false : vc_channel 
			Generic map (IS_AN_ACCESS_POINT_CHANNEL => IS_AN_ACCESS_POINT_CHANNEL)
			PORT MAP(

			rd_pkt_cntrl => 					p0_pkt_cntrl_out,
			rd_pkt_data => 					p0_dataout,

			node_dest_id => 					p0_addr_conv,
			vc_mux_wr => 						p1_channel_cntrl_in(NOCEM_CHFIFO_VC_WR_ADDR_HIX downto NOCEM_CHFIFO_VC_WR_ADDR_LIX),
			vc_mux_rd =>						p0_channel_cntrl_in(NOCEM_CHFIFO_VC_RD_ADDR_HIX downto NOCEM_CHFIFO_VC_RD_ADDR_LIX),

			wr_pkt_cntrl => 					p1_pkt_cntrl_in,
			wr_pkt_data => 					p1_datain,

			rd_pkt_chdest => 					p0_channel_cntrl_out(NOCEM_CHFIFO_VC_CHDEST_HIX downto NOCEM_CHFIFO_VC_CHDEST_LIX),
			rd_pkt_vcdest => 					p0_channel_cntrl_out(NOCEM_CHFIFO_VC_VCDEST_HIX downto NOCEM_CHFIFO_VC_VCDEST_LIX),
		   rd_pkt_vcsrc  =>					p0_channel_cntrl_out(NOCEM_CHFIFO_VC_VCSRC_HIX downto NOCEM_CHFIFO_VC_VCSRC_LIX),

			vc_eop_rd_status => 				p1_channel_cntrl_out(NOCEM_CHFIFO_VC_EOP_RD_HIX downto NOCEM_CHFIFO_VC_EOP_RD_LIX),
			vc_eop_wr_status => 				p0_channel_cntrl_out(NOCEM_CHFIFO_VC_EOP_WR_HIX downto NOCEM_CHFIFO_VC_EOP_WR_LIX),
			vc_allocate_from_node => 		p0_channel_cntrl_in(NOCEM_CHFIFO_VC_ALLOC_FROMNODE_HIX downto NOCEM_CHFIFO_VC_ALLOC_FROMNODE_LIX),
			vc_requester_from_node => 		p0_channel_cntrl_in(NOCEM_CHFIFO_VC_REQER_FROMNODE_HIX downto NOCEM_CHFIFO_VC_REQER_FROMNODE_LIX),
			vc_allocate_destch_to_node => p0_channel_cntrl_out(NOCEM_CHFIFO_VC_REQER_DEST_CH_HIX downto NOCEM_CHFIFO_VC_REQER_DEST_CH_LIX),
			vc_requester_to_node => 		p0_channel_cntrl_out(NOCEM_CHFIFO_VC_REQER_VCID_HIX downto NOCEM_CHFIFO_VC_REQER_VCID_LIX),
			vc_empty => 						p0_channel_cntrl_out(NOCEM_CHFIFO_VC_EMPTY_HIX downto NOCEM_CHFIFO_VC_EMPTY_LIX),
			vc_full => 						   p1_channel_cntrl_out(NOCEM_CHFIFO_VC_FULL_HIX downto NOCEM_CHFIFO_VC_FULL_LIX),
			RE => 								p0_data_re,
			WE => 								p1_data_we,
			clk => clk,
			rst => rst
		);

	end generate;

	g32: if IS_AN_ACCESS_POINT_CHANNEL = true generate

		p10_vc_true : vc_channel_destap 
			PORT MAP(
			node_dest_id => 					p0_addr_conv,
			vc_mux_rd =>						p0_channel_cntrl_in(NOCEM_CHFIFO_VC_RD_ADDR_HIX downto NOCEM_CHFIFO_VC_RD_ADDR_LIX),
			vc_mux_wr => 						p1_channel_cntrl_in(NOCEM_CHFIFO_VC_WR_ADDR_HIX downto NOCEM_CHFIFO_VC_WR_ADDR_LIX),
			wr_pkt_cntrl => 					p1_pkt_cntrl_in,
			wr_pkt_data => 					p1_datain,
			rd_pkt_cntrl => 					p0_pkt_cntrl_out,
			rd_pkt_data => 					p0_dataout,
			rd_pkt_chdest => 					p0_channel_cntrl_out(NOCEM_CHFIFO_VC_CHDEST_HIX downto NOCEM_CHFIFO_VC_CHDEST_LIX),
			rd_pkt_vcdest => 					p0_channel_cntrl_out(NOCEM_CHFIFO_VC_VCDEST_HIX downto NOCEM_CHFIFO_VC_VCDEST_LIX),
		   rd_pkt_vcsrc  =>					p0_channel_cntrl_out(NOCEM_CHFIFO_VC_VCSRC_HIX downto NOCEM_CHFIFO_VC_VCSRC_LIX),
			vc_eop_rd_status => 				p1_channel_cntrl_out(NOCEM_CHFIFO_VC_EOP_RD_HIX downto NOCEM_CHFIFO_VC_EOP_RD_LIX),
			vc_eop_wr_status => 				p0_channel_cntrl_out(NOCEM_CHFIFO_VC_EOP_WR_HIX downto NOCEM_CHFIFO_VC_EOP_WR_LIX),
			vc_allocate_from_node => 		p0_channel_cntrl_in(NOCEM_CHFIFO_VC_ALLOC_FROMNODE_HIX downto NOCEM_CHFIFO_VC_ALLOC_FROMNODE_LIX),
			vc_requester_from_node => 		p0_channel_cntrl_in(NOCEM_CHFIFO_VC_REQER_FROMNODE_HIX downto NOCEM_CHFIFO_VC_REQER_FROMNODE_LIX),
			vc_allocate_destch_to_node => p0_channel_cntrl_out(NOCEM_CHFIFO_VC_REQER_DEST_CH_HIX downto NOCEM_CHFIFO_VC_REQER_DEST_CH_LIX),
			vc_requester_to_node => 		p0_channel_cntrl_out(NOCEM_CHFIFO_VC_REQER_VCID_HIX downto NOCEM_CHFIFO_VC_REQER_VCID_LIX),
			vc_empty => 						p0_channel_cntrl_out(NOCEM_CHFIFO_VC_EMPTY_HIX downto NOCEM_CHFIFO_VC_EMPTY_LIX),
			vc_full => 						   p1_channel_cntrl_out(NOCEM_CHFIFO_VC_FULL_HIX downto NOCEM_CHFIFO_VC_FULL_LIX),
			RE => 								p0_data_re,
			WE => 								p1_data_we,
			clk => clk,
			rst => rst
		);

	end generate;

end generate;





g2: if NOCEM_CHFIFO_TYPE = NOCEM_CHFIFO_NOVC_TYPE generate

		 p01_cntrl_fifo_allvhdl : fifo_allvhdl 
			generic map(
				WIDTH => NOCEM_PKT_CNTRL_WIDTH,
				ADDR_WIDTH => Log2(NOCEM_CHFIFO_DEPTH)
			)
			port map (
			clk => clk,
			din => p0_pkt_cntrl_in,
			rd_en => p1_cntrl_re,	
			rst => rst,
			wr_en => p0_cntrl_we,
			dout => p1_pkt_cntrl_out,
			empty => p1_cntrl_empty,
			full => p0_cntrl_full
			);

		 p01_data_fifo_allvhdl : fifo_allvhdl 
			generic map(
				WIDTH => NOCEM_DW,
				ADDR_WIDTH => Log2(NOCEM_CHFIFO_DEPTH)
			)
			port map (
			clk => clk,
			din => p0_datain,
			rd_en => p1_data_re,	
			rst => rst,
			wr_en => p0_data_we,
			dout => p1_dataout,
			empty => p1_data_empty,
			full => p0_data_full
			);

		 p10_cntrl_fifo_allvhdl : fifo_allvhdl 
			generic map(
				WIDTH => NOCEM_PKT_CNTRL_WIDTH,
				ADDR_WIDTH => Log2(NOCEM_CHFIFO_DEPTH)
			)
			port map (
			clk => clk,
			din => p1_pkt_cntrl_in,
			rd_en => p0_cntrl_re,	
			rst => rst,
			wr_en => p1_cntrl_we,
			dout => p0_pkt_cntrl_out,
			empty => p0_cntrl_empty,
			full => p1_cntrl_full
			);

		 p10_data_fifo_allvhdl : fifo_allvhdl 
		 	generic map(
				WIDTH => NOCEM_DW,
				ADDR_WIDTH => Log2(NOCEM_CHFIFO_DEPTH)
			)
			port map (
			clk => clk,
			din => p1_datain,
			rd_en => p0_data_re,	
			rst => rst,
			wr_en => p1_data_we,
			dout => p0_dataout,
			empty => p0_data_empty,
			full => p1_data_full
			);

end generate;





end Behavioral;
