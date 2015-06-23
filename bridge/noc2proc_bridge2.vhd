
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
-- Filename: noc2proc_bridge2.vhd
-- 
-- Description: the bridge for proc2noc communication
-- 



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_textio.all;


use work.pkg_nocem.all;
--use work.pkg_snocem.all;

library std;
use std.textio.all;


entity noc2proc_bridge2 is
  generic
  (

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol parameters, do not add to or delete
    C_AWIDTH                       : integer              := 32;
    C_DWIDTH                       : integer              := 64;
    C_NUM_CS                       : integer              := 1;
    C_NUM_CE                       : integer              := 2;
    C_IP_INTR_NUM                  : integer              := 1
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
  port
  (
    -- ADD USER PORTS BELOW THIS LINE ------------------


		noc_arb_req         : out  std_logic;
		noc_arb_cntrl_out       : out  arb_cntrl_word;

		noc_arb_grant       : in  std_logic;
		noc_arb_cntrl_in        : in  arb_cntrl_word;
		
		noc_datain        : in   std_logic_vector(NOCEM_DW-1 downto 0);
		noc_datain_valid  : in   std_logic;
		noc_datain_recvd  : out  std_logic;

		noc_dataout       : out std_logic_vector(NOCEM_DW-1 downto 0);
		noc_dataout_valid : out std_logic;
		noc_dataout_recvd : in  std_logic;

		noc_pkt_cntrl_in        : in   pkt_cntrl_word;
		noc_pkt_cntrl_in_valid  : in   std_logic;
		noc_pkt_cntrl_in_recvd  : out  std_logic;      
             
		noc_pkt_cntrl_out       : out pkt_cntrl_word;
		noc_pkt_cntrl_out_valid : out std_logic;
		noc_pkt_cntrl_out_recvd : in  std_logic;





    -- ADD USER PORTS ABOVE THIS LINE ------------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol ports, do not add to or delete
    Bus2IP_Clk                     : in  std_logic;
    Bus2IP_Reset                   : in  std_logic;
    IP2Bus_IntrEvent               : out std_logic_vector(0 to C_IP_INTR_NUM-1);
    Bus2IP_Addr                    : in  std_logic_vector(0 to C_AWIDTH-1);
    Bus2IP_Data                    : in  std_logic_vector(0 to C_DWIDTH-1);
    Bus2IP_BE                      : in  std_logic_vector(0 to C_DWIDTH/8-1);
    Bus2IP_Burst                   : in  std_logic;
    Bus2IP_CS                      : in  std_logic_vector(0 to C_NUM_CS-1);
    Bus2IP_CE                      : in  std_logic_vector(0 to C_NUM_CE-1);
    Bus2IP_RdCE                    : in  std_logic_vector(0 to C_NUM_CE-1);
    Bus2IP_WrCE                    : in  std_logic_vector(0 to C_NUM_CE-1);
    Bus2IP_RdReq                   : in  std_logic;
    Bus2IP_WrReq                   : in  std_logic;
    IP2Bus_Data                    : out std_logic_vector(0 to C_DWIDTH-1);
    IP2Bus_Retry                   : out std_logic;
    IP2Bus_Error                   : out std_logic;
    IP2Bus_ToutSup                 : out std_logic;
    IP2Bus_RdAck                   : out std_logic;
    IP2Bus_WrAck                   : out std_logic
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
end noc2proc_bridge2;

architecture Behavioral of noc2proc_bridge2 is

	COMPONENT packetbuffer2
	generic(
		 METADATA_WIDTH : integer;
		 METADATA_LENGTH : integer
	);	
	Port ( 
		din   : IN std_logic_VECTOR(31 downto 0);		
		rd_en : IN std_logic;		
		wr_en : IN std_logic;
		dout  : OUT std_logic_VECTOR(31 downto 0);
		empty : OUT std_logic;
		full  : OUT std_logic;
		pkt_metadata_din 		: in std_logic_vector(METADATA_WIDTH-1 downto 0);		
		pkt_metadata_re		: IN std_logic;				
		pkt_metadata_we		: IN std_logic;
		pkt_metadata_dout 	: out std_logic_vector(METADATA_WIDTH-1 downto 0);	 
	 	clk : in std_logic;
      rst : in std_logic);
	END COMPONENT;



	------------------ GLOBAL SIGNALS     ----------------------------------
	signal clk,rst : std_logic;
	signal  arb_sending_word,arb_receiving_word   :   arb_cntrl_word;
	signal allones_vcwidth : std_logic_vector(NOCEM_NUM_VC-1 downto 0);


   ------------------ PB 2 NoC Signals   ----------------------------------
	signal pb2noc_word1,pb2noc_word2,pb2noc_word3,pb2noc_word4 : std_logic_vector(31 downto 0);
	signal outgoing_next_free_vc  : std_logic_vector(NOCEM_NUM_VC-1 downto 0);
	signal outgoing_vc_state : std_logic_Vector(NOCEM_NUM_VC-1 downto 0);   -- 0: free, 1: allocated --
	signal pb2noc_vc_alloc : std_logic;
	signal outgoing_free_this_vc	 : std_logic_vector(NOCEM_NUM_VC-1 downto 0);
	signal vc_mux_wr_reg	 : std_logic_vector(NOCEM_VC_ID_WIDTH-1 downto 0);
	signal pb2noc_byte_counter : std_logic_vector(7 downto 0);
	signal pb2noc_pkt_dest_addr : std_logic_vector(NOCEM_AW-1 downto 0);
	signal pb2noc_pkt_len : std_logic_vector(7 downto 0);

	signal pb2noc_amI_os : std_logic;

	type pb2noc_st is (init_st,getting_vc_st,sending_word1_st,sending_word2_st,sending_word3_st,sending_word4_st) ;
	signal pb2noc_state,pb2noc_nextState : pb2noc_st;

   ------------------ PB 2 Processor Signals   ----------------------------
  	signal pb2proc_interrupt : std_logic_vector(0 to C_IP_INTR_NUM-1);
	signal pb2proc_byte_counter : std_logic_vector(7 downto 0);
  	signal pb2proc_dest_addr_i : std_logic_vector(NOCEM_AW-1 downto 0);
	signal pb2proc_pkt_len_i : std_logic_vector(7 downto 0);
	signal pb2proc_len_addr_aggr : std_logic_vector(0 to C_DWIDTH-1);



	type pb2proc_st is (IDLE_ST, SENDING_META_ST,SENDING_ST) ;
	signal pb2proc_state,pb2proc_nextState : pb2proc_st;


   ------------------ NoC 2 PB Signals   ----------------------------------
	signal  noc2pb_next_vc_with_pkt,noc2pb_finished_pkt,noc2pb_eop_wr_sig,noc2pb_pkt_rdy	 : std_logic_vector(NOCEM_NUM_VC-1 downto 0);
	signal  noc2pb_recv_idle : std_logic;
	signal  noc2pb_din_pad : std_logic_vector(31 downto 0);
	signal  noc2pb_din_reg : std_logic_vector(31 downto 0);
   signal  noc2pb_byte_counter : std_logic_vector(7 downto 0);
	signal  noc2pb_we_delay, noc2pb_mwe_delay : std_logic;
	signal  noc2pb_we_b1,noc2pb_we_b2,noc2pb_we_b3,noc2pb_we_b4 : std_logic;
	signal  noc2pb_din_rotated : std_logic_vector(31 downto 0);


	type noc2pb_st is (init_st,recving_word1_st,recving_word2_st,recving_word3_st,recving_word4_st) ;
	signal noc2pb_state,noc2pb_nextState : noc2pb_st;





   ------------------ Processor 2 PB Signals   ----------------------------
	signal proc2pb_dest_addr_i : std_logic_vector(NOCEM_AW-1 downto 0);
	signal proc2pb_pkt_len_i : std_logic_vector(7 downto 0);
	signal proc2pb_byte_counter : std_logic_vector(7 downto 0);

	type proc2pb_st is (IDLE_ST, SENDING_ST) ;
	signal proc2pb_state,proc2pb_nextState : proc2pb_st;


	------------------ PKT BUFFER SIGNALS ----------------------------------
	constant METADATA_WIDTH  : integer := NOCEM_AW+8 ;
	constant METADATA_LENGTH : integer := 16 ;


	signal din_n2p,dout_n2p : std_logic_vector(31 downto 0);
	signal re_n2p,we_n2p,empty_n2p,full_n2p,mre_n2p,mwe_n2p : std_logic;
	signal mdin_n2p,mdout_n2p : std_logic_vector(METADATA_WIDTH-1 downto 0);


	signal din_p2n,dout_p2n : std_logic_vector(31 downto 0);
	signal re_p2n,we_p2n,empty_p2n,full_p2n,mre_p2n,mwe_p2n : std_logic;
	signal mdin_p2n,mdout_p2n : std_logic_vector(METADATA_WIDTH-1 downto 0);
   -------------------------------------------------------------------------




	------------------------ DEBUG SIGNALLING
	signal debug_p2n_addr1,debug_p2n_addr2 : std_logic_vector (0 to 11);
	signal debug_p2n_boolean_test1,debug_p2n_boolean_test2,debug_p2n_boolean_test3 : std_logic;
	signal tl_debug : std_logic_vector(4 downto 0);


begin

---------------------------------------------------------------------
--------------------- GLOBAL RENAMING, ETC --------------------------
---------------------------------------------------------------------

clk <= Bus2IP_Clk;
rst <= Bus2IP_Reset;
noc_arb_cntrl_out <= arb_sending_word or arb_receiving_word;

IP2Bus_Error       <= '0';
IP2Bus_Retry       <= '0';
IP2Bus_ToutSup     <= '0';





---------------------------------------------------------------------
------------ PROCESSSOR TO PKT BUFFER PROCESSES ---------------------
---------------------------------------------------------------------


----------------------------------------------------------------------------
--	Processor to noc packet flow

-- the Processor wants to write a packet to the NoC.  It must first write and address
-- into the noc_addr_reg and packet length and then begin writing the packet.  
-- This is accomplished by using the following register locations:
-- 	
--			C_BASE_ADDR + 0x000: NOC_ADDR_REG,NOC_PACKET_LENGTH
--			C_BASE_ADDR + 0x004: IP2NOC_PACKET_DATA
--					...
--					...
-- the PPC will write to successive locations (in burst mode) so once a write starts
-- this process will just accept the successive writes and hand it off to the NoC
----------------------------------------------------------------------------



proc2pb_clkd : process (clk,rst)

variable L : line;

begin
	if rst='1' then
		proc2pb_dest_addr_i 	<= (others => '0');
		proc2pb_pkt_len_i 		<= (others => '0');
		proc2pb_byte_counter  <= (others => '0');
		proc2pb_state			<= IDLE_ST;

	elsif clk='1' and clk'event then
		proc2pb_state <= proc2pb_nextState;
		case proc2pb_state is	
			when IDLE_ST =>


				-----------------------------------------------------------
				--		THIS IS FOR TASKLIST EXERCISER WORK  					--
				-----------------------------------------------------------
				--224	0E0	11100000	SIMULATION ONLY			an entire tasklist has begun being allocated
				--228	0E4	11100100	SIMULATION ONLY			an entire tasklist has finished -- all CE's are deallocated
				--232	0E8	11101000	SIMULATION ONLY			an allocation attempt has been successful
				--236	0EC	11101100	SIMULATION ONLY			an allocation attempt has NOT been successful
				--240	0F0	11110000	SIMULATION ONLY			a deallocation occurred

				if	Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) = X"0E0" and 
					Bus2IP_WrReq = '1' and 
					Bus2IP_CS /= 0 and 
					Bus2IP_CE /= 0	then

--							write(L, string'("OS checkpoint: ")); 
--							write(L,time'image(NOW));						
--							write(L, string'(" tasklist started: "));								
--							write(L, string'(" with OS Data: "));	
--							hwrite(L, Bus2IP_data);							
--							writeline(OUTPUT, L);				
						
--							tl_debug(4) <= '1';
--
--							IP2Bus_WrAck 		<= '1';
--							proc2pb_nextState <= IDLE_ST;	
				end if;			


				if	Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) = X"0E4" and 
					Bus2IP_WrReq = '1' and 
					Bus2IP_CS /= 0 and 
					Bus2IP_CE /= 0	then

--							write(L, string'("OS checkpoint: ")); 
--							write(L,time'image(NOW));						
--							write(L, string'(" tasklist ended: "));								
--							write(L, string'(" with OS Data: "));	
--							hwrite(L, Bus2IP_data);							
--							writeline(OUTPUT, L);				
		
--							tl_debug(3) <= '1';
--		
--							IP2Bus_WrAck 		<= '1';
--							proc2pb_nextState <= IDLE_ST;	
				end if;			

				if	Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) = X"0E8" and 
					Bus2IP_WrReq = '1' and 
					Bus2IP_CS /= 0 and 
					Bus2IP_CE /= 0	then

--							write(L, string'("OS checkpoint: ")); 
--							write(L,time'image(NOW));						
--							write(L, string'(" task allocated SUCCESS: "));								
--							write(L, string'(" with OS Data: "));	
--							hwrite(L, Bus2IP_data);							
--							writeline(OUTPUT, L);				

--							tl_debug(2) <= '1';
--
--							IP2Bus_WrAck 		<= '1';
--							proc2pb_nextState <= IDLE_ST;	
				end if;			

				
				if	Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) = X"0EC" and 
					Bus2IP_WrReq = '1' and 
					Bus2IP_CS /= 0 and 
					Bus2IP_CE /= 0	then

--							write(L, string'("OS checkpoint: ")); 
--							write(L,time'image(NOW));						
--							write(L, string'(" task alloacted FAILURE: "));								
--							write(L, string'(" with OS Data: "));	
--							hwrite(L, Bus2IP_data);							
--							writeline(OUTPUT, L);				

--							tl_debug(1) <= '1';
--
--							IP2Bus_WrAck 		<= '1';
--							proc2pb_nextState <= IDLE_ST;	
--							
				end if;	

				if	Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) = X"0F0" and 
					Bus2IP_WrReq = '1' and 
					Bus2IP_CS /= 0 and 
					Bus2IP_CE /= 0	then

--							write(L, string'("OS checkpoint: ")); 
--							write(L,time'image(NOW));						
--							write(L, string'(" CE Deallocated: "));								
--							write(L, string'(" with OS Data: "));	
--							hwrite(L, Bus2IP_data);							
----							writeline(OUTPUT, L);
--
--							write(L, string'(" ")); 
--							writeline(OUTPUT, L);							

--							tl_debug(0) <= '1';
--
--							IP2Bus_WrAck 		<= '1';
--							proc2pb_nextState <= IDLE_ST;	
--							
				end if;	
				
				
				if	Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) = X"0F4" and 
					Bus2IP_WrReq = '1' and 
					Bus2IP_CS /= 0 and 
					Bus2IP_CE /= 0	then

--							write(L, string'("OS checkpoint: ")); 
--							write(L,time'image(NOW));						
--							write(L, string'(" BAD SYSCALL PACKET: "));								
--							write(L, string'(" with OS Data: "));	
--							hwrite(L, Bus2IP_data);							
--							writeline(OUTPUT, L);				

--							--tl_debug(0) <= '1';
--
--							IP2Bus_WrAck 		<= '1';
--							proc2pb_nextState <= IDLE_ST;	
--							
				end if;					
				
				
				
				if	Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) = X"0D8" and 
					Bus2IP_WrReq = '1' and 
					Bus2IP_CS /= 0 and 
					Bus2IP_CE /= 0	then

--							write(L, string'("OS checkpoint: ")); 
--							write(L,time'image(NOW));						
--							write(L, string'(" STATISTICS COLLECTED: "));								
--							write(L, string'(" with runtime: "));	
--							hwrite(L, Bus2IP_data);							
--							writeline(OUTPUT, L);				

--							--tl_debug(0) <= '1';
--
--							IP2Bus_WrAck 		<= '1';
--							proc2pb_nextState <= IDLE_ST;	
--							
				end if;					
				
								
				if	Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) = X"0DC" and 
					Bus2IP_WrReq = '1' and 
					Bus2IP_CS /= 0 and 
					Bus2IP_CE /= 0	then

--							write(L, string'("OS checkpoint: ")); 
--							write(L,time'image(NOW));						
--							write(L, string'(" STATISTICS COLLECTED: "));								
--							write(L, string'(" with packets sent: "));	
--							hwrite(L, Bus2IP_data);							
--							writeline(OUTPUT, L);				

--							--tl_debug(0) <= '1';
--
--							IP2Bus_WrAck 		<= '1';
--							proc2pb_nextState <= IDLE_ST;	
--							
				end if;				
				
				
				-----------------------------------------------------------
				--		END TASKLIST EXERCISER WORK  					   		--
				-----------------------------------------------------------











				if Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) = X"000" and 
					Bus2IP_WrReq = '1' and 
					Bus2IP_CS /= 0 and 
					Bus2IP_CE /= 0	then
			
						proc2pb_dest_addr_i <= Bus2IP_Data(32-NOCEM_AW to 31);
						proc2pb_pkt_len_i <= Bus2IP_Data(16 to 23);
				else
						proc2pb_dest_addr_i   <= (others => '0');
						proc2pb_pkt_len_i     <= (others => '0');
						proc2pb_byte_counter  <= (others => '0');
				end if;	

			when SENDING_ST =>

				
				-- to send data, must have data coming from PLB and also ready on Noc side
				if full_p2n = '0' and
					Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) >= X"004" and
					Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) < X"080" and					 
					Bus2IP_WrReq = '1' and 
					Bus2IP_CS /= 0 and 
					Bus2IP_CE /= 0	then
						-- may have to decode BE signal coming in
						proc2pb_byte_counter <= proc2pb_byte_counter+4;
				else
					null;
				end if;
										
			when others =>
				null;			
		 end case;
	
	end if;
			 

end process;



proc2pb_uclkd : process (full_p2n,proc2pb_dest_addr_i,Bus2IP_Data, Bus2IP_BE,proc2pb_state, Bus2IP_Addr, Bus2IP_WrReq, Bus2IP_CS, Bus2IP_CE, proc2pb_byte_counter, proc2pb_pkt_len_i)


begin


	proc2pb_nextState 	<= IDLE_ST;
--	proc2pb_packet 		<= (others => '0');
	--proc2pb_packet_we	<= '0';
	
	IP2Bus_WrAck 		<= '0';

	din_p2n  <= (others => '0');
	mdin_p2n <= (others => '0');						
	we_p2n <= '0';
	mwe_p2n <= '0';

	tl_debug <= (others => '0');		

	case proc2pb_state	is	
			when IDLE_ST =>
			
			
				-----------------------------------------------------------
				--		THIS IS FOR TASKLIST EXERCISER WORK  					--
				-----------------------------------------------------------
				--224	0E0	11100000	SIMULATION ONLY			an entire tasklist has begun being allocated
				--228	0E4	11100100	SIMULATION ONLY			an entire tasklist has finished -- all CE's are deallocated
				--232	0E8	11101000	SIMULATION ONLY			an allocation attempt has been successful
				--236	0EC	11101100	SIMULATION ONLY			an allocation attempt has NOT been successful
				--240	0F0	11110000	SIMULATION ONLY			a deallocation occurred

				if	Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) = X"0E0" and 
					Bus2IP_WrReq = '1' and 
					Bus2IP_CS /= 0 and 
					Bus2IP_CE /= 0	then

--							write(L, string'("OS checkpoint: ")); 
--							write(L,time'image(NOW));						
--							write(L, string'(" tasklist started: "));								
--							write(L, string'(" with OS Data: "));	
--							hwrite(L, Bus2IP_data);							
--							writeline(OUTPUT, L);				
--						
							tl_debug(4) <= '1';

							IP2Bus_WrAck 		<= '1';
							proc2pb_nextState <= IDLE_ST;	
				end if;			


				if	Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) = X"0E4" and 
					Bus2IP_WrReq = '1' and 
					Bus2IP_CS /= 0 and 
					Bus2IP_CE /= 0	then

--							write(L, string'("OS checkpoint: ")); 
--							write(L,time'image(NOW));						
--							write(L, string'(" tasklist ended: "));								
--							write(L, string'(" with OS Data: "));	
--							hwrite(L, Bus2IP_data);							
--							writeline(OUTPUT, L);				
--		
							tl_debug(3) <= '1';
		
							IP2Bus_WrAck 		<= '1';
							proc2pb_nextState <= IDLE_ST;	
				end if;			

				if	Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) = X"0E8" and 
					Bus2IP_WrReq = '1' and 
					Bus2IP_CS /= 0 and 
					Bus2IP_CE /= 0	then

--							write(L, string'("OS checkpoint: ")); 
--							write(L,time'image(NOW));						
--							write(L, string'(" task allocated SUCCESS: "));								
--							write(L, string'(" with OS Data: "));	
--							hwrite(L, Bus2IP_data);							
--							writeline(OUTPUT, L);				
--
							tl_debug(2) <= '1';

							IP2Bus_WrAck 		<= '1';
							proc2pb_nextState <= IDLE_ST;	
				end if;			

				
				if	Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) = X"0EC" and 
					Bus2IP_WrReq = '1' and 
					Bus2IP_CS /= 0 and 
					Bus2IP_CE /= 0	then

--							write(L, string'("OS checkpoint: ")); 
--							write(L,time'image(NOW));						
--							write(L, string'(" task alloacted FAILURE: "));								
--							write(L, string'(" with OS Data: "));	
--							hwrite(L, Bus2IP_data);							
--							writeline(OUTPUT, L);				
--
							tl_debug(1) <= '1';

							IP2Bus_WrAck 		<= '1';
							proc2pb_nextState <= IDLE_ST;	
							
				end if;	

				if	Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) = X"0F0" and 
					Bus2IP_WrReq = '1' and 
					Bus2IP_CS /= 0 and 
					Bus2IP_CE /= 0	then

--							write(L, string'("OS checkpoint: ")); 
--							write(L,time'image(NOW));						
--							write(L, string'(" CE Deallocated: "));								
--							write(L, string'(" with OS Data: "));	
--							hhwrite(L, Bus2IP_data);							
--							writeline(OUTPUT, L);				
--
							tl_debug(0) <= '1';

							IP2Bus_WrAck 		<= '1';
							proc2pb_nextState <= IDLE_ST;	
							
				end if;	
				
				
				if	Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) = X"0F4" and 
					Bus2IP_WrReq = '1' and 
					Bus2IP_CS /= 0 and 
					Bus2IP_CE /= 0	then

--							write(L, string'("OS checkpoint: ")); 
--							write(L,time'image(NOW));						
--							write(L, string'(" BAD SYSCALL PACKET: "));								
--							write(L, string'(" with OS Data: "));	
--							hwrite(L, Bus2IP_data);							
--							writeline(OUTPUT, L);				

							--tl_debug(0) <= '1';

							IP2Bus_WrAck 		<= '1';
							proc2pb_nextState <= IDLE_ST;	
							
				end if;					
				
				
				-----------------------------------------------------------
				--		END TASKLIST EXERCISER WORK  					   		--
				-----------------------------------------------------------


			
			
				if Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) = X"000" and 
					Bus2IP_WrReq = '1' and 
					Bus2IP_CS /= 0 and 
					Bus2IP_CE /= 0	then

						IP2Bus_WrAck <= '1';				
						proc2pb_nextState <= SENDING_ST;

				else
					proc2pb_nextState <= IDLE_ST;				
				end if;
			
			when SENDING_ST =>

				if full_p2n = '0' and
					Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) >= X"004" and
					Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) < X"080" and										 
					Bus2IP_WrReq = '1' and 
					Bus2IP_CS /= 0 and 
					Bus2IP_CE /= 0	then

						din_p2n 	<= Bus2IP_data(0 to 31);
						we_p2n 		<= '1';	
						IP2Bus_WrAck <= '1';	
				end if;



				mdin_p2n(NOCEM_AW-1 downto 0) 			<= proc2pb_dest_addr_i;						
				mdin_p2n(NOCEM_AW+7 downto NOCEM_AW) 	<= proc2pb_pkt_len_i;
				-- when am done sending packet
				if proc2pb_byte_counter >= proc2pb_pkt_len_i then
					proc2pb_nextState <= IDLE_ST;
					mwe_p2n <= '1';
				else
					proc2pb_nextState <= SENDING_ST;
				end if;
			when others =>
				null;
	end case;

end process;








															
---------------------------------------------------------------------
------------  PKT BUFFER TO PROCESSOR PROCESSES     -----------------
---------------------------------------------------------------------


----------------------------------------------------------------------------
-- PKT BUFFER to Processor packet flow
--
-- the noc has pb2proc_interrupted the processor and now is being requested to send a packet
-- up to the Processor for handling.  This is accomplished by the processor reading from
-- the memory locations that are specifically used for this.
-- 		
--				C_BASE_ADDR + 0x080: NOC_ADDR_REG,NOC_PACKET_LENGTH
--				C_BASE_ADDR + 0x084: NOC2IP_PACKET_DATA
--					...
--					...
-- The PPC will read the addr and length values and then do reads of the packet.  The
-- packet will eventually be consumed directly or buffered elsewhere.  The Processor cannot
-- will not attempt to read the packet twice from this bridge as it is not supported ;)
--  
----------------------------------------------------------------------------


----------------------------------------------------------------------------
--  when a packet arrives, pb2proc_interrupt the processor and let the processor 
--  do normal plb reads to get the packet into a packetbuffer for processing
--
--  need to make sure the packet is read and copied somewhere, as this block
--  is not going to handle holding the packet and manage random access to contents
----------------------------------------------------------------------------




pb2proc_clkd : process (clk,rst)
begin

	if rst='1' then

		pb2proc_byte_counter  <= (others => '0');
		pb2proc_state			<= IDLE_ST;

	elsif clk='1' and clk'event then
		pb2proc_state <= pb2proc_nextState;
		case pb2proc_state is
			when IDLE_ST => 
				pb2proc_byte_counter  <= (others => '0');
			when SENDING_META_ST => 
				pb2proc_byte_counter  <= (others => '0');	
			when SENDING_ST =>

				-- increment this counter as 4B get read each time
				if Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) >= X"084" and
					Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) < X"100" and					 
					Bus2IP_RdReq = '1' and 
					Bus2IP_CS /= 0 and 
					Bus2IP_CE /= 0	then

						pb2proc_byte_counter <= pb2proc_byte_counter+4;
				end if;
			when others =>	 null;
		end case;		
	end if;


end process;








pb2proc_uclkd : process (mdout_n2p,pb2proc_interrupt, pb2proc_state, empty_n2p, Bus2IP_Addr, Bus2IP_RdReq, Bus2IP_CS, Bus2IP_CE, dout_n2p, pb2proc_byte_counter)
begin

	-- currently, straight translation from NoC inputs (addr,len)
   pb2proc_dest_addr_i 	<= mdout_n2p(NOCEM_AW-1 downto 0);
	pb2proc_pkt_len_i 	<= mdout_n2p(NOCEM_AW+7 downto NOCEM_AW); 


	-- aggregate the length and addr into one 64b word for the PLB to read
	pb2proc_len_addr_aggr 										<= (others => '0');
	pb2proc_len_addr_aggr(16 to 23)      					<= pb2proc_pkt_len_i;
	--pb2proc_len_addr_aggr(47 downto 40) 					<= pb2proc_pkt_len_i;
	--pb2proc_len_addr_aggr(NOCEM_AW+7 downto 8) 	<= pb2proc_dest_addr_i;


	-- zero out outgoing signals
	IP2Bus_RdAck 			<= '0';
	IP2Bus_Data 	 		<= (others => '0');
	IP2Bus_IntrEvent <= pb2proc_interrupt;

	re_n2p  <= '0';
	mre_n2p <= '0';
	pb2proc_interrupt <= (others => '0');


	case pb2proc_state	is	
		when IDLE_ST =>

			--------------------------------------
			------POLLING BASED DESIGN------------
			--------------------------------------
			pb2proc_nextState <= SENDING_META_ST;

			--------------------------------------
			------INTERRUPT BASED DESIGN----------
			--------------------------------------
--			if empty_n2p = '0' then
--	          pb2proc_interrupt <= (others => '1');
--				 pb2proc_nextState <= SENDING_META_ST;
--	      else
--				 pb2proc_nextState <= IDLE_ST;
--	          pb2proc_interrupt <= (others => '0');
--	      end if; 
--



		





		when SENDING_META_ST =>

			-- the processor has been pb2proc_interrupted and now is requesting len,addr register 
			if	Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) = X"080" and 
				Bus2IP_RdReq = '1' and 
				Bus2IP_CS /= 0 and 
				Bus2IP_CE /= 0	then


					--------------------------------------
					------INTERRUPT BASED DESIGN----------
					--------------------------------------
--					IP2Bus_RdAck 		<= '1';
--					IP2Bus_Data 		<=  pb2proc_len_addr_aggr;
--					pb2proc_nextState 	<= SENDING_ST;
--
					--------------------------------------
					------POLLING BASED DESIGN------------
					--------------------------------------
					if empty_n2p = '0' then	
						IP2Bus_RdAck 		<= '1';
						IP2Bus_Data 		<=  pb2proc_len_addr_aggr;
						pb2proc_nextState 	<= SENDING_ST;
					else
						IP2Bus_RdAck 		<= '1';
						IP2Bus_Data 		<= (others => '0');
						pb2proc_nextState 	<= SENDING_META_ST;
					end if;
			else
				pb2proc_nextState <= SENDING_META_ST;		
			 end if;


			-----------------------------------------------------------
			--		THIS IS SOME DEBUG CODE TO CHECK NOCEM					--
			-----------------------------------------------------------
			if	Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) = X"088" and 
				Bus2IP_RdReq = '1' and 
				Bus2IP_CS /= 0 and 
				Bus2IP_CE /= 0	then
	
						IP2Bus_RdAck 		<= '1';
						IP2Bus_Data 		<= X"DEADBEEF";
						pb2proc_nextState 	<= SENDING_META_ST;

			end if;



			-----------------------------------------------------------
			--		THIS IS SOME DEBUG CODE TO CHECK NOCEM					--
			-----------------------------------------------------------
			if	Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) = X"088" and 
				Bus2IP_RdReq = '1' and 
				Bus2IP_CS /= 0 and 
				Bus2IP_CE /= 0	then
	
						IP2Bus_RdAck 		<= '1';
						IP2Bus_Data 		<= X"DEADBEEF";
						pb2proc_nextState 	<= SENDING_META_ST;

			end if;
			
			
			
			
			
			
			



		when SENDING_ST =>

			-- the processor should be now requesting the packet 
			if Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) >= X"084" and
				Bus2IP_Addr(C_AWIDTH-12 to C_AWIDTH-1) < X"100" and					 
				Bus2IP_RdReq = '1' and 
				Bus2IP_CS /= 0 and 
				Bus2IP_CE /= 0	then
					IP2Bus_RdAck 	<= '1';
					IP2Bus_Data(0 to 31) 	<=  dout_n2p;	
					re_n2p <= '1';
							
			end if;
			
			-- data is read in 4B words, so possible to go over packet length
			-- will be handled in software
			if pb2proc_byte_counter >= pb2proc_pkt_len_i then
				pb2proc_nextState <= IDLE_ST;
				--re_n2p <= '1';
				mre_n2p <= '1';			
			else			
				pb2proc_nextState <= SENDING_ST;
			end if;
					
		
		when others =>
			null;
	end case;
	
end process;





---------------------------------------------------------------------
------------ NOCEM TO PKT BUFFER PROCESSES      ---------------------
---------------------------------------------------------------------


--	type noc2pb_st is (init_st,recving_word1_st,recving_word2_st,recving_word3_st,recving_word4_st) ;
--	signal noc2pb_state,noc2pb_nextState : noc2pb_st;


noc2pb_clkd : process (clk,rst)
begin


	if rst='1' then
		noc2pb_pkt_rdy <= (others => '0');
		noc2pb_next_vc_with_pkt <= (others => '0');
		noc2pb_recv_idle <= '1';
		noc2pb_state <= init_st;
		noc2pb_byte_counter <=  (others => '0');
		noc2pb_mwe_delay <= '0';
		noc2pb_we_delay  <= '0';
		noc2pb_din_reg <= (others => '0');
	elsif clk'event and clk='1' then

		-- doing some width conversion we's here.
		if noc2pb_we_b1='1' then
			noc2pb_din_reg(7 downto 0) <= noc2pb_din_rotated(7 downto 0);
		end if;
		if noc2pb_we_b2='1' then
			noc2pb_din_reg(15 downto 8) <= noc2pb_din_rotated(15 downto 8);

		end if;
		if noc2pb_we_b3='1' then
			noc2pb_din_reg(23 downto 16) <= noc2pb_din_rotated(23 downto 16);

		end if;
		if noc2pb_we_b4='1' then
			noc2pb_din_reg(31 downto 24) <= noc2pb_din_rotated(31 downto 24);
			noc2pb_we_delay <= '1';
		end if;

		-- need to force a we to the pkt buffer when the EOP is seen from NoC
		if (noc2pb_we_b1='1' or noc2pb_we_b2='1' or noc2pb_we_b3='1' or noc2pb_we_b4='1') and noc_pkt_cntrl_in(NOCEM_PKTCNTRL_EOP_IX) = '1' then

			noc2pb_mwe_delay <= '1';
			noc2pb_we_delay  <= '1';
		elsif noc2pb_we_b4='1' then
			noc2pb_we_delay  <= '1';
			noc2pb_mwe_delay <= '0';
		else
			noc2pb_mwe_delay <= '0';
			noc2pb_we_delay  <= '0';				

		end if;





		noc2pb_state <= noc2pb_nextState;
		case noc2pb_state is 
			when init_st =>
				noc2pb_byte_counter <= (others => '0');
				noc2pb_din_reg <= (others => '0');
			when recving_word1_st =>
				noc2pb_byte_counter <= noc2pb_byte_counter + NOCEM_DW/8;	
			when recving_word2_st =>
				noc2pb_byte_counter <= noc2pb_byte_counter + NOCEM_DW/8;	
			when recving_word3_st =>
				noc2pb_byte_counter <= noc2pb_byte_counter + NOCEM_DW/8;	
			when recving_word4_st =>
				noc2pb_byte_counter <= noc2pb_byte_counter + NOCEM_DW/8;	
			when others => null;
		end case;



		-------------------------------------------------------------------------------------
		---------------------------- FINDING NEXT VC WITH A PACKET --------------------------
		-------------------------------------------------------------------------------------
		l1: for I in NOCEM_NUM_VC-1 downto 0 loop

			-- is the pkt rdy for reading?
			if noc2pb_eop_wr_sig(I) = '1' then
				noc2pb_pkt_rdy(I) <= '1';
			elsif noc2pb_finished_pkt(I) = '1' then
				noc2pb_pkt_rdy(I) <= '0';			
			end if;	

			-- what is the next pkt to read from VCs?
			if noc2pb_pkt_rdy(I) = '1' and noc2pb_recv_idle = '1' then
				noc2pb_next_vc_with_pkt <= CONV_STD_LOGIC_VECTOR(2**I,NOCEM_NUM_VC);
				noc2pb_recv_idle <= '0';
			elsif noc2pb_finished_pkt /= 0 then
				noc2pb_recv_idle <= '1';	
			end if;
	  
		end loop;

		-- if no packets OR just finished a packet's handling, show that no packet is ready
		if noc2pb_pkt_rdy = 0 or noc2pb_finished_pkt /= 0 then
			noc2pb_next_vc_with_pkt <= (others => '0');
		end if;
		-------------------------------------------------------------------------------------
		
	end if;


end process;

noc2pb_uclkd : process (noc2pb_din_pad,noc2pb_next_vc_with_pkt,noc_arb_cntrl_in, noc_pkt_cntrl_in,noc2pb_mwe_delay, noc2pb_we_delay, noc2pb_din_reg, noc2pb_byte_counter, noc_datain, noc2pb_state, full_n2p)
begin



	mwe_n2p <= noc2pb_mwe_delay;
	we_n2p <= noc2pb_we_delay;

	-- a quick network to processor byte endian change
	din_n2p(7 downto 0)   <= noc2pb_din_reg(31 downto 24);
	din_n2p(15 downto 8)  <= noc2pb_din_reg(23 downto 16);
	din_n2p(23 downto 16) <= noc2pb_din_reg(15 downto 8);
	din_n2p(31 downto 24) <= noc2pb_din_reg(7 downto 0);

	mdin_n2p <= noc2pb_byte_counter & CONV_STD_LOGIC_VECTOR(0,NOCEM_AW);

	noc_datain_recvd <= '0';
	noc_pkt_cntrl_in_recvd <= '0';
	noc2pb_finished_pkt <= (others => '0');
	arb_receiving_word <= (others => '0');
	noc2pb_eop_wr_sig <= noc_arb_cntrl_in(NOCEM_ARB_CNTRL_VC_EOP_WR_HIX downto NOCEM_ARB_CNTRL_VC_EOP_WR_LIX);

	-- setting up the padded register for width conversion
	noc2pb_din_pad <= (others => '0');
	noc2pb_din_pad(NOCEM_DW-1 downto 0) <= noc_datain;
	noc2pb_din_rotated <= (others => '0');

	noc2pb_we_b1 <= '0';
	noc2pb_we_b2 <= '0';
	noc2pb_we_b3 <= '0';
	noc2pb_we_b4 <= '0';




		case noc2pb_state is 
			when init_st =>
				if noc2pb_next_vc_with_pkt /= 0 and full_n2p = '0' then
					noc2pb_nextState <= recving_word1_st;
				else
					noc2pb_nextState <= init_st;
				end if;

			when recving_word1_st =>
				


				arb_receiving_word(NOCEM_ARB_CNTRL_VC_MUX_RD_HIX downto NOCEM_ARB_CNTRL_VC_MUX_RD_LIX) <= noc2pb_next_vc_with_pkt;
				noc_datain_recvd <= '1';	
				noc_pkt_cntrl_in_recvd <= '1';	
				if noc_pkt_cntrl_in(NOCEM_PKTCNTRL_EOP_IX)	= '1' then
					noc2pb_finished_pkt <= noc2pb_next_vc_with_pkt;
				end if;
				


				-- setup the width conversion correctly....
				noc2pb_din_rotated(NOCEM_DW-1 downto 0) <= noc2pb_din_pad(NOCEM_DW-1 downto 0);				
				if NOCEM_DW = 32 then
					noc2pb_we_b1 <= '1';
					noc2pb_we_b2 <= '1';
					noc2pb_we_b3 <= '1';
					noc2pb_we_b4 <= '1';

					if noc_pkt_cntrl_in(NOCEM_PKTCNTRL_EOP_IX) = '1' then
						noc2pb_nextState <= init_st;
					else		
						noc2pb_nextState <= recving_word1_st;
					end if;
				elsif NOCEM_DW = 16 then
					noc2pb_we_b1 <= '1';
					noc2pb_we_b2 <= '1';

 					if noc_pkt_cntrl_in(NOCEM_PKTCNTRL_EOP_IX) = '1' then
						noc2pb_nextState <= init_st;
					else		
						noc2pb_nextState <= recving_word2_st;
					end if;

				elsif NOCEM_DW = 8 then
					noc2pb_we_b1 <= '1';
					
 					if noc_pkt_cntrl_in(NOCEM_PKTCNTRL_EOP_IX) = '1' then
						noc2pb_nextState <= init_st;
					else		
						noc2pb_nextState <= recving_word2_st;
					end if;					
					
					 	
				end if;				


			when recving_word2_st =>

				arb_receiving_word(NOCEM_ARB_CNTRL_VC_MUX_RD_HIX downto NOCEM_ARB_CNTRL_VC_MUX_RD_LIX) <= noc2pb_next_vc_with_pkt;
				noc_datain_recvd <= '1';	
				noc_pkt_cntrl_in_recvd <= '1';	
				if noc_pkt_cntrl_in(NOCEM_PKTCNTRL_EOP_IX)	= '1' then
					noc2pb_finished_pkt <= noc2pb_next_vc_with_pkt;
				end if;





				-- setup the width conversion correctly....
				if NOCEM_DW = 16 then
					noc2pb_din_rotated(31 downto 16) <= noc2pb_din_pad(15 downto 0);
					noc2pb_we_b3 <= '1';
					noc2pb_we_b4 <= '1';

 					if noc_pkt_cntrl_in(NOCEM_PKTCNTRL_EOP_IX) = '1' then
						noc2pb_nextState <= init_st;
					else		
						noc2pb_nextState <= recving_word1_st;
					end if;

				elsif NOCEM_DW = 8 then
					noc2pb_din_rotated(15 downto 8) <= noc2pb_din_pad(7 downto 0);
					noc2pb_we_b2 <= '1'; 	

 					if noc_pkt_cntrl_in(NOCEM_PKTCNTRL_EOP_IX) = '1' then
						noc2pb_nextState <= init_st;
					else		
						noc2pb_nextState <= recving_word3_st;
					end if;

				end if;



			when recving_word3_st =>


					arb_receiving_word(NOCEM_ARB_CNTRL_VC_MUX_RD_HIX downto NOCEM_ARB_CNTRL_VC_MUX_RD_LIX) <= noc2pb_next_vc_with_pkt;
					noc_datain_recvd <= '1';	
					noc_pkt_cntrl_in_recvd <= '1';	
					if noc_pkt_cntrl_in(NOCEM_PKTCNTRL_EOP_IX)	= '1' then
						noc2pb_finished_pkt <= noc2pb_next_vc_with_pkt;
					end if;

					-- setup the width conversion correctly....
					noc2pb_din_rotated(23 downto 16) <= noc2pb_din_pad(7 downto 0); 	
					noc2pb_we_b3 <= '1';

 					if noc_pkt_cntrl_in(NOCEM_PKTCNTRL_EOP_IX) = '1' then
						noc2pb_nextState <= init_st;
					else		
						noc2pb_nextState <= recving_word4_st;
					end if;

			when recving_word4_st =>

					arb_receiving_word(NOCEM_ARB_CNTRL_VC_MUX_RD_HIX downto NOCEM_ARB_CNTRL_VC_MUX_RD_LIX) <= noc2pb_next_vc_with_pkt;
					noc_datain_recvd <= '1';	
					noc_pkt_cntrl_in_recvd <= '1';	
					if noc_pkt_cntrl_in(NOCEM_PKTCNTRL_EOP_IX)	= '1' then
						noc2pb_finished_pkt <= noc2pb_next_vc_with_pkt;
					end if;

					-- setup the width conversion correctly....
					noc2pb_din_rotated(31 downto 24) <= noc2pb_din_pad(7 downto 0);
					noc2pb_we_b4 <= '1';

 					if noc_pkt_cntrl_in(NOCEM_PKTCNTRL_EOP_IX) = '1' then
						noc2pb_nextState <= init_st;
					else		
						noc2pb_nextState <= recving_word1_st;
					end if;

			when others => null;
		end case;




		
			



end process;


---------------------------------------------------------------------
------------  PKT BUFFER TO NOCEM PROCESSES     ---------------------
---------------------------------------------------------------------


g_dw32: if NOCEM_DW = 32 generate

	pb2noc_word1 <= dout_p2n;
	pb2noc_word2 <= (others => '0');
	pb2noc_word3 <= (others => '0');
	pb2noc_word4 <= (others => '0');

end generate;

g_dw16: if NOCEM_DW = 16 generate

	pb2noc_word1(31 downto 16) <= (others => '0');
	pb2noc_word2(31 downto 16) <= (others => '0');
	pb2noc_word1(15 downto 0) <= dout_p2n(31 downto 16);
	pb2noc_word2(15 downto 0) <= dout_p2n(15 downto 0);
	pb2noc_word3(15 downto 0) <= (others => '0');
	pb2noc_word4(15 downto 0) <= (others => '0');

end generate;

g_dw8: if NOCEM_DW = 8 generate

	pb2noc_word1(31 downto 8) <= (others => '0');
	pb2noc_word2(31 downto 8) <= (others => '0');
	pb2noc_word3(31 downto 8) <= (others => '0');
	pb2noc_word4(31 downto 8) <= (others => '0');

	pb2noc_word1(7 downto 0) <= dout_p2n(31 downto 24);
	pb2noc_word2(7 downto 0) <= dout_p2n(23 downto 16);
	pb2noc_word3(7 downto 0) <= dout_p2n(15 downto 8);
	pb2noc_word4(7 downto 0) <= dout_p2n(7 downto 0);

end generate;




gen_outgoing_vc_status_clkd : process (clk,rst)
begin


	if rst='1' then	
		outgoing_vc_state <= (others => '0');
		outgoing_free_this_vc <= (others => '0');	
		outgoing_next_free_vc <= (others => '0');
	elsif clk'event and clk='1' then


		l2: for I in NOCEM_NUM_VC-1 downto 0 loop
			if outgoing_vc_state(I) = '0' then
				outgoing_next_free_vc <= CONV_STD_LOGIC_VECTOR(2**I,NOCEM_NUM_VC);
			end if;											  	
		end loop;

		if outgoing_vc_state = allones_vcwidth then
			outgoing_next_free_vc <= (others => '0');
		end if;


	    outgoing_free_this_vc <= noc_arb_cntrl_in(NOCEM_ARB_CNTRL_VC_EOP_RD_HIX downto NOCEM_ARB_CNTRL_VC_EOP_RD_LIX);

		 -- 0: free, 1: allocated --
		 l1: for I in NOCEM_NUM_VC-1 downto 0 loop
		 	if outgoing_vc_state(I) = '0' and outgoing_next_free_vc(I) = '1' and pb2noc_vc_alloc = '1' then -- free going to allocated
				outgoing_vc_state(I) <= '1';
			elsif outgoing_vc_state(I) = '1' and outgoing_free_this_vc(I) = '1' then -- allocated going to free
				outgoing_vc_state(I) <= '0';
			end if;		 
		 end loop;

	end if;
end process;



-- see a packet is ready in pkt_buffer
-- then attempt to get a VC
-- then send the packet correctly
--      breaking up the 4B buffer word into appropriate chunks
pb2noc_clkd : process (clk,rst)
begin
	if rst = '1' then
		 pb2noc_state <= init_st;
		 pb2noc_byte_counter <= CONV_STD_LOGIC_VECTOR(NOCEM_DW/8,8);
		 vc_mux_wr_reg <= (others => '0');
	elsif clk'event and clk='1' then
		pb2noc_state <= pb2noc_nextState;
   	case pb2noc_state is
      	when init_st =>
			   pb2noc_byte_counter <= CONV_STD_LOGIC_VECTOR(NOCEM_DW/8,8);
			when getting_vc_st =>
				vc_mux_wr_reg <= outgoing_next_free_vc;
			when sending_word1_st =>
				pb2noc_byte_counter <= pb2noc_byte_counter + NOCEM_DW/8;					
			when sending_word2_st =>
				pb2noc_byte_counter <= pb2noc_byte_counter + NOCEM_DW/8;	
			when sending_word3_st =>
				pb2noc_byte_counter <= pb2noc_byte_counter + NOCEM_DW/8;	
			when sending_word4_st =>
				pb2noc_byte_counter <= pb2noc_byte_counter + NOCEM_DW/8;	
			when others => null;
		end case;
	end if;

end process;

pb2noc_uclkd : process (empty_p2n,pb2noc_state,mdout_p2n, outgoing_next_free_vc, pb2noc_word1, vc_mux_wr_reg, pb2noc_byte_counter, pb2noc_word2, pb2noc_word3, pb2noc_word4)
begin

		pb2noc_amI_os <= '1';

		noc_pkt_cntrl_out <= (others => '0');
		noc_pkt_cntrl_out(NOCEM_PKTCNTRL_OS_PKT_IX) <= pb2noc_amI_os;


		noc_dataout_valid			<= '0';
		noc_dataout		 <= (others => '0');
		noc_pkt_cntrl_out_valid	 <= '0';
		noc_arb_req	   <= '0';

		allones_vcwidth <= (others => '1');
		arb_sending_word <= (others => '0');
		pb2noc_pkt_dest_addr <= mdout_p2n(NOCEM_AW-1 downto 0);
		pb2noc_pkt_len			<= mdout_p2n(NOCEM_AW+7 downto NOCEM_AW);
	   pb2noc_vc_alloc <= '0';
		re_p2n <= '0';
		mre_p2n <= '0';

   	case pb2noc_state is
      	when init_st =>
				if empty_p2n='0' then
					pb2noc_nextstate <= getting_vc_st;
				else
					pb2noc_nextstate <= init_st;	
				end if;


			when getting_vc_st =>
				if outgoing_next_free_vc /= 0 then
					pb2noc_vc_alloc <= '1';
					pb2noc_nextState <= sending_word1_st;
				else
					pb2noc_nextState <= getting_vc_st;
				end if;

			when sending_word1_st =>
				noc_dataout <= pb2noc_word1(NOCEM_DW-1 downto 0);
				noc_dataout_valid <= '1';

				noc_pkt_cntrl_out(NOCEM_PKTCNTRL_DEST_ADDR_HIX downto NOCEM_PKTCNTRL_DEST_ADDR_LIX) <= pb2noc_pkt_dest_addr;
				noc_pkt_cntrl_out_valid <= '1';

				noc_arb_req <= '1';
				arb_sending_word(NOCEM_ARB_CNTRL_VC_MUX_WR_HIX downto NOCEM_ARB_CNTRL_VC_MUX_WR_LIX) <= vc_mux_wr_reg;				

				-- do correct SOP/EOP signalling				
			   if pb2noc_byte_counter = CONV_STD_LOGIC_VECTOR(NOCEM_DW/8,8) then
					noc_pkt_cntrl_out(NOCEM_PKTCNTRL_SOP_IX)	<= '1';	
				end if;
				if pb2noc_byte_counter >= pb2noc_pkt_len then
					noc_pkt_cntrl_out(NOCEM_PKTCNTRL_EOP_IX)	<= '1';
				end if;


				-- state change logic (depends on noc datawidth)
				if pb2noc_byte_counter = pb2noc_pkt_len then 
					re_p2n <= '1';
					mre_p2n <= '1';
					pb2noc_nextState <= init_st;
				elsif NOCEM_DW = 32 then
					pb2noc_nextState <= sending_word1_st;
					re_p2n <= '1';
				else	
					pb2noc_nextState <= sending_word2_st;
				end if;


									
			when sending_word2_st =>
				noc_dataout <= pb2noc_word2(NOCEM_DW-1 downto 0);
				noc_dataout_valid <= '1';


				noc_pkt_cntrl_out(NOCEM_PKTCNTRL_DEST_ADDR_HIX downto NOCEM_PKTCNTRL_DEST_ADDR_LIX) <= pb2noc_pkt_dest_addr;
				noc_pkt_cntrl_out_valid <= '1';

				noc_arb_req <= '1';
				arb_sending_word(NOCEM_ARB_CNTRL_VC_MUX_WR_HIX downto NOCEM_ARB_CNTRL_VC_MUX_WR_LIX) <= vc_mux_wr_reg;				

				-- do correct SOP/EOP signalling				
--			   if pb2noc_byte_counter = 0 then
--					noc_pkt_cntrl_out(NOCEM_PKTCNTRL_SOP_IX)	<= '1';	
--				end if;
				if pb2noc_byte_counter >= pb2noc_pkt_len then
					noc_pkt_cntrl_out(NOCEM_PKTCNTRL_EOP_IX)	<= '1';
				end if;


				-- state change logic (depends on noc datawidth)
				if pb2noc_byte_counter = pb2noc_pkt_len then 
					re_p2n <= '1';
					mre_p2n <= '1';
					pb2noc_nextState <= init_st;
				elsif NOCEM_DW = 16 then
					pb2noc_nextState <= sending_word1_st;
					re_p2n <= '1';
				else	
					pb2noc_nextState <= sending_word3_st;
				end if;





			when sending_word3_st =>
				noc_dataout <= pb2noc_word3(NOCEM_DW-1 downto 0);
				noc_dataout_valid <= '1';

				noc_pkt_cntrl_out(NOCEM_PKTCNTRL_DEST_ADDR_HIX downto NOCEM_PKTCNTRL_DEST_ADDR_LIX) <= pb2noc_pkt_dest_addr;
				noc_pkt_cntrl_out_valid <= '1';

				noc_arb_req <= '1';
				arb_sending_word(NOCEM_ARB_CNTRL_VC_MUX_WR_HIX downto NOCEM_ARB_CNTRL_VC_MUX_WR_LIX) <= vc_mux_wr_reg;				

				-- do correct SOP/EOP signalling				
--			   if pb2noc_byte_counter = 0 then
--					noc_pkt_cntrl_out(NOCEM_PKTCNTRL_SOP_IX)	<= '1';	
--				end if;
				if pb2noc_byte_counter >= pb2noc_pkt_len then
					noc_pkt_cntrl_out(NOCEM_PKTCNTRL_EOP_IX)	<= '1';
				end if;


				-- state change logic (depends on noc datawidth)
				if pb2noc_byte_counter = pb2noc_pkt_len then 
					re_p2n <= '1';
					mre_p2n <= '1';
					pb2noc_nextState <= init_st;
				else										 
					pb2noc_nextState <= sending_word4_st;
				end if;


			when sending_word4_st =>
				noc_dataout <= pb2noc_word4(NOCEM_DW-1 downto 0);
				noc_dataout_valid <= '1';


				noc_pkt_cntrl_out(NOCEM_PKTCNTRL_DEST_ADDR_HIX downto NOCEM_PKTCNTRL_DEST_ADDR_LIX) <= pb2noc_pkt_dest_addr;
				noc_pkt_cntrl_out_valid <= '1';

				noc_arb_req <= '1';
				arb_sending_word(NOCEM_ARB_CNTRL_VC_MUX_WR_HIX downto NOCEM_ARB_CNTRL_VC_MUX_WR_LIX) <= vc_mux_wr_reg;				

				-- do correct SOP/EOP signalling				
--			   if pb2noc_byte_counter = 0 then
--					noc_pkt_cntrl_out(NOCEM_PKTCNTRL_SOP_IX)	<= '1';	
--				end if;
				if pb2noc_byte_counter >= pb2noc_pkt_len then
					noc_pkt_cntrl_out(NOCEM_PKTCNTRL_EOP_IX)	<= '1';
				end if;


				-- state change logic (depends on noc datawidth)
				if pb2noc_byte_counter = pb2noc_pkt_len then 
					re_p2n <= '1';
					mre_p2n <= '1';
					pb2noc_nextState <= init_st;
				else
					re_p2n <= '1';	
					pb2noc_nextState <= sending_word1_st;
				end if;


			when others => null;
		end case;

end process;

 




--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------





--------------------------------------------------------------------------------
------------          THE PACKET BUFFER INSTANTIATIONS           ---------------
--------------------------------------------------------------------------------


---------------------------------------------------------
--metadata(NOCEM_AW-1 downto 0)        : dest_addr		---				
--metadata(NOCEM_AW+7 downto NOCEM_AW) : pkt_len		---
---------------------------------------------------------


	pb_noc2proc : packetbuffer2 
   
   generic map
   (
	 METADATA_WIDTH => METADATA_WIDTH,
	 METADATA_LENGTH => METADATA_LENGTH
   )
   PORT MAP(
		din => din_n2p,
		rd_en => re_n2p,
		wr_en => we_n2p,
		dout => dout_n2p,
		empty => empty_n2p,
		full => full_n2p,
		pkt_metadata_din => mdin_n2p,
		pkt_metadata_re => mre_n2p,
		pkt_metadata_we => mwe_n2p,
		pkt_metadata_dout => mdout_n2p,
		clk => clk,
		rst => rst
	);


   pb_proc2noc: packetbuffer2 
   generic map
   (
	 METADATA_WIDTH => METADATA_WIDTH,
	 METADATA_LENGTH =>  METADATA_LENGTH
   )   
   PORT MAP(
		din => din_p2n,
		rd_en => re_p2n,
		wr_en => we_p2n,
		dout => dout_p2n,
		empty => empty_p2n,
		full => full_p2n,
		pkt_metadata_din => mdin_p2n,
		pkt_metadata_re => mre_p2n,
		pkt_metadata_we => mwe_p2n,
		pkt_metadata_dout => mdout_p2n,
		clk => clk,
		rst => rst
	);






end Behavioral;
