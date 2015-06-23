///////////////////////////////////////////////////////////////////////////////
//
// AXI4-Lite Master BFM
//
////////////////////////////////////////////////////////////////////////////
//
// Structure:
//   axi_lite_master_bfm
//
// Last Update:
//   13/8/2012
////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module axi_lite_master_bfm #
   (
    parameter integer C_M_AXI_ADDR_WIDTH = 32,
    parameter integer C_M_AXI_DATA_WIDTH = 32
    )
   (
    // System Signals
    input wire M_AXI_ACLK,
    input wire M_AXI_ARESETN,

    // Master Interface Write Address
    output wire [C_M_AXI_ADDR_WIDTH-1:0] M_AXI_AWADDR,
    output wire [3-1:0] M_AXI_AWPROT,
    output wire M_AXI_AWVALID,
    input wire M_AXI_AWREADY,

    // Master Interface Write Data
    output wire [C_M_AXI_DATA_WIDTH-1:0] M_AXI_WDATA,
    output wire [C_M_AXI_DATA_WIDTH/8-1:0] M_AXI_WSTRB,
    output wire M_AXI_WVALID,
    input wire M_AXI_WREADY,

    // Master Interface Write Response
    input wire [2-1:0] M_AXI_BRESP,
    input wire M_AXI_BVALID,
    output wire M_AXI_BREADY,

    // Master Interface Read Address
    output wire [C_M_AXI_ADDR_WIDTH-1:0] M_AXI_ARADDR,
    output wire [3-1:0] M_AXI_ARPROT,
    output wire M_AXI_ARVALID,
    input wire M_AXI_ARREADY,

    // Master Interface Read Data 
    input wire [C_M_AXI_DATA_WIDTH-1:0] M_AXI_RDATA,
    input wire [2-1:0] M_AXI_RRESP,
    input wire M_AXI_RVALID,
    output wire M_AXI_RREADY,

    // External Signals
    input wire INTR_IN
    );

   // AXI4 signals
   reg 		awvalid;
   reg 		wvalid;
   reg 		push_write;
   reg 		pop_read;
   reg          arvalid;
   reg          rready;
   reg          bready;
   reg [31:0] 	awaddr;
   reg [31:0] 	wdata;
   reg [31:0] 	araddr;
   wire 	write_resp_error;
   wire         read_resp_error;
   
/////////////////
//I/O Connections
/////////////////
//////////////////// 
//Write Address (AW)
////////////////////
assign M_AXI_AWADDR = awaddr;
   
assign M_AXI_WDATA = wdata;
assign M_AXI_AWPROT = 3'h0;
assign M_AXI_AWVALID = awvalid;

///////////////
//Write Data(W)
///////////////
assign M_AXI_WVALID = wvalid;

//Set all byte strobes in this example
assign M_AXI_WSTRB = -1;

////////////////////
//Write Response (B)
////////////////////
assign M_AXI_BREADY = bready;

///////////////////   
//Read Address (AR)
///////////////////
assign M_AXI_ARADDR = araddr;
assign M_AXI_ARVALID = arvalid;
assign M_AXI_ARPROT = 3'b0;

////////////////////////////
//Read and Read Response (R)
////////////////////////////
assign M_AXI_RREADY = rready;
   
///////////////////////
//Write Address Channel
///////////////////////
/*
 The purpose of the write address channel is to request the address and 
 command information for the entire transaction.  It is a single beat
 of information.
 
 Note for this example the awvalid/wvalid are asserted at the same
 time, and then each is deasserted independent from each other.
 This is a lower-performance, but simplier control scheme.
 
 AXI VALID signals must be held active until accepted by the partner.
 
 A data transfer is accepted by the slave when a master has
 VALID data and the slave acknoledges it is also READY. While the master
 is allowed to generated multiple, back-to-back requests by not 
 deasserting VALID, this design will add an extra rest cycle for
 simplicity.
 
 Since only one outstanding transaction is issued by the user design,
 there will not be a collision between a new request and an accepted
 request on the same clock cycle. Otherwise, an additional clause is 
 necessary.
 */
always @(posedge M_AXI_ACLK)
  begin
     
     //Only VALID signals must be deasserted during reset per AXI spec
     //Consider inverting then registering active-low reset for higher fmax
     if (M_AXI_ARESETN == 0 )
       awvalid <= 1'b0;

     //Address accepted by interconnect/slave
     else if (M_AXI_AWREADY && awvalid)
       awvalid <= 1'b0;

     //Signal a new address/data command is available by user logic
     else if (push_write)
       awvalid <= 1'b1;
     else
       awvalid <= awvalid;
  end 

////////////////////
//Write Data Channel
////////////////////
/*
 The write data channel is for transfering the actual data.
 
 The data generation is specific to the example design, and
 so only the WVALID/WREADY handshake is shown here
*/
   always @(posedge M_AXI_ACLK)
  begin
      if (M_AXI_ARESETN == 0 )
	wvalid <= 1'b0;
     
     //Data accepted by interconnect/slave
      else if (M_AXI_WREADY && wvalid)
	wvalid <= 1'b0;

     //Signal a new address/data command is available by user logic
     else if (push_write)
       wvalid <= 1'b1;
     else
       wvalid <= awvalid;
  end 

