/*******************************************************************************
 *
 * Copyright 2013, Sinclair R.F., Inc.
 *
 * Test bench for the AXI4-Lite slave dual-port-ram peripheral.
 *
 ******************************************************************************/

`timescale 1ns/1ps

module tb;

// 125 MHz clock
reg s_clk = 1'b1;
always @ (s_clk)
  s_clk <= #4 ~s_clk;

reg s_rst = 1'b1;
initial begin
  repeat (5) @ (posedge s_clk);
  s_rst = 1'b0;
end

//
// Simulate the AXI4-Lite master
//

reg s_aclk = 1'b1;
always @ (s_aclk)
  s_aclk <= #5 ~s_aclk;

// Command AXI4-Lite writes and reads.
reg s_wr_done;
reg s_rd_done;
reg  [6:0] s_wr_addr    = 7'd0;
reg [31:0] s_wr_data    = 32'd0;
reg  [3:0] s_wr_vld     = 4'b0000;
reg        s_wr_go      = 1'b0;
reg  [6:0] s_rd_addr    = 7'd0;
reg        s_rd_go      = 1'b0;
initial begin
  // 1-byte write
  repeat (1500) @ (posedge s_aclk);
  s_wr_addr <= 7'h03;
  s_wr_data <= 32'h03020100;
  s_wr_vld  <= 4'b1000;
  s_wr_go <= 1'b1; @ (posedge s_aclk); s_wr_go <= 1'b0; wait(s_wr_done); @ (posedge s_aclk);
  // 2-byte write
  repeat (100) @ (posedge s_aclk);
  s_wr_addr <= 7'h06;
  s_wr_data <= 32'h07060504;
  s_wr_vld  <= 4'b1100;
  s_wr_go <= 1'b1; @ (posedge s_aclk); s_wr_go <= 1'b0; wait(s_wr_done); @ (posedge s_aclk);
  // 2-byte write
  repeat (100) @ (posedge s_aclk);
  s_wr_addr <= 7'h08;
  s_wr_data <= 32'h0B0A0908;
  s_wr_vld  <= 4'b0011;
  s_wr_go <= 1'b1; @ (posedge s_aclk); s_wr_go <= 1'b0; wait(s_wr_done); @ (posedge s_aclk);
  // 4-byte write
  repeat (100) @ (posedge s_aclk);
  s_wr_addr <= 7'h0C;
  s_wr_data <= 32'h0F0E0D0C;
  s_wr_vld  <= 4'b0011;
  s_wr_go <= 1'b1; @ (posedge s_aclk); s_wr_go <= 1'b0; wait(s_wr_done); @ (posedge s_aclk);
  // isolated read
  repeat (100) @ (posedge s_aclk);
  s_rd_addr <= 7'd16;
  s_rd_go <= 1'b1; @ (posedge s_aclk); s_rd_go <= 1'b0; wait(s_rd_done); @ (posedge s_aclk);
  // simultaneous read and write
  repeat (100) @ (posedge s_aclk);
  s_wr_addr <= 7'h10;
  s_wr_data <= 32'h13121110;
  s_wr_vld  <= 4'b1111;
  s_rd_addr <= 7'd04;
  s_wr_go <= 1'b1; s_rd_go <= 1'b1; @ (posedge s_aclk); s_wr_go <= 1'b0; s_rd_go <= 1'b0; wait(s_wr_done); wait(s_rd_done); @ (posedge s_aclk);
  // read preceding write by 1 clock cycle
  repeat (100) @ (posedge s_aclk);
  s_rd_addr <= 7'd08;
  s_wr_addr <= 7'h14;
  s_wr_data <= 32'h17161514;
  s_wr_vld  <= 4'b1111;
  s_rd_go <= 1'b1; @ (posedge s_aclk); s_rd_go <= 1'b0;
  s_wr_go <= 1'b1; @ (posedge s_aclk); s_wr_go <= 1'b0;
  wait(s_rd_done); wait(s_wr_done); @ (posedge s_aclk);
  // signal termination to the micro controller by writing a 4 to the byte at address 16;
  repeat (100) @ (posedge s_aclk);
  s_wr_addr <= 7'h10;
  s_wr_data <= 32'h04;
  s_wr_vld  <= 4'b0001;
  s_rd_addr <= 7'd0;
  s_wr_go <= 1'b1; @ (posedge s_aclk); s_wr_go <= 1'b0; wait(s_wr_done); @ (posedge s_aclk);
end

// Initiate writes and indicate their termination.
initial s_wr_done = 1'b0;
reg  [2:0] s_wr_acks = 3'b000;
reg        s_awvalid = 1'b0;
reg        s_wvalid  = 1'b0;
reg        s_bready  = 1'b0;
wire       s_awready;
wire       s_wready;
wire       s_bvalid;
always @ (posedge s_aclk) begin
  s_wr_done <= 1'b0;
  s_wr_acks <= s_wr_acks;
  s_bready <= 1'b0;
  if (s_wr_acks == 3'b111) begin
    s_wr_done <= 1'b1;
    s_wr_acks <= 3'b000;
  end
  if (s_wr_go) begin
    s_awvalid <= 1'b1;
    s_wvalid  <= 1'b1;
  end
  if (s_awvalid && s_awready) begin
    s_awvalid <= 1'b0;
    s_wr_acks[0] <= 1'b1;
  end
  if (s_wvalid && s_wready) begin
    s_wvalid <= 1'b0;
    s_wr_acks[1] <= 1'b1;
  end
  if (s_bvalid && ~s_bready && ~s_wr_acks[2])
    s_bready <= 1'b1;
  if (s_bvalid && s_bready)
    s_wr_acks[2] <= 1'b1;
end

// Initiate reads and indicate their termination
localparam S_INIT_RREADY = 1'b1;        // observed Xilinx behavior -- always high
initial s_rd_done = 1'b0;
reg  [1:0] s_rd_acks = 2'b00;
reg        s_arvalid = 1'b0;
reg        s_rready = 1'b0;
wire       s_arready;
wire       s_rvalid;
always @ (posedge s_aclk) begin
  s_rd_done <= 1'b0;
  s_rd_acks <= s_rd_acks;
  s_rready <= S_INIT_RREADY;
  if (s_rd_acks == 2'b11) begin
    s_rd_done <= 1'b1;
    s_rd_acks <= 2'b00;
  end
  if (s_rd_go)
    s_arvalid <= 1'b1;
  if (s_arvalid && s_arready) begin
    s_arvalid <= 1'b0;
    s_rd_acks[0] <= 1'b1;
  end
  if (s_rvalid && ~s_rready && ~s_rd_acks[1])
    s_rready <= 1'b1;
  if (s_rvalid && s_rready)
    s_rd_acks[1] <= 1'b1;
end

//
// Instantiate the micro controller, its data output, and program termination.
//

wire  [1:0] s_bresp;
wire [31:0] s_rdata;
wire  [1:0] s_rresp;
wire  [7:0] s_addr;
wire  [7:0] s_data;
wire        s_data_wr;
wire        s_done;
tb_AXI4_Lite_Slave_DualPortRAM uut(
  // synchronous reset and processor clock
  .i_rst                (s_rst),
  .i_clk                (s_clk),
  // AXI4-Lite Slave I/F
  .axi_lite_aresetn     (1'b1),
  .axi_lite_aclk        (s_aclk),
  .axi_lite_awvalid     (s_awvalid),
  .axi_lite_awready     (s_awready),
  .axi_lite_awaddr      (s_wr_addr),
  .axi_lite_wvalid      (s_wvalid),
  .axi_lite_wready      (s_wready),
  .axi_lite_wdata       (s_wr_data),
  .axi_lite_wstrb       (s_wr_vld),
  .axi_lite_bresp       (s_bresp),
  .axi_lite_bvalid      (s_bvalid),
  .axi_lite_bready      (s_bready),
  .axi_lite_arvalid     (s_arvalid),
  .axi_lite_arready     (s_arready),
  .axi_lite_araddr      (7'd0),
  .axi_lite_rvalid      (s_rvalid),
  .axi_lite_rready      (s_rready),
  .axi_lite_rdata       (s_rdata),
  .axi_lite_rresp       (s_rresp),
  // diagnostic output
  .o_diag_addr          (s_addr),
  .o_diag_data          (s_data),
  .o_diag_wr            (s_data_wr),
  // program termination
  .o_done               (s_done)
);

always @ (posedge s_clk)
  if (s_data_wr)
    $display("%12d : %h %h", $time, s_addr, s_data);

always @ (posedge s_clk)
  if (s_done)
    $finish;

//initial begin
//  $dumpfile("tb.vcd");
//  $dumpvars();
//end

endmodule
