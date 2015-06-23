module regfile_1w_4r(
   input clk,
   
   input  [71:0] din,
   input  [ 7:0] wraddr,
   input         wren,
   input  [ 7:0] rdaddr0,
   input  [ 7:0] rdaddr1,
   input  [ 7:0] rdaddr2,
   input  [ 7:0] rdaddr3,
   input         rd0,
   input         rd1,
   input         rd2,
   input         rd3,

   output [71:0] dout0,
   output [71:0] dout1,
   output [71:0] dout2,
   output [71:0] dout3
);

reg [7:0] rdaddr0_d;
reg [7:0] rdaddr1_d;
reg [7:0] rdaddr2_d;
reg [7:0] rdaddr3_d;
reg       rd0_d;
reg       rd1_d;
reg       rd2_d;
reg       rd3_d;

always @(posedge clk)
   begin
      rdaddr0_d<=rdaddr0;
      rdaddr1_d<=rdaddr1;
      rdaddr2_d<=rdaddr2;
      rdaddr3_d<=rdaddr3;
      rd0_d<=rd0;
      rd1_d<=rd1;
      rd2_d<=rd2;
      rd3_d<=rd3;
   end

regfile1 regfile_inst0(
   .wrclock(clk),
   .rdclock(~clk),
  
   .data(din),
   .rdaddress(rdaddr0_d),
   .rden(rd0_d),
   .wraddress(wraddr),
   .wren(wren),
   .q(dout0)
);

regfile1 regfile_inst1(
   .wrclock(clk),
   .rdclock(~clk),
  
   .data(din),
   .rdaddress(rdaddr1_d),
   .rden(rd1_d),
   .wraddress(wraddr),
   .wren(wren),
   .q(dout1)
);

regfile1 regfile_inst2(
   .wrclock(clk),
   .rdclock(~clk),
  
   .data(din),
   .rdaddress(rdaddr2_d),
   .rden(rd2_d),
   .wraddress(wraddr),
   .wren(wren),
   .q(dout2)
);

regfile1 regfile_inst3(
   .wrclock(clk),
   .rdclock(~clk),
  
   .data(din),
   .rdaddress(rdaddr3_d),
   .rden(rd3_d),
   .wraddress(wraddr),
   .wren(wren),
   .q(dout3)
);

endmodule
