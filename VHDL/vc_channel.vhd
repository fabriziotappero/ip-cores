
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
-- Filename: vc_channel.vhd
-- 
-- Description: toplevel instantion of a virtual channel
-- 



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.pkg_nocem.all;

entity vc_channel is
generic (
			  IS_AN_ACCESS_POINT_CHANNEL : boolean := FALSE
			) ;
port (

			  node_dest_id	: in node_addr_word;
			  vc_mux_wr : in std_logic_vector(NOCEM_NUM_VC-1 downto 0);
	 		  vc_mux_rd : in std_logic_vector(NOCEM_NUM_VC-1 downto 0);

           wr_pkt_cntrl : in std_logic_vector(NOCEM_PKT_CNTRL_WIDTH-1 downto 0);
           wr_pkt_data  : in std_logic_vector(NOCEM_DW-1 downto 0);

           rd_pkt_cntrl : out std_logic_vector(NOCEM_PKT_CNTRL_WIDTH-1 downto 0);
           rd_pkt_data  : out std_logic_vector(NOCEM_DW-1 downto 0);

			  rd_pkt_chdest : out std_logic_vector(NOCEM_ARB_IX_SIZE-1 downto 0);
			  rd_pkt_vcdest : out vc_addr_word;
			  rd_pkt_vcsrc  : out vc_addr_word;


			  vc_empty		: out std_logic_vector(NOCEM_NUM_VC-1 downto 0);
			  vc_full		: out std_logic_vector(NOCEM_NUM_VC-1 downto 0);


			  -- VC allocation signals
			  vc_allocate_from_node	    	: in vc_addr_word;
	        vc_requester_from_node	 	: in vc_addr_word;

			  vc_allocate_destch_to_node	: out std_logic_vector(NOCEM_ARB_IX_SIZE-1 downto 0);
	        vc_requester_to_node	      : out vc_addr_word;
			  vc_eop_rd_status				: out std_logic_vector(NOCEM_NUM_VC-1 downto 0);					
			  vc_eop_wr_status				: out std_logic_vector(NOCEM_NUM_VC-1 downto 0);

			  RE : in std_logic;
			  WE : in std_logic;

			  clk : in std_logic;
			  rst : in std_logic
);


end vc_channel;

architecture Behavioral of vc_channel is

	signal vc_pkt_cntrl			: pkt_cntrl_array(NOCEM_NUM_VC-1 downto 0);
	signal vc_allocation_req 	: std_logic_vector(NOCEM_NUM_VC-1 downto 0);


	signal vc_req_id	 			: vc_addr_array(7 downto 0);
	signal channel_dest 			: arb_decision_array(7 downto 0);
	signal vc_dest	  				: vc_addr_array(7 downto 0);
	signal vc_switch_req 		: std_logic_vector(NOCEM_NUM_VC-1 downto 0);

   signal fifo_wr_en  		: std_logic_vector(NOCEM_NUM_VC-1 downto 0);
   signal fifo_rd_en   		: std_logic_vector(NOCEM_NUM_VC-1 downto 0);

	-- pack the data and control lines of the packet into one word
   signal datain_packed,dataout_packed : std_logic_vector(NOCEM_DW+NOCEM_PKT_CNTRL_WIDTH-1 downto 0);

	--------------------------------------------------------------------
	--------- for the BRAM implementation a 32b line is used -----------
	--------------------------------------------------------------------
   signal datain_32 : std_logic_vector(31 downto 0);

	subtype slv32 is std_logic_vector(31 downto 0);
   type array_slv32 is array(natural range <>) of slv32;
	
   signal fifo_rd_data_32 : array_slv32(NOCEM_NUM_VC-1 downto 0);
	--------------------------------------------------------------------
	--------------------------------------------------------------------	

	subtype packedstdlogic is std_logic_vector(NOCEM_DW+NOCEM_PKT_CNTRL_WIDTH-1 downto 0);
   type array_packed is array(natural range <>) of packedstdlogic;

   signal fifo_rd_data : array_packed(NOCEM_NUM_VC-1 downto 0);

   signal vc_switch_grant 			: std_logic_vector(7 downto 0);

	
   signal vc_alloc_mux_sel : std_logic_vector(7 downto 0);
	signal vc_empty_i 		: std_logic_vector(NOCEM_NUM_VC-1 downto 0);

	-- needed for Modelsim Simulator ....
	signal vc_myid_conv : vc_addr_array(NOCEM_NUM_VC-1 downto 0);


	-- debug signals
	signal db_error    : std_logic_vector(NOCEM_NUM_VC-1 downto 0);
	signal db_want_eop : std_logic_vector(NOCEM_NUM_VC-1 downto 0);
	signal db_want_sop : std_logic_vector(NOCEM_NUM_VC-1 downto 0);


