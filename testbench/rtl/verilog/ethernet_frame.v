//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "ethernet_frame.v"                                ////
////                                                              ////
////  This file is part of the :                                  ////
////                                                              ////
//// "1000BASE-X IEEE 802.3-2008 Clause 36 - PCS project"         ////
////                                                              ////
////  http://opencores.org/project,1000base-x                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - D.W.Pegler Cambridge Broadband Networks Ltd           ////
////                                                              ////
////      { peglerd@gmail.com, dwp@cambridgebroadand.com }        ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 AUTHORS. All rights reserved.             ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

package ethernet_frame;
   
   import tb_utils::hexpretty;
   import tb_utils::hexformat;
   
   typedef int crc_t[4];
   typedef int proto_t[2];
   typedef int payload_t[];
   typedef int ethernet_address_t[6];
   
   localparam ethernet_address_t ETH_A_TB        = '{'haa, 'hbb, 'hcc, 'hdd, 'hee, 'hff};
   localparam ethernet_address_t ETH_A_BCAST     = '{'hff, 'hff, 'hff, 'hff, 'hff, 'hff};
   localparam ethernet_address_t ETH_A_NULL      = '{'h00, 'h00, 'h00, 'h00, 'h00, 'h00};
   
   localparam ethernet_address_t ether_broadcast = ETH_A_BCAST;
   localparam ethernet_address_t ether_null      = ETH_A_NULL;
   localparam ethernet_address_t def_dst_addr    = ETH_A_TB;
   localparam ethernet_address_t def_src_addr    = ETH_A_TB;
   
   localparam proto_t ETH_P_IP                   = '{'h08, 'h00};
   
   localparam proto_t def_proto                  = ETH_P_IP;
    
   localparam int ethernet_preamble      = 'h5;
   localparam int ethernet_preamble_len  = 15;
   localparam int ethernet_sfd           = 'hd;
   localparam int ethernet_min_payload   = 46;
   localparam int ethernet_max_payload   = 2100;
   localparam int ethernet_crc_poly      = 32'h04c11db7;
   localparam int ethernet_overhead      = (6+6+2+4); // Excludes preamble, SFD
   
   // Parameters for 100BaseTx Ethernet:
   localparam int ethernet_slot_time        = 512;  // bit times
   localparam int ethernet_inter_frame_gap  = 96;   // bits
   localparam int ethernet_attempt_limit    = 16;
   localparam int ethernet_back_off_limit   = 10;
   localparam int ethernet_jam_size         = 32;   // bits
   localparam int ethernet_min_frame_size   = ethernet_min_payload + ethernet_overhead; // = 64;
   localparam int ethernet_clk_rate         = 25e6;
   
   typedef enum   { ETH10, ETH100, ETH1000 } EthernetSpeed;
   
   int 		  nothing[] = new[0];
   
   //////////////////////////////////////////////////////////////////////////////
   //
   //////////////////////////////////////////////////////////////////////////////
   
