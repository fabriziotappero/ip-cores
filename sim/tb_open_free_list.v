`timescale 1ns/1ps

module tb_open_free_list;

reg 			reset_n;
reg 			clk;
wire      [8:0]	fl_q;
wire			fl_aempty;
wire			fl_empty;
reg				wren;
reg	     [71:0] din;
reg				eop;
reg		  [8:0] chunk_num;
reg				load_req;
reg				rel_req;
wire			load_rel_ack;
reg				rden;
wire     [71:0] dout;

reg       [8:0] pkt1_chunk;
reg       [8:0] pkt2_chunk;
reg       [8:0] pkt3_chunk;	

open_free_list open_free_list(
  .reset_n(reset_n),
  .clk(clk),
  .fl_q(fl_q),
  .fl_aempty(fl_aempty),
  .fl_empty(fl_empty),
  .wren(wren),
  .din(din),
  .eop(eop),
  .chunk_num(chunk_num),
  .load_req(load_req),
  .rel_req(rel_req),
  .load_rel_ack(load_rel_ack),
  .rden(rden),
  .dout(dout)
);
defparam
	open_free_list.RAM_W = 64,
	open_free_list.RAM_E = 8;

initial // reset
begin
    reset_n <= 1'b0;
    #1000 reset_n <= 1'b1;
end

initial // clock
	clk <= 1'b0;
always
	#5 clk <= ~clk;

initial // init all signals
begin
    wren      <= 1'b0;
    din       <= 72'b0;
    eop       <= 1'b0;
    chunk_num <= 9'b0;
    load_req  <= 1'b0;
    rel_req   <= 1'b0;
    rden      <= 1'b0;
end

initial // test
begin
    #2000;
    @(posedge clk);
    
    // write a short packet
    pkt1_chunk <= fl_q;
    din <= 72'h000001020304050607;
    wren <= 1'b1;
    @(posedge clk);
    din <= 72'h0108090a0b0c0d0e0f;
    eop <= 1'b1;
    @(posedge clk);
    wren <= 1'b0;
    eop <= 1'b0;
    
    #1000;
    @(posedge clk);

    // write a longer packet
    pkt2_chunk <= fl_q;
    din <= 72'h800001020304050607;
    wren <= 1'b1;
    @(posedge clk);
    din <= 72'h8008090a0b0c0d0e0f;
    @(posedge clk);
    din <= 72'h801011121314151617;
    @(posedge clk);
    din <= 72'h8018191a1b1c1d1e1f;
    @(posedge clk);
    din <= 72'h802021222324252627;
    @(posedge clk);
    din <= 72'h8028292a2b2c2d2e2f;
    @(posedge clk);
    din <= 72'h803031323334353637;
    @(posedge clk);
    din <= 72'h8038393a3b3c3d3e3f;
    @(posedge clk);
    din <= 72'h804041424344454647;
    @(posedge clk);
    din <= 72'h8048494a4b4c4d4e4f;
    @(posedge clk);
    din <= 72'h805051525354555657;
    @(posedge clk);
    din <= 72'h8058595a5b5c5d5e5f;
    @(posedge clk);
    din <= 72'h806061626364656667;
    @(posedge clk);
    din <= 72'h8068696a6b6c6d6e6f;
    @(posedge clk);
    din <= 72'h807071727374757677;
    @(posedge clk);
    din <= 72'h8078797a7b7c7d7e7f;
    @(posedge clk);
    din <= 72'h818081828384858687;
    eop <= 1'b1;
    @(posedge clk);
    wren <= 1'b0;
    eop <= 1'b0;
    
    #1000;
    @(posedge clk);
    
    // read the first packet
    chunk_num <= pkt1_chunk;
    load_req <= 1'b1;
    @(posedge load_rel_ack);
    load_req <= 1'b0;
    @(posedge clk);
    rden <= 1'b1;
    @(posedge clk);
    @(posedge clk);
    rden <= 1'b0;
    rel_req <= 1'b1;
    @(posedge load_rel_ack);
    rel_req <= 1'b0;
    
    #1000;
    @(posedge clk);
    
    // write a 3rd packet (short)
    pkt3_chunk <= fl_q;
    din <= 72'hc00001020304050607;
    wren <= 1'b1;
    @(posedge clk);
    din <= 72'hc108090a0b0c0d0e0f;
    eop <= 1'b1;
    @(posedge clk);
    wren <= 1'b0;
    eop <= 1'b0;
    
    #1000;
    @(posedge clk);
    
    // release the third packet without reading
    chunk_num <= pkt3_chunk;
    rel_req <= 1'b1;
    @(posedge load_rel_ack);
    rel_req <= 1'b0;
    
    #1000;
    @(posedge clk);

    // read a few lines of packet 2 and then release it
    chunk_num <= pkt2_chunk;
    load_req <= 1'b1;
    @(posedge load_rel_ack);
    load_req <= 1'b0;
    @(posedge clk);
    rden <= 1'b1;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    rden <= 1'b0;
    rel_req <= 1'b1;
    @(posedge load_rel_ack);
    rel_req <= 1'b0;
end

endmodule // tb_open_free_list
