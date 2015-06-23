
module sd_fifo
  (
    input  [1:0] wb_adr_i,
    input [7:0]  wb_dat_i,
    output [7:0] wb_dat_o,
    input 	 wb_we_i,
    input 	 wb_re_i,
    input 	 wb_clk,
    input [1:0]  sd_adr_i,
    input [7:0]  sd_dat_i,
    output [7:0] sd_dat_o,
    input 	 sd_we_i,
    input 	 sd_re_i,
    input 	 sd_clk,
    output [1:4] fifo_full,
    output [1:4] fifo_empty,
    input 	 rst 	 
   );
 
   wire [8:0] 	 wptr1, rptr1, wptr2, rptr2, wptr3, rptr3, wptr4, rptr4;
   wire [8:0] 	 wadr1, radr1, wadr2, radr2, wadr3, radr3, wadr4, radr4;
 
   wire 	 dpram_we_a, dpram_we_b;
   wire [10:0] 	 dpram_a_a, dpram_a_b;   
 
   sd_counter wptr1a
     (
      .q(wptr1),
      .q_bin(wadr1),
      .cke((wb_adr_i==2'd0) & wb_we_i & !fifo_full[1]),
      .clk(wb_clk),
      .rst(rst)
      );
 
   sd_counter rptr1a
     (
      .q(rptr1),
      .q_bin(radr1),
      .cke((sd_adr_i==2'd0) & sd_re_i & !fifo_empty[1]),
      .clk(sd_clk),
      .rst(rst)
      );
 
  versatile_fifo_async_cmp
    #
    (
     .ADDR_WIDTH(9)
     )
    cmp1
    ( 
      .wptr(wptr1), 
      .rptr(rptr1), 
      .fifo_empty(fifo_empty[1]), 
      .fifo_full(fifo_full[1]), 
      .wclk(wb_clk), 
      .rclk(sd_clk), 
      .rst(rst)
      );
 
   sd_counter wptr2a
     (
      .q(wptr2),
      .q_bin(wadr2),
      .cke((sd_adr_i==2'd1) & sd_we_i & !fifo_full[2]),
      .clk(sd_clk),
      .rst(rst)
      );
 
   sd_counter rptr2a
     (
      .q(rptr2),
      .q_bin(radr2),
      .cke((wb_adr_i==2'd1) & wb_re_i & !fifo_empty[2]),
      .clk(wb_clk),
      .rst(rst)
      );
 
  versatile_fifo_async_cmp
    #
    (
     .ADDR_WIDTH(9)
     )
    cmp2
    ( 
      .wptr(wptr2), 
      .rptr(rptr2), 
      .fifo_empty(fifo_empty[2]), 
      .fifo_full(fifo_full[2]), 
      .wclk(sd_clk), 
      .rclk(wb_clk), 
      .rst(rst)
      );
 
   sd_counter wptr3a
     (
      .q(wptr3),
      .q_bin(wadr3),
      .cke((wb_adr_i==2'd2) & wb_we_i & !fifo_full[3]),
      .clk(wb_clk),
      .rst(rst)
      );
 
   sd_counter rptr3a
     (
      .q(rptr3),
      .q_bin(radr3),
      .cke((sd_adr_i==2'd2) & sd_re_i & !fifo_empty[3]),
      .clk(sd_clk),
      .rst(rst)
      );
 
  versatile_fifo_async_cmp
    #
    (
     .ADDR_WIDTH(9)
     )
    cmp3
    ( 
      .wptr(wptr3), 
      .rptr(rptr3), 
      .fifo_empty(fifo_empty[3]), 
      .fifo_full(fifo_full[3]), 
      .wclk(wb_clk), 
      .rclk(sd_clk), 
      .rst(rst)
      );
 
   sd_counter wptr4a
     (
      .q(wptr4),
      .q_bin(wadr4),
      .cke((sd_adr_i==2'd3) & sd_we_i & !fifo_full[4]),
      .clk(sd_clk),
      .rst(rst)
      );
 
   sd_counter rptr4a
     (
      .q(rptr4),
      .q_bin(radr4),
      .cke((wb_adr_i==2'd3) & wb_re_i & !fifo_empty[4]),
      .clk(wb_clk),
      .rst(rst)
      );
 
  versatile_fifo_async_cmp
    #
    (
     .ADDR_WIDTH(9)
     )
    cmp4
    ( 
      .wptr(wptr4), 
      .rptr(rptr4), 
      .fifo_empty(fifo_empty[4]), 
      .fifo_full(fifo_full[4]), 
      .wclk(sd_clk), 
      .rclk(wb_clk), 
      .rst(rst)
      );
 
   assign dpram_we_a = ((wb_adr_i==2'd0) & !fifo_full[1]) ? wb_we_i :
		       ((wb_adr_i==2'd2) & !fifo_full[3]) ? wb_we_i :
		       1'b0;
   assign dpram_we_b = ((sd_adr_i==2'd1) & !fifo_full[2]) ? sd_we_i :
		       ((sd_adr_i==2'd3) & !fifo_full[4]) ? sd_we_i :
		       1'b0;
   assign dpram_a_a = (wb_adr_i==2'd0) ? {wb_adr_i,wadr1} :
		      (wb_adr_i==2'd1) ? {wb_adr_i,radr2} :
		      (wb_adr_i==2'd2) ? {wb_adr_i,wadr3} :
		      {wb_adr_i,radr4};
   assign dpram_a_b = (sd_adr_i==2'd0) ? {sd_adr_i,radr1} :
		      (sd_adr_i==2'd1) ? {sd_adr_i,wadr2} :
		      (sd_adr_i==2'd2) ? {sd_adr_i,radr3} : //(sd_adr_i==2'd3) ? {sd_adr_i,radr3} :--->(sd_adr_i==2'd2) ? {sd_adr_i,radr3} :
		      {sd_adr_i,wadr4};
 
 //versatile_fifo_dual_port_ram_dc_dw
   versatile_fifo_dptam_dw
     dpram
     (
      .d_a(wb_dat_i),
      .q_a(wb_dat_o),
      .adr_a(dpram_a_a), 
      .we_a(dpram_we_a),
      .clk_a(wb_clk),
      .q_b(sd_dat_o),
      .adr_b(dpram_a_b),
      .d_b(sd_dat_i), 
      .we_b(dpram_we_b),
      .clk_b(sd_clk)
      );
 
endmodule // sd_fifo
 

