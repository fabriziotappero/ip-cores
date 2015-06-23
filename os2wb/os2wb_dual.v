`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  (C) Athree, 2009
// Engineer: Dmitry Rozhdestvenskiy 
// Email dmitry.rozhdestvenskiy@srisc.com dmitryr@a3.spb.ru divx4log@narod.ru
// 
// Design Name:    Bridge from SPARC Core to Wishbone Master
// Module Name:    os2wb 
// Project Name:   SPARC SoC single-core
//
// LICENSE:
// This is a Free Hardware Design; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// version 2 as published by the Free Software Foundation.
// The above named program is distributed in the hope that it will
// be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
//////////////////////////////////////////////////////////////////////////////////
module os2wb_dual(
    input              clk,
    input              rstn,
    
    // Core interface 
    input      [  4:0] pcx_req,
    input              pcx_atom,
    input      [123:0] pcx_data,
    output reg [  4:0] pcx_grant,
    output reg         cpx_ready,
    output reg [144:0] cpx_packet,
    
    // Core 2nd interface 
    input      [  4:0] pcx1_req,
    input              pcx1_atom,
    input      [123:0] pcx1_data,
    output reg [  4:0] pcx1_grant,
    output reg         cpx1_ready,
    output reg [144:0] cpx1_packet,
    
    // Wishbone master interface
    input      [ 63:0] wb_data_i,
    input              wb_ack,
    output reg         wb_cycle,
    output reg         wb_strobe,
    output reg         wb_we,
    output reg [  7:0] wb_sel,
    output reg [ 63:0] wb_addr,
    output reg [ 63:0] wb_data_o,
    
    // FPU interface
    output reg [123:0] fp_pcx,
    output reg         fp_req,
    input      [144:0] fp_cpx,
    input              fp_rdy,
    
    // Ethernet interrupt, sensed on posedge, mapped to vector 'd29
    input              eth_int
);

reg [123:0] pcx_packet_d;    // Latched incoming PCX packet
reg [123:0] pcx_packet_2nd;  // Second packet for atomic (CAS)
reg [  4:0] pcx_req_d;       // Latched request
reg         pcx_atom_d;      // Latched atomic flasg
reg [  4:0] state;           // FSM state
reg [144:0] cpx_packet_1;    // First CPX packet
reg [144:0] cpx_packet_2;    // Second CPX packet (for atomics and cached IFILLs)
reg         cpx_two_packet;  // CPX answer is two-packet (!=atomic, SWAP has atomic==0 and answer is two-packet)

wire [111:0] inval_vect0; // Invalidate, instr/data, way
wire [111:0] inval_vect1; // IFill may cause two D lines invalidation at a time

wire [1:0] othercachehit;
wire [1:0] othercpuhit;
wire [1:0] wayval0;
wire [1:0] wayval1;

`define TEST_DRAM_1      5'b00000
`define TEST_DRAM_2      5'b00001
`define TEST_DRAM_3      5'b00010
`define TEST_DRAM_4      5'b00011
`define INIT_DRAM_1      5'b00100
`define INIT_DRAM_2      5'b00101
`define WAKEUP           5'b00110
`define PCX_IDLE         5'b00111
`define GOT_PCX_REQ      5'b01000
`define PCX_REQ_2ND      5'b01001
`define PCX_REQ_STEP1    5'b01010
`define PCX_REQ_STEP1_1  5'b01011
`define PCX_REQ_STEP2    5'b01100
`define PCX_REQ_STEP2_1  5'b01101
`define PCX_REQ_STEP3    5'b01110
`define PCX_REQ_STEP3_1  5'b01111
`define PCX_REQ_STEP4    5'b10000
`define PCX_REQ_STEP4_1  5'b10001
`define PCX_BIS          5'b10010
`define PCX_BIS_1        5'b10011
`define PCX_BIS_2        5'b10100
`define CPX_READY_1      5'b10101
`define CPX_READY_2      5'b10110
`define PCX_REQ_STEP1_2  5'b10111
`define PCX_UNKNOWN      5'b11000
`define PCX_FP_1         5'b11001
`define PCX_FP_2         5'b11010
`define FP_WAIT          5'b11011
`define CPX_FP           5'b11100
`define CPX_SEND_ETH_IRQ 5'b11101
`define CPX_INT_VEC_DIS  5'b11110
`define PCX_REQ_CAS_COMPARE 5'b11111

`define MEM_SIZE         64'h00000000_10000000

`define TEST_DRAM        1
`define DEBUGGING        1

reg        cache_init;
wire [3:0] dcache0_hit;
wire [3:0] dcache1_hit;
wire [3:0] icache_hit;
reg        multi_hit;
reg        multi_hit1;
reg        eth_int_d;
reg        eth_int_send;
reg        eth_int_sent;
reg  [3:0] cnt;

// PCX channel FIFO
wire [129:0] pcx_data_fifo;
wire         pcx_fifo_empty;
reg  [  4:0] pcx_req_1;
reg  [  4:0] pcx_req_2;
reg          pcx_atom_1;
reg          pcx_atom_2;
reg          pcx_data_123_d;

// PCX 2nf channel FIFO
wire [129:0] pcx1_data_fifo;
wire         pcx1_fifo_empty;
reg  [  4:0] pcx1_req_1;
reg  [  4:0] pcx1_req_2;
reg          pcx1_atom_1;
reg          pcx1_atom_2;
reg          pcx1_data_123_d;

always @(posedge clk)
   begin
      pcx_req_1<=pcx_req;
      pcx_atom_1<=pcx_atom;
      pcx_atom_2<=pcx_atom_1;
      pcx_req_2<=pcx_atom_1 ? pcx_req_1:5'b0;
      pcx_grant<=(pcx_req_1 | pcx_req_2);
      pcx_data_123_d<=pcx_data[123];

      pcx1_req_1<=pcx1_req;
      pcx1_atom_1<=pcx1_atom;
      pcx1_atom_2<=pcx1_atom_1;
      pcx1_req_2<=pcx1_atom_1 ? pcx1_req_1:5'b0;
      pcx1_grant<=(pcx1_req_1 | pcx1_req_2);
      pcx1_data_123_d<=pcx1_data[123];
   end
        
