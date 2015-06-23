
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.pkg_nocem.all;


entity vc_node_ch_arbiter is
    Port ( 
		-- needed to mux outputs for the accompanying switch
 		arb_grant_output : out arb_decision_array(4 downto 0);

	   n_channel_cntrl_in  : in channel_cntrl_word;
	   n_channel_cntrl_out : out channel_cntrl_word;

	   s_channel_cntrl_in  : in channel_cntrl_word;
	   s_channel_cntrl_out : out channel_cntrl_word;

	   e_channel_cntrl_in  : in channel_cntrl_word;
	   e_channel_cntrl_out : out channel_cntrl_word;

	   w_channel_cntrl_in  : in channel_cntrl_word;
	   w_channel_cntrl_out : out channel_cntrl_word;

	   ap_channel_cntrl_in  : in channel_cntrl_word;
	   ap_channel_cntrl_out : out channel_cntrl_word;
	 
	   clk : in std_logic;
      rst : in std_logic
		
		);
end vc_node_ch_arbiter;

architecture Behavioral of vc_node_ch_arbiter is
 		
	constant VCS_ALL_FULL : std_logic_vector(NOCEM_NUM_VC-1 downto 0) := (others => '1');


	signal dest_local_port    	  		: arb_decision_array(4 downto 0);
	signal arb_decision_enum     		: arb_decision_array(4 downto 0);
	signal channel_cntrl_in_array_i  : channel_cntrl_array(4 downto 0);
	signal channel_cntrl_out_array_ureg : channel_cntrl_array(4 downto 0);
	signal dest_local_vc_ureg,dest_local_vc_reg 				: vc_addr_array(4 downto 0);
	signal channel_cntrl_out_array   : channel_cntrl_array(4 downto 0);
	signal n_channel_cntrl_out_reg	: channel_cntrl_word;
	signal s_channel_cntrl_out_reg	: channel_cntrl_word;
	signal e_channel_cntrl_out_reg	: channel_cntrl_word;
	signal w_channel_cntrl_out_reg	: channel_cntrl_word;
	signal ap_channel_cntrl_out_reg	: channel_cntrl_word;
	signal arb_grant_output_reg,arb_grant_output_ureg		: arb_decision_array(4 downto 0);

	signal zeroes_bv : bit_vector(NOCEM_NUM_VC-1 downto 0);

begin

	zeroes_bv <= (others => '0');


	-- just setting up an array or two for "easy" looping
	arb_decision_enum(NOCEM_AP_IX) 		<= ARB_AP;
	arb_decision_enum(NOCEM_NORTH_IX) 	<= ARB_NORTH;
	arb_decision_enum(NOCEM_SOUTH_IX) 	<= ARB_SOUTH;
	arb_decision_enum(NOCEM_EAST_IX) 	<= ARB_EAST;
	arb_decision_enum(NOCEM_WEST_IX) 	<= ARB_WEST;

	dest_local_port(NOCEM_AP_IX) 		<= ap_channel_cntrl_in(NOCEM_CHFIFO_VC_CHDEST_HIX downto NOCEM_CHFIFO_VC_CHDEST_LIX);
	dest_local_port(NOCEM_NORTH_IX) 	<= n_channel_cntrl_in(NOCEM_CHFIFO_VC_CHDEST_HIX downto NOCEM_CHFIFO_VC_CHDEST_LIX);
	dest_local_port(NOCEM_SOUTH_IX) 	<= s_channel_cntrl_in(NOCEM_CHFIFO_VC_CHDEST_HIX downto NOCEM_CHFIFO_VC_CHDEST_LIX);
	dest_local_port(NOCEM_EAST_IX) 	<= e_channel_cntrl_in(NOCEM_CHFIFO_VC_CHDEST_HIX downto NOCEM_CHFIFO_VC_CHDEST_LIX);
	dest_local_port(NOCEM_WEST_IX) 	<= w_channel_cntrl_in(NOCEM_CHFIFO_VC_CHDEST_HIX downto NOCEM_CHFIFO_VC_CHDEST_LIX);

	dest_local_vc_ureg(NOCEM_AP_IX) 		<= ap_channel_cntrl_in(NOCEM_CHFIFO_VC_VCDEST_HIX downto NOCEM_CHFIFO_VC_VCDEST_LIX);
	dest_local_vc_ureg(NOCEM_NORTH_IX) 	<= n_channel_cntrl_in(NOCEM_CHFIFO_VC_VCDEST_HIX downto NOCEM_CHFIFO_VC_VCDEST_LIX);
	dest_local_vc_ureg(NOCEM_SOUTH_IX) 	<= s_channel_cntrl_in(NOCEM_CHFIFO_VC_VCDEST_HIX downto NOCEM_CHFIFO_VC_VCDEST_LIX);
	dest_local_vc_ureg(NOCEM_EAST_IX) 	<= e_channel_cntrl_in(NOCEM_CHFIFO_VC_VCDEST_HIX downto NOCEM_CHFIFO_VC_VCDEST_LIX);
	dest_local_vc_ureg(NOCEM_WEST_IX) 	<= w_channel_cntrl_in(NOCEM_CHFIFO_VC_VCDEST_HIX downto NOCEM_CHFIFO_VC_VCDEST_LIX);




  	channel_cntrl_in_array_i(NOCEM_NORTH_IX) <= n_channel_cntrl_in;
  	channel_cntrl_in_array_i(NOCEM_SOUTH_IX) <= s_channel_cntrl_in;
	channel_cntrl_in_array_i(NOCEM_EAST_IX)  <= e_channel_cntrl_in;
	channel_cntrl_in_array_i(NOCEM_WEST_IX)  <= w_channel_cntrl_in;
	channel_cntrl_in_array_i(NOCEM_AP_IX)    <= ap_channel_cntrl_in;



	n_channel_cntrl_out  <= channel_cntrl_out_array(NOCEM_NORTH_IX);
	s_channel_cntrl_out  <= channel_cntrl_out_array(NOCEM_SOUTH_IX);
	e_channel_cntrl_out  <= channel_cntrl_out_array(NOCEM_EAST_IX);
	w_channel_cntrl_out  <= channel_cntrl_out_array(NOCEM_WEST_IX);
	ap_channel_cntrl_out <= channel_cntrl_out_array(NOCEM_AP_IX);



