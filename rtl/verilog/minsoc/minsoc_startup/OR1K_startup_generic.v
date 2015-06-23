
`include "minsoc_defines.v"

module OR1K_startup
  (
    input [6:2]       wb_adr_i,
    input 	      wb_stb_i,
    input 	      wb_cyc_i,
    output reg [31:0] wb_dat_o,
    output reg 	      wb_ack_o,
    input 	      wb_clk,
    input 	      wb_rst
   );

   always @ (posedge wb_clk or posedge wb_rst)
     if (wb_rst)
       wb_dat_o <= 32'h15000000;
     else
       case (wb_adr_i)
	  0 : wb_dat_o <= 32'h18000000;
	  1 : wb_dat_o <= 32'hA8200000;
	  2 : wb_dat_o <= { 16'h1880 , `APP_ADDR_SPI , 8'h00 };
	  3 : wb_dat_o <= 32'hA8A00520;
	  4 : wb_dat_o <= 32'hA8600001;
	  5 : wb_dat_o <= 32'h04000014;
	  6 : wb_dat_o <= 32'hD4041818;
	  7 : wb_dat_o <= 32'h04000012;
	  8 : wb_dat_o <= 32'hD4040000;
	  9 : wb_dat_o <= 32'hE0431804;
	 10 : wb_dat_o <= 32'h0400000F;
	 11 : wb_dat_o <= 32'h9C210008;
	 12 : wb_dat_o <= 32'h0400000D;
	 13 : wb_dat_o <= 32'hE1031804;
	 14 : wb_dat_o <= 32'hE4080000;
	 15 : wb_dat_o <= 32'h0FFFFFFB;
	 16 : wb_dat_o <= 32'hD4081800;
	 17 : wb_dat_o <= 32'h04000008;
	 18 : wb_dat_o <= 32'h9C210004;
	 19 : wb_dat_o <= 32'hD4011800;
	 20 : wb_dat_o <= 32'hE4011000;
	 21 : wb_dat_o <= 32'h0FFFFFFC;
	 22 : wb_dat_o <= 32'hA8C00100;
	 23 : wb_dat_o <= 32'h44003000;
	 24 : wb_dat_o <= 32'hD4040018;
	 25 : wb_dat_o <= 32'hD4042810;
	 26 : wb_dat_o <= 32'h84640010;
	 27 : wb_dat_o <= 32'hBC030520;
	 28 : wb_dat_o <= 32'h13FFFFFE;
	 29 : wb_dat_o <= 32'h15000000;
	 30 : wb_dat_o <= 32'h44004800;
	 31 : wb_dat_o <= 32'h84640000;
       endcase

   always @ (posedge wb_clk or posedge wb_rst)
     if (wb_rst)
       wb_ack_o <= 1'b0;
     else
       wb_ack_o <= wb_stb_i & wb_cyc_i & !wb_ack_o;
   
endmodule // OR1K_startup