begin

		
	gen_vcids : process (rst)
	begin
		lgen : for I in NOCEM_NUM_VC-1 downto 0 loop
			  vc_myid_conv(I) <= CONV_STD_LOGIC_VECTOR(2**I,NOCEM_VC_ID_WIDTH);
		end loop;
	end process;

	datain_packed(NOCEM_DW+NOCEM_PKT_CNTRL_WIDTH-1 downto NOCEM_DW) <= wr_pkt_cntrl;
	datain_packed(NOCEM_DW-1 downto 0) <= wr_pkt_data;
	


	vc_read_sel : process (vc_empty_i,vc_mux_rd,rst,RE, vc_mux_wr, WE, dataout_packed,fifo_rd_data)
	begin
	
		vc_pkt_cntrl <= (others => (others => '0'));
		fifo_wr_en <= (others => '0');
		fifo_rd_en <= (others => '0');
		dataout_packed <= (others => '0');
		vc_empty <= vc_empty_i;
	
	
	
	
		-- push dataout from the correct fifo
		l1: for I in NOCEM_NUM_VC-1 downto 0 loop
	
			fifo_wr_en(I) <= vc_mux_wr(I) and WE;
			fifo_rd_en(I) <= vc_mux_rd(I) and RE;
			vc_pkt_cntrl(I) <=	fifo_rd_data(I)(NOCEM_DW+NOCEM_PKT_CNTRL_WIDTH-1 downto NOCEM_DW);	
	
			if vc_mux_rd(I) = '1' then	
				dataout_packed  <= fifo_rd_data(I);						
			end if;         	
		end loop;
	
	end process;


	data_packed_handling : process (dataout_packed,datain_packed)
	begin
	
		-- breakout the padded dataout lines
		rd_pkt_cntrl <= dataout_packed(NOCEM_DW+NOCEM_PKT_CNTRL_WIDTH-1 downto NOCEM_DW);
		rd_pkt_data  <= dataout_packed(NOCEM_DW-1 downto 0);

		datain_32 <= (others => '0');
		datain_32(NOCEM_DW+NOCEM_PKT_CNTRL_WIDTH-1 downto 0) <= datain_packed;



	
	end process;


	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- 	GENERATE	THE NEEDED FIFOS AND DATA PADDING AS NEEDED                --
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------


   g1: for I in NOCEM_NUM_VC-1 downto 0 generate

		-- ONLY difference is:
		--		if FIFO is attached to an accesspoint, it must be able to
		--    hold an ENTIRE packet, where inside the NoC, this is not the case
		g11: if IS_AN_ACCESS_POINT_CHANNEL = FALSE generate


			g111: if NOCEM_FIFO_IMPLEMENTATION= NOCEM_FIFO_LUT_TYPE generate
			
				I_vc : fifo_allvhdl 
					generic map(
						WIDTH => NOCEM_DW+NOCEM_PKT_CNTRL_WIDTH,
						ADDR_WIDTH => Log2(NOCEM_CHFIFO_DEPTH)	 -- LENGTH: CHFIFO_DEPTH
					)
					PORT MAP(
						din => datain_packed,
						clk => clk,
						rd_en => fifo_rd_en(I),
						rst => rst,
						wr_en => fifo_wr_en(I),
						dout => fifo_rd_data(I),
						empty => vc_empty_i(I),
						full => 	vc_full(I)
					);

			end generate;


		end generate;



		g12: if IS_AN_ACCESS_POINT_CHANNEL = TRUE generate



			g121: if NOCEM_FIFO_IMPLEMENTATION= NOCEM_FIFO_LUT_TYPE generate



				I_vc : fifo_allvhdl 
					generic map(
						WIDTH => NOCEM_DW+NOCEM_PKT_CNTRL_WIDTH,
						ADDR_WIDTH => Log2(NOCEM_MAX_PACKET_LENGTH) -- LENGTH: PACKET LENGTH
					)
					PORT MAP(
						din => datain_packed,
						clk => clk,
						rd_en => fifo_rd_en(I),
						rst => rst,
						wr_en => fifo_wr_en(I),
						dout => fifo_rd_data(I),
						empty => vc_empty_i(I),
						full => 	vc_full(I)
					);

			end generate;


		end generate;


		-- generate a virtual FIFO controller.
		I_vc_cntrlr : vc_controller PORT MAP(
			vc_my_id => vc_myid_conv(I),
			node_my_id => node_dest_id,
			pkt_cntrl_rd => vc_pkt_cntrl(I),
			pkt_cntrl_wr => wr_pkt_cntrl,
			pkt_re => fifo_rd_en(I),
			pkt_we => fifo_wr_en(I),
			vc_fifo_empty => vc_empty_i(I),
			vc_eop_rd_status => vc_eop_rd_status(I), -- directly outputted to channel_fifo
			vc_eop_wr_status => vc_eop_wr_status(I), -- directly outputted to channel_fifo			

			vc_allocation_req => vc_allocation_req(I),
			vc_req_id => vc_req_id(I),
			vc_allocate_from_node => vc_allocate_from_node,
			vc_requester_from_node => vc_requester_from_node,
			channel_dest => channel_dest(I),
			vc_dest => vc_dest(I),
			vc_switch_req =>  vc_switch_req(I),
			rst => rst,
			clk =>  clk
		);




  end generate;

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- VC Allocation muxing, arbitration, marshalling/demarshalling of arguments 
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------


