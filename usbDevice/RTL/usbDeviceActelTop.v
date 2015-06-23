
module usbDeviceActelTop (

  //
  // Global signals
  //
  clk,
  rst_n,

  // eval board features
  ledOut,

  //
  // USB
  //
  usbSlaveVP,
  usbSlaveVM,
  usbSlaveOE_n,
  usbDPlusPullup

);

  //
  // Global signals
  //
  input	clk;
  input rst_n;

  output [9:0] ledOut;

  //
  // USB
  //
  inout usbSlaveVP;
  inout usbSlaveVM;
  output usbSlaveOE_n;
  output usbDPlusPullup;

//local wires and regs
reg [1:0] rstReg;
wire rst;

//generate sync reset
always @(posedge clk) begin
  rstReg[1:0] <= {rstReg[0], ~rst_n};
end
assign rst = rstReg[1];


usbDevice u_usbDevice (
  .clk(clk),
  .rst(rst),
  .usbSlaveVP_in(usbSlaveVP_in),
  .usbSlaveVM_in(usbSlaveVM_in),
  .usbSlaveVP_out(usbSlaveVP_out),
  .usbSlaveVM_out(usbSlaveVM_out),
  .usbSlaveOE_n(usbSlaveOE_n),
  .usbDPlusPullup(usbDPlusPullup),
  .vBusDetect(1'b1)
);


assign {usbSlaveVP_in, usbSlaveVM_in} = {usbSlaveVP, usbSlaveVM};
assign {usbSlaveVP, usbSlaveVM} = (usbSlaveOE_n == 1'b0) ? {usbSlaveVP_out, usbSlaveVM_out} : 2'bzz;


// comfort lights
reg [9:0] ledCntReg;
reg [21:0] cnt;

assign ledOut = ledCntReg;


always @(posedge clk) begin
  if (rst == 1'b1) begin
    ledCntReg <= 10'b00_0000_0000;
    cnt <= {22{1'b0}};
  end
  else begin
    cnt <= cnt + 1'b1;
    if (cnt == {22{1'b0}})
      ledCntReg <= ledCntReg + 1'b1;
  end
end

endmodule


