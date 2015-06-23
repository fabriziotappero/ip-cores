
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
-- Filename: access_point_exerciser.vhd
-- 
-- Description: access point exerciser for nonVC designs
-- 



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.pkg_nocem.all;



entity access_point_exerciser is
	Generic(

		DELAY_START_COUNTER_WIDTH : integer := 32;
		DELAY_START_CYCLES : integer := 500;


		BURST_LENGTH : integer := 5;
		INIT_DATA_OUT : data_word := CONV_STD_LOGIC_VECTOR(1,NOCEM_DW);

		INTERVAL_COUNTER_WIDTH : integer := 8;
		DATA_OUT_INTERVAL : integer := 16;

	   INIT_DEST_ADDR : integer := 2



		 )	;
    Port ( 
	 
		-- arbitration lines (usage depends on underlying network)
		arb_req         : out  std_logic;
		arb_cntrl_out   : out  arb_cntrl_word;

		arb_grant         : in std_logic;
		arb_cntrl_in   : in  arb_cntrl_word;
		
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



end access_point_exerciser;

architecture Behavioral of access_point_exerciser is




signal rst_i : std_logic;
signal rst_counter : std_logic_vector(DELAY_START_COUNTER_WIDTH-1 downto 0);
signal interval_counter : std_logic_vector(INTERVAL_COUNTER_WIDTH-1 downto 0);
signal dataout_reg : std_logic_vector(NOCEM_DW-1 downto 0);
signal pkt_cntrl_out_reg : pkt_cntrl_word;


signal burst_counter : std_logic_vector(7 downto 0);

signal datain_reg : data_word;
signal pkt_cntrl_in_reg : pkt_cntrl_word;


  type stateType is (init_st,sending_st,getting_arb_st);
  signal state,nextState : stateType;


begin

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


dataout_gen_clkd : process (clk,rst_i,nextState)
begin
	if rst_i = '1' then
		 state <= init_st;
		 interval_counter		<= (others => '0');
		 dataout_reg			<= INIT_DATA_OUT;

		 -- setup pkt_cntrl correctly
		 pkt_cntrl_out_reg	<= CONV_STD_LOGIC_VECTOR(INIT_DEST_ADDR,NOCEM_PKT_CNTRL_WIDTH);



		 burst_counter       <= (others => '0');
	elsif clk'event and clk='1' then
		state <= nextState;
   	case state is
      	when init_st =>
				interval_counter <= interval_counter+1;
				burst_counter <= (others => '0');
				--dataout_reg <=  INIT_DATA_OUT;
				--pkt_cntrl_out_reg <= 
			when getting_arb_st =>
				interval_counter <= (others => '0');

				if nextState = sending_st or nextState = init_st then
					dataout_reg <= dataout_reg + 1;
					burst_counter <= burst_counter+1;
				end if;

				if nextState = init_st then
					pkt_cntrl_out_reg <= pkt_cntrl_out_reg + 1;
				end if;


			when sending_st =>
				if arb_grant = '1' and dataout_recvd = '1' then
					burst_counter <= 	burst_counter + 1;
				end if;
				
				if nextState = init_st then
					pkt_cntrl_out_reg <= pkt_cntrl_out_reg + 1;
				end if;	

			when others =>
				null;
		end case;
	end if;
end process;


dataout_gen_uclkd : process (pkt_cntrl_out_reg, pkt_cntrl_out_recvd,state, interval_counter, dataout_reg, arb_grant, dataout_recvd, burst_counter)
begin

		 arb_req	 <= '0';
		 dataout	 <= (others => '0');
		 dataout_valid	 <= '0';
		 nextState <= init_st;
		 arb_cntrl_out <= (others => '0');
		 pkt_cntrl_out	 <= (others => '0');
		 pkt_cntrl_out_valid <= '0';
		 
	case state is
      	when init_st =>
					if interval_counter = CONV_STD_LOGIC_VECTOR(DATA_OUT_INTERVAL,INTERVAL_COUNTER_WIDTH) then
						nextState <= getting_arb_st;
					else
						nextState <= init_st;						
					end if;
       
			when getting_arb_st =>
				arb_req <= '1';
				dataout <= dataout_reg;
				dataout_valid <= '1';

				pkt_cntrl_out <= pkt_cntrl_out_reg;
				pkt_cntrl_out_valid <= '1';


				if arb_grant = '1' and dataout_recvd = '1' and pkt_cntrl_out_recvd = '1'and BURST_LENGTH /= 1 then
		 			nextState <= sending_st;
				elsif	arb_grant = '1' and dataout_recvd = '1' and pkt_cntrl_out_recvd = '1' and BURST_LENGTH = 1 then 
					nextState <= init_st;
				else
					nextState <= getting_arb_st;
				end if;

				


			when sending_st =>
				arb_req <= '1';
				dataout <= dataout_reg;
				dataout_valid <= '1';

				if burst_counter = BURST_LENGTH then
		 			nextState <= init_st;				
				else
		 			nextState <= sending_st;				
				end if;

			when others =>
				null;
		end case;
end process;



datain_gather_clkd : process (clk,rst)
begin

	if rst='1' then
		--datain_recvd      <= '0';
		datain_reg	      <= (others => '0');
		pkt_cntrl_in_reg 	<= (others => '0');
		--pkt_cntrl_in_recvd <= '0';
	elsif clk'event and clk= '1' then 
	  	if datain_valid = '1' then
	  		datain_reg <= datain;
			--datain_recvd <= '1';
			--pkt_cntrl_in_recvd <= '1';
	  	else
			--datain_recvd <= '0';
			--pkt_cntrl_in_recvd <= '0';
		end if;

	  	if pkt_cntrl_in_valid = '1' then
	  		pkt_cntrl_in_reg <= pkt_cntrl_in;
			--pkt_cntrl_in_recvd  <= '1';
		else
			--pkt_cntrl_in_recvd  <= '0';
		end if;	
	end if;

end process;

datain_gather_uclkd : process (datain_valid,pkt_cntrl_in_valid)
begin

	datain_recvd <= '0';
	pkt_cntrl_in_recvd <= '0';
	
  	if datain_valid = '1' then
		datain_recvd <= '1';	
	end if;

  	if pkt_cntrl_in_valid = '1' then
		pkt_cntrl_in_recvd <= '1';			
	end if;


end process;





end Behavioral;
