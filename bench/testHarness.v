// -------------------------- testHarness.v -----------------------
`include "timescale.v"

module testHarness ();

reg rst;
reg clk; 
reg i2cHostClk;
wire sda;
wire scl;
wire sdaOutEn;
wire sdaOut;
wire sdaIn;
wire [2:0] adr;
wire [7:0] masterDout;
wire [7:0] masterDin;
wire we;
wire stb;
wire cyc;
wire ack;
wire scl_pad_i;
wire scl_pad_o;
wire scl_padoen_o;
wire sda_pad_i;
wire sda_pad_o;
wire sda_padoen_o;

initial begin
$dumpfile("wave.vcd");
$dumpvars(0, testHarness); 
end


i2cSlave u_i2cSlave(
  .clk(clk),
  .rst(rst),
  .sda(sda),
  .scl(scl),
  .myReg0(),
  .myReg1(),
  .myReg2(),
  .myReg3(),
  .myReg4(8'h12),
  .myReg5(8'h34),
  .myReg6(8'h56),
  .myReg7(8'h78)
);

i2c_master_top #(.ARST_LVL(1'b1)) u_i2c_master_top (
  .wb_clk_i(clk), 
  .wb_rst_i(rst),
  .arst_i(rst),
  .wb_adr_i(adr),
  .wb_dat_i(masterDout),
  .wb_dat_o(masterDin),
  .wb_we_i(we),
  .wb_stb_i(stb),
  .wb_cyc_i(cyc),
  .wb_ack_o(ack),
  .wb_inta_o(),
  .scl_pad_i(scl_pad_i),
  .scl_pad_o(scl_pad_o),
  .scl_padoen_o(scl_padoen_o),
  .sda_pad_i(sda_pad_i),
  .sda_pad_o(sda_pad_o),
  .sda_padoen_o(sda_padoen_o)
);

wb_master_model #(.dwidth(8), .awidth(3)) u_wb_master_model (
  .clk(clk), 
  .rst(rst), 
  .adr(adr), 
  .din(masterDin), 
  .dout(masterDout), 
  .cyc(cyc), 
  .stb(stb), 
  .we(we), 
  .sel(), 
  .ack(ack), 
  .err(1'b0), 
  .rty(1'b0)
);

assign sda = (sda_padoen_o == 1'b0) ? sda_pad_o : 1'bz;
assign sda_pad_i = sda;
pullup(sda);

assign scl = (scl_padoen_o == 1'b0) ? scl_pad_o : 1'bz;
assign scl_pad_i = scl;
pullup(scl);


// ******************************  Clock section  ******************************
//approx 48MHz clock
`define CLK_HALF_PERIOD 10
always begin
  #`CLK_HALF_PERIOD clk <= 1'b0;
  #`CLK_HALF_PERIOD clk <= 1'b1;
end


// ******************************  reset  ****************************** 
task reset;
begin
  rst <= 1'b1;
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  rst <= 1'b0;
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
end
endtask

endmodule
