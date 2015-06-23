
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
-- Filename: vc_channel_destap.vhd
-- 
-- Description: vc channel with destination being an access point
-- 


--
--a different vc_channel is used for the channel fifo that has its destination
--being the actual access point.  This is necessary for a variety of reasons.  Any bug
--fixes here will probably need to be fixed in vc_channel.vhd as well 
--(I'm sure a software engineer just died somewhere).

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.pkg_nocem.all;

entity vc_channel_destap is
port (
	 		  -- id of destination node
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
end vc_channel_destap;

architecture Behavioral of vc_channel_destap is

	signal vc_pkt_cntrl			: pkt_cntrl_array(NOCEM_NUM_VC-1 downto 0);
	signal vc_pkt_data			: data_array(NOCEM_NUM_VC-1 downto 0);

   signal fifo_wr_en  		: std_logic_vector(NOCEM_NUM_VC-1 downto 0);
   signal fifo_rd_en   		: std_logic_vector(NOCEM_NUM_VC-1 downto 0);
   signal datain_pad,dataout_pad : std_logic_vector(NOCEM_DW+NOCEM_PKT_CNTRL_WIDTH-1 downto 0);

   type array_packed is array(natural range <>) of std_logic_vector(NOCEM_DW+NOCEM_PKT_CNTRL_WIDTH-1 downto 0);
   signal fifo_rd_data : array_packed(NOCEM_NUM_VC-1 downto 0);


   -- signal vc_mux_rd : std_logic_vector(NOCEM_NUM_VC-1 downto 0);

	signal dummy_vcid : std_logic_vector(NOCEM_NUM_VC-1 downto 0);
   signal vc_alloc_mux_sel : std_logic_vector(NOCEM_NUM_VC-1 downto 0);
	signal vc_empty_i 		: std_logic_vector(NOCEM_NUM_VC-1 downto 0);

	-- needed for Modelsim Simulator to work....
	signal vc_myid_conv : vc_addr_array(NOCEM_NUM_VC-1 downto 0);


begin

		rd_pkt_vcsrc <= vc_mux_rd;


	  	vc_requester_to_node	  			<= (others => '0');
		rd_pkt_vcdest			  			<= (others => '0');
	  	vc_allocate_destch_to_node	   <= (others => '0');
		rd_pkt_chdest						<= (others => '0');
		vc_alloc_mux_sel					<= (others => '0');


		-- for accesspoint vc_req lines
		dummy_vcid <= ('1',others=>'0');

		gen_vcids : process (rst)
		begin
			lgen : for I in NOCEM_NUM_VC-1 downto 0 loop
				  vc_myid_conv(I) <= CONV_STD_LOGIC_VECTOR(2**I,NOCEM_VC_ID_WIDTH);
			end loop;
		end process;


      --FIFO data format: (...) pkt_cntrl,pkt_data (0)

		datain_pad(NOCEM_DW+NOCEM_PKT_CNTRL_WIDTH-1 downto NOCEM_DW) <= wr_pkt_cntrl;
      datain_pad(NOCEM_DW-1 downto 0) <= wr_pkt_data;




vc_read_sel : process (vc_empty_i,vc_mux_rd,rst,RE, vc_mux_wr, WE, dataout_pad,fifo_rd_data)
begin

	rd_pkt_data  <= (others => '0');
   rd_pkt_cntrl <= (others => '0');
	vc_pkt_cntrl <= (others => (others => '0'));
	vc_pkt_data <= (others => (others => '0'));
	fifo_wr_en <= (others => '0');
	fifo_rd_en <= (others => '0');
	dataout_pad <= (others => '0');
	vc_empty <= vc_empty_i;

	if rst = '1' then
      null;
	else



      -- push dataout from the correct fifo
		l1: for I in NOCEM_NUM_VC-1 downto 0 loop

   	   fifo_wr_en(I) <= vc_mux_wr(I) and WE;
   	   fifo_rd_en(I) <= vc_mux_rd(I) and RE;
			vc_pkt_cntrl(I) <=	fifo_rd_data(I)(NOCEM_DW+NOCEM_PKT_CNTRL_WIDTH-1 downto NOCEM_DW);	
			vc_pkt_data(I)	 <=	fifo_rd_data(I)(NOCEM_DW-1 downto 0);


			if vc_mux_rd(I) = '1' then
				dataout_pad  <= fifo_rd_data(I);						
			end if;         	
		end loop;

      -- breakout the padded dataout lines
      rd_pkt_cntrl <=	dataout_pad(NOCEM_DW+NOCEM_PKT_CNTRL_WIDTH-1 downto NOCEM_DW);
		rd_pkt_data  <=	dataout_pad(NOCEM_DW-1 downto 0);

	end if;

end process;


   g1: for I in NOCEM_NUM_VC-1 downto 0 generate






   	I_vc : fifo_allvhdl 
			generic map(
				WIDTH => NOCEM_DW+NOCEM_PKT_CNTRL_WIDTH,
				ADDR_WIDTH => Log2(NOCEM_MAX_PACKET_LENGTH)
			)
			PORT MAP(
	   		din => datain_pad,
	   		clk => clk,
	   		rd_en => fifo_rd_en(I),
	   		rst => rst,
	   		wr_en => fifo_wr_en(I),
	   		dout => fifo_rd_data(I),
	   		empty => vc_empty_i(I),
	   		full => 	vc_full(I)
	   	);



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

			vc_allocation_req => open,
			vc_req_id => open,
			vc_allocate_from_node => dummy_vcid,
			vc_requester_from_node => vc_myid_conv(I),
			channel_dest => open,
			vc_dest => open,
			vc_switch_req =>  open,
			rst => rst,
			clk =>  clk
		);



  end generate;

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------



end Behavioral;


