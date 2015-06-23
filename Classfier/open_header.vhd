--------------------------------------------------------

	LIBRARY IEEE;
	USE IEEE.STD_LOGIC_1164.ALL;
	use ieee.numeric_std.all;
	use IEEE.STD_LOGIC_ARITH.ALL;
	use IEEE.STD_LOGIC_UNSIGNED.ALL;
	USE WORK.CONFIG.ALL;
-------------------------------
	ENTITY open_header IS
	GENERIC(DATA_WIDTH :INTEGER := 64;
			CTRL_WIDTH :INTEGER := 8);
	PORT(
	SIGNAL 		in_data 			:	IN   	STD_LOGIC_VECTOR(63 DOWNTO 0)	;
	SIGNAL 		in_ctrl 			: 	IN   	STD_LOGIC_VECTOR(7 DOWNTO 0)	;
    SIGNAL 		in_wr 				:	IN 		STD_LOGIC	;
	
	SIGNAL 		pkt_type			:	OUT   	STD_LOGIC_VECTOR(7 DOWNTO 0)	;
	SIGNAL 		pkt_type_rdy		:	OUT   	STD_LOGIC 	;
	SIGNAL 		pkt_type_rdy_ack		:	IN   	STD_LOGIC 	;
    --- Misc
    
    SIGNAL 		reset 				:	IN 		STD_LOGIC	;
    SIGNAL 		clk   				:	IN 		STD_LOGIC
	);
	END ENTITY;
	
 ------------------------------------------------------
	ARCHITECTURE behavior OF open_header IS 
------------ one hot encoding state definition
	TYPE state_type is (READ_HEADER, READ_WORD_1, READ_WORD_2, READ_WORD_3,READ_WORD_4,
						READ_WORD_5,READ_WORD_6,READ_WORD_7);
	ATTRIBUTE enum_encoding: STRING;
	ATTRIBUTE enum_encoding of state_type : type is "onehot";

	SIGNAL state, state_NEXT : state_type; 
---------------internal signals
   --- ethr  header
    ---SOURCE PORT
	SIGNAL 		source_port			: 	STD_LOGIC_VECTOR(1 DOWNTO 0);--just four ports
-----------signal to check if it ARP request
	
	SIGNAL 		arp_ok			 	: 	STD_LOGIC;
	SIGNAL 		arp_dest_mac_ok 	: 	STD_LOGIC; --DEST MAC = FF:FF:FF:FF:FF:FF
	SIGNAL 		arp_port_ok 		: 	STD_LOGIC; -- ARP PORT = X0806
	SIGNAL 		arp_HTYPE_ok 		: 	STD_LOGIC; --htype = 1 ETHERNET 
	SIGNAL 		arp_PTYPE_ok  		:	STD_LOGIC;--PTYPE = 4  IPv4
	SIGNAL 		arp_HLEN_ok 		: 	STD_LOGIC; -- HLEN =6 OCTETS MAC ADDRESS
	SIGNAL 		arp_PLEN_ok 		: 	STD_LOGIC;--PLEN = 4 OCTETS IP ADDRESS
	SIGNAL 		arp_operation_ok 	: 	STD_LOGIC; -- ARP REQUEST  = 1
	SIGNAL 		arp_ip1_int_ok		: 	STD_LOGIC;  
	SIGNAL 		arp_ip2_int_ok		: 	STD_LOGIC;
	SIGNAL 		arp_ip1_ext_ok		: 	STD_LOGIC;  
	SIGNAL 		arp_ip2_ext_ok		: 	STD_LOGIC;
	SIGNAL 		arp_dest_mac_ok_p 	: 	STD_LOGIC; 
	SIGNAL 		arp_port_ok_p 		: 	STD_LOGIC; 
	SIGNAL 		arp_HTYPE_ok_p 		: 	STD_LOGIC;  
	SIGNAL 		arp_PTYPE_ok_p  	:	STD_LOGIC;
	SIGNAL 		arp_HLEN_ok_p 		: 	STD_LOGIC; 
	SIGNAL 		arp_PLEN_ok_p 		: 	STD_LOGIC;
	SIGNAL 		arp_operation_ok_p	: 	STD_LOGIC;
	SIGNAL 		arp_ip1_int_ok_p		: 	STD_LOGIC;  
	SIGNAL 		arp_ip2_int_ok_p		: 	STD_LOGIC;
	SIGNAL 		arp_ip1_ext_ok_p		: 	STD_LOGIC;  
	SIGNAL 		arp_ip2_ext_ok_p		: 	STD_LOGIC;
