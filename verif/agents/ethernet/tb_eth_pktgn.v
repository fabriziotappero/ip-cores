/*-----------------------------------------------------------------
|           Ethernet Traffic Generator Testbench                    |
|                                                                   |
 ------------------------------------------------------------------*/

/*-----------------------------------------------------------------\
|  DESCRIPTION:                                                    |
|  tb_pktgn.v:  Packet generation tasks                            |
|                                                                  |
|  Instantiated modules: none                                      |
|  Included files: none                                            |
\-----------------------------------------------------------------*/

task construct_frame;
   integer size;
   integer payload_byte;
   reg [`MAX_PKT_SIZE*8 -1:0]  packet;
   integer i,j;
   begin 
      size = current_pkt_size;
      // clear packet
      packet = 0;
      add_L2_header(packet);
      if (flow_type >= 3)
       add_L3_header(packet);
      if (flow_type >= 5)
       add_L4_header(packet);
      add_payload(packet); 
      
      transmit_pkt = packet;
      transmit_pkt_size= size;
   end
endtask // construct_frame

task add_L2_header;
   inout [`MAX_PKT_SIZE*8 -1:0] packet;
   reg [47:0] mac_addr;
   reg [15:0] temp;
   integer length_field, next_offset, j;
   reg [`MAX_HEADER_SIZE*8-1:0] std_LLC_header;

   begin
      if (L2_custom_header_enable) // use user-defined header
       begin
	  insert_header(packet, 0, L2_custom_header,
		     L2_custom_header_length);
	  L3_header_position = L2_custom_header_length;
	  if (flow_type < 3) // Layer-2 flow
	   payload_position =  L2_custom_header_length;
       end // if (L2_custom_header_enable)
      else
       begin
	  mac_addr = current_dstn_mac;
	  //swap bytes in MAC address
	  // MS byte goes first on the link
	  packet[ 7: 0] =  mac_addr[47:40];
	  packet[15: 8] =  mac_addr[39:32];
	  packet[23:16] =  mac_addr[31:24];
	  packet[31:24] =  mac_addr[23:16];
	  packet[39:32] =  mac_addr[15: 8];
	  packet[47:40] =  mac_addr[ 7: 0];

	  mac_addr = current_src_mac;
	  packet[55:48] =  mac_addr[47:40];
	  packet[63:56] =  mac_addr[39:32];
	  packet[71:64] =  mac_addr[31:24];
	  packet[79:72] =  mac_addr[23:16];
	  packet[87:80] =  mac_addr[15: 8];
	  packet[95:88] =  mac_addr[ 7: 0];

	  length_field = current_pkt_size - 6*2 - 2 -4; // SA, DA, length, CRC
	  next_offset = 12;
	  if ((L2_protocol_type == 1) ||
	      (L2_protocol_type == 3))   // tagged frame
	   begin // attach VLAN tag
	      packet[103:96] = (L2_VLAN_TPID >> 8) & 8'hff;
	      packet[111:104] = L2_VLAN_TPID & 8'hff;
	      temp = current_VLAN_TCI;
	      packet[119:112] = temp[15:8];
	      packet[127:120] = temp[7:0];
	      length_field = length_field -4;
	      next_offset = next_offset +4;
	   end

      // set type-length field 
	  if ((L2_protocol_type == 0) ||
	      (L2_protocol_type == 1))  // Ethernet frame
	   begin
	      if (flow_type < 3) // Layer-2 flow
	       temp[15:0] = L2_type_field;
	      else
	       case(L3_protocol_type)
		 4: // IP Version 4
		  temp = 16'h0800;
		 6: // IP version 6
		  temp = 16'h08dd;
		 8: // TCP/IP ARP
		  temp = 16'h0806;
		 9: // IPX
		  temp = 16'h8137;
		 default:
		  temp = 16'h0800; // default is IP Version 4
	       endcase // case(L3_protocol)
	   end // if ((L2_protocol_type == 0) ||...
	  else
	   begin // 802.3 frame
	      // Allow undersize L2 frames with padding
	      // by setting length field based on payload length
	      if ((flow_type <= 2)  // Layer-2 flow
		  && (payload_length < length_field))
	       length_field = payload_length;
	      temp[15:0] = length_field[15:0];
	   end // else: !if((L2_protocol_type == 0) ||...
	  
	  for (i=0; i<8; i=i+1)
	   packet[next_offset*8 +i] = temp[8+i];
	  next_offset = next_offset+1;
	  for (i=0; i<8; i=i+1)
	   packet[next_offset*8 +i] = temp[i];
	  next_offset = next_offset+1;	  

	  // set LLC header for 802.3 frames
	  if ((L2_protocol_type == 2) ||
	      (L2_protocol_type == 3))  // 802.3 frame
	   begin
	      std_LLC_header[63:48] = 16'haaaa; //DSAP and SSAP
	      std_LLC_header[47:40] = 8'd3;     // control
	      std_LLC_header[39:16] = 24'd0;    // org code
	      // set type field
	      if (flow_type < 3) // Layer-2 flow
	       std_LLC_header[15:0] = L2_type_field;
	      else
	       case(L3_protocol_type)
		 4: // IP Version 4
		  std_LLC_header[15:0] = 16'h0800;
		 6: // IP version 6
		  std_LLC_header[15:0] = 16'h08dd;
		 8: // TCP/IP ARP
		  std_LLC_header[15:0] = 16'h0806;
		 9: // IPX
		  std_LLC_header[15:0] = 16'h8137;
		 default:
		  std_LLC_header[15:0] = 16'h0800; // default is IPv4
	       endcase // case(L3_protocol)
	      
	      if (L2_LLC_header_enable) // use user-defined header
	       begin
		  insert_header(packet, next_offset, L2_LLC_header,
			     L2_LLC_header_length);
		  next_offset = next_offset + L2_LLC_header_length;
	       end // if (L2_LLC_header_enable)
	      else
	       begin
		  insert_header(packet, next_offset, std_LLC_header, 8);
		  next_offset = next_offset + 8;
	       end // else: !if(L2_LLC_header_enable)
	   end // if ((L2_protocol_type == 2) ||...
	  
	  L3_header_position = next_offset;
	  if (flow_type < 3) // Layer-2 flow
	   payload_position =  next_offset;
       end // else: !if(L2_custom_header_enable)
   end
endtask // add_L2_header

task add_L3_header;
   inout [`MAX_PKT_SIZE*8 -1:0] packet;

   reg [`MAX_HEADER_SIZE*8-1:0] L3_header;
   integer length;
   reg [31:0] x;

   begin
      if (L3_custom_header_enable) // use user-defined header
       begin
	  insert_header(packet, L3_header_position, L3_custom_header,
		     L3_custom_header_length);
	  L4_header_position =  L3_header_position + L3_custom_header_length;
	  if (flow_type < 5) // Layer-4 flow
	   payload_position =  L4_header_position;
       end // if (L3_custom_header_enable)
      else
       begin
	  case (L3_protocol_type)
	    4: // IP Version 4
	     begin
		L3_header[159:156] = 4'h4;// Version = 4
		L3_header[155:152] = 4'd5 + IP_ext_header_length/4;
		// size of datagram

		L3_header[151:144] = IP_service_type;// TOS field

		// Determine length of datagram
		length = current_pkt_size - L3_header_position -4; // leave 4 bytes for CRC
		// check payload length defined by user
		if (flow_type >= 5) // Layer-4 flow
		 begin
		    if (L4_protocol_type == 1) // UDP, header length = 8 bytes
		     begin
			if ((payload_length + 20 + IP_ext_header_length + 8)
			    < length)
			 length = payload_length + 20 + IP_ext_header_length + 8;
		     end // if (L4_protocol_type == 1)
		    else // TCP, header length = 20 bytes
		     begin
			if ((payload_length + 20 + IP_ext_header_length + 20) < length)
			 length = payload_length + 20 + IP_ext_header_length + 20;
		     end // else: !if(L4_protocol_type == 1)
		 end // if (flow_type >= 5)
		else // Layer-3 flow
		 if ((payload_length + 20 + IP_ext_header_length) < length)
		  length = payload_length + 20 + IP_ext_header_length;

		L3_header[143:128] = length[15:0];
		L3_header[127:112] = L3_sequence_number[15:0]; //IP sequence number
		L3_sequence_number = L3_sequence_number+1;

		L3_header[111:109] = IP_flags[2:0]; // IP flags 
		L3_header[108:96] =  IP_fragment_offset[12:0]; // fragment offset

		L3_header[95:88]  = L3_TTL[7:0]; // IP time to live
		L3_header[87:80]  = IP_protocol_field[7:0]; // L4 protocol
		// If flow is defined as Layer-4 set protocol field
		// according to the L4 protocol defined
		if (flow_type >= 5) // Layer-4 flow
		 case(L4_protocol_type)
		   0: // TCP
		    L3_header[87:80] = 8'h06;
		   1: // UDP
		    L3_header[87:80] = 8'h11;
		 endcase // case(L4_protocol_type)
		L3_header[79:64] = 16'h0; // reset IP checksum
		L3_header[63:32] = L3_src_address;
		L3_header[31:0] = L3_dstn_address;
		// calculate IP checksum
		L3_header[79:64] = IP_checksum(L3_header, 20);

		// insert IP header in packet
		insert_header(packet, L3_header_position, L3_header, 20);

		// insert IP extension header
		if (IP_ext_header_length != 0)
		 insert_header(packet, L3_header_position + 20,
			       IP_ext_header, IP_ext_header_length);
		L4_header_position =  L3_header_position + 20 +
				      IP_ext_header_length;
		payload_position =  L4_header_position;
	     end // case: 4
	    default:
	     begin
		L4_header_position =  L3_header_position;
		payload_position =  L4_header_position;
	     end // case: default
	  endcase // case(L3_protocol_type)
       end // else: !if(L3_custom_header_enable)
   end
endtask // add_L3_header

task add_L4_header;
   inout [`MAX_PKT_SIZE*8 -1:0] packet;
   reg [`MAX_HEADER_SIZE*8-1:0] L4_header;

   integer length;

   begin
      if (L4_custom_header_enable) // use user-defined header
       begin
	  insert_header(packet, L4_header_position, L4_custom_header,
		     L4_custom_header_length);
	  payload_position =  L4_header_position + L4_custom_header_length;
       end // if (L4_custom_header_enable)
      else
       begin
	  case(L4_protocol_type)

	    1: begin // UDP, header size = 8 bytes
	       L4_header[63:48] = L4_src_port;
	       L4_header[47:32] = L4_dstn_port;

	       // Determine length field
	       length = current_pkt_size - L4_header_position -4; // leave 4 bytes for CRC
	       // check payload length defined by user
	       if ((payload_length + 8) < length)
		length = payload_length + 8;

	       L4_header[31:16] = length[15:0];
	       L4_header[15:0] =  0; // calculate checksum later after constructing payload

	       insert_header(packet, L4_header_position, L4_header, 8);
	       payload_position =  L4_header_position + 8;
	    end

	    default: begin // TCP, header size = 20 bytes
	       
	       L4_header[159:144] = L4_src_port;
	       L4_header[143:128] = L4_dstn_port;
	       L4_header[127:96] = L4_sequence_number;
	       L4_header[95:64] = L4_ack_number;
	       L4_header[63:60] = 4'd5; // length of header in 32-bit words
	       L4_header[59:54] = 6'd0; // reserved field
	       L4_header[53:48] = TCP_flags;
	       L4_header[47:32] = TCP_window_size;
	       L4_header[31:16] = 16'd0; // calculate checksum later
	       L4_header[15:0]  = TCP_urgent_pointer; // calculate checksum later
	       insert_header(packet, L4_header_position, L4_header, 20);
	       payload_position =  L4_header_position + 20;

	       // update TCP sequence number
	       length = current_pkt_size - payload_position - 4; // leave 4 bytes for CRC
	       if (payload_length < length)
		length = payload_length;
	       L4_sequence_number = L4_sequence_number + length;
	    end // case: default
	  endcase // case(L4_protocol_type)
       end // else: !if(L4_custom_header_enable)
   end
endtask // add_L4_header
   
task add_payload;
   inout [`MAX_PKT_SIZE*8 -1:0] packet;

   integer length, checksum_position, i, j;
   reg [31:0] x;
   reg [7:0] payload_byte;
   reg [15:0] next_word;
   reg [31:0] checksum;

   begin

      length = current_pkt_size - payload_position;
      if (flowrec_crc_option != 2'b10)
       length = length - 4; // leave 4 bytes for CRC
      if (payload_length < length)
       length = payload_length;
      case(payload_option)
	0: begin // increasing sequence of bytes
	   payload_byte = payload_start;
	   for (i = payload_position; i < (payload_position+length); i = i+1)
	    begin
	       for (j=0; j<8; j=j+1)
		packet[i*8 +j] = payload_byte[j];
	       payload_byte = payload_byte +1;
	    end // for (i = payload_position; i < (payload_position+length); i = i+1)
	end // case: 0
	
	1: begin // decreasing sequence of bytes
	   payload_byte = payload_start;
	   for (i = payload_position; i < (payload_position+length); i = i+1)
	    begin
	       for (j=0; j<8; j=j+1)
		packet[i*8 +j] = payload_byte[j];
	       payload_byte = payload_byte -1;
	    end // for (i = payload_position; i < (payload_position+length); i = i+1)
	end // case: 1

	2: begin // random payload
	   for (i = payload_position; i < (payload_position+length); i = i+1)
	    begin
	       x = $random();
	       for (j=0; j<8; j=j+1)
		packet[i*8 +j] = x[j];
	    end // for (i = payload_position; i < (payload_position+length); i = i+1)
	end // case: 2
	
	3: begin // user-defined payload
	   for (i=0; i < length; i = i+1)
	    for (j=0; j < 8; j= j+1)
	     packet[(payload_position+i)*8 +j] = user_payload[(length-i-1)*8 +j];
	end // case: 3
      endcase // case(payload_option)
      
      // for TCP and UDP flows, update L4 checksum
      if (flow_type >= 5)
       begin
	  if (L4_protocol_type == 1) // UDP
	   checksum_position = L4_header_position + 6; // position of checksum in pkt
	  else // TCP
	   checksum_position = L4_header_position + 16;
	  
	  // determine length of packet, including TCP/UDP header
	  length = current_pkt_size - payload_position - 4; // leave 4 bytes for CRC
	  if (payload_length < length)
	   length = payload_length;
	  if (L4_protocol_type == 1) // UDP
	   length = length + 8;
	  else // TCP
	   length = length + 20;	     
	  
	  // calculate checksum
	  checksum[31:0] = 32'd0;
	  for (i=0; i < length; i = i+2)
	   begin
	      next_word[15:8] = 0;
	      for (j=0; j < 8; j= j+1)
	       next_word[8+j] = packet[(L4_header_position+i)*8 +j];
	      // if length is an odd number of bytes, pad last byte with zeroes
	      next_word[7:0] = 0;
	      if ((i+1) < length)
	       for (j=0; j < 8; j= j+1)
		next_word[j] = packet[(L4_header_position+i+1)*8 +j];
	      checksum = checksum + {16'd0, next_word[15:0]};
	   end // for (i=0; i < length; i = i+2)
	  // add pseudo header
	  checksum = checksum + 
		     {16'd0, L3_src_address[31:16]} +
		     {16'd0, L3_src_address[15:0]} +
		     {16'd0, L3_dstn_address[31:16]} +
		     {16'd0, L3_dstn_address[15:0]};
	  if (L4_protocol_type == 1) // UDP
	   checksum = checksum + 32'h00000011   // protocol = 17
				+ {16'd0, length[15:0]};
                              	  // length field from UDP header
	  else // TCP
	   checksum = checksum + 32'h00000006   // protocol = 6
		      + {16'd0, length[15:0]}; // length of payload + TCP header
	  
	  // add "end-around carry"
	  checksum = checksum + {16'd0, checksum[31:16]};

	  if (checksum[15:0] == 16'd0) // complement checksum
	   checksum[15:0] = 16'hffff;

	  case(L4_checksum_option)
	    0: // calculate good checksum
	     begin
		// nothing to do
	     end // case: 0

	    1: // generate bad checksum
	     begin
		x = $random();
		if (x[15:0] == checksum[15:0]) // if we got correct checksum by accident
		 x[15] = ~x[15]; //invert MS bit;
		checksum[15:0] = x[15:0];
	     end // case: 1

	    2: // set checksum to zero
	     checksum[15:0] = 16'd0;

	    3: // set checksum to user-defined value
	     checksum[15:0] = L4_user_checksum;
	  endcase // case(L4_checksum_option)

	  // insert checkum in L4 header
	  for (j=0; j < 8; j= j+1)
	   packet[checksum_position*8 +j] = checksum[8+j];
	  for (j=0; j < 8; j= j+1)
	   packet[(checksum_position +1)*8 +j] = checksum[j];
       end // if (flow_type >= 5)
   end
endtask // add_payload

task insert_header;
   inout [`MAX_PKT_SIZE*8 -1:0] packet;
   input  offset;
   input [`MAX_HEADER_SIZE*8-1:0] header;
   input length;
   integer offset, length;
   integer i,j;
  begin
     if (length != 0)
      for (i=0; i < length; i = i+1)
       for (j=0; j < 8; j= j+1)
	packet[(offset+i)*8 +j] = header[(length-i-1)*8 +j];
  end
endtask // insert_header

task construct_pause_frame;
   // Constructs an 802.3x PAUSE frame
   input [47:0] src_mac;
   input [15:0] pause_time;
   output [`MAX_PKT_SIZE*8 -1:0]  packet;
   output size;
   integer i,j, size;

   reg [47:0] mac_addr;
   reg [15:0] temp;
   begin 
      size = 64;
      // clear packet
      packet = 0;
      // construct header;
      mac_addr = `PAUSE_DEST_MAC;
      //swap bytes in MAC address
      // MS byte goes first on the link
      packet[ 7: 0] =  mac_addr[47:40];
      packet[15: 8] =  mac_addr[39:32];
      packet[23:16] =  mac_addr[31:24];
      packet[31:24] =  mac_addr[23:16];
      packet[39:32] =  mac_addr[15: 8];
      packet[47:40] =  mac_addr[ 7: 0];

      mac_addr = src_mac;
      packet[55:48] =  mac_addr[47:40];
      packet[63:56] =  mac_addr[39:32];
      packet[71:64] =  mac_addr[31:24];
      packet[79:72] =  mac_addr[23:16];
      packet[87:80] =  mac_addr[15: 8];
      packet[95:88] =  mac_addr[ 7: 0];

      // set type-length field
      temp = `PAUSE_TYPE;
      packet[103:96] = temp[15:8];
      packet[111:104] = temp[7:0];
      // set PAUSE opcode
      temp = `PAUSE_OPCODE;
      packet[119:112] = temp[15:8];
      packet[127:120] = temp[7:0];

      // set pause parameter
      temp = pause_time;
      packet[135:128] = temp[15:8];
      packet[143:136] = temp[7:0];
   end
endtask // construct_pause_frame

function [15:0] IP_checksum;
   input [`MAX_PKT_SIZE*8 -1:0] header;
   input length;
   integer length;
   reg [31:0] checksum;
   reg [15:0] next_word;
   integer i, j;
   reg [31:0] x;

   begin
      // compute header checksum
      checksum[31:0] = 32'd0;
      for (i=0; i< length/2; i=i+1)
       begin
	  for (j=0; j<16; j=j+1)
	   next_word[j] = header[i*16 +j]; // get next 16 bits
	  checksum = checksum + {16'd0, next_word[15:0]};
       end // for (j=0; j<16; j=j+1)

      // include IP extension header, if present
      if (IP_ext_header_length != 0)
       begin
	  for (i=0; i< IP_ext_header_length/2; i=i+1)
	   begin
	      for (j=0; j<16; j=j+1)
	       next_word[j] = IP_ext_header[i*16 +j]; // get next 16 bits
	      checksum = checksum + {16'd0, next_word[15:0]};
	   end // for (j=0; j<16; j=j+1)
       end // if (IP_ext_header_length != 0)

      // add "end-around carry"
      checksum = checksum + {16'd0, checksum[31:16]};

      case (L3_checksum_option)
	0: // calculate good checksum
	 begin
	    IP_checksum = ~checksum[15:0];
	 end // case: 0

	1: // generate bad checksum
	 begin
	    x = $random();
	    if (x[15:0] == ~checksum[15:0])
	     // if the checksum is good by accident
	     x[15:0] = x[15:0] ^ 16'h8000; // complement MS bit
	    IP_checksum = x[15:0];
	 end // case: 1

	2: // set checksum to zero
	 IP_checksum = 16'd0;

	3: // set checksum to user-defined value
	 IP_checksum = L3_user_checksum;
      endcase // case(L3_checksum_option[flow_id])
   end
endfunction

