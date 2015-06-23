////////////////////////////////////////////////////////////
//
// This confidential and proprietary software may be used
// only as authorized by a licensing agreement from
// Bean Digital Ltd
// In the event of publication, the following notice is
// applicable:
//
// (C)COPYRIGHT 2012 BEAN DIGITAL LTD.
// ALL RIGHTS RESERVED
//
// The entire notice above must be reproduced on all
// authorized copies.
//
// File        : sata_phy_host_ctrl_x6series.v
// Author      : J.Bean
// Date        : Mar 2012
// Description : SATA PHY Layer Host Control Xilinx 6 Series
////////////////////////////////////////////////////////////

`resetall
`timescale 1ns/10ps

`include "sata_constants.v"

module sata_phy_host_ctrl_x6series
  #(parameter SATA_REV = 1)(              // SATA Revision (1, 2, 3)
  input  wire          clk_phy,           // Clock PHY
  input  wire          rst_n,	            // Reset
  output reg           link_up_o,         // Link Up
  // Transceiver
  input  wire          gt_rst_done_i,     // GT Reset Done
  output reg  [31:0]   gt_tx_data_o,	     // GT Transmit Data
  output reg  [3:0]    gt_tx_charisk_o,	  // GT Transmit K/D
  output reg           gt_tx_com_strt_o,  // GT Transmit	COM Start
  output reg           gt_tx_com_type_o,	 // GT Transmit COM Type
  output reg           gt_tx_elec_idle_o, // GT Transmit Electrical Idle
  input  wire [31:0]   gt_rx_data_i,      // GT Receive Data   
  input  wire [2:0]    gt_rx_status_i,	   // GT Receive Status
  input  wire          gt_rx_elec_idle_i 	// GT Receive Electrical Idle   
);

////////////////////////////////////////////////////////////
// Parameters
//////////////////////////////////////////////////////////// 

// Time delays
parameter SATA1_10MS            = 750000;   // 75MHz * 750000
parameter SATA2_10MS            = 1500000;  // 150MHz * 1500000
parameter SATA3_10MS            = 3000000;  // 300MHz * 3000000
parameter SATA1_873US           = 65535;    // 75MHz * 65535
parameter SATA2_873US           = 131070;   // 150MHz * 131070
parameter SATA3_873US           = 262140;   // 300MHz * 262140

// State machine states
parameter HP1_RESET             = 0;
parameter HP2_AWAIT_COMINIT     = 1;
parameter HP2B_AWAIT_NO_COMINIT = 2;
parameter HP3_CALIBRATE         = 3;
parameter HP4_COMWAKE           = 4;
parameter HP5_AWAIT_COMWAKE     = 5;
parameter HP5B_AWAIT_NO_COMWAKE = 6;
parameter HP6_AWAIT_ALIGN       = 7;
parameter HP7_SEND_ALIGN        = 8;
parameter HP8_READY             = 9;

////////////////////////////////////////////////////////////
// Signals
//////////////////////////////////////////////////////////// 

reg  [3:0]   state_cs;            // Current state
reg  [3:0]   state_ns;            // Next state  
reg  [199:0] state_ascii;         // ASCII state
wire         phy_ctrl_strt;       // PHY Control Start
reg	 [31:0]	 align_timeout_cnt;   // ALIGN Timeout Count
reg  [31:0]  retry_cnt;           // Retry Count 
wire         cominit_detect;      // COMINIT Detect
wire         comwake_detect;      // COMWAKE Detect
wire         align_detect;        // ALIGN Detected
wire         align_timeout;       // ALIGN Timeout
reg  [1:0]   non_align_cnt;       // Non ALIGN Count
reg          tx_com_strt;         // Transmit COM Start
wire         tx_com_strt_pedge;   // Transmit COM Start Positive Edge
reg          tx_com_done;         // Transmit COM Done

////////////////////////////////////////////////////////////
// Instance    : Transmit Com Start Pos Edge
// Description : Detect positive edge on com start signal.
////////////////////////////////////////////////////////////

det_pos_edge U_tx_com_strt_pedge(
  .clk   (clk_phy),
  .rst_n (rst_n),
  .d     (tx_com_strt),
  .q     (tx_com_strt_pedge));

////////////////////////////////////////////////////////////
// Comb Assign : PHY Control Start
// Description : Starts the control.
////////////////////////////////////////////////////////////

assign phy_ctrl_strt = gt_rst_done_i;

////////////////////////////////////////////////////////////
// Comb Assign : COMWAKE Detect
// Description : 
////////////////////////////////////////////////////////////

assign comwake_detect = gt_rx_status_i[1];

////////////////////////////////////////////////////////////
// Comb Assign : COMINIT Detect
// Description : 
////////////////////////////////////////////////////////////

assign cominit_detect = gt_rx_status_i[2];

////////////////////////////////////////////////////////////
// Comb Assign : ALIGN Timeout
// Description : 
////////////////////////////////////////////////////////////

assign align_timeout = (align_timeout_cnt == 0);

////////////////////////////////////////////////////////////
// Comb Assign : ALIGN primitive detect
// Description : 
////////////////////////////////////////////////////////////

assign align_detect = (gt_rx_data_i == 32'h7B4A4ABC); 

////////////////////////////////////////////////////////////
// Seq Block   : State machine seq logic
// Description : Sets the current state to the next state.
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin
  if (rst_n == 0) begin
    state_cs <= HP1_RESET;   
  end else begin
    state_cs <= state_ns;
  end
end  

////////////////////////////////////////////////////////////
// Comb Block  : State machine ascii 
// Description : Converts the state to ascii for debug.
////////////////////////////////////////////////////////////

always @(*)
begin
  case (state_cs)
    HP1_RESET:             state_ascii = "HP1_RESET";
    HP2_AWAIT_COMINIT:     state_ascii = "HP2_AWAIT_COMINIT";
    HP2B_AWAIT_NO_COMINIT: state_ascii = "HP2B_AWAIT_NO_COMINIT";
    HP3_CALIBRATE:         state_ascii = "HP3_CALIBRATE";
    HP4_COMWAKE:           state_ascii = "HP4_COMWAKE";
    HP5_AWAIT_COMWAKE:     state_ascii = "HP5_AWAIT_COMWAKE";
    HP5B_AWAIT_NO_COMWAKE: state_ascii = "HP5B_AWAIT_NO_COMWAKE";
    HP6_AWAIT_ALIGN:       state_ascii = "HP6_AWAIT_ALIGN";
    HP7_SEND_ALIGN:        state_ascii = "HP7_SEND_ALIGN";
    HP8_READY:             state_ascii = "HP8_READY"; 
  endcase
end

////////////////////////////////////////////////////////////
// Comb Block  : State machine comb logic
// Description : Assigns the next state.
////////////////////////////////////////////////////////////

always @(*)
begin
  state_ns = state_cs;

  case (state_cs)
    // HP1_RESET - Interface quiescent
    HP1_RESET: begin
      if ((phy_ctrl_strt == 1) && (tx_com_done == 1) && (cominit_detect == 0)) begin
        state_ns = HP2_AWAIT_COMINIT;
      end	      
    end
    
    // HP2_AWAIT_COMINIT - Wait for COMINIT to be detected
    HP2_AWAIT_COMINIT: begin
      if (cominit_detect == 1) begin
        state_ns = HP2B_AWAIT_NO_COMINIT;
      end else begin
        // Test if need to send COMRESET again
        if (retry_cnt == 0) begin
          state_ns = HP1_RESET;
        end
      end
    end

    // HP2B_AWAIT_NO_COMINIT - Wait for COMINIT to finish
    HP2B_AWAIT_NO_COMINIT: begin
      if (cominit_detect == 0) begin
        state_ns = HP3_CALIBRATE;
      end
    end
    
    // HP3_CALIBRATE
    HP3_CALIBRATE: begin
      state_ns = HP4_COMWAKE;
    end
    
    // HP4_COMWAKE - Send COMWAKE
    HP4_COMWAKE: begin
      if (tx_com_done == 1) begin
        state_ns = HP5_AWAIT_COMWAKE;
      end
    end
    
    // HP5_AWAIT_COMWAKE - Wait for COMWAKE to be detected
    HP5_AWAIT_COMWAKE: begin
      if (comwake_detect == 1) begin
        state_ns = HP5B_AWAIT_NO_COMWAKE;
      end else begin
        // Test if need to send COMRESET again
        if (retry_cnt == 0) begin
          state_ns = HP1_RESET;
        end
      end
    end
    
    // HP5B_AWAIT_NO_COMWAKE - Wait for COMWAKE to finish
    HP5B_AWAIT_NO_COMWAKE: begin
      if (comwake_detect == 0) begin
        state_ns = HP6_AWAIT_ALIGN;
      end
    end
    
    // HP6_AWAIT_ALIGN - Wait for ALIGN to be detected
    HP6_AWAIT_ALIGN: begin
      casez({align_detect, align_timeout})
        2'b10:   state_ns = HP7_SEND_ALIGN; 
        2'b01:   state_ns = HP1_RESET; 
        default: state_ns = HP6_AWAIT_ALIGN; 
      endcase
    end
    
    // HP7_SEND_ALIGN - Send ALIGN
    HP7_SEND_ALIGN: begin
      if (non_align_cnt == 3) begin
        state_ns = HP8_READY; 
      end
    end
    
    // HP8_READY - Link ready
    HP8_READY: begin
      if (gt_rx_elec_idle_i == 1) begin
        state_ns = HP1_RESET;
      end     
    end    
    
    default: begin
      state_ns = 'bx;
    end
  endcase
end

////////////////////////////////////////////////////////////
// Seq Block   : Link Up
// Description : Set when communication has been established
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
    link_up_o <= 0;
  end	else begin
    case (state_cs)
      // HP8_READY - Link ready
      HP8_READY: begin
        link_up_o <= 1;
      end  
      
      default: begin
        link_up_o <= 0;
      end
    endcase
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : GT Transmit COM Start
// Description : Transmits the selected COM signal.
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
    gt_tx_com_strt_o <= 0;
  end	else begin
    gt_tx_com_strt_o <= tx_com_strt_pedge;
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : GT Transmit COM Type
// Description : 0 = COMRESET/COMINIT, 1 = COMWAKE
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
    gt_tx_com_type_o <= 0;
  end	else begin
    case (state_cs)
      // HP1_RESET - Interface quiescent
      HP1_RESET: begin
        if (phy_ctrl_strt == 1) begin
          gt_tx_com_type_o <= 0;		
        end	      
      end
      
      // HP4_COMWAKE - Send COMWAKE
      HP4_COMWAKE: begin
        gt_tx_com_type_o <= 1;		
      end
    endcase
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : GT Transmit Electrical Idle
// Description : 
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
    gt_tx_elec_idle_o <= 0;
  end	else begin
    case (state_cs)
      // HP5B_AWAIT_NO_COMWAKE - Wait for COMWAKE to finish
      HP5B_AWAIT_NO_COMWAKE: begin
        if (comwake_detect == 0) begin
          gt_tx_elec_idle_o <= 0;
        end
      end
    
      // HP6_AWAIT_ALIGN - Wait for ALIGN to be detected
      HP6_AWAIT_ALIGN: begin
        gt_tx_elec_idle_o <= 0;
      end
      
      // HP7_SEND_ALIGN - Send ALIGN
      HP7_SEND_ALIGN: begin
        gt_tx_elec_idle_o <= 0;
      end
      
      // HP8_READY - Link ready
      HP8_READY: begin
        gt_tx_elec_idle_o <= 0;
      end          
      
      default: begin
        gt_tx_elec_idle_o <= 1;
      end
    endcase
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : GT Transmit Data
// Description : 
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
    gt_tx_data_o <= 0;
  end	else begin
    case (state_cs)  
      // HP6_AWAIT_ALIGN - Wait for ALIGN to be detected
      HP6_AWAIT_ALIGN: begin
        gt_tx_data_o <= 32'h4A4A4A4A; // D10.2     
      end
      
      // HP7_SEND_ALIGN - Send ALIGN
      HP7_SEND_ALIGN: begin
        gt_tx_data_o <= `ALIGN_VAL;   // ALIGN; 
      end
      
      // HP8_READY - Link ready
      HP8_READY: begin
        gt_tx_data_o <= `SYNC_VAL;    // SYNC;  
      end        
      
      default: begin
        gt_tx_data_o <= 0;      
      end
    endcase
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : GT Transmit K/D
// Description : 
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
    gt_tx_charisk_o <= 0;
  end	else begin
    case (state_cs)  
      // HP6_AWAIT_ALIGN - Wait for ALIGN to be detected
      HP6_AWAIT_ALIGN: begin
        gt_tx_charisk_o <= 4'b0000; // D10.2     
      end
      
      // HP7_SEND_ALIGN - Send ALIGN
      HP7_SEND_ALIGN: begin
        gt_tx_charisk_o <= 4'b0001; // ALIGN; 
      end
      
      // HP8_READY - Link ready
      HP8_READY: begin
        gt_tx_charisk_o <= 4'b0001; // SYNC;  
      end        
      
      default: begin
        gt_tx_charisk_o <= 0;      
      end
    endcase
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : Transmit COM Start
// Description : Starts transmission of a COM sequence.
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
    tx_com_strt <= 0;
  end	else begin
    case (state_cs)
      // HP1_RESET - Interface quiescent
      HP1_RESET: begin
        if (phy_ctrl_strt == 1) begin
          tx_com_strt <= 1;	
        end	else begin
          tx_com_strt <= 0;
        end
      end
      
      // HP4_COMWAKE - Send COMWAKE
      HP4_COMWAKE: begin
        tx_com_strt <= 1;	
      end
          
      default: begin
        tx_com_strt <= 0;   
      end
    endcase
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : Transmit COM Done
// Description : Detects when COM signal has been sent.
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
    tx_com_done <= 0;
  end	else begin
    case (state_cs)     
      // HP1_RESET - Interface quiescent
      HP1_RESET: begin
        if ((phy_ctrl_strt == 1) && (tx_com_done == 1) && (cominit_detect == 0)) begin
          tx_com_done <= 0;
        end else begin
          if (gt_rx_status_i[0] == 1) begin
            tx_com_done <= 1;
          end
        end     
      end
      
      // HP4_COMWAKE - Send COMWAKE
      HP4_COMWAKE: begin
        if (tx_com_done == 1) begin
          tx_com_done <= 0;
        end else begin
          if (gt_rx_status_i[0] == 1) begin
            tx_com_done <= 1;
          end
        end   
      end
    endcase     
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : ALIGN Timeout Count
// Description : Used to send COMRESET if ALIGN primitives
//               are not detected within 873.8us.
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
		align_timeout_cnt <= 0;
	end	else begin
	  case (state_cs)     
      // HP1_RESET - Interface quiescent
      HP1_RESET: begin
        case (SATA_REV)
          1:       align_timeout_cnt <= SATA1_873US;
          2:       align_timeout_cnt <= SATA2_873US;
          3:       align_timeout_cnt <= SATA3_873US;    
          default: align_timeout_cnt <= SATA1_873US;    
        endcase
      end	   
      
      // HP6_AWAIT_ALIGN - Wait for ALIGN to be detected
      HP6_AWAIT_ALIGN: begin
        align_timeout_cnt <= align_timeout_cnt - 1;
      end      
	  endcase
	end
end

////////////////////////////////////////////////////////////
// Seq Block   : Retry Count
// Description : Used to for async signal recovery (10 ms)
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
		retry_cnt <= 0;
	end	else begin
	  case (state_cs)  
      // HP1_RESET - Interface quiescent
      HP1_RESET: begin
        case (SATA_REV)
          1:       retry_cnt <= SATA1_10MS;
          2:       retry_cnt <= SATA2_10MS;
          3:       retry_cnt <= SATA3_10MS;    
          default: retry_cnt <= SATA1_10MS;    
        endcase	       
      end
      
      // HP2_AWAIT_COMINIT - Wait for COMINIT to be detected
      HP2_AWAIT_COMINIT: begin
        retry_cnt <= retry_cnt - 1;
      end	 
      
      // HP2B_AWAIT_NO_COMINIT - Wait for COMINIT to finish
      HP2B_AWAIT_NO_COMINIT: begin
        case (SATA_REV)
          1:       retry_cnt <= SATA1_10MS;
          2:       retry_cnt <= SATA2_10MS;
          3:       retry_cnt <= SATA3_10MS;    
          default: retry_cnt <= SATA1_10MS;    
        endcase	 
      end      
      
      // HP5_AWAIT_COMWAKE - Wait for COMWAKE to be detected
      HP5_AWAIT_COMWAKE: begin
        retry_cnt <= retry_cnt - 1;
      end      
	  endcase	  
	end
end

////////////////////////////////////////////////////////////
// Seq Block   : Non ALIGN Count
// Description : Counts 3 non ALIGN primitives. 
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
		non_align_cnt <= 0;
	end	else begin
	  case (state_cs)  
      // HP7_SEND_ALIGN - Send ALIGN
      HP7_SEND_ALIGN: begin
  	    // Look for K28.3
        if (gt_rx_data_i[7:0] == 8'hbc) begin
        		non_align_cnt <= non_align_cnt + 1;
        end else begin
  		      non_align_cnt <= 0;	  
        end    
      end	    
      
      default: begin
        non_align_cnt <= 0;	 
      end
	  endcase	  
	end
end

endmodule