-----------signal to check Balance Traffic Module ---------------
	SIGNAL 		my_mac 				: 	STD_LOGIC_VECTOR(47 DOWNTO 0); ------This is A Register to Store my MAC Address
	SIGNAL 		my_mac_ok 			: 	STD_LOGIC;
	SIGNAL 		my_mac_ok_p 		: 	STD_LOGIC;---pipe line version of my_mac_ok.
	SIGNAL 		balance_ok   		: 	STD_LOGIC;
-------------------------------------------
-----------signal to check Router Traffic Module ---------------
	SIGNAL		ip_packet_ok 		:	STD_LOGIC	;	
	SIGNAL		udp_ok 				:	STD_LOGIC	;		
	SIGNAL		tcp_ok 				:	STD_LOGIC	;	
	SIGNAL		ospf_proto_ok 		:	STD_LOGIC	;	
	SIGNAL		rip_port_ok 		:	STD_LOGIC	;	
	SIGNAL		bgp_port_ok  		:	STD_LOGIC	;
	SIGNAL		ip_packet_ok_p 		:	STD_LOGIC	;	
	SIGNAL		udp_ok_p 			:	STD_LOGIC	;		
	SIGNAL		tcp_ok_p 			:	STD_LOGIC	;	
	SIGNAL		ospf_proto_ok_p 	:	STD_LOGIC	;	
	SIGNAL		rip_port_ok_p 		:	STD_LOGIC	;	
	SIGNAL		bgp_port_ok_p  		:	STD_LOGIC	;	
	SIGNAL		router_ok	  		:	STD_LOGIC	;
-------------------------------------------
    SIGNAL 		classifier_start 	: 	STD_LOGIC;
	SIGNAL 		classifier_done 	: 	STD_LOGIC;
	SIGNAL 		classifier_done_p 	: 	STD_LOGIC;
-------------------------------------------------------	
	SIGNAL 		manage_ok 			: 	STD_LOGIC;
	SIGNAL		manage_ip_packet_ok : 	STD_LOGIC;
	SIGNAL		manage_udp_ok		: 	STD_LOGIC;
	SIGNAL		manage_ip_addmulti_p1_ok : 	STD_LOGIC;
	SIGNAL		manage_ip_addmulti_p2_ok : 	STD_LOGIC;
	SIGNAL		manage_ip_adduni_p1_ok : 	STD_LOGIC;
	SIGNAL		manage_ip_adduni_p2_ok : 	STD_LOGIC;
	SIGNAL		manage_port_ok 		: 	STD_LOGIC;
	SIGNAL		manage_hello_ok 	: 	STD_LOGIC;
	SIGNAL		manage_ip_packet_ok_p : 	STD_LOGIC;
	SIGNAL		manage_ip_addmulti_p1_ok_p : 	STD_LOGIC;
	SIGNAL		manage_ip_addmulti_p2_ok_p : 	STD_LOGIC;
	SIGNAL		manage_ip_adduni_p1_ok_p : 	STD_LOGIC;
	SIGNAL		manage_ip_adduni_p2_ok_p : 	STD_LOGIC;
	SIGNAL		manage_udp_ok_p		: 	STD_LOGIC;
	SIGNAL		manage_port_ok_p 		: 	STD_LOGIC;
	SIGNAL		manage_hello_ok_p 	: 	STD_LOGIC;
	---------------------------------------------------
	SIGNAL		internal_ok		: 	STD_LOGIC;
	SIGNAL		int_ok_p 		: 	STD_LOGIC;
	SIGNAL		int_ok 	: 	STD_LOGIC;
	----------------------------------------------------
	SIGNAL 		pkt_type_i			:	   	STD_LOGIC_VECTOR(7 DOWNTO 0)	;
	SIGNAL 		pkt_type_rdy_i		:   	STD_LOGIC 	;
	BEGIN
