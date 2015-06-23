//************************************************************************************************
// Internal I/O registers decoder/multiplexer for the AVR core
// Version 2.1
// Modified 08.01.2007
// Designed by Ruslan Lepetenok
// std_library was added
// Converted to Verilog
// Modified 18.08.12
//************************************************************************************************

`timescale 1 ns / 1 ns

module io_adr_dec #(
                    parameter pc22b = 0
		    ) 
		    (
   		     input wire [5:0]  adr,
   		     input wire        iore,
   		     input wire [7:0]  dbusin_ext,
   		     output reg [7:0]  dbusin_int,
   		     // SREG/SPL/SPH/RAMPZ i/f  	
   		     input wire [7:0]  spl_out,
   		     input wire [7:0]  sph_out,
   		     input wire [7:0]  sreg_out,
   		     input wire [7:0]  rampz_out,
   		     input wire [7:0]  eind_out
                     );

//************************************************************************************************

// Register addresses  
parameter P_SPL_Address   = 6'h3D; // Stack Pointer(Low)
parameter P_SPH_Address   = 6'h3E; // Stack Pointer(High)
parameter P_SREG_Address  = 6'h3F; // Status Register
parameter P_RAMPZ_Address = 6'h3B; // RAM Page Z Select Register
parameter P_EIND_Address  = 6'h3C; // !!!TBD!!! Occupated by XDIV in Mega128
  
//************************************************************************************************  
   
   generate
      if (!pc22b)
      begin : no_eind
         
         always @*
         begin: out_mux_comb
            if (iore)
               case (adr)
                  P_SPL_Address   : dbusin_int = spl_out;
                  P_SPH_Address   : dbusin_int = sph_out;
                  P_SREG_Address  : dbusin_int = sreg_out;
                  P_RAMPZ_Address : dbusin_int = rampz_out;
                  default         : dbusin_int = dbusin_ext;
               endcase
            else
               dbusin_int = dbusin_ext;
            end // out_mux_comb
         end // no_eind

         else // (pc22b != 0)
         begin : eind_is_impl
            
            always @*
            begin: out_mux_comb
               if (iore)
                  case (adr)
                     P_SPL_Address   : dbusin_int = spl_out;
                     P_SPH_Address   : dbusin_int = sph_out;
                     P_SREG_Address  : dbusin_int = sreg_out;
                     P_RAMPZ_Address : dbusin_int = rampz_out;
                     P_EIND_Address  : dbusin_int = eind_out;
                     default         : dbusin_int = dbusin_ext;
                  endcase
               else
                  dbusin_int = dbusin_ext;
               end // out_mux_comb
            end // eind_is_impl
         endgenerate
         
endmodule // io_adr_dec