////////////////////////////
//Write Response (B) Channel
////////////////////////////
/* 
 The write response channel provides feedback that the write has committed
 to memory. BREADY will occur after both the data and the write address
 has arrived and been accepted by the slave, and can guarantee that no
 other accesses launched afterwards will be able to be reordered before it.
 
 The BRESP bit [1] is used indicate any errors from the interconnect or
 slave for the entire write burst. This example will capture the error.
 
 While not necessary per spec, it is advisable to reset READY signals in
 case of differing reset latencies between master/slave.
 */

//Always accept write responses
always @(posedge M_AXI_ACLK)
  begin
     if (M_AXI_ARESETN == 0)
 	  bready <= 1'b0;
      else
 	  bready <= 1'b1;
  end

//Flag write errors
assign write_resp_error = bready & M_AXI_BVALID & M_AXI_BRESP[1];
   
//////////////////////   
//Read Address Channel
//////////////////////
always @(posedge M_AXI_ACLK)
  begin
     if (M_AXI_ARESETN == 0 )
       arvalid <= 1'b0;
     else if (M_AXI_ARREADY && arvalid)
       arvalid <= 1'b0;
     else if (pop_read)
       arvalid <= 1'b1;
     else
       arvalid <= arvalid;
  end 

//////////////////////////////////   
//Read Data (and Response) Channel
//////////////////////////////////
/* 
 The Read Data channel returns the results of the read request 
 
 In this example the data checker is always able to accept
 more data, so no need to throttle the RREADY signal. 
 
 While not necessary per spec, it is advisable to reset READY signals in
 case of differing reset latencies between master/slave.
 */ 
always @(posedge M_AXI_ACLK)
  begin
     if (M_AXI_ARESETN == 0)
 	  rready <= 1'b0;
      else
 	  rready <= 1'b1;
   end

//Flag write errors
assign read_resp_error = rready & M_AXI_RVALID & M_AXI_RRESP[1];  

////////////
//User Logic
////////////

///////////////////////
//Main write controller
///////////////////////
/*  
 By only issuing one request at a time, the control logic is 
 simplified.
 
 Request a new write if:
  -A command was not just submitted
  -AW and W channels are both idle
  -A new request was not requested last cycle
 */
/*always @(posedge M_AXI_ACLK)
  begin
      if (M_AXI_ARESETN == 0 )
	begin
	   push_write <= 1'b0;
	end

      //Request new write
      else if (~awvalid && ~wvalid && ~push_write)
	begin
	   push_write <= 1'b1;
	end
      else
	begin
	   push_write <= 1'b0; //Negate to generate a pulse
	end
  end */

//////////////////////
//Main read controller
//////////////////////
/*
 By only issuing one request at a time, the control logic is 
 simplified.

 Request a new read if:
  -A command was not just submitted
  -AR channel is idle
  -A new request was not requested last cycle
 */
/*always @(posedge M_AXI_ACLK)
  begin
     if (M_AXI_ARESETN == 0 )
       begin
	  pop_read <= 1'b0;
       end

     //Request new read
     else if (~arvalid && ~pop_read)
       begin
	  pop_read <= 1'b1;	  
       end
     else
       begin
	  pop_read <= 1'b0; //Negate to generate a pulse
       end
  end */


task axi4_wr_req(input [31:0]addr, input [31:0]data);
integer i;
begin
  $write("axi4_wr %08x", addr);
  $write(" %08x", data);
  for (i=0; i<1; i=i+1) @(posedge M_AXI_ACLK);
  awaddr     = addr;
  wdata      = data;
  push_write = 1'b1;
  for (i=0; i<1; i=i+1) @(posedge M_AXI_ACLK);
  awaddr     = addr;
  wdata      = data;
  push_write = 1'b0;
  for (i=0; i<1; i=i+1) @(posedge M_AXI_ACLK);
  @(~awvalid && ~wvalid);
end
endtask

task axi4_rd_req(input [31:0]addr);
integer i;
begin
  $write("axi4_rd %08x", addr);
  for (i=0; i<1; i=i+1) @(posedge M_AXI_ACLK);
  araddr   = addr;
  pop_read = 1'b1;
  for (i=0; i<1; i=i+1) @(posedge M_AXI_ACLK);
  araddr   = addr;
  pop_read = 1'b0;
  for (i=0; i<1; i=i+1) @(posedge M_AXI_ACLK);
  @(~arvalid);
end
endtask

task axi4_wr_ack;
begin
  @(M_AXI_BVALID && bready);
  @(posedge M_AXI_ACLK);
  $write(" W_RESP: %08x\n", M_AXI_BRESP);
end
endtask

task axi4_rd_ack;
begin
  @(M_AXI_RVALID && rready);
  @(posedge M_AXI_ACLK);
  $write(" %08x", M_AXI_RDATA);
  $write(" R_RESP: %08x\n", M_AXI_RRESP);
end
endtask

initial begin
  #300;
  @(posedge M_AXI_ACLK);
  axi4_wr_req(32'h00000004,32'h12345678);axi4_wr_ack;
  axi4_rd_req(32'h00000004             );axi4_rd_ack;
end

endmodule
