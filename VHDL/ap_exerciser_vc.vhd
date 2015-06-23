
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
-- Filename: ap_exerciser_vc.vhd
-- 
-- Description: access point exerciser for VC designs
-- 



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.pkg_nocem.all;


entity ap_exerciser_vc is
	Generic(

		DELAY_START_COUNTER_WIDTH 		: integer := 32;
		DELAY_START_CYCLES 				: integer := 500;
		PKT_LENGTH 							: integer := 5;
		INTERVAL_COUNTER_WIDTH 			: integer := 8;
		DATA_OUT_INTERVAL 				: integer := 16;
	   INIT_DEST_ADDR 					: integer := 0;
		MY_ADDR 								: integer := 0;
		EXERCISER_MODE						: integer := EXERCISER_MODE_SIM
		 )	;
    Port ( 
	 
		-- arbitration lines (usage depends on underlying network)
		arb_req         : out  std_logic;
		arb_cntrl_out   : out  arb_cntrl_word;

		arb_grant         : in std_logic;
		arb_cntrl_in      : in  arb_cntrl_word;
		
		datain        : in   data_word;
		datain_valid  : in   std_logic;
		datain_recvd  : out  std_logic;

		dataout       : out data_word;
		dataout_valid : out std_logic;
		dataout_recvd : in  std_logic;

		pkt_cntrl_in        : in   pkt_cntrl_word;
		pkt_cntrl_in_valid  : in   std_logic;
		pkt_cntrl_in_recvd  : out  std_logic;      
             
		pkt_cntrl_out       : out pkt_cntrl_word;
		pkt_cntrl_out_valid : out std_logic;
		pkt_cntrl_out_recvd : in  std_logic;

		clk : in std_logic;
      rst : in std_logic		
		
		);
end ap_exerciser_vc;

architecture Behavioral of ap_exerciser_vc is

		signal rst_i : std_logic;
		signal rst_counter : std_logic_vector(DELAY_START_COUNTER_WIDTH-1 downto 0);
		signal interval_counter : std_logic_vector(INTERVAL_COUNTER_WIDTH-1 downto 0);
		signal dataout_reg : std_logic_vector(NOCEM_DW-1 downto 0);
		signal pkt_cntrl_out_reg : pkt_cntrl_word;


		signal burst_counter : std_logic_vector(7 downto 0);

		signal datain_reg : data_word;
		signal pkt_cntrl_in_reg : pkt_cntrl_word;


		type stateType is (init_st,sending_st,getting_vc_st);
		signal state,nextState : stateType;

		-- determine the next free outgoing VC
		signal next_free_vc  : std_logic_vector(NOCEM_NUM_VC-1 downto 0);
		signal vc_state : std_logic_Vector(NOCEM_NUM_VC-1 downto 0);   -- 0: free, 1: allocated --
		signal vc_allocate : std_logic;
		signal free_this_vc	 : std_logic_vector(NOCEM_NUM_VC-1 downto 0);
		signal vc_mux_wr_reg	 : std_logic_vector(NOCEM_VC_ID_WIDTH-1 downto 0);


		-- data gathering signals
		signal  next_vc_with_pkt,finished_pkt,eop_wr_sig,pkt_rdy	 : std_logic_vector(NOCEM_NUM_VC-1 downto 0);
		signal  recv_idle : std_logic;

		-- arbcntrl out signals used for ORing together
		signal  arb_sending_word,arb_receiving_word   :   arb_cntrl_word;

		signal allones_vcwidth : std_logic_vector(NOCEM_NUM_VC-1 downto 0);

		-- any debug signals
		signal  debug_vc_mux_wr	: std_logic_vector(NOCEM_VC_ID_WIDTH-1 downto 0);

				  
begin

allones_vcwidth <= (others => '1');

-- arbcntrl out signals used for ORing together
arb_cntrl_out <= arb_sending_word or arb_receiving_word;


rst_gen : process (clk,rst)
begin 
	if rst='1' then
		rst_i <= '1';
		rst_counter <= (others => '0');
	elsif clk'event and clk ='1' then	
		rst_counter <= rst_counter+1;
		if rst_counter = DELAY_START_CYCLES then
				 rst_i <= '0';
		end if;	
	end if;
end process;

																											 
----------------------------------------------------------------------------------
--------KEEPING TRACK OF OUTGOING VC STATES --------------------------------------
----------------------------------------------------------------------------------

gen_vc_status_uclkd : process (vc_state)
begin

end process;

