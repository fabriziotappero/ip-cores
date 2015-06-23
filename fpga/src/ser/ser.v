//
// ser.v -- serial line interface
//


module ser(clk, reset,
           en, wr, addr,
           data_in, data_out,
           wt, irq_r, irq_t,
	   rxd, txd);
    // internal interface
    input clk;
    input reset;
    input en;
    input wr;
    input [3:2] addr;
    input [7:0] data_in;
    output reg [7:0] data_out;
    output wt;
    output irq_r;
    output irq_t;
    // external interface
    input rxd;
    output txd;

  wire wr_rcv_ctrl;
  wire rd_rcv_data;
  wire wr_xmt_ctrl;
  wire wr_xmt_data;

  wire rcv_ready;
  reg rcv_ien;
  wire [7:0] rcv_data;
  wire xmt_ready;
  reg xmt_ien;

  assign wr_rcv_ctrl = (en == 1 && wr == 1 && addr == 2'b00) ? 1 : 0;
  assign rd_rcv_data = (en == 1 && wr == 0 && addr == 2'b01) ? 1 : 0;
  assign wr_xmt_ctrl = (en == 1 && wr == 1 && addr == 2'b10) ? 1 : 0;
  assign wr_xmt_data = (en == 1 && wr == 1 && addr == 2'b11) ? 1 : 0;

  rcvbuf rcvbuf1(clk, reset, rd_rcv_data, rcv_ready, rcv_data, rxd);
  xmtbuf xmtbuf1(clk, reset, wr_xmt_data, xmt_ready, data_in, txd);

  always @(posedge clk) begin
    if (reset == 1) begin
      rcv_ien <= 0;
      xmt_ien <= 0;
    end else begin
      if (wr_rcv_ctrl) begin
        rcv_ien <= data_in[1];
      end
      if (wr_xmt_ctrl) begin
        xmt_ien <= data_in[1];
      end
    end
  end

  always @(*) begin
    case (addr[3:2])
      2'b00:
        // rcv ctrl
        data_out = { 6'b000000, rcv_ien, rcv_ready };
      2'b01:
        // rcv data
        data_out = rcv_data;
      2'b10:
        // xmt ctrl
        data_out = { 6'b000000, xmt_ien, xmt_ready };
      2'b11:
        // xmt data (cannot be read)
        data_out = 8'hxx;
      default:
        data_out = 8'hxx;
    endcase
  end

  assign wt = 1'b0;
  assign irq_r = rcv_ien & rcv_ready;
  assign irq_t = xmt_ien & xmt_ready;

endmodule