--------------read the source port process
	PROCESS(clk)
		BEGIN
	
			IF RISING_EDGE( clk )THEN		
					IF( in_wr = '1' AND in_ctrl=X"FF"  ) THEN
						IF in_data(31 DOWNTO 16)=X"0000" THEN
								source_port <= "00";
							ELSIF in_data(31 DOWNTO 16)=X"0002" THEN
								source_port <= "01";
							ELSIF in_data(31 DOWNTO 16)=X"0004" THEN
								source_port <= "10";
							ELSIF in_data(31 DOWNTO 16)=X"0006" THEN
								source_port <= "11";
						END IF;
					END IF;
			END IF;
		END PROCESS;

---------------------------------------------	
		PROCESS(reset,clk)
		BEGIN

			IF clk'EVENT AND clk ='1' THEN
				pkt_type_rdy <= pkt_type_rdy_i  ;
			END IF;
		END PROCESS;
		


	
		PROCESS(reset,clk)
		BEGIN
			IF (reset ='1') THEN
				state <=READ_HEADER;
			ELSIF clk'EVENT AND clk ='1' THEN
				state<=state_next; 
			END IF;
		END PROCESS;
		
		PROCESS(state , in_ctrl , in_wr)
		BEGIN
									 pkt_type_rdy_i <='0';
									 pkt_type <="00000000";
									 pkt_type(7) <= (NOT balance_ok )AND ( NOT router_ok) and  (not internal_ok ) AND ( NOT manage_ok) and (not arp_ok) ;
									 pkt_type(4) <= internal_ok AND ( NOT manage_ok) and (not arp_ok);--AND (NOT manage_ok) AND NOT (arp_ok);
 								    pkt_type(3) <= manage_ok;
									 pkt_type(2) <= router_ok   and (not arp_ok);
									 pkt_type(1) <= balance_ok  AND ( NOT router_ok) and (not arp_ok)  ;
									 pkt_type(0) <= arp_ok;
									 classifier_start				<='0';
									 state_next				   <=  state;
			CASE state IS		
				WHEN READ_HEADER =>			
					IF( in_wr = '1' AND in_ctrl=X"FF"  ) THEN
													classifier_start				<='1';
													state_next                 <=  READ_WORD_1;
					END IF;
					
				WHEN READ_WORD_1 =>			
					IF( in_wr = '1') THEN	
													
													state_next                <=  READ_WORD_2;
											
						END IF;
					
				WHEN READ_WORD_2 =>
					
					IF(in_wr = '1' ) THEN
													state_next                <= READ_WORD_3;
					
					END IF;
					
				WHEN READ_WORD_3 =>
				
					IF(in_wr = '1' ) THEN	
													state_next               <= READ_WORD_4;
					
					END IF;
				WHEN READ_WORD_4 =>
				
					IF(in_wr = '1' ) THEN	
						
													state_next               <= READ_WORD_5;
					
					END IF;
				WHEN READ_WORD_5 =>
				
					IF(in_wr = '1' ) THEN	
						
													state_next               <= READ_WORD_6;
					
					END IF;
				WHEN READ_WORD_6 =>
				
					IF(in_wr = '1' ) THEN	
						
													state_next               <= READ_WORD_7;
					
					END IF;		
				WHEN READ_WORD_7 =>												 
					IF(in_wr = '1'  ) THEN pkt_type_rdy_i <='1'; 												
													state_next               <= READ_HEADER;
					END IF;							
				WHEN OTHERS =>
													state_next              <= READ_HEADER;
			END CASE;
		END PROCESS;
		
