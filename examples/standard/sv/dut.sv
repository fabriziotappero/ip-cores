
module dut_module (
  rst_n, // reset not
  clk,  //  input clock
  out1,  // output buss one
  out2,  // output buss two
  addr,     //  address
  data_in,  //  write data
  data_out, //  read data
  sel,      //  select
  ack       //  acknowlage out.
);


input          rst_n;
input          clk;
output [31:0]  out1;
output [31:0]  out2;
input  [31:0]  addr;
input  [31:0]  data_in;
input          sel;
output [31:0]  data_out;
output         ack;

logic  rst_n;
logic  clk;
logic  sel;
logic  ack;
logic  [31:0] out1;
logic  [31:0] out2;
logic  [31:0] addr;
logic  [31:0] data_in;
logic  [31:0] data_out;


  initial begin
    out1 =  32'h00000000;
    out2 =  32'h00000000;
    ack  =  1'b0;
    data_out = 32'hzzzzzzzz;
  end


  always @(posedge clk) begin
    if(rst_n  == 0) begin
      out1  = 0;
      out2  = 0;
      data_out = 32'hzzzzzzzz;
      ack   = 0;
    end else if (sel == 1) begin
      if(addr == 0) begin
        out1 = data_in;
      end else begin
        out2 = data_in;
      end
      #1;
      ack  = 1;
      #1;
      ack  = 0;
    end else begin
      ack  = 0;
    end
  end

endmodule // dut_module