--  currently, only 2 and 4 virtual channel per physical channel are implemented
--  this is due to needed a power of 2 virtual channel count and with 8 virtual channels
--  the design gets very large very fast!


 	I_vc_ch_alloc_arb: xto1_arbiter 
	
	generic map(
		NUM_REQS => NOCEM_NUM_VC,
		REG_OUTPUT => 0
	)
	PORT MAP(
		arb_req => vc_allocation_req,
		arb_grant => vc_alloc_mux_sel(NOCEM_NUM_VC-1 downto 0),
		clk => clk,
		rst => rst
	);


	vc_alloc_mux4_gen: if NOCEM_NUM_VC = 4 generate

	I_vc_ch_alloc_mux1 : mux4to1 
	generic map(
		DWIDTH => 5,			 -- one hot encoding for ch-dest
		REG_OUTPUT => 0
	)
	PORT MAP(
		din0 => channel_dest(0),
		din1 => channel_dest(1),
		din2 => channel_dest(2),
		din3 => channel_dest(3),
		sel => vc_alloc_mux_sel(3 downto 0),
		dout => vc_allocate_destch_to_node,
		clk => clk,
		rst => rst
	);

	I_vc_ch_alloc_mux2 : mux4to1 
	generic map(
		DWIDTH => NOCEM_VC_ID_WIDTH,
		REG_OUTPUT => 0
	)
	PORT MAP(
		din0 => vc_req_id(0),
		din1 => vc_req_id(1),
		din2 => vc_req_id(2),
		din3 => vc_req_id(3),
		sel => vc_alloc_mux_sel(3 downto 0),
		dout => vc_requester_to_node,
		clk => clk,
		rst => rst
	);

	end generate;



	vc_alloc_mux2_gen: if NOCEM_NUM_VC = 2 generate

	I_vc_ch_alloc_mux1 : mux2to1 
	generic map(
		DWIDTH => 5,			 -- one hot encoding for ch-dest
		REG_OUTPUT => 0
	)
	PORT MAP(
		din0 => channel_dest(0),
		din1 => channel_dest(1),
		sel => vc_alloc_mux_sel(1 downto 0),
		dout => vc_allocate_destch_to_node,
		clk => clk,
		rst => rst
	);

	I_vc_ch_alloc_mux2 : mux2to1 
	generic map(
		DWIDTH => NOCEM_VC_ID_WIDTH,
		REG_OUTPUT => 0
	)
	PORT MAP(
		din0 => vc_req_id(0),
		din1 => vc_req_id(1),
		sel => vc_alloc_mux_sel(1 downto 0),
		dout => vc_requester_to_node,
		clk => clk,
		rst => rst
	);

	end generate;



-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- switch allocation muxing, arbitration, marshalling/demarshalling of arguments 
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

