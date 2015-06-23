
module gpio_mod (
  clk,   // input clock
  rst_n,
  addr,  // address
  datai,  // data in
  datao,  // data out
  w_n,   // Write  not
  sel,   // select input
  io_o,  // gpio  out
  io_i   // gpio  in
);


input         rst_n;
input         clk;
input         sel;
input  [31:0] addr;
input  [31:0] datai;
output [31:0] datao;
input         w_n;
input  [31:0] io_i;
output [31:0] io_o;

reg [31:0] io_mode; //  1 = output
reg [31:0] tdatao;
reg [31:0] tio_o;

assign datao = tdatao;
assign io_o  = tio_o & io_mode;

always @(posedge clk) begin
  if(rst_n == 0) begin
    tio_o   <= 32'h00000000;
    io_mode <= 32'h00000000;

  end else if (w_n == 1 && sel == 1'b1) begin
    if (addr[3:0] > 4'h0) begin
      tdatao <= io_i & ~io_mode;
    end else begin
      tdatao <= io_mode;
    end
  end else if (w_n == 0 && sel == 1'b1) begin
    if (addr[3:0] > 4'h0) begin
      tio_o <= datai;
    end else begin
      io_mode <= datai;
    end
  end else if (sel == 1'b0) begin
    tdatao <= 32'hzzzzzzzz;
  end
end


endmodule
