//****************************************************************************************************
// RAM
// Version 0.2
// Modified 17.06.2007
// Designed by Ruslan Lepetenok (lepetenokr@yahoo.com)
// Modified 27.05.12 (Verilog version)
//**************************************************************************************************

`timescale 1 ns / 1 ns

module snc_ram_int(
   clk,
   en,
   we,
   adr,
   din,
   dout
);
   parameter                 tech = 0;
   parameter                 adr_width = 16;
   parameter                 data_width = 8;
   
   input                     clk;
   input                     en;
   input                     we;
   input [(adr_width-1):0]   adr;
   input [(data_width-1):0]  din;
   output [(data_width-1):0] dout;
   
   wire [(data_width-1):0]   ram_mux[15:0];
   wire [15:0]               block_we;
   wire [7:0]                addr_tmp;
   
   generate
         genvar                    k;
         genvar                    j;
         genvar                    i;


         for (k = 7; k >= 0; k = k - 1)
         begin : adr_exp
            assign addr_tmp[k] = ((k + 8 < (adr_width-1))) ? adr[k + 8] : 1'b0;
         end
      
            for (j = 15; j >= 0; j = j - 1)
            begin : block_we_dcd
               assign block_we[j] = ((we && addr_tmp == j)) ? 1'b1 : 1'b0;
            end

		  	 
            if (adr_width == 13)
            begin : adr_width_13
                  for (i = 0; i <= 1; i = i + 1)
                  begin : ram_inst
                     
                     snc_ram #(.tech(tech), .adr_width(12), .data_width(8)) snc_ram_inst(
                        .clk(clk),
                        .en(en),
                        .we(block_we[i]),
                        .adr(adr[11:0]),
                        .din(din[7:0]),
                        .dout(ram_mux[i][7:0])
                     );
                  end  // ram_inst    
            end        // adr_width_13

            if (adr_width == 14)
            begin : adr_width_14
                  for (i = 0; i <= 3; i = i + 1)
                  begin : ram_inst
                     
                     snc_ram #(.tech(tech), .adr_width(12), .data_width(8)) snc_ram_inst(
                        .clk(clk),
                        .en(en),
                        .we(block_we[i]),
                        .adr(adr[11:0]),
                        .din(din[7:0]),
                        .dout(ram_mux[i][7:0])
                     );
                  end // ram_inst    
            end       // adr_width_14

            if (adr_width == 15)
            begin : adr_width_15
                  for (i = 0; i <= 7; i = i + 1)
                  begin : ram_inst
                     
                     snc_ram #(.tech(tech), .adr_width(12), .data_width(8)) snc_ram_inst(
                        .clk(clk),
                        .en(en),
                        .we(block_we[i]),
                        .adr(adr[11:0]),
                        .din(din[7:0]),
                        .dout(ram_mux[i][7:0])
                     );
                  end // ram_inst    
            end       // adr_width_15

            if (adr_width == 16)
            begin : adr_width_16
                  for (i = 0; i <= 15; i = i + 1)
                  begin : ram_inst
                     
                     snc_ram #(.tech(tech), .adr_width(12), .data_width(8)) snc_ram_inst(
                        .clk(clk),
                        .en(en),
                        .we(block_we[i]),
                        .adr(adr[11:0]),
                        .din(din[7:0]),
                        .dout(ram_mux[i][7:0])
                     );
                  end // ram_inst
            end       // adr_width_16
         endgenerate

         assign dout = ram_mux[addr_tmp];

         
endmodule // snc_ram_int
