

module mem_mod (
  clk,   // input clock
  addr,  // address
  datai,  // data in
  datao,  // data out
  sel,   // select
  w_n   // Write  not
);


  //input         rst_n;
  input         clk;
  input  [31:0] addr;
  input  [31:0] datai;
  output [31:0] datao;
  input         w_n;
  input         sel;

  reg [31:0] mem[0:64];
  reg [31:0] dout;
  reg [6:0]  aidx;

  assign datao = dout;

  integer i;

  initial begin
    i = 0;
    while (i < 64) begin
      mem[i] = 0;
      i = i + 1;
    end
  end


  always @(posedge clk) begin
    if (addr[15:0] < 16'h0040 && sel == 1'b1) begin
      aidx = addr[6:0];
      if (w_n == 1'b1) begin
        dout <= mem[aidx];
      end else if (w_n == 1'b0) begin
        mem[aidx] <= datai;
      end
    end else if (sel == 1'b0) begin
      dout <= 32'hzzzzzzzz;
    end
  end



endmodule