--------------------------------ARP Check-------------
PROCESS(state, in_wr, in_ctrl, in_data)
		BEGIN
											 arp_dest_mac_ok 		   <= '0'; --DEST MAC = FF:FF:FF:FF:FF:FF
											 arp_port_ok 			   <= '0'; -- ARP PORT = X0806
											 arp_HTYPE_ok			   <= '0'; --htype = 1 ETHERNET 
											 arp_PTYPE_ok 			   <= '0';--PTYPE = 4  IPv4
											 arp_HLEN_ok 			   <= '0'; -- HLEN =6 OCTETS MAC ADDRESS
											 arp_PLEN_ok 			   <= '0';--PLEN = 4 OCTETS IP ADDRESS
											 arp_operation_ok 		<= '0'; -- ARP REQUEST  = 1
											 arp_ip1_int_ok         <= '0';
											 arp_ip2_int_ok    	    <= '0'; 
											 arp_ip1_ext_ok	        <= '0';
											 arp_ip2_ext_ok    	    <= '0'; 
			CASE state IS		
			
				WHEN READ_WORD_1 =>			
					
						IF (in_data(63 DOWNTO 16)=X"FFFFFFFFFFFF")THEN  arp_dest_mac_ok 		<= '1'; END IF;																
				WHEN READ_WORD_2 =>
					
						IF (in_data(31 DOWNTO 16)=X"0806")THEN  arp_port_ok 	<= '1'; END IF;
						IF (in_data(15 DOWNTO 0)=X"0001")THEN  arp_HTYPE_ok 	<= '1'; END IF;
				
					
				WHEN READ_WORD_3 =>
				
				
						IF (in_data(63 DOWNTO 48)=X"0800")THEN  arp_PTYPE_ok 		<= '1'; END IF;
						IF (in_data(47 DOWNTO 40)=X"06")THEN  arp_HLEN_ok 		<= '1'; END IF;
						IF (in_data(39 DOWNTO 32)=X"04")THEN  arp_PLEN_ok 		<= '1'; END IF;
						IF (in_data(31 DOWNTO 16)=X"0001")THEN  arp_Operation_ok 		<= '1'; END IF;
				
				WHEN READ_WORD_5 =>
				IF status_array(CONV_INTEGER(source_port))='0' THEN
				IF (in_data(15 DOWNTO 0)=ip_array(CONV_INTEGER(source_port))(31 downto 16))THEN  
												arp_ip1_ext_ok 		<= '1'; END IF;
				ELSE
				IF (in_data(15 DOWNTO 0)=DIST_UNICAST_LB(31 downto 16))THEN  
												arp_ip1_int_ok 		<= '1'; END IF;
				END IF;
				WHEN READ_WORD_6 =>	
				IF status_array(CONV_INTEGER(source_port))='0' THEN
				IF (in_data(63 DOWNTO 48)=ip_array(CONV_INTEGER(source_port))(15 downto 0))THEN
												arp_ip2_ext_ok 		<= '1'; END IF;	
				ELSE
				IF (in_data(63 DOWNTO 48)=DIST_UNICAST_LB(15 downto 0))THEN
												arp_ip2_int_ok 		<= '1'; END IF;	
				END IF;
--				WHEN READ_WORD_5 =>
--				IF (in_data(15 DOWNTO 0)=X"C0A8")THEN  
--												arp_ip1_ok 		<= '1'; END IF;
--				WHEN READ_WORD_6 =>	
--				IF (in_data(63 DOWNTO 48)=X"0101")THEN
--												arp_ip2_ok 		<= '1'; END IF;
				WHEN OTHERS =>
												
			END CASE;
		END PROCESS;
	
	
		PROCESS(classifier_start, clk)
		BEGIN
		IF (classifier_start ='1') THEN
													classifier_done_p<='0';
													arp_dest_mac_ok_p 		<= '0'; 
													arp_port_ok_p 			<= '0'; 
													arp_HTYPE_ok_p			<= '0';  
													arp_PTYPE_ok_p 			<= '0';
													arp_HLEN_ok_p			<= '0'; 
													arp_PLEN_ok_p 			<= '0';
													arp_operation_ok_p 		<= '0';		
													arp_ip1_int_ok_p	        <= '0';
													arp_ip2_int_ok_p    	    <= '0'; 
													arp_ip1_ext_ok_p	        <= '0';
													arp_ip2_ext_ok_p    	    <= '0'; 
												
		ELSIF clk'EVENT AND clk =	'1' THEN
			IF classifier_done	= 	'1' 	THEN   	classifier_done_p 		<= '1'; END IF;
			IF arp_dest_mac_ok	= 	'1' 	THEN   	arp_dest_mac_ok_p 		<= '1'; END IF;
			IF arp_port_ok		=	'1' 	THEN	arp_port_ok_p 			<= '1'; END IF; 
			IF arp_HTYPE_ok		=	'1'		THEN   	arp_HTYPE_ok_p			<= '1'; END IF;
			IF arp_PTYPE_ok		=	'1'		THEN	arp_PTYPE_ok_p 			<= '1';	END IF;
			IF arp_HLEN_ok		=	'1' 	THEN	arp_HLEN_ok_p			<= '1';	END IF;
			IF arp_PLEN_ok		=	'1' 	THEN	arp_PLEN_ok_p 			<= '1';	END IF;
			IF arp_operation_ok =	'1' 	THEN	arp_operation_ok_p      <= '1';	END IF;			
			IF arp_ip1_int_ok		=	'1' 	THEN	arp_ip1_int_ok_p		    <= '1';	END IF;	
			IF arp_ip2_int_ok		=	'1' 	THEN	arp_ip2_int_ok_p		    <= '1';	END IF;	
			IF arp_ip1_ext_ok		=	'1' 	THEN	arp_ip1_ext_ok_p		    <= '1';	END IF;	
			IF arp_ip2_ext_ok		=	'1' 	THEN	arp_ip2_ext_ok_p		    <= '1';	END IF;	
		END IF;
		END PROCESS;
		arp_ok <=  arp_port_ok_p AND arp_HTYPE_ok_p AND arp_PTYPE_ok_p AND arp_HLEN_ok_p 
		AND arp_PLEN_ok_p AND arp_operation_ok_p
		AND ((arp_ip1_int_ok_p and arp_ip2_int_ok_p) OR (arp_ip1_ext_ok_p and arp_ip2_ext_ok_p)); 
