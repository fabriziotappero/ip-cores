// wrapper for the above dual port RAM
module ram (dat_i, dat_o, adr_i, we_i, clk );

   parameter dat_width = 32;
   parameter adr_width = 11;
   parameter mem_size  = 2048;
   
   input [dat_width-1:0]      dat_i;
   input [adr_width-1:0]      adr_i;
   input 		      we_i;
   output [dat_width-1:0]     dat_o;
   input 		      clk;   

   wire [dat_width-1:0]       q_b;
   
   ram_sc_dw
     /*
     #
     (
      .dat_width(dat_width),
      .adr_width(adr_width),
      .mem_size(mem_size)
      )
      */
     ram0
     (
      .d_a(dat_i),
      .q_a(dat_o),
      .adr_a(adr_i),
      .we_a(we_i),
      .q_b(q_b),
      .adr_b({adr_width{1'b0}}),
      .d_b({dat_width{1'b0}}),
      .we_b(1'b0),
      .clk(clk)
      );

endmodule // ram
