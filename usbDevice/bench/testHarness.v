`include "timescale.v"

module testHarness(	);


// -----------------------------------
// Local Wires
// -----------------------------------
reg clk;
reg rst;
wire [8:0] adr;
wire [7:0] masterDout;
wire [7:0] masterDin;
wire [7:0] usbSlaveDout;
wire [7:0] usbHostDout;
wire stb;
wire we;
wire ack;
wire host_stb;
wire DPlusPullup;
wire DPlusPullDown;
wire DMinusPullup;
wire DMinusPulDown;
reg USBWireVP;
reg USBWireVM;
wire [1:0] hostUSBWireDataIn;
wire [1:0] hostUSBWireDataOut;
wire hostUSBWireCtrlOut;
wire usbSlaveOE_n;
wire usbSlaveVP_out;
wire usbSlaveVM_out;
wire USBDMinusPullup;

assign USBDMinusPullup = 1'b0;

initial begin
$dumpfile("wave.vcd");
$dumpvars(0, testHarness); 
end

pullup(DPlusPullup);
pulldown(DPlusPullDown);
pullup(DMinusPullup);
pulldown(DMinusPullDown);

assign hostUSBWireDataIn = {USBWireVP, USBWireVM};
always @(*) begin
  if (hostUSBWireCtrlOut == 1'b1 && usbSlaveOE_n == 1'b1)
    {USBWireVP, USBWireVM} <= hostUSBWireDataOut;
  else if (hostUSBWireCtrlOut == 1'b0 && usbSlaveOE_n == 1'b0)
    {USBWireVP, USBWireVM} <= {usbSlaveVP_out, usbSlaveVM_out};
  else if (hostUSBWireCtrlOut == 1'b1 && usbSlaveOE_n == 1'b0)
    {USBWireVP, USBWireVM} <= 2'bxx;
  else if (hostUSBWireCtrlOut == 1'b0 && usbSlaveOE_n == 1'b1) begin
    if (USBDPlusPullup == 1'b1)
      USBWireVP <= DPlusPullup;
    else
      USBWireVP <= DPlusPullDown;
    if (USBDMinusPullup == 1'b1)
      USBWireVM <= DMinusPullup;
    else
      USBWireVM <= DMinusPullDown;
  end
end

assign host_stb = stb;
assign masterDin = usbHostDout;

//Parameters declaration: 
defparam u_usbHost.HOST_FIFO_DEPTH = 64;
parameter HOST_FIFO_DEPTH = 64;
defparam u_usbHost.HOST_FIFO_ADDR_WIDTH = 6;
parameter HOST_FIFO_ADDR_WIDTH = 6;
usbHost u_usbHost (
  .clk_i(clk),
  .rst_i(rst),
  .address_i(adr[7:0]),
  .data_i(masterDout),
  .data_o(usbHostDout),
  .we_i(we),
  .strobe_i(host_stb),
  .ack_o(ack),
  .usbClk(clk),
  .hostSOFSentIntOut(hostSOFSentIntOut),
  .hostConnEventIntOut(hostConnEventIntOut),
  .hostResumeIntOut(hostResumeIntOut),
  .hostTransDoneIntOut(hostTransDoneIntOut),
  .USBWireDataIn(hostUSBWireDataIn),
  .USBWireDataInTick(USBWireDataInTick),
  .USBWireDataOut(hostUSBWireDataOut),
  .USBWireDataOutTick(USBWireDataOutTick),
  .USBWireCtrlOut(hostUSBWireCtrlOut),
  .USBFullSpeed(USBFullSpeed)
);

usbDevice u_usbDevice (
  .clk(clk),
  .rst(rst),
  .usbSlaveVP_in(USBWireVP),
  .usbSlaveVM_in(USBWireVM),
  .usbSlaveVP_out(usbSlaveVP_out),
  .usbSlaveVM_out(usbSlaveVM_out),
  .usbSlaveOE_n(usbSlaveOE_n),
  .usbDPlusPullup(USBDPlusPullup),
  .vBusDetect(1'b1)
);


wb_master_model #(.dwidth(8), .awidth(9)) u_wb_master_model (
  .clk(clk), 
  .rst(rst), 
  .adr(adr), 
  .din(masterDin), 
  .dout(masterDout), 
  .cyc(), 
  .stb(stb), 
  .we(we), 
  .sel(), 
  .ack(ack), 
  .err(1'b0), 
  .rty(1'b0)
);


//--------------- reset ---------------
initial begin
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  rst <= 1'b1;
  @(posedge clk);
  rst <= 1'b0;
  @(posedge clk);
end
 
// ******************************  Clock section  ******************************
`define CLK_50MHZ_HALF_PERIOD 10
`define CLK_25MHZ_HALF_PERIOD 20

always begin
  #`CLK_25MHZ_HALF_PERIOD clk <= 1'b0;
  #`CLK_25MHZ_HALF_PERIOD clk <= 1'b1;
end





endmodule