-------------------------------------------------------------------
-----------Process  to check Balance Traffic Module ---------------
-------------------------------------------------------------------
	

	
		PROCESS(state,  in_data)
		BEGIN													
				my_mac_ok 		<= '0';
			CASE state IS	
				WHEN READ_WORD_1 =>		
		IF (status_array(CONV_INTEGER(source_port))='0')	THEN			
					IF (in_data(63 DOWNTO 16)=mac_array(CONV_INTEGER(source_port)))THEN  my_mac_ok 		<= '1'; END IF;	
--		IF (in_data(63 DOWNTO 16)=X"CCCCCCCCCCCC")THEN  my_mac_ok 		<= '1'; END IF;	
				END IF;			
				WHEN OTHERS => 								   my_mac_ok 		<= '0';
					
			END CASE;
		END PROCESS;
PROCESS(classifier_start, clk)
		BEGIN
		IF (classifier_start ='1') THEN
															  my_mac_ok_p 		<='0';
														   
		ELSIF clk'EVENT AND clk =	'1' THEN
			IF my_mac_ok	= 	'1' 	THEN   				  my_mac_ok_p 		<='1'; END IF;		
		END IF;
		END PROCESS;
							balance_ok <= my_mac_ok_p; 
---------------------------------------------------------------------
-------------Process  to check Balance Traffic Module ---------------
---------------------------------------------------------------------
--
---------------------------------------------------------------------
-------------Process  to check Router Traffic Module ---------------
---------------------------------------------------------------------
--	
----		   Proto     Protocol_Num      TCP Port      UDP Port
----		------------|---------------|--------------|-----------
----		1.RIP V1           17             NO           520 
----		------------|---------------|--------------|-----------
----		2.OSPF             89              NO           NO 
----		------------|---------------|--------------|-----------
----		6.BGP              6             179            NO 
----		------------|---------------|--------------|-----------
--	
		PROCESS(state,  in_data)
				BEGIN	
											ip_packet_ok 	<= '0';	
											udp_ok 			<= '0';		
											tcp_ok 			<= '0';	
											ospf_proto_ok 	<= '0';	
											rip_port_ok 	<= '0';	
											bgp_port_ok  	<= '0';					
			CASE state IS		
				WHEN READ_WORD_1 =>	
				--Dest MAC Address{6 Bytes}
				--Src MAC(47..32){2 Bytes}							
								
				WHEN READ_WORD_2 =>	
				--Src MAC(31 ..0){4 Bytes}
				--Ethernet Type{2 Bytes}
				--Start IP Packet.---------
				--Version(4..0)	Header_length(4..0)	Differentiated_Services(7..0){2 Bytes}
						IF (status_array(CONV_INTEGER(source_port))='0')	THEN						
						IF (in_data(31 DOWNTO 16)=X"0800")THEN  ip_packet_ok 		<= '1'; END IF;--IP packet
						END IF;
				WHEN READ_WORD_3 =>	
				--Total_Length(15..0){2 Bytes}						
				--Identification(15..0){2 Bytes}
				--Flags(4..0)	Fragment_Offse(11..0){2 Bytes}
				--Time to Live(7:0){1 Bytes}	
				--Protocol(7:0){1 Bytes}						
					IF (in_data(7 DOWNTO 0)=X"11")THEN  udp_ok 		<= '1'; END IF;--17
					IF (in_data(7 DOWNTO 0)=X"06")THEN  tcp_ok 		<= '1'; END IF;--6
					IF (in_data(7 DOWNTO 0)=X"59")THEN  ospf_proto_ok 		<= '1'; END IF;--89	
				WHEN READ_WORD_4 =>			
				--Header Checksum(15:0){2 Bytes}
				--Source Address(31:0){4 Bytes}
				--Destination Address(31:16){2 Bytes}
								
				WHEN READ_WORD_5 =>			
				--Destination Address(15:0)	{2 Bytes}
				--Option 
				--TCP AND UDP ---
				--Source_Port(15:0)	Destination_Port(15:0){4 Bytes}
				 IF (in_data(47 DOWNTO 32)=X"0208")THEN    rip_port_ok 		<= '1'; END IF;--17
				 IF (in_data(47 DOWNTO 32)=X"00B3")  THEN    bgp_port_ok  	<= '1'; END IF;--6
									
				WHEN OTHERS => 								  
					
			END CASE;
		END PROCESS;
