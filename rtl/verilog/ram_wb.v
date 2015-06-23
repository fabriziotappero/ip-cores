module ram_wb ( dat_i, dat_o, adr_i, we_i, sel_i, cyc_i, stb_i, ack_o, cti_i, clk_i, rst_i);

   parameter dat_width = `RAM_WB_DAT_WIDTH;
   parameter adr_width = `RAM_WB_ADR_WIDTH;
   parameter mem_size  = `RAM_WB_MEM_SIZE;
   
   // wishbone signals
   input [31:0]          dat_i;   
   output [31:0]         dat_o;
   input [adr_width-1:2] adr_i;
   input 		 we_i;
   input [3:0] 		 sel_i;
   input 		 cyc_i;
   input 		 stb_i;
   output reg 		 ack_o;
   input [2:0] 		 cti_i;
   
   // clock
   input 		 clk_i;
   // async reset
   input 		 rst_i;
   
   wire [31:0] 		 wr_data;
   
   // mux for data to ram
   assign wr_data[31:24] = sel_i[3] ? dat_i[31:24] : dat_o[31:24];
   assign wr_data[23:16] = sel_i[2] ? dat_i[23:16] : dat_o[23:16];
   assign wr_data[15: 8] = sel_i[1] ? dat_i[15: 8] : dat_o[15: 8];
   assign wr_data[ 7: 0] = sel_i[0] ? dat_i[ 7: 0] : dat_o[ 7: 0];
   
   ram
     #
     (
      .dat_width(dat_width),
      .adr_width(adr_width),
      .mem_size(mem_size)
      )
     ram0
     (
      .dat_i(wr_data),
      .dat_o(dat_o),
      .adr_i(adr_i), 
      .we_i(we_i & ack_o),
      .clk(clk_i)
      );
 
   // ack_o
   always @ (posedge clk_i or posedge rst_i)
     if (rst_i)
       ack_o <= 1'b0;
     else
       if (!ack_o) begin
	 if (cyc_i & stb_i)
	   ack_o <= 1'b1; end  
       else
	 if ((sel_i != 4'b1111) | (cti_i == 3'b000) | (cti_i == 3'b111))
	   ack_o <= 1'b0;
         
endmodule
 
	      