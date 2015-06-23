
module usbDeviceXilinxTop (

  //
  // Global signals
  //
  clk,

  //
  // misc Starter Kit control sigs
  //
  E_NRST,
  SPI_SCK,
  NF_CE,
  SD_CS,

  //
  // USB slave
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

  //
  // misc Starter Kit control sigs
  //
  output E_NRST;
  output SPI_SCK;
  output NF_CE;
  output SD_CS;

  //
  // USB slave
  //
  inout usbSlaveVP;
  inout usbSlaveVM;
  output usbSlaveOE_n;
  output usbDPlusPullup;

//local wires and regs
reg [1:0] rstReg;
wire rst;
wire pll_locked;
wire clk48MHz;


assign E_NRST = 1'b0;
assign SPI_SCK = 1'b0;
assign NF_CE = 1'b0;
assign SD_CS = 1'b1;


pll_48MHz_xilinx	pll_48MHz_inst (
	.CLKIN_IN ( clk ),
   .CLK0_OUT (clk48MHz),
	.LOCKED_OUT( pll_locked)
	);

//generate sync reset from pll lock signal
always @(posedge clk48MHz) begin
  rstReg[1:0] <= {rstReg[0], ~pll_locked};
end
assign rst = rstReg[1];


usbDevice u_usbDevice (
  .clk(clk48MHz),
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

endmodule