pcx_fifo pcx_fifo_inst( 
       // FIFO should be first word fall-through
       // It has no full flag as the core will send only limited number of requests,
       // in original design we used it 32 words deep
       // Just make it deeper if you experience overflow - 
       // you can't just send no grant on full because the core expects immediate
       // grant for at least two requests for each zone
    .aclr(!rstn),
    .clock(clk),
    .data({pcx_atom_1,pcx_req_1,pcx_data}),
    .rdreq(fifo_rd),
    .wrreq((pcx_req_1!=5'b00000 && pcx_data[123]) || (pcx_atom_2 && pcx_data_123_d)), 
       // Second atomic packet for FPU may be invalid, but should be sent to FPU
       // so if the first atomic packet is valid we latch both
    .empty(pcx_fifo_empty),
    .q(pcx_data_fifo)
);

pcx_fifo pcx_fifo_inst1( 
       // FIFO should be first word fall-through
       // It has no full flag as the core will send only limited number of requests,
       // in original design we used it 32 words deep
       // Just make it deeper if you experience overflow - 
       // you can't just send no grant on full because the core expects immediate
       // grant for at least two requests for each zone
    .aclr(!rstn),
    .clock(clk),
    .data({pcx1_atom_1,pcx1_req_1,pcx1_data}),
    .rdreq(fifo_rd1),
    .wrreq((pcx1_req_1!=5'b00000 && pcx1_data[123]) || (pcx1_atom_2 && pcx1_data_123_d)), 
       // Second atomic packet for FPU may be invalid, but should be sent to FPU
       // so if the first atomic packet is valid we latch both
    .empty(pcx1_fifo_empty),
    .q(pcx1_data_fifo)
);
// --------------------------

reg wb_ack_d;

always @(posedge clk or negedge rstn)
   if(!rstn)
      eth_int_send<=0;
   else
      begin
         wb_ack_d<=wb_ack;
         eth_int_d<=eth_int;
         if(eth_int && !eth_int_d)
            eth_int_send<=1;
         else
            if(eth_int_sent)
               eth_int_send<=0;
      end

reg fifo_rd;
reg fifo_rd1;
wire [123:0] pcx_packet;
assign pcx_packet=cpu ? pcx1_data_fifo[123:0]:pcx_data_fifo[123:0];
reg cpu;
reg cpu2;

always @(posedge clk or negedge rstn)
   if(rstn==0)
      begin
         if(`TEST_DRAM)
            state<=`TEST_DRAM_1;
         else
            state<=`INIT_DRAM_1; // DRAM initialization is mandatory!
         cpx_ready<=0;
         fifo_rd<=0;
         cpx_packet<=145'b0;
         wb_cycle<=0;
         wb_strobe<=0;
         wb_we<=0;
         wb_sel<=0;
         wb_addr<=64'b0;
         wb_data_o<=64'b0;
         pcx_packet_d<=124'b0;
         fp_pcx<=124'b0;
         fp_req<=0;
      end
   else
      case(state)
         `TEST_DRAM_1:
            begin
               wb_cycle<=1;
               wb_strobe<=1;
               wb_sel<=8'hFF;
               wb_we<=1;
               state<=`TEST_DRAM_2;
            end
         `TEST_DRAM_2:
            if(wb_ack)
               begin
                  wb_strobe<=0;
                  if(wb_addr<`MEM_SIZE-8)
                     begin
                        wb_addr[31:0]<=wb_addr[31:0]+8;
                        wb_data_o<={wb_addr[31:0]+8,wb_addr[31:0]+8};
                        state<=`TEST_DRAM_1;
                     end
                  else
                     begin
                        state<=`TEST_DRAM_3;
                        wb_cycle<=0;
                        wb_sel<=0;
                        wb_we<=0;
                        wb_data_o<=64'b0;
                        wb_addr<=64'b0;
                     end
               end               
         `TEST_DRAM_3:
            begin
               wb_cycle<=1;
               wb_strobe<=1;
               wb_sel<=8'hFF;
               state<=`TEST_DRAM_4;
            end
         `TEST_DRAM_4:
            if(wb_ack)
               begin
                  wb_strobe<=0;
                  if(wb_addr<`MEM_SIZE-8)
                     begin
                        if(wb_data_i=={wb_addr[31:0],wb_addr[31:0]})
                           begin
                              wb_addr[31:0]<=wb_addr[31:0]+8;
                              state<=`TEST_DRAM_3;
                           end
                     end
                  else
                     begin
                        state<=`INIT_DRAM_1;
                        wb_cycle<=0;
                        wb_sel<=0;
                        wb_we<=0;
                        wb_data_o<=64'b0;
                        wb_addr<=64'b0;
                     end
               end               
         `INIT_DRAM_1:
            begin
               wb_cycle<=1;
               wb_strobe<=1;
               wb_sel<=8'hFF;
               wb_we<=1;
               cache_init<=1; // We also init cache directories here
               state<=`INIT_DRAM_2;
            end
         `INIT_DRAM_2:
            if(wb_ack)
               begin
                  wb_strobe<=0;
                  if(wb_addr<`MEM_SIZE-8)
                     begin
                        wb_addr[31:0]<=wb_addr[31:0]+8;
                        pcx_packet_d[64+11:64+4]<=pcx_packet_d[64+11:64+4]+1; // Address for cachedir init
                        state<=`INIT_DRAM_1;
                     end
                  else
                     begin
                        state<=`WAKEUP;
                        wb_cycle<=0;
                        wb_sel<=0;
                        wb_we<=0;
                        cache_init<=0;
                        wb_addr<=64'b0;
                     end
               end               
         `WAKEUP:
            begin
               cpx_packet<=145'h1700000000000000000000000000000010001;
               cpx_ready<=1;
               state<=`PCX_IDLE;
            end
         `PCX_IDLE:
            begin
               cnt<=0;
               cpx_packet<=145'b0;
               cpx_ready<=0;
               cpx1_packet<=145'b0;
               cpx1_ready<=0;
               cpx_two_packet<=0;
               multi_hit<=0;
               multi_hit1<=0;
               if(eth_int_send)
                  begin
                     state<=`CPX_SEND_ETH_IRQ;
                     eth_int_sent<=1;
                  end
               else
                  if(!pcx_fifo_empty)
                     begin
                        pcx_req_d<=pcx_data_fifo[128:124];
                        pcx_atom_d<=pcx_data_fifo[129];
                        fifo_rd<=1;
                        state<=`GOT_PCX_REQ;
								cpu<=0;
								cpu2<=0;
                     end
						else
                     if(!pcx1_fifo_empty)
                        begin
                           pcx_req_d<=pcx1_data_fifo[128:124];
                           pcx_atom_d<=pcx1_data_fifo[129];
                           fifo_rd1<=1;
                           state<=`GOT_PCX_REQ;
						   		cpu<=1;
									cpu2<=1;
                        end
            end
         `GOT_PCX_REQ:
            begin
               pcx_packet_d<=pcx_packet;
               if(`DEBUGGING)
                  begin
                     wb_sel[1:0]<=pcx_packet[113:112];
                     wb_sel[2]<=1;
                  end
               if(pcx_packet[103:64]==40'h9800000800 && pcx_packet[122:118]==5'b00001)
                  begin
                     state<=`CPX_INT_VEC_DIS;
                     fifo_rd<=0;
							fifo_rd1<=0;
                  end
               else
                  if(pcx_atom_d==0)
                     begin
                        fifo_rd<=0;
								fifo_rd1<=0;
                        if(pcx_packet[122:118]==5'b01010) // FP req
                           begin
                              state<=`PCX_FP_1;
                              pcx_packet_2nd[123]<=0;
                           end
                        else
                           state<=`PCX_REQ_STEP1;
                     end
                  else
                     state<=`PCX_REQ_2ND;
            end
         `PCX_REQ_2ND:
            begin
               pcx_packet_2nd<=pcx_packet; //Latch second packet for atomics
               if(`DEBUGGING)
                  if(pcx_fifo_empty)
                     wb_sel<=8'h67;
               fifo_rd<=0;
					fifo_rd1<=0;
               if(pcx_packet_d[122:118]==5'b01010) // FP req
                  state<=`PCX_FP_1;
               else               
                  state<=`PCX_REQ_STEP1;
            end
         `PCX_REQ_STEP1:
            begin
               if(pcx_packet_d[111]==1'b1) // Invalidate request
                  begin
                     cpx_packet_1[144]<=1;     // Valid
                     cpx_packet_1[143:140]<=4'b0100; // Invalidate reply is Store ACK
                     cpx_packet_1[139]<=1;     // L2 miss
                     cpx_packet_1[138:137]<=0; // Error
                     cpx_packet_1[136]<=pcx_packet_d[117]; // Non-cacheble
                     cpx_packet_1[135:134]<=pcx_packet_d[113:112]; // Thread ID
                     cpx_packet_1[133:131]<=0; // Way valid
                     cpx_packet_1[130]<=((pcx_packet_d[122:118]==5'b10000) && (pcx_req_d==5'b10000)) ? 1:0; // Four byte fill
                     cpx_packet_1[129]<=pcx_atom_d;
                     cpx_packet_1[128]<=pcx_packet_d[110]; // Prefetch
                     cpx_packet_1[127:0]<={2'b0,pcx_packet_d[109]/*BIS*/,pcx_packet_d[122:118]==5'b00000 ? 2'b01:2'b10,pcx_packet_d[64+5:64+4],2'b0,cpu,pcx_packet_d[64+11:64+6],112'b0};
                     state<=`CPX_READY_1;
                  end
               else
                  if(pcx_packet_d[122:118]!=5'b01001) // Not INT
                     begin
                        wb_cycle<=1'b1;
                        wb_strobe<=1'b1;
                        if((pcx_packet_d[122:118]==5'b00000 && !pcx_req_d[4]) || pcx_packet_d[122:118]==5'b00010 || pcx_packet_d[122:118]==5'b00100 || pcx_packet_d[122:118]==5'b00110)
                           wb_addr<={pcx_req_d,19'b0,pcx_packet_d[103:64+4],4'b0000}; //DRAM load/streamload, CAS and SWAP always use DRAM and load first 
                        else
                           if(pcx_packet_d[122:118]==5'b10000 && !pcx_req_d[4])
                              wb_addr<={pcx_req_d,19'b0,pcx_packet_d[103:64+5],5'b00000}; //DRAM ifill
                           else
                              if(pcx_packet_d[64+39:64+28]==12'hFFF && pcx_packet_d[64+27:64+24]!=4'b0) // flash remap FFF1->FFF8
                                 wb_addr<={pcx_req_d,19'b0,pcx_packet_d[103:64+3]+37'h0000E00000,3'b000};
                              else
                                 wb_addr<={pcx_req_d,19'b0,pcx_packet_d[103:64+3],3'b000};
                        wb_data_o<=pcx_packet_d[63:0];
                        state<=`PCX_REQ_STEP1_1;
                     end
                  else
                     //if((pcx_packet_d[12:10]!=3'b000) && !pcx_packet_d[117]) // Not FLUSH int and not this core
                     //   state<=`PCX_IDLE; 
                     //else
                        state<=`CPX_READY_1;
               case(pcx_packet_d[122:118]) // Packet type
                  5'b00000://Load
                     begin
                        wb_we<=0;
                        if(!pcx_req_d[4])
                           wb_sel<=8'b11111111; // DRAM requests are always 128 bit
                        else
                           case(pcx_packet_d[106:104]) //Size
                              3'b000://Byte
                                 case(pcx_packet_d[64+2:64])
                                    3'b000:wb_sel<=8'b10000000;
                                    3'b001:wb_sel<=8'b01000000;
                                    3'b010:wb_sel<=8'b00100000;
                                    3'b011:wb_sel<=8'b00010000;
                                    3'b100:wb_sel<=8'b00001000;
                                    3'b101:wb_sel<=8'b00000100;
                                    3'b110:wb_sel<=8'b00000010;
                                    3'b111:wb_sel<=8'b00000001;
                                 endcase
                              3'b001://Halfword
                                 case(pcx_packet_d[64+2:64+1])
                                    2'b00:wb_sel<=8'b11000000;
                                    2'b01:wb_sel<=8'b00110000;
                                    2'b10:wb_sel<=8'b00001100;
                                    2'b11:wb_sel<=8'b00000011;
                                 endcase
                              3'b010://Word
                                 wb_sel<=(pcx_packet_d[64+2]==0) ? 8'b11110000:8'b00001111;
                              3'b011://Doubleword
                                 wb_sel<=8'b11111111;
                              3'b100://Quadword
                                 wb_sel<=8'b11111111;
                              3'b111://Cacheline
                                 wb_sel<=8'b11111111;
                              default:
                                 wb_sel<=8'b01011010; // Unreal eye-catching value for debug
                           endcase
                     end
                  5'b00001://Store
                     begin
                        wb_we<=1;
                        if(pcx_packet_d[110:109]!=2'b00) //Block (or init) store
                           wb_sel<=8'b11111111; // Blocks are always 64 bit
                        else
                           case(pcx_packet_d[106:104]) //Size
                              3'b000://Byte
                                 case(pcx_packet_d[64+2:64])
                                    3'b000:wb_sel<=8'b10000000;
                                    3'b001:wb_sel<=8'b01000000;
                                    3'b010:wb_sel<=8'b00100000;
                                    3'b011:wb_sel<=8'b00010000;
                                    3'b100:wb_sel<=8'b00001000;
                                    3'b101:wb_sel<=8'b00000100;
                                    3'b110:wb_sel<=8'b00000010;
                                    3'b111:wb_sel<=8'b00000001;
                                 endcase
                              3'b001://Halfword
                                 case(pcx_packet_d[64+2:64+1])
                                    2'b00:wb_sel<=8'b11000000;
                                    2'b01:wb_sel<=8'b00110000;
                                    2'b10:wb_sel<=8'b00001100;
                                    2'b11:wb_sel<=8'b00000011;
                                 endcase
                              3'b010://Word
                                 wb_sel<=(pcx_packet_d[64+2]==0) ? 8'b11110000:8'b00001111;
                              3'b011://Doubleword
                                 wb_sel<=8'b11111111;
                              default:
                                 if(`DEBUGGING)
                                    wb_sel<=8'b01011010; // Unreal eye-catching value for debug
                           endcase
                     end
                  5'b00010://CAS
                     begin
                        wb_we<=0; //Load first
                        wb_sel<=8'b11111111; // CAS loads are as cacheline
                     end
                  5'b00100://STRLOAD
                     begin
                        wb_we<=0;
                        wb_sel<=8'b11111111; // Stream loads are always 128 bit
                     end
                  5'b00101://STRSTORE
                     begin
                        wb_we<=1;
                        case(pcx_packet_d[106:104]) //Size
                           3'b000://Byte
                              case(pcx_packet_d[64+2:64])
                                 3'b000:wb_sel<=8'b10000000;
                                 3'b001:wb_sel<=8'b01000000;
                                 3'b010:wb_sel<=8'b00100000;
                                 3'b011:wb_sel<=8'b00010000;
                                 3'b100:wb_sel<=8'b00001000;
                                 3'b101:wb_sel<=8'b00000100;
                                 3'b110:wb_sel<=8'b00000010;
                                 3'b111:wb_sel<=8'b00000001;
                              endcase
                           3'b001://Halfword
                              case(pcx_packet_d[64+2:64+1])
                                 2'b00:wb_sel<=8'b11000000;
                                 2'b01:wb_sel<=8'b00110000;
                                 2'b10:wb_sel<=8'b00001100;
                                 2'b11:wb_sel<=8'b00000011;
                              endcase
                           3'b010://Word
                              wb_sel<=(pcx_packet_d[64+2]==0) ? 8'b11110000:8'b00001111;
                           3'b011://Doubleword
                              wb_sel<=8'b11111111;
                           3'b100://Quadword
                              wb_sel<=8'b11111111;
                           3'b111://Cacheline
                              wb_sel<=8'b11111111;
                           default:
                              wb_sel<=8'b01011010; // Unreal eye-catching value for debug
                        endcase
                     end
                  5'b00110://SWAP/LDSTUB
                     begin
                        wb_we<=0; // Load first, as CAS
                        wb_sel<=8'b11111111; // SWAP/LDSTUB loads are as cacheline
                     end
                  5'b01001://INT
                     if(pcx_packet_d[117]) // Flush
							   begin
                           cpx_packet_1<={9'h171,pcx_packet_d[113:112],11'h0,pcx_packet_d[64+5:64+4],2'b0,cpu,pcx_packet_d[64+11:64+6],30'h0,pcx_packet_d[17:0],46'b0,pcx_packet_d[17:0]}; //FLUSH instruction answer
                           //cpx_packet_2<={9'h171,pcx_packet_d[113:112],11'h0,pcx_packet_d[64+5:64+4],2'b0,cpu,pcx_packet_d[64+11:64+6],30'h0,pcx_packet_d[17:0],46'b0,pcx_packet_d[17:0]}; //FLUSH instruction answer
									//cpx_two_packet<=1;
									//cpu2<=!cpu; // Flush should be sent to both cores
								end
                     else // Tread-to-thread interrupt
							   begin
                           cpx_packet_1<={9'h170,pcx_packet_d[113:112],52'h0,pcx_packet_d[17:0],46'h0,pcx_packet_d[17:0]}; 
									cpu<=pcx_packet_d[10];
							   end
                  //5'b01010: FP1 - processed by separate state
                  //5'b01011: FP2 - processed by separate state
                  //5'b01101: FWDREQ - not implemented
                  //5'b01110: FWDREPL - not implemented
                  5'b10000://IFILL
                     begin
                        wb_we<=0;
                        if(pcx_req_d[4]) // I/O access
                           wb_sel<=(pcx_packet_d[64+2]==0) ? 8'b11110000:8'b00001111;
                        else
                           wb_sel<=8'b11111111;
                     end
                  default:
                     begin
                        wb_we<=0;
                        wb_sel<=8'b10101010; // Unreal eye-catching value for debug
                     end
               endcase
            end
         `PCX_REQ_STEP1_1:
            state<=`PCX_REQ_STEP1_2; // Delay for L1 directory
         `PCX_REQ_STEP1_2:
            begin
               if(wb_ack || wb_ack_d)
                  begin
                     cpx_packet_1[144]<=1;     // Valid
                     cpx_packet_1[139]<=(pcx_packet_d[122:118]==5'b00000) || (pcx_packet_d[122:118]==5'b10000) ? 1:0;     // L2 always miss on load and ifill
                     cpx_packet_1[138:137]<=0; // Error
                     cpx_packet_1[136]<=pcx_packet_d[117] || (pcx_packet_d[122:118]==5'b00001) ? 1:0; // Non-cacheble is set on store too
                     cpx_packet_1[135:134]<=pcx_packet_d[113:112]; // Thread ID
                     if((pcx_packet_d[122:118]==5'b00000 && !pcx_packet_d[117] && !pcx_packet_d[110]) || (pcx_packet_d[122:118]==5'b10000)) // Cacheble Load or IFill
                        cpx_packet_1[133:131]<={othercachehit[0],wayval0};
                     else
                        cpx_packet_1[133:131]<=3'b000; // Way valid
                     if(pcx_packet_d[122:118]==5'b00100) // Strload
                        cpx_packet_1[130]<=pcx_packet_d[106]; // A
                     else
                        if(pcx_packet_d[122:118]==5'b00101) // Stream store
                           cpx_packet_1[130]<=pcx_packet_d[108]; // A
                        else
                           cpx_packet_1[130]<=((pcx_packet_d[122:118]==5'b10000) && pcx_req_d[4]) ? 1:0; // Four byte fill
                     if(pcx_packet_d[122:118]==5'b00100) // Strload
                        cpx_packet_1[129]<=pcx_packet_d[105]; // B
                     else      
                        cpx_packet_1[129]<=pcx_atom_d || (pcx_packet_d[122:118]==5'b00110); // SWAP is single-packet but needs atom in CPX
                     cpx_packet_1[128]<=pcx_packet_d[110] && pcx_packet_d[122:118]==5'b00000; // Prefetch
                     cpx_packet_2[144]<=1;     // Valid
                     cpx_packet_2[139]<=0;     // L2 miss
                     cpx_packet_2[138:137]<=0; // Error
                     cpx_packet_2[136]<=pcx_packet_d[117] || (pcx_packet_d[122:118]==5'b00001) ? 1:0; // Non-cacheble is set on store too
                     cpx_packet_2[135:134]<=pcx_packet_d[113:112]; // Thread ID
                     if(pcx_packet_d[122:118]==5'b10000) // IFill
                        cpx_packet_2[133:131]<={othercachehit[1],wayval1};
                     else
                        cpx_packet_2[133:131]<=3'b000; // Way valid
                     cpx_packet_2[130]<=0; // Four byte fill
                     cpx_packet_2[129]<=pcx_atom_d || (pcx_packet_d[122:118]==5'b00110) || ((pcx_packet_d[122:118]==5'b10000) && !pcx_req_d[4]);
                     cpx_packet_2[128]<=0; // Prefetch
                     wb_strobe<=0;
                     wb_sel<=8'b0;
                     wb_addr<=64'b0;
                     wb_data_o<=64'b0;
                     wb_we<=0;
                     case(pcx_packet_d[122:118]) // Packet type
                        5'b00000://Load
                           begin
                              cpx_packet_1[143:140]<=4'b0000; // Type
                              if(!pcx_req_d[4])
                                 begin
                                    cpx_packet_1[127:0]<={wb_data_i,wb_data_i};   
                                    state<=`PCX_REQ_STEP2;
                                 end
                              else
                                 case(pcx_packet_d[106:104]) //Size
                                    3'b000://Byte
                                       begin
                                          case(pcx_packet_d[64+2:64])
                                             3'b000:cpx_packet_1[127:0]<={wb_data_i[63:56],wb_data_i[63:56],wb_data_i[63:56],wb_data_i[63:56],wb_data_i[63:56],wb_data_i[63:56],wb_data_i[63:56],wb_data_i[63:56],wb_data_i[63:56],wb_data_i[63:56],wb_data_i[63:56],wb_data_i[63:56],wb_data_i[63:56],wb_data_i[63:56],wb_data_i[63:56],wb_data_i[63:56]};
                                             3'b001:cpx_packet_1[127:0]<={wb_data_i[55:48],wb_data_i[55:48],wb_data_i[55:48],wb_data_i[55:48],wb_data_i[55:48],wb_data_i[55:48],wb_data_i[55:48],wb_data_i[55:48],wb_data_i[55:48],wb_data_i[55:48],wb_data_i[55:48],wb_data_i[55:48],wb_data_i[55:48],wb_data_i[55:48],wb_data_i[55:48],wb_data_i[55:48]};
                                             3'b010:cpx_packet_1[127:0]<={wb_data_i[47:40],wb_data_i[47:40],wb_data_i[47:40],wb_data_i[47:40],wb_data_i[47:40],wb_data_i[47:40],wb_data_i[47:40],wb_data_i[47:40],wb_data_i[47:40],wb_data_i[47:40],wb_data_i[47:40],wb_data_i[47:40],wb_data_i[47:40],wb_data_i[47:40],wb_data_i[47:40],wb_data_i[47:40]};
                                             3'b011:cpx_packet_1[127:0]<={wb_data_i[39:32],wb_data_i[39:32],wb_data_i[39:32],wb_data_i[39:32],wb_data_i[39:32],wb_data_i[39:32],wb_data_i[39:32],wb_data_i[39:32],wb_data_i[39:32],wb_data_i[39:32],wb_data_i[39:32],wb_data_i[39:32],wb_data_i[39:32],wb_data_i[39:32],wb_data_i[39:32],wb_data_i[39:32]};
                                             3'b100:cpx_packet_1[127:0]<={wb_data_i[31:24],wb_data_i[31:24],wb_data_i[31:24],wb_data_i[31:24],wb_data_i[31:24],wb_data_i[31:24],wb_data_i[31:24],wb_data_i[31:24],wb_data_i[31:24],wb_data_i[31:24],wb_data_i[31:24],wb_data_i[31:24],wb_data_i[31:24],wb_data_i[31:24],wb_data_i[31:24],wb_data_i[31:24]};
                                             3'b101:cpx_packet_1[127:0]<={wb_data_i[23:16],wb_data_i[23:16],wb_data_i[23:16],wb_data_i[23:16],wb_data_i[23:16],wb_data_i[23:16],wb_data_i[23:16],wb_data_i[23:16],wb_data_i[23:16],wb_data_i[23:16],wb_data_i[23:16],wb_data_i[23:16],wb_data_i[23:16],wb_data_i[23:16],wb_data_i[23:16],wb_data_i[23:16]};
                                             3'b110:cpx_packet_1[127:0]<={wb_data_i[15: 8],wb_data_i[15: 8],wb_data_i[15: 8],wb_data_i[15: 8],wb_data_i[15: 8],wb_data_i[15: 8],wb_data_i[15: 8],wb_data_i[15: 8],wb_data_i[15: 8],wb_data_i[15: 8],wb_data_i[15: 8],wb_data_i[15: 8],wb_data_i[15: 8],wb_data_i[15: 8],wb_data_i[15: 8],wb_data_i[15: 8]};
                                             3'b111:cpx_packet_1[127:0]<={wb_data_i[ 7: 0],wb_data_i[ 7: 0],wb_data_i[ 7: 0],wb_data_i[ 7: 0],wb_data_i[ 7: 0],wb_data_i[ 7: 0],wb_data_i[ 7: 0],wb_data_i[ 7: 0],wb_data_i[ 7: 0],wb_data_i[ 7: 0],wb_data_i[ 7: 0],wb_data_i[ 7: 0],wb_data_i[ 7: 0],wb_data_i[ 7: 0],wb_data_i[ 7: 0],wb_data_i[ 7: 0]};
                                          endcase                      
                                          wb_cycle<=0;
                                          state<=`CPX_READY_1;
                                       end
                                    3'b001://Halfword
                                       begin
                                          case(pcx_packet_d[64+2:64+1])
                                             2'b00:cpx_packet_1[127:0]<={wb_data_i[63:48],wb_data_i[63:48],wb_data_i[63:48],wb_data_i[63:48],wb_data_i[63:48],wb_data_i[63:48],wb_data_i[63:48],wb_data_i[63:48]};
                                             2'b01:cpx_packet_1[127:0]<={wb_data_i[47:32],wb_data_i[47:32],wb_data_i[47:32],wb_data_i[47:32],wb_data_i[47:32],wb_data_i[47:32],wb_data_i[47:32],wb_data_i[47:32]};
                                             2'b10:cpx_packet_1[127:0]<={wb_data_i[31:16],wb_data_i[31:16],wb_data_i[31:16],wb_data_i[31:16],wb_data_i[31:16],wb_data_i[31:16],wb_data_i[31:16],wb_data_i[31:16]};
                                             2'b11:cpx_packet_1[127:0]<={wb_data_i[15: 0],wb_data_i[15: 0],wb_data_i[15: 0],wb_data_i[15: 0],wb_data_i[15: 0],wb_data_i[15: 0],wb_data_i[15: 0],wb_data_i[15: 0]};
                                          endcase                     
                                          wb_cycle<=0;
                                          state<=`CPX_READY_1;
                                       end
                                    3'b010://Word
                                       begin
                                          if(pcx_packet_d[64+2]==0)
                                             cpx_packet_1[127:0]<={wb_data_i[63:32],wb_data_i[63:32],wb_data_i[63:32],wb_data_i[63:32]};
                                          else
                                             cpx_packet_1[127:0]<={wb_data_i[31:0],wb_data_i[31:0],wb_data_i[31:0],wb_data_i[31:0]};
                                          wb_cycle<=0;
                                          state<=`CPX_READY_1;
                                       end
                                    3'b011://Doubleword
                                       begin
                                          cpx_packet_1[127:0]<={wb_data_i,wb_data_i};   
                                          wb_cycle<=0;
                                          state<=`CPX_READY_1;
                                       end
                                    3'b100://Quadword
                                       begin
                                          cpx_packet_1[127:0]<={wb_data_i,wb_data_i};   
                                          wb_cycle<=0;
                                          state<=`CPX_READY_1; // 16 byte access to PROM should just duplicate the data
                                       end
                                    3'b111://Cacheline
                                       begin
                                          cpx_packet_1[127:0]<={wb_data_i,wb_data_i};   
                                          wb_cycle<=0;
                                          state<=`CPX_READY_1; // 16 byte access to PROM should just duplicate the data
                                       end
                                    default:
                                       begin
                                          cpx_packet_1[127:0]<={wb_data_i,wb_data_i};   
                                          wb_cycle<=0;
                                          state<=`PCX_UNKNOWN;
                                       end
                                 endcase
                           end
                        5'b00001://Store
                           begin
                              cpx_packet_1[143:140]<=4'b0100; // Type
                              cpx_packet_1[127:0]<={2'b0,pcx_packet_d[109]/*BIS*/,2'b0,pcx_packet_d[64+5:64+4],2'b0,cpu,pcx_packet_d[64+11:64+6],inval_vect0};
//                              if((pcx_packet_d[110:109]==2'b01) && (pcx_packet_d[64+5:64]==0) && !inval_vect0[3] && !inval_vect1[3]) // Block init store
//                                 state<=`PCX_BIS;
//                              else
//                                 begin
                                    wb_cycle<=0;
                                    state<=`CPX_READY_1;
//                                 end
                           end
                        5'b00010://CAS
                           begin
                              cpx_packet_1[143:140]<=4'b0000; // Load return for first packet
                              cpx_packet_2[143:140]<=4'b0100; // Store ACK for second packet
                              cpx_packet_2[127:0]<={5'b0,pcx_packet_d[64+5:64+4],2'b0,cpu,pcx_packet_d[64+11:64+6],inval_vect0};
                              cpx_packet_1[127:0]<={wb_data_i,wb_data_i};
                              state<=`PCX_REQ_STEP2;
                           end
                        5'b00100://STRLOAD
                           begin
                              cpx_packet_1[143:140]<=4'b0010; // Type
                              cpx_packet_1[127:0]<={wb_data_i,wb_data_i};
                              state<=`PCX_REQ_STEP2;
                           end
                        5'b00101://STRSTORE
                           begin
                              cpx_packet_1[143:140]<=4'b0110; // Type
                              cpx_packet_1[127:0]<={5'b0,pcx_packet_d[64+5:64+4],2'b0,cpu,pcx_packet_d[64+11:64+6],inval_vect0};
                              wb_cycle<=0;
                              state<=`CPX_READY_1;
                           end
                        5'b00110://SWAP/LDSTUB
                           begin
                              cpx_packet_1[143:140]<=4'b0000; // Load return for first packet
                              cpx_packet_2[143:140]<=4'b0100; // Store ACK for second packet
                              cpx_packet_2[127:0]<={5'b0,pcx_packet_d[64+5:64+4],2'b0,cpu,pcx_packet_d[64+11:64+6],inval_vect0};
                              cpx_packet_1[127:0]<={wb_data_i,wb_data_i};
                              state<=`PCX_REQ_STEP2; 
                           end
                        5'b10000://IFILL
                           begin
                              cpx_packet_1[143:140]<=4'b0001; // Type
                              cpx_packet_2[143:140]<=4'b0001; // Type
                              if(pcx_req_d[4]) // I/O access
                                 begin
                                    if(pcx_packet_d[64+2]==0)
                                       cpx_packet_1[127:0]<={wb_data_i[63:32],wb_data_i[63:32],wb_data_i[63:32],wb_data_i[63:32]};
                                    else
                                       cpx_packet_1[127:0]<={wb_data_i[31:0],wb_data_i[31:0],wb_data_i[31:0],wb_data_i[31:0]};
                                    state<=`CPX_READY_1;
                                    wb_cycle<=0; 
                                 end
                              else
                                 begin
                                    cpx_packet_1[127:0]<={wb_data_i,wb_data_i};
                                    state<=`PCX_REQ_STEP2;
                                 end
                           end
                        default:
                           begin
                              wb_cycle<=0;
                              state<=`PCX_UNKNOWN;
                           end
                     endcase
                  end               
               end
         `PCX_REQ_STEP2: // IFill, Load/strload, CAS, SWAP, LDSTUB - alwas load
            begin
               wb_strobe<=1'b1;
               if(pcx_packet_d[122:118]==5'b10000)
                  wb_addr<={pcx_req_d,19'b0,pcx_packet_d[103:64+5],5'b01000};
               else
                  wb_addr<={pcx_req_d,19'b0,pcx_packet_d[103:64+4],4'b1000};
               wb_sel<=8'b11111111; // It is always full width for subsequent IFill and load accesses
               state<=`PCX_REQ_STEP2_1;
            end
         `PCX_REQ_STEP2_1:
            if(wb_ack==1)
               begin
                  wb_strobe<=0;
                  wb_sel<=8'b0;
                  wb_addr<=64'b0;
                  wb_data_o<=64'b0;
                  wb_we<=0;
                  cpx_packet_1[63:0]<=wb_data_i;
                  if((pcx_packet_d[122:118]!=5'b00000) && (pcx_packet_d[122:118]!=5'b00100))
                     if(pcx_packet_d[122:118]!=5'b00010) // IFill, SWAP
                        state<=`PCX_REQ_STEP3;
                     else
                        state<=`PCX_REQ_CAS_COMPARE; // CAS
                  else
                     begin
                        wb_cycle<=0;
                        state<=`CPX_READY_1;
                     end
               end
         `PCX_REQ_CAS_COMPARE:
            begin
               cpx_two_packet<=1;
               if(pcx_packet_d[106:104]==3'b010) // 32-bit
                  case(pcx_packet_d[64+3:64+2])
                     2'b00:state<=cpx_packet_1[127:96]==pcx_packet_d[63:32] ? `PCX_REQ_STEP3:`CPX_READY_1;
                     2'b01:state<=cpx_packet_1[95:64]==pcx_packet_d[63:32] ? `PCX_REQ_STEP3:`CPX_READY_1;
                     2'b10:state<=cpx_packet_1[63:32]==pcx_packet_d[63:32] ? `PCX_REQ_STEP3:`CPX_READY_1;
                     2'b11:state<=cpx_packet_1[31:0]==pcx_packet_d[63:32] ? `PCX_REQ_STEP3:`CPX_READY_1;
                  endcase
               else
                  if(pcx_packet_d[64+3]==0)
                     state<=cpx_packet_1[127:64]==pcx_packet_d[63:0] ? `PCX_REQ_STEP3:`CPX_READY_1;
                  else
                     state<=cpx_packet_1[63:0]==pcx_packet_d[63:0] ? `PCX_REQ_STEP3:`CPX_READY_1;
            end
         `PCX_REQ_STEP3: // 256-bit IFILL; CAS, SWAP and LDSTUB store
            begin
               if(pcx_packet_d[122:118]==5'b10000)
                  wb_addr<={pcx_req_d,19'b0,pcx_packet_d[103:64+5],5'b10000};
               else
                  wb_addr<={pcx_req_d,19'b0,pcx_packet_d[103:64+3],3'b000}; // CAS or SWAP save
               cpx_two_packet<=1;
               if(pcx_packet_d[122:118]==5'b10000)
                  wb_we<=0;
               else
                  wb_we<=1;
               wb_strobe<=1'b1;
               if(pcx_packet_d[122:118]==5'b00010) // CAS
                  if(pcx_packet_d[106:104]==3'b010)
                     wb_sel<=(pcx_packet_d[64+2]==0) ? 8'b11110000:8'b00001111;
                  else
                     wb_sel<=8'b11111111; //CASX
               else
                  if(pcx_packet_d[122:118]==5'b00110) //SWAP or LDSTUB
                     if(pcx_packet_d[106:104]==3'b000)  //LDSTUB
                        case(pcx_packet_d[64+2:64])
                           3'b000:wb_sel<=8'b10000000;
                           3'b001:wb_sel<=8'b01000000;
                           3'b010:wb_sel<=8'b00100000;
                           3'b011:wb_sel<=8'b00010000;
                           3'b100:wb_sel<=8'b00001000;
                           3'b101:wb_sel<=8'b00000100;
                           3'b110:wb_sel<=8'b00000010;
                           3'b111:wb_sel<=8'b00000001;
                        endcase
                     else   
                        wb_sel<=(pcx_packet_d[64+2]==0) ? 8'b11110000:8'b00001111; ///SWAP is always 32-bit
                  else
                     wb_sel<=8'b11111111; // It is always full width for subsequent IFill accesses
               if(pcx_packet_d[122:118]==5'b00110) //SWAP or LDSTUB
                  wb_data_o<={pcx_packet_d[63:32],pcx_packet_d[63:32]};
//                  wb_data_o<=pcx_packet_d[63:0];
               else
                  wb_data_o<=pcx_packet_2nd[63:0]; // CAS store second packet data
//                  if(pcx_packet_d[106:104]==3'b010)
//                     wb_data_o<={pcx_packet_2nd[63:32],pcx_packet_2nd[63:32]}; // CAS store second packet data
//                  else
//                     wb_data_o<=pcx_packet_2nd[63:0];
               state<=`PCX_REQ_STEP3_1;
            end
         `PCX_REQ_STEP3_1:
            if(wb_ack==1)
               begin
                  wb_strobe<=0;
                  wb_sel<=8'b0;
                  wb_addr<=64'b0;
                  wb_we<=0;
                  wb_data_o<=64'b0;
                  if(pcx_packet_d[122:118]==5'b10000) // IFill
                     begin
                        cpx_packet_2[127:64]<=wb_data_i;
                        state<=`PCX_REQ_STEP4;
                     end
                  else
                     begin
                        wb_cycle<=0;
                        state<=`CPX_READY_1;
                     end
               end
         `PCX_REQ_STEP4: // 256-bit IFILL only
            begin
               wb_strobe<=1'b1;
               wb_addr<={pcx_req_d,19'b0,pcx_packet_d[103:64+5],5'b11000};
               wb_sel<=8'b11111111; // It is always full width for subsequent accesses
               state<=`PCX_REQ_STEP4_1;
            end 
         `PCX_REQ_STEP4_1:
            if(wb_ack==1)  
               begin
                  wb_cycle<=0;
                  wb_strobe<=0;
                  wb_sel<=8'b0;
                  wb_addr<=64'b0;
                  wb_we<=0;
                  cpx_packet_2[63:0]<=wb_data_i;
                  state<=`CPX_READY_1;
               end
         `PCX_BIS: // Block init store
            begin
               wb_strobe<=1'b1;
               wb_we<=1;
               wb_addr<={pcx_req_d,19'b0,pcx_packet_d[103:64+6],6'b001000};
               wb_sel<=8'b11111111;
               wb_data_o<=64'b0;
               state<=`PCX_BIS_1;
            end
         `PCX_BIS_1:
            if(wb_ack)
               begin
                  wb_strobe<=0;
                  if(wb_addr[39:0]<(pcx_packet_d[64+39:64]+8*7))
                     state<=`PCX_BIS_2;
                  else
                     begin
                        wb_cycle<=0;
                        wb_sel<=0;
                        wb_we<=0;
                        wb_addr<=64'b0;
                        state<=`CPX_READY_1;
                     end
               end
         `PCX_BIS_2:
            begin
               wb_strobe<=1'b1;
               wb_addr[5:0]<=wb_addr[5:0]+8;
               state<=`PCX_BIS_1;
            end
         `PCX_FP_1:
            begin
               fp_pcx<=pcx_packet_d;
               fp_req<=1;
               state<=`PCX_FP_2;
               if(`DEBUGGING)
                  begin
                     wb_addr<=pcx_packet_d[103:64];
                     wb_data_o<=pcx_packet_d[63:0];
                     wb_sel<=8'h22;
                  end
            end
         `PCX_FP_2:
            begin
               fp_pcx<=pcx_packet_2nd;
               state<=`FP_WAIT;
               if(`DEBUGGING)
                  begin
                     wb_addr<=pcx_packet_2nd[103:64];
                     wb_data_o<=pcx_packet_d[63:0];
                     wb_sel<=8'h23;
                  end
            end
         `FP_WAIT:
            begin
               fp_pcx<=124'b0;
               fp_req<=0;
               if(fp_rdy)
                  state<=`CPX_FP;
               if(`DEBUGGING)
                  wb_sel<=8'h24;
            end
         `CPX_FP:
            if(fp_cpx[144]) // Packet valid
               begin               
                  cpx_packet_1<=fp_cpx;
                  state<=`CPX_READY_1;
                  if(`DEBUGGING)
                     begin
                        wb_addr<=fp_cpx[63:0];
                        wb_data_o<=fp_cpx[127:64];
                     end
               end
            else
               if(!fp_rdy)
                  state<=`FP_WAIT; // Else wait for another one if it is not here still
         `CPX_SEND_ETH_IRQ:
            begin
               cpx_packet_1<=145'h1_7_000_000000000000001D_000000000000_001D;
               eth_int_sent<=0;
               state<=`CPX_READY_1;
            end
         `CPX_INT_VEC_DIS:
            begin
               //if(pcx_packet_d[12:10]==3'b000) // Send interrupt only if it is for this core
                  cpx_two_packet<=1; 
				   cpu2<=pcx_packet_d[10];
               cpx_packet_1[144:140]<=5'b10100;
               cpx_packet_1[139:137]<=0;
               cpx_packet_1[136]<=1;
               cpx_packet_1[135:134]<=pcx_packet_d[113:112]; // Thread ID
               cpx_packet_1[133:130]<=0;
               cpx_packet_1[129]<=pcx_atom_d;
               cpx_packet_1[128]<=0;
               cpx_packet_1[127:0]<={5'b0,pcx_packet_d[64+5:64+4],2'b0,cpu,pcx_packet_d[64+11:64+6],112'b0};
               cpx_packet_2<={9'h170,54'h0,pcx_packet_d[17:0],46'h0,pcx_packet_d[17:0]}; 
               state<=`CPX_READY_1;
            end
         `CPX_READY_1:
            begin
				   if(!cpu)
					   begin
                     cpx_ready<=1;
                     cpx_packet<=cpx_packet_1;
							if(othercpuhit[0])
							   begin
                           cpx1_ready<=1;
                           cpx1_packet<={1'b1,4'b0011,12'b0,5'b0,pcx_packet_d[64+5:64+4],3'b001,pcx_packet_d[64+11:64+6],inval_vect0};
								end
					   end
					else
					   begin
                     cpx1_ready<=1;
                     cpx1_packet<=cpx_packet_1;
							if(othercpuhit[0])
							   begin
                           cpx_ready<=1;
                           cpx_packet<={1'b1,4'b0011,12'b0,5'b0,pcx_packet_d[64+5:64+4],3'b000,pcx_packet_d[64+11:64+6],inval_vect0};;
								end
					   end
               cnt<=cnt+1;
               if(`DEBUGGING)
                  if(multi_hit || multi_hit1)
                     wb_sel<=8'h11;
                state<=`CPX_READY_2;
            end
         `CPX_READY_2:
            begin
				   if(cpx_two_packet && !cpu2)
					   begin
						   cpx_ready<=1;
						   cpx_packet<=cpx_packet_2;
						end
					else
					   if(cpu2 && othercpuhit[1])
						   begin
                        cpx_ready<=1;
                        cpx_packet<={1'b1,4'b0011,12'b0,5'b0,pcx_packet_d[64+5],1'b1,3'b000,pcx_packet_d[64+11:64+6],inval_vect1};;
      					end
						else
						   begin
							   cpx_ready<=0;
								cpx_packet<=145'b0;
							end
				   if(cpx_two_packet && cpu2)
					   begin
						   cpx1_ready<=1;
						   cpx1_packet<=cpx_packet_2;
						end
					else
					   if(!cpu2 && othercpuhit[1])
						   begin
                        cpx1_ready<=1;
                        cpx1_packet<={1'b1,4'b0011,12'b0,5'b0,pcx_packet_d[64+5],1'b1,3'b001,pcx_packet_d[64+11:64+6],inval_vect1};;
      					end
						else
						   begin
							   cpx1_ready<=0;
								cpx1_packet<=145'b0;
							end
					state<=`PCX_IDLE;
            end
         `PCX_UNKNOWN:
            begin
               wb_sel<=8'b10100101; // Illegal eye-catching value for debugging
               state<=`PCX_IDLE;
            end
      endcase

l1dir l1dir_inst(
   .clk(clk),
   .reset(!rstn),
   
   .cpu(cpu),     // Issuing CPU number
   .strobe(state==`GOT_PCX_REQ),
   .way(pcx_packet[108:107]),     // Way to allocate for allocating loads
   .address(pcx_packet[64+39:64]),
   .load(pcx_packet[122:118]==5'b00000),
   .ifill(pcx_packet[122:118]==5'b10000),
   .store(pcx_packet[122:118]==5'b00001),
   .cas(pcx_packet[122:118]==5'b00010),
   .swap(pcx_packet[122:118]==5'b00110),
   .strload(pcx_packet[122:118]==5'b00100),
   .strstore(pcx_packet[122:118]==5'b00101),
   .cacheable((!pcx_packet[117]) && (!pcx_req_d[4])),
   .prefetch(pcx_packet[110]),
   .invalidate(pcx_packet[111]),
   .blockstore(pcx_packet[109] | pcx_packet[110]),
   
   .inval_vect0(inval_vect0),    // Invalidation vector
   .inval_vect1(inval_vect1),    
   .othercachehit(othercachehit), // Other cache hit in the same CPU, wayval0/wayval1
   .othercpuhit(othercpuhit),   // Any cache hit in the other CPU, wayval0/wayval1
   .wayval0(wayval0),       // Way valid
   .wayval1(wayval1),       // Second way valid for ifill
   .ready(ready),         // Directory init done   
);

endmodule