outputs_regd : process (clk,rst)
begin
	
	if rst='1' then

	  	n_channel_cntrl_out_reg  <= (others => '0');
	  	s_channel_cntrl_out_reg  <= (others => '0');
		e_channel_cntrl_out_reg  <= (others => '0');
		w_channel_cntrl_out_reg  <= (others => '0');
		ap_channel_cntrl_out_reg <= (others => '0');
		arb_grant_output_reg     <= (others => ARB_NODECISION);
		dest_local_vc_reg        <= (others => (others => '0'));
	elsif clk='1' and clk'event then

	  	n_channel_cntrl_out_reg  <= channel_cntrl_out_array_ureg(NOCEM_NORTH_IX);
	  	s_channel_cntrl_out_reg  <= channel_cntrl_out_array_ureg(NOCEM_SOUTH_IX);
		e_channel_cntrl_out_reg  <= channel_cntrl_out_array_ureg(NOCEM_EAST_IX);
		w_channel_cntrl_out_reg  <= channel_cntrl_out_array_ureg(NOCEM_WEST_IX);
		ap_channel_cntrl_out_reg <= channel_cntrl_out_array_ureg(NOCEM_AP_IX);
		arb_grant_output_reg     <= arb_grant_output_ureg;
		dest_local_vc_reg			 <=  dest_local_vc_ureg;								
	end if;


end process;


