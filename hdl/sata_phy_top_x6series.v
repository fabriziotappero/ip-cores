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
// File        : sata_phy_top_x6series.v
// Author      : J.Bean
// Date        : Mar 2012
// Description : SATA PHY Layer Top Xilinx 6 Series
////////////////////////////////////////////////////////////

`resetall
`timescale 1ns/10ps

`include "sata_constants.v"

module sata_phy_top_x6series
  #(parameter DATA_BITS = 32,                         // Data Bits
    parameter IS_HOST   = 1,                          // 1 = Host, 0 = Device  
    parameter SATA_REV  = 1)(                         // SATA Revision (1, 2, 3)
  input  wire                     clk,                // Clock
  input  wire                     clk_phy,            // Clock PHY
  input  wire                     rst_n,              // Reset
  // Link Transmit
  input  wire [DATA_BITS-1:0]     lnk_tx_tdata_i,     // Link Transmit Data 
  input  wire                     lnk_tx_tvalid_i,    // Link Transmit Source Ready 
  output wire                     lnk_tx_tready_o,    // Link Transmit Destination Ready
  input  wire [3:0]               lnk_tx_tuser_i,     // Link Transmit User
  // Link Receive
  output wire [DATA_BITS-1:0]     lnk_rx_tdata_o,     // Link Receive Data 
  output wire                     lnk_rx_tvalid_o,    // Link Receive Source Ready     
  input  wire                     lnk_rx_tready_i,    // Link Receive Destination Ready     
  output wire [7:0]               lnk_rx_tuser_o,     // Link Receive User    
  // Status
  output wire [7:0]               phy_status_o,       // PHY Status      
  // Transceiver
  input  wire                     gt_rst_done_i,      // GT Reset Done
  input  wire [15:0]              gt_rx_data_i,       // GT Receive Data
  input  wire [1:0]               gt_rx_charisk_i,    // GT Receive K/D
  input  wire [1:0]               gt_rx_disp_err_i,   // GT Receive Disparity Error
  input  wire [1:0]               gt_rx_8b10b_err_i,  // GT Receive 8b10b Error
  input  wire                     gt_rx_elec_idle_i,  // GT Receive Electrical Idle
  input  wire [2:0]               gt_rx_status_i,     // GT Receive Status     
  output wire [15:0]              gt_tx_data_o,       // GT Transmit Data
  output wire [1:0]               gt_tx_charisk_o,    // GT Transmit K/D
  output wire                     gt_tx_elec_idle_o,  // GT Transmit Electrical Idle
  output wire                     gt_tx_com_strt_o,   // GT Transmit Com Start 
  output wire                     gt_tx_com_type_o    // GT Transmit Com Type
);

////////////////////////////////////////////////////////////
// Signals
//////////////////////////////////////////////////////////// 

wire                 link_up;         // Link Up
reg                  tx_data_mux_sel; // Transmit Mux Data Select
reg  [7:0]           rx_data_mux_sel; // Receive Mux Data Select
wire [31:0]          gt_rx_data;      // GT Receive Data
reg  [31:0]          gt_rx_data_r;    // GT Receive Data
wire [3:0]           gt_rx_charisk;   // GT Receive K/D
reg  [3:0]           gt_rx_charisk_r; // GT Receive K/D
wire [3:0]           gt_rx_err;       // GT Receive Error
reg  [3:0]           gt_rx_err_r;     // GT Receive Error
reg                  gt_rx_valid;     // GT Receive Valid
reg  [47:0]          gt_rx_data_sr;   // GT Receive Data Shift Reg
reg  [5:0]           gt_rx_k_sr;      // GT Receive K/D Shift Reg
reg  [5:0]           gt_rx_err_sr;    // GT Receive Error Shift Reg
wire [31:0]          gt_tx_data;      // GT Transmit Data
wire [3:0]           gt_tx_charisk;   // GT Transmit K/D
wire [DATA_BITS-1:0] lnk_tx_tdata;    // Link Transmit Data
wire                 lnk_tx_tvalid;   // Link Transmit Source Ready  
reg                  lnk_tx_tready;   // Link Transmit Destination Ready
wire [3:0]           lnk_tx_tuser;    // Link Transmit User 
wire [DATA_BITS-1:0] lnk_rx_tdata;    // Link Receive Data
wire                 lnk_rx_tvalid;   // Link Receive Source Ready  
wire                 lnk_rx_tready;   // Link Receive Destination Ready
wire [7:0]           lnk_rx_tuser;    // Link Receive User

////////////////////////////////////////////////////////////
// Comb Assign : PHY Status
// Description : 
////////////////////////////////////////////////////////////

assign phy_status_o = {7'd0, link_up};

////////////////////////////////////////////////////////////
// Comb Assign : Port Signals
// Description : 
////////////////////////////////////////////////////////////

assign lnk_rx_tdata      = gt_rx_data_r;
assign lnk_rx_tvalid     = gt_rx_valid;
assign lnk_rx_tuser[3:0] = gt_rx_charisk_r;
assign lnk_rx_tuser[7:4] = gt_rx_err_r;

////////////////////////////////////////////////////////////
// Instance    : PHY Transmit FIFO
// Description : 
////////////////////////////////////////////////////////////

axis_fifo_36W_16D U_phy_tx_fifo(
  .m_aclk        (clk_phy), 
  .s_aclk        (clk), 
  .s_aresetn     (rst_n), 
  .s_axis_tdata  (lnk_tx_tdata_i),
  .s_axis_tuser  (lnk_tx_tuser_i),  
  .s_axis_tvalid (lnk_tx_tvalid_i),
  .s_axis_tready (lnk_tx_tready_o),
  .m_axis_tdata  (lnk_tx_tdata),
  .m_axis_tuser  (lnk_tx_tuser),  
  .m_axis_tvalid (lnk_tx_tvalid), 
  .m_axis_tready (lnk_tx_tready));
  
////////////////////////////////////////////////////////////
// Instance    : PHY Receive FIFO
// Description : 
////////////////////////////////////////////////////////////

axis_fifo_40W_16D U_phy_rx_fifo(
  .m_aclk        (clk), 
  .s_aclk        (clk_phy), 
  .s_aresetn     (rst_n), 
  .s_axis_tdata  (lnk_rx_tdata),
  .s_axis_tuser  (lnk_rx_tuser),  
  .s_axis_tvalid (lnk_rx_tvalid),
  .s_axis_tready (lnk_rx_tready),
  .m_axis_tdata  (lnk_rx_tdata_o),
  .m_axis_tuser  (lnk_rx_tuser_o),  
  .m_axis_tvalid (lnk_rx_tvalid_o), 
  .m_axis_tready (lnk_rx_tready_i));

////////////////////////////////////////////////////////////
// Instance    : GT Receive Data
// Description : 
////////////////////////////////////////////////////////////
  
mux #(
  .DATA_BITS  (DATA_BITS),
  .IP_NUM     (2),
  .USE_OP_REG (0))
  U_rx_data_mux(
  .clk        (clk_phy),
  .data_i     ({gt_rx_data_sr[39:8], gt_rx_data_sr[31:0]}),
  .sel_i      (rx_data_mux_sel),
  .data_o     (gt_rx_data));

////////////////////////////////////////////////////////////
// Instance    : GT Receive K/D
// Description : 
////////////////////////////////////////////////////////////
  
mux #(
  .DATA_BITS  (4),
  .IP_NUM     (2),
  .USE_OP_REG (0))
  U_rx_charisk_mux(
  .clk        (clk_phy),
  .data_i     ({gt_rx_k_sr[4:1], gt_rx_k_sr[3:0]}),
  .sel_i      (rx_data_mux_sel),
  .data_o     (gt_rx_charisk));
    
////////////////////////////////////////////////////////////
// Instance    : GT Receive Error
// Description : 
////////////////////////////////////////////////////////////

mux #(
  .DATA_BITS  (4),
  .IP_NUM     (2),
  .USE_OP_REG (0))
  U_rx_err_mux(
  .clk        (clk_phy),
  .data_i     ({gt_rx_err_sr[4:1], gt_rx_err_sr[3:0]}),
  .sel_i      (rx_data_mux_sel),
  .data_o     (gt_rx_err));

////////////////////////////////////////////////////////////
// Instance    : GT Transmit Data
// Description : 
////////////////////////////////////////////////////////////
  
mux #(
  .DATA_BITS  (16),
  .IP_NUM     (4),
  .USE_OP_REG (1))
  U_txdata_mux(
  .clk        (clk_phy),
  .data_i     ({lnk_tx_tdata[31:16], lnk_tx_tdata[15:0], gt_tx_data[31:16], gt_tx_data[15:0]}),
  .sel_i      ({6'd0, link_up, tx_data_mux_sel}),
  .data_o     (gt_tx_data_o));

////////////////////////////////////////////////////////////
// Instance    : GT Transmit K/D
// Description : 
////////////////////////////////////////////////////////////

mux #(
  .DATA_BITS  (2),
  .IP_NUM     (4),
  .USE_OP_REG (1))
  U_txcharisk_mux(
  .clk        (clk_phy),
  .data_i     ({lnk_tx_tuser[3:2], lnk_tx_tuser[1:0], gt_tx_charisk[3:2], gt_tx_charisk[1:0]}),
  .sel_i      ({6'd0, link_up, tx_data_mux_sel}),
  .data_o     (gt_tx_charisk_o));

////////////////////////////////////////////////////////////
// Instance    : SATA Spartan 6 PHY Control
// Description : 
////////////////////////////////////////////////////////////
  
generate 
  if (IS_HOST == 1) begin
    sata_phy_host_ctrl_x6series #(
      .SATA_REV          (SATA_REV))
      U_phy_host_ctrl_x6series(
      .clk_phy           (clk_phy),
      .rst_n		      		   (rst_n),
      .link_up_o         (link_up), 
      .gt_rst_done_i     (gt_rst_done_i),  
      .gt_tx_data_o      (gt_tx_data),		         
      .gt_tx_charisk_o   (gt_tx_charisk),  
      .gt_tx_com_strt_o  (gt_tx_com_strt_o),
      .gt_tx_com_type_o  (gt_tx_com_type_o),
      .gt_tx_elec_idle_o (gt_tx_elec_idle_o),     
      .gt_rx_data_i      (lnk_rx_tdata_o),                                                                  
      .gt_rx_status_i    (gt_rx_status_i),
      .gt_rx_elec_idle_i (gt_rx_elec_idle_i));
  end else begin
    sata_phy_dev_ctrl_x6series #(
      .SATA_REV          (SATA_REV))
      U_phy_dev_ctrl_x6series(
      .clk_phy           (clk_phy),
      .rst_n		      		   (rst_n),
      .link_up_o         (link_up), 
      .gt_rst_done_i     (gt_rst_done_i),  
      .gt_tx_data_o      (gt_tx_data),		         
      .gt_tx_charisk_o   (gt_tx_charisk),   
      .gt_tx_com_strt_o  (gt_tx_com_strt_o),
      .gt_tx_com_type_o  (gt_tx_com_type_o),
      .gt_tx_elec_idle_o (gt_tx_elec_idle_o),     
      .gt_rx_data_i      (lnk_rx_tdata_o),                                                                       
      .gt_rx_status_i    (gt_rx_status_i));
  end
endgenerate  

////////////////////////////////////////////////////////////
// Seq Block   : Receive Data Shift Register
// Description : 
////////////////////////////////////////////////////////////

always@(posedge clk_phy)
begin
  gt_rx_data_sr[47:32] <= gt_rx_data_i;
  gt_rx_data_sr[31:0]  <= gt_rx_data_sr[47:16];
end

////////////////////////////////////////////////////////////
// Seq Block   : Receive K Shift Register
// Description : 
////////////////////////////////////////////////////////////

always@(posedge clk_phy)
begin
  gt_rx_k_sr[5:4] <= gt_rx_charisk_i;
  gt_rx_k_sr[3:0] <= gt_rx_k_sr[5:2];
end

////////////////////////////////////////////////////////////
// Seq Block   : Receive Error Shift Register
// Description : 
////////////////////////////////////////////////////////////

always@(posedge clk_phy)
begin
  gt_rx_err_sr[4]   <= gt_rx_disp_err_i[0] | gt_rx_8b10b_err_i[0];
  gt_rx_err_sr[5]   <= gt_rx_disp_err_i[1] | gt_rx_8b10b_err_i[1];
  gt_rx_err_sr[3:0] <= gt_rx_err_sr[5:2];
end

////////////////////////////////////////////////////////////
// Seq Block   : Link Transmit Desrination Ready
// Description : 
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy)
begin
  if (rst_n == 0) begin
    lnk_tx_tready <= 0;
  end else begin
    if (lnk_tx_tready == 0) begin
      lnk_tx_tready <= 1;    
    end else begin
      lnk_tx_tready <= 0;    
    end      
  end   
end

////////////////////////////////////////////////////////////
// Comb Block  : Transmit Mux Data Select
// Description : Selects 16-bit data to send to the transceiver
//               from the 32-bit data on the mux input.
////////////////////////////////////////////////////////////

always @(*)
begin
  if ((lnk_tx_tvalid == 1) && (lnk_tx_tready == 1)) begin
    tx_data_mux_sel = 0;
  end else begin
    tx_data_mux_sel = 1;  
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : Receive Mux Data Select
// Description : Determines the location of the data in the 
//               GT receive data, and then sets the select.
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy)
begin
  if (rst_n == 0) begin
    rx_data_mux_sel <= 0;
  end else begin
    // Test for the ALIGN primitive in bits 31:0
    if ((gt_rx_k_sr[3:0] == 4'b0001) && (gt_rx_data_sr[31:0] == `ALIGN_VAL)) begin
      rx_data_mux_sel <= 0;    
    end else begin  
      // Test for the ALIGN primitive in bits 39:8
      if ((gt_rx_k_sr[4:1] == 4'b0001) && (gt_rx_data_sr[39:8] == `ALIGN_VAL)) begin
        rx_data_mux_sel <= 1;    
      end
    end
  end   
end

////////////////////////////////////////////////////////////
// Seq Block   : GT Receive Valid
// Description : Indicates when the data is valid. It is 
//               synchronised to the ALIGN primitive.
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy)
begin 
  if (rst_n == 0) begin
    gt_rx_valid <= 0;
  end	else begin
    if ((gt_rx_charisk == 4'b0001) && (gt_rx_data == `ALIGN_VAL)) begin
      gt_rx_valid <= 1;
    end else begin
      if (gt_rx_valid == 1) begin
        gt_rx_valid <= 0;
      end else begin
        gt_rx_valid <= 1;
      end
    end      
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : GT Receive Data
// Description :
////////////////////////////////////////////////////////////

always @(posedge clk_phy)
begin    
  gt_rx_data_r <= gt_rx_data;
end

////////////////////////////////////////////////////////////
// Seq Block   : GT Receive K/D
// Description :
////////////////////////////////////////////////////////////

always @(posedge clk_phy)
begin    
  gt_rx_charisk_r <= gt_rx_charisk;
end

////////////////////////////////////////////////////////////
// Seq Block   : GT Receive Error
// Description :
////////////////////////////////////////////////////////////

always @(posedge clk_phy)
begin    
  gt_rx_err_r <= gt_rx_err;
end

endmodule