gen_vc_status_clkd : process (clk,rst)
begin


	if rst='1' then
		--next_free_vc <= ('1',others => '0');	
		vc_state <= (others => '0');
		free_this_vc <= (others => '0');	
		next_free_vc <= (others => '0');
	elsif clk'event and clk='1' then


		l2: for I in NOCEM_NUM_VC-1 downto 0 loop
			if vc_state(I) = '0' then
				next_free_vc <= CONV_STD_LOGIC_VECTOR(2**I,NOCEM_NUM_VC);
			end if;											  	
		end loop;

		if vc_state = allones_vcwidth then
			next_free_vc <= (others => '0');
		end if;


	    free_this_vc <= arb_cntrl_in(NOCEM_ARB_CNTRL_VC_EOP_RD_HIX downto NOCEM_ARB_CNTRL_VC_EOP_RD_LIX);

		 -- 0: free, 1: allocated --
		 l1: for I in NOCEM_NUM_VC-1 downto 0 loop
		 	if vc_state(I) = '0' and next_free_vc(I) = '1' and vc_allocate = '1' then -- free going to allocated
				vc_state(I) <= '1';
			elsif vc_state(I) = '1' and free_this_vc(I) = '1' then -- allocated going to free
				vc_state(I) <= '0';
			end if;		 
		 end loop;

	end if;
end process;

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------


dataout_gen_clkd : process (clk,rst_i,nextState)
begin
	if rst_i = '1' then
		 state <= init_st;
		 interval_counter		<= (others => '0');
		 dataout_reg		   <= (others => '0');
		 vc_mux_wr_reg		   <= (others => '0');
		 -- setup pkt_cntrl correctly
		 pkt_cntrl_out_reg <= (others => '0');
		 pkt_cntrl_out_reg(NOCEM_PKTCNTRL_DEST_ADDR_HIX downto NOCEM_PKTCNTRL_DEST_ADDR_LIX)	<=  addr_gen(INIT_DEST_ADDR,NOCEM_NUM_ROWS,NOCEM_NUM_COLS,NOCEM_AW); 
																																 

		 burst_counter       <= (others => '0');
	elsif clk'event and clk='1' then
		state <= nextState;
   	case state is
      	when init_st =>
				 interval_counter		<= interval_counter+1;
				 --dataout_reg		   <= (others => '0');