outputs_post_regd : process (n_channel_cntrl_in, s_channel_cntrl_in, e_channel_cntrl_in, w_channel_cntrl_in, ap_channel_cntrl_in, n_channel_cntrl_out_reg, s_channel_cntrl_out_reg, e_channel_cntrl_out_reg, w_channel_cntrl_out_reg, ap_channel_cntrl_out_reg, arb_grant_output_reg, dest_local_vc_reg, channel_cntrl_in_array_i, zeroes_bv)
begin



																											
 																																																		 


		-- need to do a sanity check that the incoming channel still has 
		-- data to give.  This is an artifact of the register pushing inside the 
		-- the arbitration process;

	  	channel_cntrl_out_array(NOCEM_NORTH_IX) 		<= n_channel_cntrl_out_reg;
	  	channel_cntrl_out_array(NOCEM_SOUTH_IX) 		<= s_channel_cntrl_out_reg;
		channel_cntrl_out_array(NOCEM_EAST_IX) 		<= e_channel_cntrl_out_reg;
		channel_cntrl_out_array(NOCEM_WEST_IX) 		<= w_channel_cntrl_out_reg;
		channel_cntrl_out_array(NOCEM_AP_IX) 			<= ap_channel_cntrl_out_reg;
	   
		arb_grant_output		 								<=  arb_grant_output_reg;
		

		-- looking to see that what is being read is still there after some pipeline stages
		-- if not, just kill the read/write and switch allocation.  Also need to check if outgoing
		-- VC is not full now


		-- I iterates over output channels
		lll: for I in 4 downto 0 loop

			if arb_grant_output_reg(I) = ARB_NORTH and 
				-- if incoming FIFO is now empty			 
				((((TO_BITVECTOR(n_channel_cntrl_in(NOCEM_CHFIFO_VC_EMPTY_HIX downto NOCEM_CHFIFO_VC_EMPTY_LIX))) 
					and (TO_BITVECTOR(n_channel_cntrl_out_reg(NOCEM_CHFIFO_VC_RD_ADDR_HIX downto NOCEM_CHFIFO_VC_RD_ADDR_LIX)))) /= zeroes_bv) or 
				-- if outgoing is FIFO is mow full
				((TO_BITVECTOR(dest_local_vc_reg(NOCEM_NORTH_IX)) and TO_BITVECTOR(channel_cntrl_in_array_i(I)(NOCEM_CHFIFO_VC_FULL_HIX downto NOCEM_CHFIFO_VC_FULL_LIX))) /= zeroes_bv) )					
					then
				
					arb_grant_output(I) <= ARB_NODECISION;

					channel_cntrl_out_array(NOCEM_NORTH_IX)(NOCEM_CHFIFO_DATA_RE_IX) <= '0';
					channel_cntrl_out_array(NOCEM_NORTH_IX)(NOCEM_CHFIFO_CNTRL_RE_IX) <= '0';			
					channel_cntrl_out_array(NOCEM_NORTH_IX)(NOCEM_CHFIFO_VC_RD_ADDR_HIX downto NOCEM_CHFIFO_VC_RD_ADDR_LIX) <= (others => '0');  

				   channel_cntrl_out_array(I)(NOCEM_CHFIFO_DATA_WE_IX) <= '0';
				   channel_cntrl_out_array(I)(NOCEM_CHFIFO_CNTRL_WE_IX) <= '0';
		         channel_cntrl_out_array(I)(NOCEM_CHFIFO_VC_WR_ADDR_HIX downto NOCEM_CHFIFO_VC_WR_ADDR_LIX) <= (others => '0'); 

			end if;

			if arb_grant_output_reg(I) = ARB_SOUTH and 
				-- if incoming FIFO is now empty			 
				((((TO_BITVECTOR(s_channel_cntrl_in(NOCEM_CHFIFO_VC_EMPTY_HIX downto NOCEM_CHFIFO_VC_EMPTY_LIX))) 
					and (TO_BITVECTOR(s_channel_cntrl_out_reg(NOCEM_CHFIFO_VC_RD_ADDR_HIX downto NOCEM_CHFIFO_VC_RD_ADDR_LIX)))) /= zeroes_bv) or 
				-- if outgoing is FIFO is mow full
				((TO_BITVECTOR(dest_local_vc_reg(NOCEM_SOUTH_IX)) and TO_BITVECTOR(channel_cntrl_in_array_i(I)(NOCEM_CHFIFO_VC_FULL_HIX downto NOCEM_CHFIFO_VC_FULL_LIX))) /= zeroes_bv) )					
					then



					arb_grant_output(I) <= ARB_NODECISION;

					channel_cntrl_out_array(NOCEM_SOUTH_IX)(NOCEM_CHFIFO_DATA_RE_IX) <= '0';
					channel_cntrl_out_array(NOCEM_SOUTH_IX)(NOCEM_CHFIFO_CNTRL_RE_IX) <= '0';			
					channel_cntrl_out_array(NOCEM_SOUTH_IX)(NOCEM_CHFIFO_VC_RD_ADDR_HIX downto NOCEM_CHFIFO_VC_RD_ADDR_LIX) <= (others => '0');  

				   channel_cntrl_out_array(I)(NOCEM_CHFIFO_DATA_WE_IX) <= '0';
				   channel_cntrl_out_array(I)(NOCEM_CHFIFO_CNTRL_WE_IX) <= '0';
		         channel_cntrl_out_array(I)(NOCEM_CHFIFO_VC_WR_ADDR_HIX downto NOCEM_CHFIFO_VC_WR_ADDR_LIX) <= (others => '0'); 

			end if;

			if arb_grant_output_reg(I) = ARB_EAST and 
				-- if incoming FIFO is now empty			 
				((((TO_BITVECTOR(e_channel_cntrl_in(NOCEM_CHFIFO_VC_EMPTY_HIX downto NOCEM_CHFIFO_VC_EMPTY_LIX))) 
					and (TO_BITVECTOR(e_channel_cntrl_out_reg(NOCEM_CHFIFO_VC_RD_ADDR_HIX downto NOCEM_CHFIFO_VC_RD_ADDR_LIX)))) /= zeroes_bv) or 
				-- if outgoing is FIFO is mow full
				((TO_BITVECTOR(dest_local_vc_reg(NOCEM_EAST_IX)) and TO_BITVECTOR(channel_cntrl_in_array_i(I)(NOCEM_CHFIFO_VC_FULL_HIX downto NOCEM_CHFIFO_VC_FULL_LIX))) /= zeroes_bv) )					
					then





					arb_grant_output(I) <= ARB_NODECISION;

					channel_cntrl_out_array(NOCEM_EAST_IX)(NOCEM_CHFIFO_DATA_RE_IX) <= '0';
					channel_cntrl_out_array(NOCEM_EAST_IX)(NOCEM_CHFIFO_CNTRL_RE_IX) <= '0';			
					channel_cntrl_out_array(NOCEM_EAST_IX)(NOCEM_CHFIFO_VC_RD_ADDR_HIX downto NOCEM_CHFIFO_VC_RD_ADDR_LIX) <= (others => '0');  

				   channel_cntrl_out_array(I)(NOCEM_CHFIFO_DATA_WE_IX) <= '0';
				   channel_cntrl_out_array(I)(NOCEM_CHFIFO_CNTRL_WE_IX) <= '0';
		         channel_cntrl_out_array(I)(NOCEM_CHFIFO_VC_WR_ADDR_HIX downto NOCEM_CHFIFO_VC_WR_ADDR_LIX) <= (others => '0'); 

			end if;

			if arb_grant_output_reg(I) = ARB_WEST and 
				-- if incoming FIFO is now empty			 
				((((TO_BITVECTOR(w_channel_cntrl_in(NOCEM_CHFIFO_VC_EMPTY_HIX downto NOCEM_CHFIFO_VC_EMPTY_LIX))) 
					and (TO_BITVECTOR(w_channel_cntrl_out_reg(NOCEM_CHFIFO_VC_RD_ADDR_HIX downto NOCEM_CHFIFO_VC_RD_ADDR_LIX)))) /= zeroes_bv) or 
				-- if outgoing is FIFO is mow full
				((TO_BITVECTOR(dest_local_vc_reg(NOCEM_WEST_IX)) and TO_BITVECTOR(channel_cntrl_in_array_i(I)(NOCEM_CHFIFO_VC_FULL_HIX downto NOCEM_CHFIFO_VC_FULL_LIX))) /= zeroes_bv) )					
					then


					arb_grant_output(I) <= ARB_NODECISION;

					channel_cntrl_out_array(NOCEM_WEST_IX)(NOCEM_CHFIFO_DATA_RE_IX) <= '0';
					channel_cntrl_out_array(NOCEM_WEST_IX)(NOCEM_CHFIFO_CNTRL_RE_IX) <= '0';			
					channel_cntrl_out_array(NOCEM_WEST_IX)(NOCEM_CHFIFO_VC_RD_ADDR_HIX downto NOCEM_CHFIFO_VC_RD_ADDR_LIX) <= (others => '0');  

				   channel_cntrl_out_array(I)(NOCEM_CHFIFO_DATA_WE_IX) <= '0';
				   channel_cntrl_out_array(I)(NOCEM_CHFIFO_CNTRL_WE_IX) <= '0';
		         channel_cntrl_out_array(I)(NOCEM_CHFIFO_VC_WR_ADDR_HIX downto NOCEM_CHFIFO_VC_WR_ADDR_LIX) <= (others => '0'); 

			end if;

			if arb_grant_output_reg(I) = ARB_AP and 
				-- if incoming FIFO is now empty			 
				((((TO_BITVECTOR(ap_channel_cntrl_in(NOCEM_CHFIFO_VC_EMPTY_HIX downto NOCEM_CHFIFO_VC_EMPTY_LIX))) 
					and (TO_BITVECTOR(ap_channel_cntrl_out_reg(NOCEM_CHFIFO_VC_RD_ADDR_HIX downto NOCEM_CHFIFO_VC_RD_ADDR_LIX)))) /= zeroes_bv) or 
				-- if outgoing is FIFO is mow full
				((TO_BITVECTOR(dest_local_vc_reg(NOCEM_AP_IX)) and TO_BITVECTOR(channel_cntrl_in_array_i(I)(NOCEM_CHFIFO_VC_FULL_HIX downto NOCEM_CHFIFO_VC_FULL_LIX))) /= zeroes_bv) )					
					then

					arb_grant_output(I) <= ARB_NODECISION;

					channel_cntrl_out_array(NOCEM_AP_IX)(NOCEM_CHFIFO_DATA_RE_IX) <= '0';
					channel_cntrl_out_array(NOCEM_AP_IX)(NOCEM_CHFIFO_CNTRL_RE_IX) <= '0';			
					channel_cntrl_out_array(NOCEM_AP_IX)(NOCEM_CHFIFO_VC_RD_ADDR_HIX downto NOCEM_CHFIFO_VC_RD_ADDR_LIX) <= (others => '0');  

				   channel_cntrl_out_array(I)(NOCEM_CHFIFO_DATA_WE_IX) <= '0';
				   channel_cntrl_out_array(I)(NOCEM_CHFIFO_CNTRL_WE_IX) <= '0';
		         channel_cntrl_out_array(I)(NOCEM_CHFIFO_VC_WR_ADDR_HIX downto NOCEM_CHFIFO_VC_WR_ADDR_LIX) <= (others => '0'); 
		                     




			end if;

		end loop;