--  currently, only 2 and 4 virtual channel per physical channel are implemented
--  this is due to needed a power of 2 virtual channel count and with 8 virtual channels
--  the design gets very large very fast!


 	I_ch_switch_arb: xto1_arbiter 
	
	generic map(
		NUM_REQS => NOCEM_NUM_VC,
		REG_OUTPUT => 1
	)
	PORT MAP(
		arb_req => vc_switch_req,
		arb_grant => vc_switch_grant(NOCEM_NUM_VC-1 downto 0),
		clk => clk,
		rst => rst
	);



	ch_alloc_mux4_gen: if NOCEM_NUM_VC = 4 generate


	I_vc_switch_alloc4_mux1 : mux4to1 
	generic map
	(
		DWIDTH => NOCEM_ARB_IX_SIZE,
		REG_OUTPUT => 1

	)
	PORT MAP(
		din0 => channel_dest(0),
		din1 => channel_dest(1),
		din2 => channel_dest(2),
		din3 => channel_dest(3),
		sel => vc_switch_grant(3 downto 0),
		dout => rd_pkt_chdest,
		clk => clk,
		rst => rst
	);

	I_vc_switch_alloc4_mux2 : mux4to1 
	generic map(
		DWIDTH => NOCEM_VC_ID_WIDTH,
		REG_OUTPUT => 1
	)
	PORT MAP(
		din0 => vc_dest(0),
		din1 => vc_dest(1),
		din2 => vc_dest(2),
		din3 => vc_dest(3),
		sel => vc_switch_grant(3 downto 0),
		dout => rd_pkt_vcdest,
		clk => clk,
		rst => rst
	);

	I_vc_switch_alloc4_mux3 : mux4to1 
	generic map(
		DWIDTH => NOCEM_VC_ID_WIDTH,
		REG_OUTPUT => 1
	)
	PORT MAP(
		din0 => "0001",
		din1 => "0010",
		din2 => "0100",
		din3 => "1000",
		sel => vc_switch_grant(3 downto 0),
		dout => rd_pkt_vcsrc,
		clk => clk,
		rst => rst
	);

	end generate;


	ch_alloc_mux2_gen: if NOCEM_NUM_VC = 2 generate


	I_vc_switch_alloc2_mux1 : mux2to1 
	generic map
	(
		DWIDTH => NOCEM_ARB_IX_SIZE,
		REG_OUTPUT => 1

	)
	PORT MAP(
		din0 => channel_dest(0),
		din1 => channel_dest(1),
		sel => vc_switch_grant(1 downto 0),
		dout => rd_pkt_chdest,
		clk => clk,
		rst => rst
	);

	I_vc_switch_alloc2_mux2 : mux2to1 
	generic map(
		DWIDTH => NOCEM_VC_ID_WIDTH,
		REG_OUTPUT => 1
	)
	PORT MAP(
		din0 => vc_dest(0),
		din1 => vc_dest(1),
		sel => vc_switch_grant(1 downto 0),
		dout => rd_pkt_vcdest,
		clk => clk,
		rst => rst
	);

	I_vc_switch_alloc2_mux3 : mux2to1 
	generic map(
		DWIDTH => NOCEM_VC_ID_WIDTH,
		REG_OUTPUT => 1
	)
	PORT MAP(
		din0 => "01",
		din1 => "10",
		sel => vc_switch_grant(1 downto 0),
		dout => rd_pkt_vcsrc,
		clk => clk,
		rst => rst
	);

	end generate;


---------------------------------------------------------------------------------
--debugging process:  simply for debugging purposes.  These signals would get	 --
--eaten during synthesis as they do not affect downstream logic					 --
--	....delete if needed....																	 --
---------------------------------------------------------------------------------

db_gen : process (clk,rst)
begin


	if rst='1' then
		db_error	<= (others => '0');
		db_want_eop	<= (others => '0');
		db_want_sop	<= (others => '1');
	elsif clk='1' and clk'event then

		db_loop: for I in NOCEM_NUM_VC-1 downto 0 loop
			if fifo_wr_en(I)='1' and wr_pkt_cntrl(NOCEM_PKTCNTRL_SOP_IX)='1' then
				db_want_eop(I) <= '1';
				db_want_sop(I) <= '0';

			elsif fifo_wr_en(I)='1' and wr_pkt_cntrl(NOCEM_PKTCNTRL_EOP_IX)='1' then
				db_want_eop(I) <= '0';
				db_want_sop(I) <= '1';
			end if;

			if fifo_wr_en(I)='1' and db_want_eop(I)='1' and wr_pkt_cntrl(NOCEM_PKTCNTRL_SOP_IX)='1' then
				db_error(I) <= '1';
			elsif fifo_wr_en(I)='1' and db_want_sop(I)='1' and wr_pkt_cntrl(NOCEM_PKTCNTRL_EOP_IX)='1' then
				db_error(I) <= '1';
			else 
				db_error(I) <= '0';
			end if;

		end loop;
	 end if;



end process;





end Behavioral;