PROCESS(classifier_start, clk)
		BEGIN
		IF (classifier_start ='1') THEN
																ip_packet_ok_p 		<= '0';	
																udp_ok_p 			<= '0';		
																tcp_ok_p 			<= '0';	
																ospf_proto_ok_p		<= '0';	
																rip_port_ok_p 		<= '0';	
																bgp_port_ok_p  		<= '0';		
														   
		ELSIF clk'EVENT AND clk =	 '1' THEN
			IF ip_packet_ok		= 	 '1' 	THEN   				ip_packet_ok_p 		<='1'; END IF;
			IF udp_ok			= 	 '1' 	THEN   				udp_ok_p		 	<='1'; END IF;
			IF tcp_ok			= 	 '1' 	THEN   				tcp_ok_p		 	<='1'; END IF;
			IF ospf_proto_ok	=	 '1'    THEN   				ospf_proto_ok_p 	<='1'; END IF;
			IF rip_port_ok      = 	 '1' 	THEN   				rip_port_ok_p 		<='1'; END IF;
			IF bgp_port_ok 	= 	 '1' 	THEN   				bgp_port_ok_p 		<='1'; END IF;		
		END IF;
		END PROCESS;
router_ok <=    (ip_packet_ok_p AND udp_ok_p AND rip_port_ok_p)--RIP
			 OR (ip_packet_ok_p AND tcp_ok_p AND bgp_port_ok_p)--BGP
			 OR (ip_packet_ok_p AND ospf_proto_ok_p ); --OSPF
---------------------------------------------------------------------
-------------Process  to check Router Traffic Module ---------------
---------------------------------------------------------------------
------------Process  to check Manager Traffic Module ---------------
---------------------------------------------------------------------
	
		PROCESS(state,  in_data)
		BEGIN													
													manage_ip_packet_ok 		<= '0';
													manage_udp_ok		 		<= '0';
													manage_ip_addmulti_p1_ok 	<= '0';
													manage_ip_addmulti_p2_ok 	<= '0';
													manage_ip_adduni_p1_ok 	    <= '0';
													manage_ip_adduni_p2_ok 	    <= '0';
													manage_port_ok 				<= '0';
													manage_hello_ok 			<= '0';
		CASE state IS	
			WHEN READ_WORD_2 =>	
					IF (status_array(CONV_INTEGER(source_port))='1')	THEN	
			IF (in_data(31 DOWNTO 16)=X"0800")THEN  manage_ip_packet_ok 		<= '1'; END IF;
			END IF;
			WHEN READ_WORD_3 =>	
			IF (in_data(7 DOWNTO 0)=X"11")THEN  	manage_udp_ok 		    	<= '1'; END IF;--17
			WHEN READ_WORD_4 =>	
			IF (in_data(15 DOWNTO 0)=DIST_MULTICAST_LB(31 DOWNTO 16))	THEN 
													manage_ip_addmulti_p1_ok 	<= '1'; END IF;
			IF	(in_data(15 DOWNTO 0)=DIST_UNICAST_LB(31 DOWNTO 16)	)	THEN
													manage_ip_adduni_p1_ok 	<= '1'; END IF;
				--Destination Address(31:16){2 Bytes}
			WHEN READ_WORD_5 =>	
				--Destination Address(15:0)	{2 Bytes}
			IF (in_data(63 DOWNTO 48)=DIST_MULTICAST_LB(15 DOWNTO 0))	THEN 
													manage_ip_addmulti_p2_ok 	<= '1'; END IF;
			IF	(in_data(63 DOWNTO 48)=DIST_UNICAST_LB(15 DOWNTO 0)	)	THEN
													manage_ip_adduni_p2_ok	 	<= '1'; END IF;
				--Source_Port(15:0)	Destination_Port(15:0){4 Bytes}
			IF (in_data(47 DOWNTO 32)=DIST_PORT AND in_data(31 DOWNTO 16)=DIST_PORT) THEN
												    manage_port_ok 				<= '1'; END IF;
