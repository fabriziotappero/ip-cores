// True dual port RAM as found in ACTEL proasic3 devices
module ram_sc_dw (d_a, q_a, adr_a, we_a, q_b, adr_b, d_b, we_b, clk);
   
   parameter dat_width = `RAM_WB_DAT_WIDTH;
   parameter adr_width = `RAM_WB_ADR_WIDTH;
   parameter mem_size  = `RAM_WB_MEM_SIZE;
   
   input [dat_width-1:0]      d_a;
   input [adr_width-1:0]      adr_a;
   input [adr_width-1:0]      adr_b;
   input 		      we_a;
   output reg [dat_width-1:0] q_b;
   input [dat_width-1:0]      d_b;
   output reg [dat_width-1:0] q_a;
   input 		      we_b;
   input 		      clk;   

   reg [dat_width-1:0] ram [0:mem_size - 1] /*synthesis syn_ramstyle = "no_rw_check"*/;
   
   always @ (posedge clk)
     begin 
	q_a <= ram[adr_a];
	if (we_a)
	  ram[adr_a] <= d_a;
     end
   
   always @ (posedge clk)
     begin 
	q_b <= ram[adr_b];
	if (we_b)
	  ram[adr_b] <= d_b;
     end
   
endmodule 
