interface dut_if();
  logic rst_n;
  logic clk;
  logic [31:0] out1;
  logic [31:0] out2;
  logic [31:0] addr;
  logic [31:0] data_in;
  logic [31:0] data_out;
  logic sel;
  logic ack;

  modport dut_conn(
    input   rst_n,
    input   clk,
    output  out1,
    output  out2,
    input   addr,
    input   data_in,
    output  data_out,
    input   sel,
    output  ack
  );
  modport tb_conn(
    output  rst_n,
    output  clk,
    input   out1,
    input   out2,
    output  addr,
    output  data_in,
    input   data_out,
    output  sel,
    input   ack
  );
endinterface
