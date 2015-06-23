/*
 * Bridge from SPARC Core to Wishbone Master
 *
 * (C) 2007 Simply RISC LLP
 * AUTHOR: Fabrizio Fazzino <fabrizio.fazzino@srisc.com>
 *
 * LICENSE:
 * This is a Free Hardware Design; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * version 2 as published by the Free Software Foundation.
 * The above named program is distributed in the hope that it will
 * be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * DESCRIPTION:
 * This block implements a bridge from one SPARC Core of the
 * OpenSPARC T1 to a master interface that makes use of the
 * Wishbone interconnect protocol.
 * For informations about Sun Microsystems' OpenSPARC T1
 * refer to the web site http://www.opensparc.net
 * For informations about OpenCores' Wishbone interconnect
 * please refer to the web site http://www.opencores.org
 */

`include "s1_defs.h"

module spc2wbm (

    /*
     * Inputs
     */

    // System inputs
    input sys_clock_i,                            // System Clock
    input sys_reset_i,                            // System Reset
    input[5:0] sys_interrupt_source_i,            // Encoded Interrupt Source

    // SPARC-side inputs connected to the PCX (Processor-to-Cache Xbar) outputs of the SPARC Core
    input[4:0] spc_req_i,                         // Request
    input spc_atom_i,                             // Atomic Request
    input[(`PCX_WIDTH-1):0] spc_packetout_i,      // Outgoing Packet

    // Wishbone Master interface inputs
    input wbm_ack_i,                              // Ack
    input[(`WB_DATA_WIDTH-1):0] wbm_data_i,       // Data In

    /*
     * Outputs
     */

    // SPARC-side outputs connected to the CPX (Cache-to-Processor Xbar) inputs of the SPARC Core
    output reg[4:0] spc_grant_o,                  // Grant
    output reg spc_ready_o,                       // Ready
    output reg[`CPX_WIDTH-1:0] spc_packetin_o,    // Incoming Packet
    output reg spc_stall_o,                       // Stall Requests
    output reg spc_resume_o,                      // Resume Requests

    // Wishbone Master interface outputs
    output reg wbm_cycle_o,                       // Cycle Start
    output reg wbm_strobe_o,                      // Strobe Request
    output reg wbm_we_o,                          // Write Enable
    output reg[`WB_ADDR_WIDTH-1:0] wbm_addr_o,    // Address Bus
    output reg[`WB_DATA_WIDTH-1:0] wbm_data_o,    // Data Out
    output reg[`WB_DATA_WIDTH/8-1:0] wbm_sel_o    // Select Output

  );


  /*
   * Registers
   */

  // Registers to latch requests from SPARC Core to Wishbone Master
  reg[3:0] state;
  reg[4:0] spc2wbm_region;                                             // Target region number (one-hot encoded)
  reg spc2wbm_atomic;                                                  // Request is Atomic
  reg[(`PCX_WIDTH-1):0] spc2wbm_packet;                                // Latched Packet

  // Wishbone Master to SPARC Core info used to encode the return packet
  reg wbm2spc_valid;                                                   // Valid
  reg[(`CPX_RQ_HI-`CPX_RQ_LO):0] wbm2spc_type;                         // Request type
  reg wbm2spc_miss;                                                    // L2 Miss
  reg[(`CPX_ERR_HI-`CPX_ERR_LO-1):0] wbm2spc_error;                    // Error
  reg wbm2spc_nc;                                                      // Non-Cacheable
  reg[(`CPX_TH_HI-`CPX_TH_LO):0] wbm2spc_thread;                       // Thread
  reg wbm2spc_way_valid;                                               // L2 Way Valid
  reg[(`CPX_WY_HI-`CPX_WY_LO):0] wbm2spc_way;                          // Replaced L2 Way
  reg wbm2spc_boot_fetch;                                              // Fetch for Boot
  reg wbm2spc_atomic;                                                  // Atomic LD/ST or 2nd IFill packet
  reg wbm2spc_pfl;                                                     // PFL
  reg[(`CPX_DA_HI-`CPX_DA_LO):0] wbm2spc_data;                         // Load Data
  reg[6:0] wbm2spc_interrupt_source;                                   // Encoded Interrupt Source
  reg wbm2spc_interrupt_new;                                           // New Interrupt Pending
   
  /*
   * Wires
   */

  // Decoded SPARC Core to Wishbone Master info
  wire spc2wbm_req;                                                     // Request
  wire spc2wbm_valid;                                                   // Valid
  wire[(`PCX_RQ_HI-`PCX_RQ_LO):0] spc2wbm_type;                         // Request type
  wire spc2wbm_nc;                                                      // Non-Cacheable
  wire[(`PCX_CP_HI-`PCX_CP_LO):0] spc2wbm_cpu_id;                       // CPU ID
  wire[(`PCX_TH_HI-`PCX_TH_LO):0] spc2wbm_thread;                       // Thread
  wire spc2wbm_invalidate;                                              // Invalidate all
  wire[(`PCX_WY_HI-`PCX_WY_LO):0] spc2wbm_way;                          // Replaced L1 Way
  wire[(`PCX_SZ_HI-`PCX_SZ_LO):0] spc2wbm_size;                         // Load/Store size
  wire[(`PCX_AD_HI-`PCX_AD_LO):0] spc2wbm_addr;                         // Address
  wire[(`PCX_DA_HI-`PCX_DA_LO):0] spc2wbm_data;                         // Store Data

  // Return packets assembled with various fields
  wire[`CPX_WIDTH-1:0] wbm2spc_packet;                                  // Incoming Packet

  /*
   * Encode/decode incoming info
   *
   * Legenda: available constants for some of the PCX/CPX fields.
   *
   * spc2wbm_size (3 bits) is one of:
   * - PCX_SZ_1B
   * - PCX_SZ_2B
   * - PCX_SZ_4B
   * - PCX_SZ_8B
   * - PCX_SZ_16B (Read accesses only)
   *
   * spc2wbm_type (5 bits) is one of:
   * { LOAD_RQ, IMISS_RQ, STORE_RQ, CAS1_RQ, CAS2_RQ, SWAP_RQ, STRLOAD_RQ, STRST_RQ, STQ_RQ,
   *   INT_RQ, FWD_RQ, FWD_RPY, RSVD_RQ }
   *
   * wbm2spc_type (4 bits) is one of:
   * { LOAD_RET, INV_RET, ST_ACK, AT_ACK, INT_RET, TEST_RET, FP_RET, IFILL_RET, EVICT_REQ,
   *   ERR_RET, STRLOAD_RET, STRST_ACK, FWD_RQ_RET, FWD_RPY_RET, RSVD_RET }
   *
   */

  // Decode info arriving from the SPC side
  assign spc2wbm_req = ( spc_req_i[4] | spc_req_i[3] | spc_req_i[2] | spc_req_i[1] | spc_req_i[0] );
  assign spc2wbm_valid = spc2wbm_packet[`PCX_VLD];
  assign spc2wbm_type = spc2wbm_packet[`PCX_RQ_HI:`PCX_RQ_LO];
  assign spc2wbm_nc = spc2wbm_packet[`PCX_NC];
  assign spc2wbm_cpu_id = spc2wbm_packet[`PCX_CP_HI:`PCX_CP_LO];
  assign spc2wbm_thread = spc2wbm_packet[`PCX_TH_HI:`PCX_TH_LO];
  assign spc2wbm_invalidate = spc2wbm_packet[`PCX_INVALL];
  assign spc2wbm_way = spc2wbm_packet[`PCX_WY_HI:`PCX_WY_LO];
  assign spc2wbm_size = spc2wbm_packet[`PCX_SZ_HI:`PCX_SZ_LO];
  assign spc2wbm_addr = spc2wbm_packet[`PCX_AD_HI:`PCX_AD_LO];
  assign spc2wbm_data = spc2wbm_packet[`PCX_DA_HI:`PCX_DA_LO];

  // Encode info going to the SPC side assembling return packets
  assign wbm2spc_packet = { wbm2spc_valid, wbm2spc_type, wbm2spc_miss, wbm2spc_error, wbm2spc_nc, wbm2spc_thread,
    wbm2spc_way_valid, wbm2spc_way, wbm2spc_boot_fetch, wbm2spc_atomic, wbm2spc_pfl, wbm2spc_data };

  /*
   * State Machine
   */

  always @(posedge sys_clock_i) begin

    // Initialization
    if(sys_reset_i==1) begin

      // Clear outputs going to SPARC Core inputs
      spc_grant_o <= 5'b00000;
      spc_ready_o <= 0;
      spc_packetin_o <= 0;
      spc_stall_o <= 0;
      spc_resume_o <= 0;

      // Clear Wishbone Master interface outputs
      wbm_cycle_o <= 0;
      wbm_strobe_o <= 0;
      wbm_we_o <= 0;
      wbm_addr_o <= 64'b0;
      wbm_data_o <= 64'b0;
      wbm_sel_o <= 8'b0;

      // Prepare wakeup packet for SPARC Core, the resulting output is
      // spc_packetin_o <= `CPX_WIDTH'h1700000000000000000000000000000010001;
      wbm2spc_valid <= 1;
      wbm2spc_type <= `INT_RET;
      wbm2spc_miss <= 0;
      wbm2spc_error <= 0;
      wbm2spc_nc <= 0;
      wbm2spc_thread <= 0;
      wbm2spc_way_valid <= 0;
      wbm2spc_way <= 0;
      wbm2spc_boot_fetch <= 0;
      wbm2spc_atomic <= 0;
      wbm2spc_pfl <= 0;
      wbm2spc_data <= 64'h10001;
      wbm2spc_interrupt_source <= 7'h0;
      wbm2spc_interrupt_new <= 1'b0;

      // Clear state machine
      state <= `STATE_WAKEUP;

    end else begin

      // FSM State 0: STATE_WAKEUP
      // Send to the SPARC Core the wakeup packet
      if(state==`STATE_WAKEUP) begin

        // Send wakeup packet
        spc_ready_o <= 1;
        spc_packetin_o <= wbm2spc_packet;

// synopsys translate_off
        // Display comment
`ifdef DEBUG
        $display("INFO: SPC2WBM: SPARC Core to Wishbone Master bridge starting...");
        $display("INFO: SPC2WBM: Wakeup packet sent to SPARC Core");
`endif
// synopsys translate_on

        // Unconditional state change
        state <= `STATE_IDLE;

      // FSM State 1: STATE_IDLE
      // Wait for a request from the SPARC Core
      // If available send an interrupt packet to the Core
      end else if(state==`STATE_IDLE) begin

        // Check if there's an incoming request
        if(spc2wbm_req==1) begin

          // Clear previously modified outputs
          spc_ready_o <= 0;
          spc_packetin_o <= 0;

          // Stall other requests from the SPARC Core
          spc_stall_o <= 1;

          // Latch target region and atomicity
          spc2wbm_region <= spc_req_i;
          spc2wbm_atomic <= spc_atom_i;

          // Jump to next state
          state <= `STATE_REQUEST_LATCHED;

        // See if the interrupt vector has changed
        end else if(sys_interrupt_source_i!=wbm2spc_interrupt_source) begin

          // Set the flag for next cycle
          wbm2spc_interrupt_new <= 1;

          // Prepare the interrupt packet for the SPARC Core
          wbm2spc_valid <= 1;
          wbm2spc_type <= `INT_RET;
          wbm2spc_miss <= 0;
          wbm2spc_error <= 0;
          wbm2spc_nc <= 0;
          wbm2spc_thread <= 0;
          wbm2spc_way_valid <= 0;
          wbm2spc_way <= 0;
          wbm2spc_boot_fetch <= 0;
          wbm2spc_atomic <= 0;
          wbm2spc_pfl <= 0;	   

        // Next cycle see if there's an int to be forwarded to the Core
        end else if(wbm2spc_interrupt_source!=6'b000000 && wbm2spc_interrupt_new) begin

          // Clean the flag
          wbm2spc_interrupt_new <= 0;

          // Send the interrupt packet to the Core
          spc_ready_o <= 1;
          spc_packetin_o <= wbm2spc_packet;

          // Stay in this state
          state <= `STATE_IDLE;

        // Nothing to do, stay idle
        end else begin

          // Clear previously modified outputs
          spc_ready_o <= 0;
          spc_packetin_o <= 0;

	  // Clear stall/resume signals
          spc_stall_o <= 0;
	  spc_resume_o <= 0;

          // Stay in this state
          state <= `STATE_IDLE;

        end

      // FSM State 2: STATE_REQUEST_LATCHED
      // We've just latched the request
      // Now we latch the packet
      // Start granting the request
      end else if(state==`STATE_REQUEST_LATCHED) begin

        // Latch the incoming packet
        spc2wbm_packet <= spc_packetout_i;

        // Grant the request to the SPARC Core
        spc_grant_o <= spc2wbm_region;

        // Clear the stall signal
        spc_stall_o <= 0; 
	 
// synopsys translate_off
        // Print details of SPARC Core request
`ifdef DEBUG
        $display("INFO: SPC2WBM: *** NEW REQUEST FROM SPARC CORE ***");
        if(spc2wbm_region[0]==1) $display("INFO: SPC2WBM: Request to RAM Bank 0");
        else if(spc2wbm_region[1]==1) $display("INFO: SPC2WBM: Request to RAM Bank 1");
        else if(spc2wbm_region[2]==1) $display("INFO: SPC2WBM: Request to RAM Bank 2");
        else if(spc2wbm_region[3]==1) $display("INFO: SPC2WBM: Request to RAM Bank 3");
        else if(spc2wbm_region[4]==1) $display("INFO: SPC2WBM: Request targeted to I/O Block");
        else $display("INFO: SPC2WBM: Request to target region unknown");
        if(spc2wbm_atomic==1) $display("INFO: SPC2WBM: Request is ATOMIC");
        else $display("INFO: SPC2WBM: Request is not atomic");
`endif
// synopsys translate_on

        // Unconditional state change
        state <= `STATE_PACKET_LATCHED;

      // FSM State 3: STATE_PACKET_LATCHED
      // The packet has already been latched
      // Decode this packet to build the request for the Wishbone bus
      // The grant of the request to the SPARC Core has been completed
      end else if(state==`STATE_PACKET_LATCHED) begin

        // Clear previously modified outputs
        spc_grant_o <= 5'b0;

        // Issue a request on the Wishbone bus
        wbm_cycle_o <= 1;
        wbm_strobe_o <= 1;
        wbm_addr_o <= { spc2wbm_region, 19'b0, spc2wbm_addr[`PCX_AD_HI-`PCX_AD_LO:3], 3'b000 };
        wbm_data_o <= spc2wbm_data;

        // Handle write enable and byte select
        if(spc2wbm_type==`IMISS_RQ) begin

          // For instruction miss always read memory
          wbm_we_o <= 0;
          if(spc2wbm_region==5'b10000)
            // For accesses to SSI ROM only 32 bits are required
            wbm_sel_o <= (4'b1111<<(spc2wbm_addr[2]<<2));
          else
            // For accesses to RAM 256 bits are expected (2 ret packets)
            wbm_sel_o <= 8'b11111111;

        end else if(spc2wbm_type==`LOAD_RQ) begin
	   
          // For data load use the provided data
          wbm_we_o <= 0;
          case(spc2wbm_size)
            `PCX_SZ_1B: wbm_sel_o <= (1'b1<<spc2wbm_addr[2:0]);
            `PCX_SZ_2B: wbm_sel_o <= (2'b11<<(spc2wbm_addr[2:1]<<1));
            `PCX_SZ_4B: wbm_sel_o <= (4'b1111<<(spc2wbm_addr[2]<<2));
            `PCX_SZ_8B: wbm_sel_o <= 8'b11111111;
            `PCX_SZ_16B: wbm_sel_o <= 8'b11111111;  // Requires a 2nd access
            default: wbm_sel_o <= 8'b00000000;
          endcase

        end else if(spc2wbm_type==`STORE_RQ) begin

          // For data store use the provided data
          wbm_we_o <= 1;
          case(spc2wbm_size)
            `PCX_SZ_1B: wbm_sel_o <= (1'b1<<spc2wbm_addr[2:0]);
            `PCX_SZ_2B: wbm_sel_o <= (2'b11<<(spc2wbm_addr[2:1]<<1));
            `PCX_SZ_4B: wbm_sel_o <= (4'b1111<<(spc2wbm_addr[2]<<2));
            `PCX_SZ_8B: wbm_sel_o <= 8'b11111111;
            `PCX_SZ_16B: wbm_sel_o <= 8'b11111111;  // Requires a 2nd access
            default: wbm_sel_o <= 8'b00000000;
          endcase

        end else begin

          wbm_we_o <= 1;
          wbm_sel_o <= 8'b00000000;

        end

// synopsys translate_off
        // Print details of request packet
`ifdef DEBUG
        $display("INFO: SPC2WBM: Valid bit is %X", spc2wbm_valid);
        case(spc2wbm_type)
          `LOAD_RQ: $display("INFO: SPC2WBM: Request of Type LOAD_RQ");
          `IMISS_RQ: $display("INFO: SPC2WBM: Request of Type IMISS_RQ");
          `STORE_RQ: $display("INFO: SPC2WBM: Request of Type STORE_RQ");
          `CAS1_RQ: $display("INFO: SPC2WBM: Request of Type CAS1_RQ");
          `CAS2_RQ: $display("INFO: SPC2WBM: Request of Type CAS2_RQ");
          `SWAP_RQ: $display("INFO: SPC2WBM: Request of Type SWAP_RQ");
          `STRLOAD_RQ: $display("INFO: SPC2WBM: Request of Type STRLOAD_RQ");
          `STRST_RQ: $display("INFO: SPC2WBM: Request of Type STRST_RQ");
          `STQ_RQ: $display("INFO: SPC2WBM: Request of Type STQ_RQ");
          `INT_RQ: $display("INFO: SPC2WBM: Request of Type INT_RQ");
          `FWD_RQ: $display("INFO: SPC2WBM: Request of Type FWD_RQ");
          `FWD_RPY: $display("INFO: SPC2WBM: Request of Type FWD_RPY");
          `RSVD_RQ: $display("INFO: SPC2WBM: Request of Type RSVD_RQ");
          default: $display("INFO: SPC2WBM: Request of Type Unknown");
	endcase
        $display("INFO: SPC2WBM: Non-Cacheable bit is %X", spc2wbm_nc);
        $display("INFO: SPC2WBM: CPU-ID is %X", spc2wbm_cpu_id);
        $display("INFO: SPC2WBM: Thread is %X", spc2wbm_thread);
        $display("INFO: SPC2WBM: Invalidate All is %X", spc2wbm_invalidate);
        $display("INFO: SPC2WBM: Replaced L1 Way is %X", spc2wbm_way);
        case(spc2wbm_size)
          `PCX_SZ_1B: $display("INFO: SPC2WBM: Request size is 1 Byte");
          `PCX_SZ_2B: $display("INFO: SPC2WBM: Request size is 2 Bytes");
          `PCX_SZ_4B: $display("INFO: SPC2WBM: Request size is 4 Bytes");
          `PCX_SZ_8B: $display("INFO: SPC2WBM: Request size is 8 Bytes");
          `PCX_SZ_16B: $display("INFO: SPC2WBM: Request size is 16 Bytes");
          default: $display("INFO: SPC2WBM: Request size is Unknown");
        endcase
        $display("INFO: SPC2WBM: Address is %X", spc2wbm_addr);
        $display("INFO: SPC2WBM: Data is %X", spc2wbm_data);
`endif
// synopsys translate_on

        // Unconditional state change
        state <= `STATE_REQUEST_GRANTED;

      // FSM State 4: STATE_REQUEST_GRANTED
      // Wishbone access completed, latch the incoming data
      end else if(state==`STATE_REQUEST_GRANTED) begin

        // Wait until Wishbone access completes
        if(wbm_ack_i==1) begin

          // Clear previously modified outputs
          if(spc2wbm_atomic==0) wbm_cycle_o <= 0;
          wbm_strobe_o <= 0;
          wbm_we_o <= 0;
          wbm_addr_o <= 64'b0;
          wbm_data_o <= 64'b0;
          wbm_sel_o <= 8'b0;

          // Latch the data and set up the return packet for the SPARC Core
          wbm2spc_valid <= 1;
          case(spc2wbm_type)
            `IMISS_RQ: begin
              wbm2spc_type <= `IFILL_RET; // I-Cache Miss
              wbm2spc_atomic <= 0;
            end
            `LOAD_RQ: begin
              wbm2spc_type <= `LOAD_RET;  // Load
              wbm2spc_atomic <= spc2wbm_atomic;
            end
            `STORE_RQ: begin
              wbm2spc_type <= `ST_ACK;    // Store
              wbm2spc_atomic <= spc2wbm_atomic;
            end
          endcase
          wbm2spc_miss <= 0;
          wbm2spc_error <= 0;
          wbm2spc_nc <= spc2wbm_nc;
          wbm2spc_thread <= spc2wbm_thread;
          wbm2spc_way_valid <= 0;
          wbm2spc_way <= 0;
	  if(spc2wbm_region==5'b10000) wbm2spc_boot_fetch <= 1;
	  else wbm2spc_boot_fetch <= 0;
          wbm2spc_pfl <= 0;	   
          if(spc2wbm_addr[3]==0) wbm2spc_data <= { wbm_data_i, 64'b0 };
          else wbm2spc_data <= { 64'b0, wbm_data_i };

          // See if other 64-bit Wishbone accesses are required
          if(
              // Instruction miss directed to RAM expects 256 bits
              ( (spc2wbm_type==`IMISS_RQ)&&(spc2wbm_region!=5'b10000) ) ||
              // Data access of 128 bits
              ( (spc2wbm_type==`LOAD_RQ)&&(spc2wbm_size==`PCX_SZ_16B) )
            )
            state <= `STATE_ACCESS2_BEGIN;
          else
            state <= `STATE_PACKET_READY;

        end else state <= `STATE_REQUEST_GRANTED;

      // FSM State 5: STATE_ACCESS2_BEGIN
      // If needed start a second read access to the Wishbone bus
      end else if(state==`STATE_ACCESS2_BEGIN) begin

        // Issue a second request on the Wishbone bus
        wbm_cycle_o <= 1;
        wbm_strobe_o <= 1;
        wbm_we_o <= 0;
        wbm_addr_o <= { spc2wbm_region, 19'b0, spc2wbm_addr[`PCX_AD_HI-`PCX_AD_LO:4], 4'b1000 };  // 2nd doubleword inside the same quadword
        wbm_data_o <= 64'b0;
        wbm_sel_o <= 8'b11111111;

        // Unconditional state change
        state <= `STATE_ACCESS2_END;

      // FSM State 6: STATE_ACCESS2_END
      // Latch the second data returning from Wishbone when ready
      end else if(state==`STATE_ACCESS2_END) begin

        // Wait until Wishbone access completes
        if(wbm_ack_i==1) begin

          // Clear previously modified outputs
          if(spc2wbm_atomic==0) wbm_cycle_o <= 0;
          wbm_strobe_o <= 0;
          wbm_we_o <= 0;
          wbm_addr_o <= 64'b0;
          wbm_data_o <= 64'b0;
          wbm_sel_o <= 8'b0;

          // Latch the data and set up the return packet for the SPARC Core
          wbm2spc_data[63:0] <= wbm_data_i;

          // See if two return packets are required or just one
          if(spc2wbm_type==`IMISS_RQ && spc2wbm_region==5'b10000)
            state <= `STATE_PACKET_READY;
          else
            state <= `STATE_ACCESS3_BEGIN;

        end else state <= `STATE_ACCESS2_END;

      // FSM State 7: STATE_ACCESS3_BEGIN
      // If needed start a third read access to the Wishbone bus
      // In the meanwhile we can return the first 128-bit packet
      end else if(state==`STATE_ACCESS3_BEGIN) begin

        // Return the packet to the SPARC Core
        spc_ready_o <= 1;
        spc_packetin_o <= wbm2spc_packet;

        // Issue a third request on the Wishbone bus
        wbm_cycle_o <= 1;
        wbm_strobe_o <= 1;
        wbm_we_o <= 0;
        wbm_addr_o <= { spc2wbm_region, 19'b0, spc2wbm_addr[`PCX_AD_HI-`PCX_AD_LO:5], 5'b10000 };  // 3nd doubleword inside the same 256-bit data
        wbm_data_o <= 64'b0;
        wbm_sel_o <= 8'b11111111;

// synopsys translate_off
        // Print details of return packet
`ifdef DEBUG
        $display("INFO: WBM2SPC: *** RETURN PACKET TO SPARC CORE ***");	 
        $display("INFO: WBM2SPC: Valid bit is %X", wbm2spc_valid);
        case(wbm2spc_type)
          `IFILL_RET: $display("INFO: WBM2SPC: Return Packet of Type IFILL_RET");
          `LOAD_RET: $display("INFO: WBM2SPC: Return Packet of Type LOAD_RET");
          `ST_ACK: $display("INFO: WBM2SPC: Return Packet of Type ST_ACK");
          default: $display("INFO: WBM2SPC: Return Packet of Type Unknown");
        endcase
        $display("INFO: WBM2SPC: L2 Miss is %X", wbm2spc_miss);
        $display("INFO: WBM2SPC: Error is %X", wbm2spc_error);
        $display("INFO: WBM2SPC: Non-Cacheable bit is %X", wbm2spc_nc);
        $display("INFO: WBM2SPC: Thread is %X", wbm2spc_thread);
        $display("INFO: WBM2SPC: Way Valid is %X", wbm2spc_way_valid);
        $display("INFO: WBM2SPC: Replaced L2 Way is %X", wbm2spc_way);
        $display("INFO: WBM2SPC: Fetch for Boot is %X", wbm2spc_boot_fetch);
        $display("INFO: WBM2SPC: Atomic LD/ST or 2nd IFill Packet is %X", wbm2spc_atomic);
        $display("INFO: WBM2SPC: PFL is %X", wbm2spc_pfl); 
        $display("INFO: WBM2SPC: Data is %X", wbm2spc_data);
`endif
// synopsys translate_on

        // Unconditional state change
        state <= `STATE_ACCESS3_END;

      // FSM State 8: STATE_ACCESS3_END
      // Latch the second data returning from Wishbone when ready
      end else if(state==`STATE_ACCESS3_END) begin

        // Clear previously modified outputs
        spc_ready_o <= 0;

        // Wait until Wishbone access completes
        if(wbm_ack_i==1) begin

          // Clear previously modified outputs
          if(spc2wbm_atomic==0) wbm_cycle_o <= 0;
          wbm_strobe_o <= 0;
          wbm_we_o <= 0;
          wbm_addr_o <= 64'b0;
          wbm_data_o <= 64'b0;
          wbm_sel_o <= 8'b0;

          // Latch the data and set up the return packet for the SPARC Core
          wbm2spc_data <= { wbm_data_i, 64'b0 };

          // Jump to next state
          state <= `STATE_ACCESS4_BEGIN;

        end else state <= `STATE_ACCESS3_END;

      // FSM State 9: STATE_ACCESS4_BEGIN
      // If needed start a second read access to the Wishbone bus
      end else if(state==`STATE_ACCESS4_BEGIN) begin

        // Issue a fourth request on the Wishbone bus
        wbm_cycle_o <= 1;
        wbm_strobe_o <= 1;
        wbm_we_o <= 0;
        wbm_addr_o <= { spc2wbm_region, 19'b0, spc2wbm_addr[`PCX_AD_HI-`PCX_AD_LO:5], 5'b11000 };  // 4th doubleword inside the same 256-bit data
        wbm_data_o <= 64'b0;
        wbm_sel_o <= 8'b11111111;

        // Unconditional state change
        state <= `STATE_ACCESS4_END;

      // FSM State 10: STATE_ACCESS4_END
      // Latch the second data returning from Wishbone when ready
      end else if(state==`STATE_ACCESS4_END) begin

        // Wait until Wishbone access completes
        if(wbm_ack_i==1) begin

          // Clear previously modified outputs
          if(spc2wbm_atomic==0) wbm_cycle_o <= 0;
          wbm_strobe_o <= 0;
          wbm_we_o <= 0;
          wbm_addr_o <= 64'b0;
          wbm_data_o <= 64'b0;
          wbm_sel_o <= 8'b0;

          // Latch the data and set up the return packet for the SPARC Core
          wbm2spc_atomic <= 1;
          wbm2spc_data[63:0] <= wbm_data_i;

          // Jump to next state
          state <= `STATE_PACKET_READY;

        end else state <= `STATE_ACCESS4_END;

      // FSM State 11: STATE_PACKET_READY
      // We can start returning the packet to the SPARC Core
      end else if(state==`STATE_PACKET_READY) begin

        // Return the packet to the SPARC Core
        spc_ready_o <= 1;
        spc_packetin_o <= wbm2spc_packet;

        // Resume requests
        spc_resume_o <= 1;

        // Unconditional state change
        state <= `STATE_IDLE;

// synopsys translate_off
        // Print details of return packet
`ifdef DEBUG
        $display("INFO: WBM2SPC: *** RETURN PACKET TO SPARC CORE ***");	 
        $display("INFO: WBM2SPC: Valid bit is %X", wbm2spc_valid);
        case(wbm2spc_type)
          `IFILL_RET: $display("INFO: WBM2SPC: Return Packet of Type IFILL_RET");
          `LOAD_RET: $display("INFO: WBM2SPC: Return Packet of Type LOAD_RET");
          `ST_ACK: $display("INFO: WBM2SPC: Return Packet of Type ST_ACK");
          default: $display("INFO: WBM2SPC: Return Packet of Type Unknown");
        endcase
        $display("INFO: WBM2SPC: L2 Miss is %X", wbm2spc_miss);
        $display("INFO: WBM2SPC: Error is %X", wbm2spc_error);
        $display("INFO: WBM2SPC: Non-Cacheable bit is %X", wbm2spc_nc);
        $display("INFO: WBM2SPC: Thread is %X", wbm2spc_thread);
        $display("INFO: WBM2SPC: Way Valid is %X", wbm2spc_way_valid);
        $display("INFO: WBM2SPC: Replaced L2 Way is %X", wbm2spc_way);
        $display("INFO: WBM2SPC: Fetch for Boot is %X", wbm2spc_boot_fetch);
        $display("INFO: WBM2SPC: Atomic LD/ST or 2nd IFill Packet is %X", wbm2spc_atomic);
        $display("INFO: WBM2SPC: PFL is %X", wbm2spc_pfl); 
        $display("INFO: WBM2SPC: Data is %X", wbm2spc_data);
`endif
// synopsys translate_on

      end
    end
  end

endmodule

