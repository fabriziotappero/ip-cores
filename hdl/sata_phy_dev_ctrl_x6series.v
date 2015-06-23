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
// File        : sata_phy_dev_ctrl_x6series.v
// Author      : J.Bean
// Date        : Mar 2012
// Description : SATA PHY Layer Device Control Xilinx 6 Series
////////////////////////////////////////////////////////////

`resetall
`timescale 1ns/10ps

`include "sata_constants.v"

module sata_phy_dev_ctrl_x6series
  #(parameter SATA_REV = 1)(              // SATA Revision (1, 2, 3)
  input  wire         clk_phy,	           // Clock PHY
  input  wire         rst_n,	             // Reset
  output reg          link_up_o,          // Link Up     
  // Transceiver  
  input  wire         gt_rst_done_i,      // GT Reset Done
  output reg  [31:0]  gt_tx_data_o,	      // GT Transmit Data
  output reg  [3:0]   gt_tx_charisk_o,	   // GT Transmit K/D
  output reg          gt_tx_com_strt_o,	  // GT Transmit	COM Start
  output reg          gt_tx_com_type_o,	  // GT Transmit COM Type
  output reg          gt_tx_elec_idle_o,  // GT Transmit Electrical Idle	                   
  input  wire [31:0]  gt_rx_data_i,       // GT Receive Data                
  input  wire [2:0]   gt_rx_status_i      // GT Receive Status
);

////////////////////////////////////////////////////////////
// Parameters
//////////////////////////////////////////////////////////// 

// Time delays
parameter SATA1_10MS            = 750000;   // 75MHz * 750000
parameter SATA2_10MS            = 1500000;  // 150MHz * 1500000
parameter SATA3_10MS            = 3000000;  // 300MHz * 3000000
parameter SATA1_55US            = 4095;     // 75MHz * 4095
parameter SATA2_55US            = 8190;     // 150MHz * 8190
parameter SATA3_55US            = 16380;    // 300MHz * 16380

// State machine states
parameter DP1_RESET             = 0;
parameter DP2_COMINIT           = 1;
parameter DP3_AWAIT_COMWAKE     = 2;
parameter DP3B_AWAIT_NO_COMWAKE = 3;
parameter DP4_CALIBRATE         = 4;
parameter DP5_COMWAKE           = 5;
parameter DP6_SEND_ALIGN        = 6;
parameter DP7_READY             = 7;
parameter DP11_ERROR            = 8;

////////////////////////////////////////////////////////////
// Signals
//////////////////////////////////////////////////////////// 

reg  [3:0]   state_cs;          // Current state
reg  [3:0]   state_ns;          // Next state  
reg  [199:0] state_ascii;       // ASCII state
reg	 [31:0]	 align_timeout_cnt; // ALIGN Timeout Count
reg  [31:0]  retry_cnt;         // Retry Count 
wire         comreset_detect;   // COMRESET Detect
wire         comwake_detect;    // COMWAKE Detect
wire         align_detect;      // ALIGN Detected
reg          tx_com_strt;       // Transmit COM Start
wire         tx_com_strt_pedge; // Transmit COM Start Positive Edge
reg          tx_com_done;       // Transmit COM Done

////////////////////////////////////////////////////////////
// Instance    : Transmit Com Start Pos Edge
// Description : Detect positive edge on COM start signal.
////////////////////////////////////////////////////////////
  
det_pos_edge U_tx_com_strt_pedge(
  .clk   (clk_phy),
  .rst_n (rst_n),
  .d     (tx_com_strt),
  .q     (tx_com_strt_pedge));
  
////////////////////////////////////////////////////////////
// Comb Assign : ALIGN primitive detect
// Description : 
////////////////////////////////////////////////////////////

assign align_detect = (gt_rx_data_i == 32'h7B4A4ABC); 

////////////////////////////////////////////////////////////
// Comb Assign : COMWAKE Detect
// Description : 
////////////////////////////////////////////////////////////

assign comwake_detect = gt_rx_status_i[1];

////////////////////////////////////////////////////////////
// Comb Assign : COMRESET Detect
// Description : 
////////////////////////////////////////////////////////////

assign comreset_detect = gt_rx_status_i[2];
 
////////////////////////////////////////////////////////////
// Seq Block   : State machine seq logic
// Description : Sets the current state to the next state.
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin
  if (rst_n == 0) begin
    state_cs <= DP1_RESET;   
  end else begin
    if (comreset_detect == 1) begin
      state_cs <= DP1_RESET;   
    end else begin
      state_cs <= state_ns;
    end
  end
end  

////////////////////////////////////////////////////////////
// Comb Block  : State machine ascii 
// Description : Converts the state to ascii for debug.
////////////////////////////////////////////////////////////

always @(*)
begin
  case (state_cs)
    DP1_RESET:             state_ascii = "DP1_RESET";
    DP2_COMINIT:           state_ascii = "DP2_COMINIT";
    DP3_AWAIT_COMWAKE:     state_ascii = "DP3_AWAIT_COMWAKE";
    DP3B_AWAIT_NO_COMWAKE: state_ascii = "DP3B_AWAIT_NO_COMWAKE";
    DP4_CALIBRATE:         state_ascii = "DP4_CALIBRATE";
    DP5_COMWAKE:           state_ascii = "DP5_COMWAKE";
    DP6_SEND_ALIGN:        state_ascii = "DP6_SEND_ALIGN";
    DP7_READY:             state_ascii = "DP7_READY";
    DP11_ERROR:            state_ascii = "DP11_ERROR"; 
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
    // DP1_RESET - Interface quiescent
    DP1_RESET: begin
      if ((gt_rst_done_i == 1) && (comreset_detect == 0)) begin
        state_ns = DP2_COMINIT; 
      end  
    end
    
    // DP2_COMINIT - Send COMINIT
    DP2_COMINIT: begin
      if (tx_com_done == 1) begin
        state_ns = DP3_AWAIT_COMWAKE;
      end  
    end    
    
    // DP3_AWAIT_COMWAKE - Wait for COMWAKE to be detected
    DP3_AWAIT_COMWAKE: begin
      if (comwake_detect == 1) begin
        state_ns = DP3B_AWAIT_NO_COMWAKE; 
      end else begin
        if (retry_cnt == 0) begin
          state_ns = DP1_RESET;
        end
      end    
    end        
    
    // DP3B_AWAIT_NO_COMWAKE - Wait for COMWAKE to finish
    DP3B_AWAIT_NO_COMWAKE: begin
      if (comwake_detect == 0) begin
        state_ns = DP4_CALIBRATE; 
      end          
    end        
    
    // DP4_CALIBRATE 
    DP4_CALIBRATE: begin
      state_ns = DP5_COMWAKE;
    end   

    // DP5_COMWAKE - Send COMWAKE
    DP5_COMWAKE: begin
      if (tx_com_done == 1) begin
        state_ns = DP6_SEND_ALIGN;
      end      
    end     
    
    // DP6_SEND_ALIGN - Send ALIGN
    DP6_SEND_ALIGN: begin
      if (align_detect == 1) begin
        state_ns = DP7_READY; 
      end else begin
        if (align_timeout_cnt == 0) begin
          state_ns = DP11_ERROR;
        end      
      end     
    end   
    
    // DP7_READY - Link ready
    DP7_READY: begin
      state_ns = DP7_READY;    
    end   
    
    // DP11_ERROR
    DP11_ERROR: begin
      state_ns = DP1_RESET; 
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
      // DP7_READY - Link ready
      DP7_READY: begin
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
// Description : 
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
// Seq Block   : Transmit COM Type
// Description : 
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
    gt_tx_com_type_o <= 0;
  end	else begin
    case (state_cs)
      // DP2_COMINIT - Send COMINIT
      DP2_COMINIT: begin
        gt_tx_com_type_o <= 0;	      
      end          
  
      // DP5_COMWAKE - Send COMWAKE
      DP5_COMWAKE: begin
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
      // DP5_COMWAKE - Send COMWAKE
      DP5_COMWAKE: begin
        if (tx_com_done == 1) begin
          gt_tx_elec_idle_o <= 0;	
        end         
      end     
    
      // DP6_SEND_ALIGN - Send ALIGN
      DP6_SEND_ALIGN: begin
        gt_tx_elec_idle_o <= 0;	    
      end 
      
      // DP7_READY - Link ready
      DP7_READY: begin
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
      // DP6_SEND_ALIGN - Send ALIGN
      DP6_SEND_ALIGN: begin
        gt_tx_data_o <= `ALIGN_VAL; // ALIGN;        
      end 
      
      // DP7_READY - Link ready
      DP7_READY: begin
        gt_tx_data_o <= `SYNC_VAL;  // SYNC;     
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
      // DP6_SEND_ALIGN - Send ALIGN
      DP6_SEND_ALIGN: begin
        gt_tx_charisk_o <= 4'b0001; // ALIGN;        
      end 
      
      // DP7_READY - Link ready
      DP7_READY: begin
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
      // DP2_COMINIT - Send COMINIT
      DP2_COMINIT: begin
        tx_com_strt <= 1;		     
      end          

      // DP5_COMWAKE - Send COMWAKE
      DP5_COMWAKE: begin
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
// Description : 
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
    tx_com_done <= 0;
  end	else begin
    case (state_cs)   
      // DP1_RESET - Interface quiescent
      DP1_RESET: begin
        tx_com_done <= 0;
      end
      
      // DP2_COMINIT - Send COMINIT
      DP2_COMINIT: begin
        if (gt_rx_status_i[0] == 1) begin
          tx_com_done <= 1;
        end     
      end    
    
      // DP5_COMWAKE - Send COMWAKE
      DP5_COMWAKE: begin
        if (gt_rx_status_i[0] == 1) begin
          tx_com_done <= 1;
        end   
      end  
      
      default: begin
        tx_com_done <= 0;
      end
    endcase     
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : ALIGN Timeout Count
// Description : Error if ALIGN not detected within 54.6us.
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
		align_timeout_cnt <= 0;
	end	else begin
    case (state_cs)     
      // DP1_RESET - Interface quiescent
      DP1_RESET: begin
        case (SATA_REV)
          1:       align_timeout_cnt <= SATA1_55US;
          2:       align_timeout_cnt <= SATA2_55US;
          3:       align_timeout_cnt <= SATA3_55US;    
          default: align_timeout_cnt <= SATA1_55US;    
        endcase   
      end  
      
      // DP6_SEND_ALIGN - Send ALIGN
      DP6_SEND_ALIGN: begin
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
      // DP1_RESET - Interface quiescent
      DP1_RESET: begin
        case (SATA_REV)
          1:       retry_cnt <= SATA1_10MS;
          2:       retry_cnt <= SATA2_10MS;
          3:       retry_cnt <= SATA3_10MS;    
          default: retry_cnt <= SATA1_10MS;    
        endcase	       
      end
      
      // DP3_AWAIT_COMWAKE - Wait for COMWAKE to be detected
      DP3_AWAIT_COMWAKE: begin
        retry_cnt <= retry_cnt - 1;
      end  
    endcase	  
	end
end

endmodule