class CRC32;
   
   static function reg [7:0] byte_swap(reg [7:0] x);
      return {x[0], x[1], x[2], x[3], x[4], x[5], x[6], x[7]};
   endfunction
   
   static function reg [31:0] word_swap(reg [31:0] x);
      return {byte_swap(x[7:0]), byte_swap(x[15:8]), byte_swap(x[23:16]), byte_swap(x[31:24])};
   endfunction
   
   static function reg[31:0] pack_swap(reg [31:0] x);
      return  { x[7:0], x[15:8], x[23:16], x[31:24]};
   endfunction // pack_swap
   
   static int 	  crc32_table[256];
   static int 	  crc32_table_ready = 0;
   int 		  accum = 32'hffffffff;
   
   static function automatic void populate_crc_table();
      $display("Populating crc32 table...");
      for(int i=0; i<256; i++)
        begin
           int c = i<<24;
           for(int j=0; j<8; j++)
             begin
		if(c & 32'h80000000)
                  c = (c << 1) ^ ethernet_crc_poly;
		else
                  c = (c << 1);
             end
           crc32_table[byte_swap(i)] = word_swap(c);
        end
      crc32_table_ready = 1;
   endfunction
   
   function void reset();
      accum = 32'hffffffff;
      if(!crc32_table_ready) populate_crc_table();
   endfunction
   
   function new();
      reset();
   endfunction
   
   function void push(int x);
      accum = (accum[31:8] ^ crc32_table[accum[7:0] ^ x[7:0]]) & 32'hffffffff; 
   endfunction
   
   function int eval();
      return ~accum;
   endfunction
   
   static function int block(int buffer[], int start, int finish);
      CRC32 x = new();
      x.reset();
      for(int i=start; i<finish; i++) x.push(buffer[i]);
      return x.eval();
   endfunction
   
endclass // CRC32
   
   //////////////////////////////////////////////////////////////////////////////
   //
   //////////////////////////////////////////////////////////////////////////////
   
   function automatic string fmt_addr(ethernet_address_t addr);
      
      $sformat(fmt_addr, "%02X.%02X.%02X.%02X.%02X.%02X",
	       addr[0], addr[1], addr[2], addr[3], addr[4], addr[5]);
      
   endfunction 
   
   function void random_payload(int size, output int rv[], input int randomize, int seed=-1);
      
      int tmp;
      
      if (seed >= 0) tmp = $urandom(seed);
      
      rv = new[size];
      
      for(int i=0; i<size; i++)
	rv[i] = (randomize) ? ($urandom() & 'hff) : ((1+i) & 'hff);
      
   endfunction
   
   //----------------------------------------------------------------------------

  class EthernetFrame extends packet::Packet;
    int raw[];
    int badcrc;
    time delay = 0;  
    int epd_sequence = 0;
     
    function new(
      int da[]      = def_dst_addr,
      int sa[]      = def_src_addr,
      int proto[]   = def_proto,
      int payload[] = nothing,
      int seed      = -1,
      int randomize = 1,
      int length    = 100,
      int badcrc    = 0,
      int initraw[] = nothing
    );
       set_badcrc(badcrc, 0);

      if(initraw.size()!=0)
        raw = new[initraw.size()](initraw);
      else
        begin
          if(payload.size()==0) random_payload(length, payload, randomize, seed);
          set_payload(payload);
          set_da(da, 0);
          set_sa(sa, 0);
          set_proto(proto, 1);  
        end
    endfunction

    function int len();
      return raw.size();
    endfunction

    function int payload_len();
      return raw.size() - ethernet_overhead;
    endfunction
   
    function string repr_verbose(int n_start=4, int n_end=4);
      string s;
      $sformat(s, "<Frame,da=%s,sa=%s,len=%s,pay=%s,crc=%s>",
        fmt_addr(get_da()),
        fmt_addr(get_sa()),
        hexpretty(get_proto()),
        hexpretty(get_payload(), n_start, n_end),
        hexpretty(get_crc())
      );
      return s;
   endfunction // repr
     
     
   function string dump();
      string s;
      $sformat(s, "<len=%0d,da=%s,sa=%s,type=%s,pay=%s,crc=%s>",
        len(),
        fmt_addr(get_da()),
        fmt_addr(get_sa()),
        hexpretty(get_proto()),
        hexformat(get_payload(), "0x%02x", ","),
        hexpretty(get_crc())
      );
      return s;
    endfunction

     
    function void resize(int n);
      raw = new[n](raw);
    endfunction


     function void cut(int pos, int n);
	for(int i=pos; i<(raw.size-n); i++)
	  raw[i] = raw[i+n];
	
	resize(raw.size - n);	
     endfunction; // extract  
    
    function void set_da(ethernet_address_t da, int update=1);
      raw[0:5] = da;
      if(update)
        update_crc();
    endfunction

    function ethernet_address_t get_da();
      return raw[0:5];
    endfunction

    function void set_sa(ethernet_address_t sa, int update=1);
      raw[6:11] = sa;
      if(update)
        update_crc();
    endfunction

    function ethernet_address_t get_sa();
      return raw[6:11];
    endfunction

    function void set_proto(proto_t x, int update=1);
      raw[12:13] = x;
      if(update)
        update_crc();
    endfunction

    function proto_t get_proto();
      return raw[12:13];
    endfunction

    function void set_badcrc(int b, int update=1);
      badcrc = b;
      if(update)
        update_crc();
    endfunction

     function void set_payload(int p[]);
       int   n = p.size();
       resize(n+ethernet_overhead);
       for(int i=0; i<n; i++)
         raw[14+i] = p[i];
    endfunction

    function void pad_up();
      int n = raw.size();
      if(n < ethernet_min_frame_size)
        begin
           $display("Inserting %0d bytes of padding.", ethernet_min_frame_size-n);
           resize(ethernet_min_frame_size);
           for(int i=n-4; i<ethernet_min_frame_size-4; i++)
             raw[i] = 0;
           update_crc();
        end
    endfunction

     function void align();
	int n = raw.size();
	if(n[0])
          begin
             $display("Increasing size of frame from %0d bytes to %0d bytes.", n, n+1);
             resize(n+1);
             raw[n-4] = 0;
             update_crc();
          end
     endfunction
     
    // Seems we can't avoid the copy in here...
    function payload_t get_payload();
      int n = raw.size()-ethernet_overhead;
      get_payload = new[n];
      for(int i=0; i<n; i++)
        get_payload[i] = raw[14+i];
    endfunction

    function crc_t calc_crc();
      int crc = CRC32::block(raw, 0, raw.size()-4);
      calc_crc[0] = crc[7:0];
      calc_crc[1] = crc[15:8];
      calc_crc[2] = crc[23:16];
      calc_crc[3] = crc[31:24];
    endfunction

    function crc_t get_crc();
      return raw[raw.size()-4+:4];
    endfunction

    function int check_crc();
      int expected_crc[4] = calc_crc();
      int extracted_crc[4] = get_crc();
      return expected_crc==extracted_crc;
    endfunction

    // Update length and CRC fields.
    function void update_crc();
      if(raw.size()>=4)
        begin
          int fcs[4];
          int n;
          fcs = calc_crc();
	   n = raw.size();
          for(int i=0; i<4; i++)
            raw[n-4+i] = fcs[i] ^ (badcrc ? 'ha5 : 0);
        end
    endfunction

  endclass

  // Specialize a mailbox for passing Ethernet frames.
  typedef mailbox #(EthernetFrame) FrameMailBox;

endpackage