--				--DIST Message Version and Type
--			IF (in_data(15 DOWNTO 8)=DIST_VER AND in_data(7 DOWNTO 0)=DIST_MSGTYPE) THEN
--												    manage_hello_ok 			<= '1'; END IF;
		
			WHEN READ_WORD_6 =>	
				--DIST Message Version and Type
			IF (in_data(47 DOWNTO 40)=DIST_VER AND in_data(39 DOWNTO 32)=DIST_MSGTYPE) THEN
												    manage_hello_ok 			<= '1'; END IF;
			WHEN OTHERS => 		
																
					
			END CASE;
		END PROCESS;
PROCESS(classifier_start, clk)
		BEGIN
		IF (classifier_start ='1') THEN
														manage_ip_packet_ok_p 		<= '0';
														manage_udp_ok_p		 		<= '0';
														manage_ip_addmulti_p1_ok_p 	<= '0';
														manage_ip_addmulti_p2_ok_p 	<= '0';
														manage_ip_adduni_p1_ok_p	<= '0';
														manage_ip_adduni_p2_ok_p	<= '0';
														manage_port_ok_p 			<= '0';
														manage_hello_ok_p			<= '0';
														   
		ELSIF clk'EVENT AND clk =	'1' THEN
			IF manage_ip_packet_ok	= 	'1' THEN 		manage_ip_packet_ok_p 		<='1'; END IF;	
			IF manage_udp_ok		= 	'1' THEN   		manage_udp_ok_p 			<='1'; END IF;	
			IF manage_ip_addmulti_p1_ok	= 	'1' THEN   	manage_ip_addmulti_p1_ok_p 	<='1'; END IF;	
			IF manage_ip_addmulti_p2_ok	= 	'1' THEN   	manage_ip_addmulti_p2_ok_p 	<='1'; END IF;
			IF manage_ip_adduni_p1_ok	= 	'1' THEN   	manage_ip_adduni_p1_ok_p 	<='1'; END IF;	
			IF manage_ip_adduni_p2_ok	= 	'1' THEN   	manage_ip_adduni_p2_ok_p 	<='1'; END IF;		
			IF manage_port_ok	= 	'1' THEN   			manage_port_ok_p 			<='1'; END IF;	
			IF manage_hello_ok	= 	'1' THEN   			manage_hello_ok_p 			<='1'; END IF;	
			
		END IF;
		END PROCESS;
							manage_ok <= manage_ip_packet_ok_p AND manage_udp_ok_p AND
										((manage_ip_addmulti_p1_ok_p AND manage_ip_addmulti_p2_ok_p)
									OR	(manage_ip_adduni_p1_ok_p AND manage_ip_adduni_p2_ok_p))	AND
										 manage_port_ok_p AND manage_hello_ok_p	; 
										
		-------------------INT => EXT -------------
		
		PROCESS(state,  in_data)
		BEGIN													
				int_ok 		<= '0';
			CASE state IS	
				WHEN READ_WORD_1 =>			
					
						IF (status_array(CONV_INTEGER(source_port))='1')THEN  int_ok 		<= '1'; END IF;	
				WHEN OTHERS => 								   int_ok 		<= '0';
					
			END CASE;
		END PROCESS;
	PROCESS(classifier_start, clk)
			BEGIN
			IF (classifier_start ='1') THEN
																  int_ok_p 		<='0';
															   
			ELSIF clk'EVENT AND clk =	'1' THEN
				IF int_ok	= 	'1' 	THEN   				  	  int_ok_p 		<='1'; END IF;		
			END IF;
			END PROCESS;
							internal_ok <= int_ok_p;
	
END behavior;
   