end process;






-- THIS IS WHERE THE DECISION IS MADE...

arb_gen : process (channel_cntrl_in_array_i,dest_local_port, dest_local_vc_ureg, ap_channel_cntrl_in, n_channel_cntrl_in, s_channel_cntrl_in, e_channel_cntrl_in, w_channel_cntrl_in, arb_decision_enum, zeroes_bv)
begin


	arb_grant_output_ureg <= (others => ARB_NODECISION);
	channel_cntrl_out_array_ureg <= (others => (others => '0'));


l3: for I in 4 downto 0 loop

	-- I iterates over the OUTPUT ports
	if channel_cntrl_in_array_i(I)(NOCEM_CHFIFO_VC_FULL_HIX downto NOCEM_CHFIFO_VC_FULL_LIX) /= VCS_ALL_FULL then
		

      -- determining if data can flow....
      -- incoming channel wants to travel to THIS (I) channel AND
      -- destination VC is not full 
      --        (done by AND'ing dest_local_vc, full_vector --> 0: dest_vc not full, /= 0, dest_vc is full)

		if dest_local_port(NOCEM_AP_IX) = arb_decision_enum(I) and 
			((TO_BITVECTOR(dest_local_vc_ureg(NOCEM_AP_IX)) and TO_BITVECTOR(channel_cntrl_in_array_i(I)(NOCEM_CHFIFO_VC_FULL_HIX downto NOCEM_CHFIFO_VC_FULL_LIX))) = zeroes_bv) then

			--arb grant will push data through switch
			arb_grant_output_ureg(I) <= ARB_AP;

			-- do read enable for selected incoming data
			channel_cntrl_out_array_ureg(NOCEM_AP_IX)(NOCEM_CHFIFO_DATA_RE_IX) <= '1';
			channel_cntrl_out_array_ureg(NOCEM_AP_IX)(NOCEM_CHFIFO_CNTRL_RE_IX) <= '1';

			
			channel_cntrl_out_array_ureg(NOCEM_AP_IX)(NOCEM_CHFIFO_VC_RD_ADDR_HIX downto NOCEM_CHFIFO_VC_RD_ADDR_LIX) 
							<= channel_cntrl_in_array_i(NOCEM_AP_IX)(NOCEM_CHFIFO_VC_VCSRC_HIX downto NOCEM_CHFIFO_VC_VCSRC_LIX); 


			-- do write enable for outgoing port
		   channel_cntrl_out_array_ureg(I)(NOCEM_CHFIFO_DATA_WE_IX) <= '1';
		   channel_cntrl_out_array_ureg(I)(NOCEM_CHFIFO_CNTRL_WE_IX) <= '1';

         -- do correct WR mux on virtual channel
         channel_cntrl_out_array_ureg(I)(NOCEM_CHFIFO_VC_WR_ADDR_HIX downto NOCEM_CHFIFO_VC_WR_ADDR_LIX) 
                     <= ap_channel_cntrl_in(NOCEM_CHFIFO_VC_VCDEST_HIX downto NOCEM_CHFIFO_VC_VCDEST_LIX);

		elsif dest_local_port(NOCEM_NORTH_IX) = arb_decision_enum(I) and 
			((TO_BITVECTOR(dest_local_vc_ureg(NOCEM_NORTH_IX)) and TO_BITVECTOR(channel_cntrl_in_array_i(I)(NOCEM_CHFIFO_VC_FULL_HIX downto NOCEM_CHFIFO_VC_FULL_LIX))) = zeroes_bv) then

			arb_grant_output_ureg(I) <= ARB_NORTH;

			-- do read enable for selected incoming data
			channel_cntrl_out_array_ureg(NOCEM_NORTH_IX)(NOCEM_CHFIFO_DATA_RE_IX) <= '1';
			channel_cntrl_out_array_ureg(NOCEM_NORTH_IX)(NOCEM_CHFIFO_CNTRL_RE_IX) <= '1';

			channel_cntrl_out_array_ureg(NOCEM_NORTH_IX)(NOCEM_CHFIFO_VC_RD_ADDR_HIX downto NOCEM_CHFIFO_VC_RD_ADDR_LIX) 
							<= channel_cntrl_in_array_i(NOCEM_NORTH_IX)(NOCEM_CHFIFO_VC_VCSRC_HIX downto NOCEM_CHFIFO_VC_VCSRC_LIX); 


			-- do write enable for outgoing port
		   channel_cntrl_out_array_ureg(I)(NOCEM_CHFIFO_DATA_WE_IX) <= '1';
		   channel_cntrl_out_array_ureg(I)(NOCEM_CHFIFO_CNTRL_WE_IX) <= '1';

         -- do correct WR mux on virtual channel
         channel_cntrl_out_array_ureg(I)(NOCEM_CHFIFO_VC_WR_ADDR_HIX downto NOCEM_CHFIFO_VC_WR_ADDR_LIX) 
                     <= n_channel_cntrl_in(NOCEM_CHFIFO_VC_VCDEST_HIX downto NOCEM_CHFIFO_VC_VCDEST_LIX);


		elsif dest_local_port(NOCEM_SOUTH_IX) = arb_decision_enum(I) and 
			((TO_BITVECTOR(dest_local_vc_ureg(NOCEM_SOUTH_IX)) and TO_BITVECTOR(channel_cntrl_in_array_i(I)(NOCEM_CHFIFO_VC_FULL_HIX downto NOCEM_CHFIFO_VC_FULL_LIX))) = zeroes_bv) then

			arb_grant_output_ureg(I) <= ARB_SOUTH;

			-- do read enable for selected incoming data
			channel_cntrl_out_array_ureg(NOCEM_SOUTH_IX)(NOCEM_CHFIFO_DATA_RE_IX) <= '1';
			channel_cntrl_out_array_ureg(NOCEM_SOUTH_IX)(NOCEM_CHFIFO_CNTRL_RE_IX) <= '1';

			channel_cntrl_out_array_ureg(NOCEM_SOUTH_IX)(NOCEM_CHFIFO_VC_RD_ADDR_HIX downto NOCEM_CHFIFO_VC_RD_ADDR_LIX) 
							<= channel_cntrl_in_array_i(NOCEM_SOUTH_IX)(NOCEM_CHFIFO_VC_VCSRC_HIX downto NOCEM_CHFIFO_VC_VCSRC_LIX); 


			-- do write enable for outgoing port
		   channel_cntrl_out_array_ureg(I)(NOCEM_CHFIFO_DATA_WE_IX) <= '1';
		   channel_cntrl_out_array_ureg(I)(NOCEM_CHFIFO_CNTRL_WE_IX) <= '1';

         -- do correct WR mux on virtual channel
         channel_cntrl_out_array_ureg(I)(NOCEM_CHFIFO_VC_WR_ADDR_HIX downto NOCEM_CHFIFO_VC_WR_ADDR_LIX) 
                     <= s_channel_cntrl_in(NOCEM_CHFIFO_VC_VCDEST_HIX downto NOCEM_CHFIFO_VC_VCDEST_LIX);


		elsif dest_local_port(NOCEM_EAST_IX) = arb_decision_enum(I) and 
			((TO_BITVECTOR(dest_local_vc_ureg(NOCEM_EAST_IX)) and TO_BITVECTOR(channel_cntrl_in_array_i(I)(NOCEM_CHFIFO_VC_FULL_HIX downto NOCEM_CHFIFO_VC_FULL_LIX))) = zeroes_bv) then

			arb_grant_output_ureg(I) <= ARB_EAST;

			-- do read enable for selected incoming data
			channel_cntrl_out_array_ureg(NOCEM_EAST_IX)(NOCEM_CHFIFO_DATA_RE_IX) <= '1';
			channel_cntrl_out_array_ureg(NOCEM_EAST_IX)(NOCEM_CHFIFO_CNTRL_RE_IX) <= '1';

			channel_cntrl_out_array_ureg(NOCEM_EAST_IX)(NOCEM_CHFIFO_VC_RD_ADDR_HIX downto NOCEM_CHFIFO_VC_RD_ADDR_LIX) 
							<= channel_cntrl_in_array_i(NOCEM_EAST_IX)(NOCEM_CHFIFO_VC_VCSRC_HIX downto NOCEM_CHFIFO_VC_VCSRC_LIX); 


			-- do write enable for outgoing port
		   channel_cntrl_out_array_ureg(I)(NOCEM_CHFIFO_DATA_WE_IX) <= '1';
		   channel_cntrl_out_array_ureg(I)(NOCEM_CHFIFO_CNTRL_WE_IX) <= '1';

         -- do correct WR mux on virtual channel
         channel_cntrl_out_array_ureg(I)(NOCEM_CHFIFO_VC_WR_ADDR_HIX downto NOCEM_CHFIFO_VC_WR_ADDR_LIX) 
                     <= e_channel_cntrl_in(NOCEM_CHFIFO_VC_VCDEST_HIX downto NOCEM_CHFIFO_VC_VCDEST_LIX);


		elsif dest_local_port(NOCEM_WEST_IX) = arb_decision_enum(I) and 
			((TO_BITVECTOR(dest_local_vc_ureg(NOCEM_WEST_IX)) and TO_BITVECTOR(channel_cntrl_in_array_i(I)(NOCEM_CHFIFO_VC_FULL_HIX downto NOCEM_CHFIFO_VC_FULL_LIX))) = zeroes_bv) then

			arb_grant_output_ureg(I) <= ARB_WEST;	 			

			-- do read enable for selected incoming data
			channel_cntrl_out_array_ureg(NOCEM_WEST_IX)(NOCEM_CHFIFO_DATA_RE_IX) <= '1';
			channel_cntrl_out_array_ureg(NOCEM_WEST_IX)(NOCEM_CHFIFO_CNTRL_RE_IX) <= '1';

			channel_cntrl_out_array_ureg(NOCEM_WEST_IX)(NOCEM_CHFIFO_VC_RD_ADDR_HIX downto NOCEM_CHFIFO_VC_RD_ADDR_LIX) 
							<= channel_cntrl_in_array_i(NOCEM_WEST_IX)(NOCEM_CHFIFO_VC_VCSRC_HIX downto NOCEM_CHFIFO_VC_VCSRC_LIX); 


			-- do write enable for outgoing port
		   channel_cntrl_out_array_ureg(I)(NOCEM_CHFIFO_DATA_WE_IX) <= '1';
		   channel_cntrl_out_array_ureg(I)(NOCEM_CHFIFO_CNTRL_WE_IX) <= '1';

         -- do correct WR mux on virtual channel
         channel_cntrl_out_array_ureg(I)(NOCEM_CHFIFO_VC_WR_ADDR_HIX downto NOCEM_CHFIFO_VC_WR_ADDR_LIX) 
                     <= w_channel_cntrl_in(NOCEM_CHFIFO_VC_VCDEST_HIX downto NOCEM_CHFIFO_VC_VCDEST_LIX);


		end if;
	end if;




end loop;



end process;




end Behavioral;