--				 pkt_cntrl_out_reg(NOCEM_PKTCNTRL_SOP_IX)	<= '1'; 
--				 
--				 if PKT_LENGTH = 1 then
--				 	pkt_cntrl_out_reg(NOCEM_PKTCNTRL_EOP_IX)	<= '1';	
--				 else
--				 	pkt_cntrl_out_reg(NOCEM_PKTCNTRL_EOP_IX)	<= '0';
--				 end if;				 
				 vc_mux_wr_reg <= (others => '0');
				 
				 
	
				 			  
				 burst_counter       <= (others => '0');

			when getting_vc_st =>
				--pkt_cntrl_out_reg <= (others => '0');
				interval_counter <= (others => '0');
				vc_mux_wr_reg <= next_free_vc;
			when sending_st =>
				-- marking packets with src addrs...
				dataout_reg(NOCEM_DW-1 downto NOCEM_AW) <= dataout_reg(NOCEM_DW-1 downto NOCEM_AW) + 1;
				dataout_reg(NOCEM_AW-1 downto 0)        <= addr_gen(MY_ADDR,NOCEM_NUM_ROWS,NOCEM_NUM_COLS,NOCEM_AW);
					
				-- handle the pkt_control reg

				-- increment the data inside
				if arb_grant = '1' and dataout_recvd = '1' then
					burst_counter <= 	burst_counter + 1;
				end if;
				
				if nextState = init_st then
				
					-- increment destination field (making sure it doesn't send a packet to myself)				 
					if pkt_cntrl_out_reg(NOCEM_PKTCNTRL_DEST_ADDR_HIX downto NOCEM_PKTCNTRL_DEST_ADDR_LIX)+1 = addr_gen(MY_ADDR,NOCEM_NUM_ROWS,NOCEM_NUM_COLS,NOCEM_AW) then
							pkt_cntrl_out_reg(NOCEM_PKTCNTRL_DEST_ADDR_HIX downto NOCEM_PKTCNTRL_DEST_ADDR_LIX) <= pkt_cntrl_out_reg(NOCEM_PKTCNTRL_DEST_ADDR_HIX downto NOCEM_PKTCNTRL_DEST_ADDR_LIX) + 2;
					else
							pkt_cntrl_out_reg(NOCEM_PKTCNTRL_DEST_ADDR_HIX downto NOCEM_PKTCNTRL_DEST_ADDR_LIX) <= pkt_cntrl_out_reg(NOCEM_PKTCNTRL_DEST_ADDR_HIX downto NOCEM_PKTCNTRL_DEST_ADDR_LIX) + 1;
					end if;	
				end if;



			when others =>
				null;
		end case;
	end if;
end process;


dataout_gen_uclkd : process (next_free_vc, vc_mux_wr_reg,pkt_cntrl_out_reg, pkt_cntrl_out_recvd,state, interval_counter, dataout_reg, arb_grant, dataout_recvd, burst_counter)
begin

		 arb_req	 <= '0';
		 arb_sending_word <= (others => '0');
		 dataout	 <= (others => '0');
		 dataout_valid	 <= '0';
		 --nextState <= init_st;

		 pkt_cntrl_out	 <= (others => '0');
		 pkt_cntrl_out_valid <= '0';
		 vc_allocate <= '0';

		case state is
      	when init_st =>

					if interval_counter = CONV_STD_LOGIC_VECTOR(DATA_OUT_INTERVAL,INTERVAL_COUNTER_WIDTH) then					
						nextState <= getting_vc_st;
					else
						nextState <= init_st;						
					end if;
       
			when getting_vc_st =>

				if next_free_vc /= 0 then
					vc_allocate <= '1';
					nextState <= sending_st;
				else
					nextState <= getting_vc_st;
				end if;			


			when sending_st =>

				arb_req <= '1';
				arb_sending_word(NOCEM_ARB_CNTRL_VC_MUX_WR_HIX downto NOCEM_ARB_CNTRL_VC_MUX_WR_LIX) <= vc_mux_wr_reg;

				dataout <= dataout_reg;
				dataout_valid <= '1';

				pkt_cntrl_out <= pkt_cntrl_out_reg;
				pkt_cntrl_out_valid <= '1';


				if burst_counter = 0 then
					pkt_cntrl_out(NOCEM_PKTCNTRL_SOP_IX)	<= '1';	
				end if;

				if burst_counter = PKT_LENGTH then
					pkt_cntrl_out(NOCEM_PKTCNTRL_EOP_IX)	<= '1';
		 			nextState <= init_st;				
				else
		 			nextState <= sending_st;				
				end if;

			when others =>
				null;
		end case;
end process;



----------------------------------------------------
----------------------------------------------------
-----------      DATAIN SIGNALLING     -------------
----------------------------------------------------
----------------------------------------------------

vc_datain_st_gen_clkd : process(clk,rst,arb_cntrl_in)
begin
 
	eop_wr_sig <= arb_cntrl_in(NOCEM_ARB_CNTRL_VC_EOP_WR_HIX downto NOCEM_ARB_CNTRL_VC_EOP_WR_LIX);

	if rst='1' then
		pkt_rdy <= (others => '0');
		next_vc_with_pkt <= (others => '0');
		datain_reg <= (others => '0');
		pkt_cntrl_in_reg <= (others => '0');
		recv_idle <= '1';
	elsif clk'event and clk='1' then
		

		l1: for I in NOCEM_NUM_VC-1 downto 0 loop

			-- is the pkt rdy for reading?
			if eop_wr_sig(I) = '1' then
				pkt_rdy(I) <= '1';
			elsif finished_pkt(I) = '1' then
				pkt_rdy(I) <= '0';			
			end if;	

			-- what is the next pkt to read from VCs?
			if pkt_rdy(I) = '1' and recv_idle = '1' then
				next_vc_with_pkt <= CONV_STD_LOGIC_VECTOR(2**I,NOCEM_NUM_VC);
				recv_idle <= '0';
			elsif finished_pkt /= 0 then
				recv_idle <= '1';	
			end if;
	  
		end loop;

		if pkt_rdy = 0 then
			next_vc_with_pkt <= (others => '0');
		end if;


	end if;

end process;

 

datain_gather_uclkd : process (next_vc_with_pkt, pkt_cntrl_in,datain_valid,pkt_cntrl_in_valid)
begin

	datain_recvd <= '0';
	pkt_cntrl_in_recvd <= '0';
	finished_pkt <= (others => '0');
	arb_receiving_word <= (others => '0');


  	if next_vc_with_pkt /= 0 then
		arb_receiving_word(NOCEM_ARB_CNTRL_VC_MUX_RD_HIX downto NOCEM_ARB_CNTRL_VC_MUX_RD_LIX) <= next_vc_with_pkt;
		datain_recvd <= '1';	
	end if;

  	if next_vc_with_pkt /= 0 then
		pkt_cntrl_in_recvd <= '1';	
		if pkt_cntrl_in(NOCEM_PKTCNTRL_EOP_IX)	= '1' then
			finished_pkt <= next_vc_with_pkt;
		end if;			
	end if;


end process;



debug_gen : process (arb_sending_word)
begin

	debug_vc_mux_wr <= arb_sending_word(NOCEM_ARB_CNTRL_VC_MUX_WR_HIX downto NOCEM_ARB_CNTRL_VC_MUX_WR_LIX);

end process;



end Behavioral;
