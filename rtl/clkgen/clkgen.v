//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores clockgen Module                             ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

module clkgen (
               reset_n      ,
               fastsim_mode ,
               mastermode   ,
               xtal_clk     ,
               clkout       ,
               gen_resetn   ,
               risc_reset   ,
               app_clk      ,
               uart_ref_clk 
              );



input	        reset_n        ; // Async reset signal
input         fastsim_mode   ; // fast sim mode = 1
input         mastermode     ; // 1 : Risc master mode
input	        xtal_clk       ; // Xtal clock-25Mhx 
output	      clkout         ; // clock output, 250Mhz
output        gen_resetn     ; // internally generated reset
output        risc_reset      ; // internally generated reset
output        app_clk        ; // application clock
output        uart_ref_clk   ; // uart 16x Ref clock


wire          hard_reset_st  ;
wire          configure_st   ;
wire          wait_pll_st    ;
wire          run_st         ;
wire          slave_run_st   ;
reg           pll_done       ;
reg [11:0] 	  pll_count      ;
reg [2:0] 	  clkgen_ps      ;
reg           gen_resetn     ; // internally generated reset
reg           risc_reset      ; // internally generated reset


assign        clkout = app_clk;
wire          pllout;
/***********************************************
 Alternal PLL pr-programmed for xtal: 25Mhz , clkout 250Mhz
*********************************************************/
/*******************
altera_stargate_pll u_pll (
	. areset     (!reset_n ),
	. inclk0     (xtal_clk),
	. c0         (pllout),
	. locked     ()
       );
*************************/

assign pllout = xtal_clk;

//---------------------------------------------
//
// 100us use 25.000 Mhz clock, counter = 2500(0x9C4)

//--------------------------------------------
always @(posedge xtal_clk or negedge reset_n)
   begin // {
      if (!reset_n)
      begin // {
	 pll_count <= 12'h9C4;
      end   // }                                                                 
      else if (configure_st)
      begin // {
	 pll_count <= (fastsim_mode) ? 12'h040  :  12'h9C4;
      end // }
      else if (wait_pll_st)
      begin // {
         pll_count <= (pll_done) ? pll_count : (pll_count - 1'b1); 
     end // }
   end // }


/************************************************
    PLL Timer Counter
************************************************/

always @(posedge xtal_clk or negedge reset_n)
begin
   if (!reset_n) 
      pll_done <= 0;
   else if (pll_count == 16'h0)
      pll_done <= 1;
   else if (configure_st)
      pll_done <= 0;
end


/************************************************
  internally generated reset 
************************************************/
always @(posedge xtal_clk or negedge reset_n )
begin
   if (!reset_n) begin
      gen_resetn  <=  0;
      risc_reset  <=  1;
   end else if(run_st ) begin
      gen_resetn  <=  1;
      risc_reset  <=  0;
   end else if(slave_run_st ) begin
      gen_resetn  <=  1;
      risc_reset  <=  1; // Keet Risc in Reset
   end else begin
      gen_resetn  <=  0;
      risc_reset  <=  1;
   end
end


/****************************************
    Reset State Machine
****************************************/
/*****************************************
   Define Clock Gen stat machine state
*****************************************/
`define HARD_RESET      3'b000
`define CONFIGURE       3'b001
`define WAIT_PLL        3'b010
`define RUN            	3'b011
`define SLAVE_RUN       3'b100

assign hard_reset_st     = (clkgen_ps == `HARD_RESET);
assign configure_st      = (clkgen_ps == `CONFIGURE);
assign wait_pll_st       = (clkgen_ps == `WAIT_PLL);
assign run_st            = (clkgen_ps == `RUN);
assign slave_run_st      = (clkgen_ps == `SLAVE_RUN);

always @(posedge xtal_clk or negedge reset_n)
begin
   if (!reset_n) begin
      clkgen_ps <= `HARD_RESET;
   end
   else begin
      case (clkgen_ps)
         `HARD_RESET:
            clkgen_ps <= `CONFIGURE;

          `CONFIGURE:        
             clkgen_ps <= `WAIT_PLL;

         `WAIT_PLL:	
           if (pll_done) begin
              if ( mastermode )
		             clkgen_ps <= `RUN;
	            else
		             clkgen_ps <= `SLAVE_RUN;
          end
      endcase
   end
end


//----------------------------------
// Generate Application clock 125Mhz
//----------------------------------

clk_ctl #(1) u_appclk (
   // Outputs
       .clk_o         (app_clk),
   // Inputs
       .mclk          (pllout),
       .reset_n       (gen_resetn), 
       .clk_div_ratio (2'b00)
   );


//----------------------------------
// Generate Uart Ref Clock clock 50Mhz
// 200Mhz/(2+0) = 50Mhz
// 250Mhz/(2+3) = 50Mhz
//----------------------------------

clk_ctl #(2) u_uart_clk (
   // Outputs
       .clk_o         (uart_ref_clk),

   // Inputs
       .mclk          (pllout      ),
       .reset_n       (gen_resetn  ), 
       .clk_div_ratio (3'b000      )
   );



endmodule
