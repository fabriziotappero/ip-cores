//File name=Module=TickCounter       2005-04-23      btltz@mail.china.com    btltz from CASIC  
//Description:    Tick counter / time reister   
//                
//Abbreviations: 	 						
//Origin:  SpaceWire Std - Draft-1(Clause 8)of ECSS(European Cooperation for Space Standardization),ESTEC,ESA.
//         SpaceWire Router Requirements Specification Issue 1 Rev 5. Astrium & University of Dundee 
//TODO:	  
////////////////////////////////////////////////////////////////////////////////////
//
/*synthesis translate_off*/
`timescale 1ns/100ps
/*synthesis translate_on */
`define    reset     1    // WISHBONE standard reset

module TickCounter #(parameter CW=24)                     // internal counter width 
                   (
		// External time interface(also associated with the external input/output port) 				 	
							output TICK_OUT,							
							input TICK_IN,
							output [CW-1:0] COUNT, 

							output [5:1] time_o,
						   output [1:0] ctrl_flg_o,
							input [5:1]	time_i,
							input [1:0]	ctrl_flg_i,
      // interconnect
		               output [] TimeReg_o,
							input [PORTNUM-1:0] IFtick_i,        	 // Interface ports tick_out internal 

      // global signal input
		               input reset,
							input gclk   );

reg [] TimeReg;															// "time register"
reg [CW-1:0] tcnt;                                          // "internal time counter"

assign TimeReg_o = TimeReg;

///////////////////////
//	 tcnt(timer counter)
//	 
wire run_tcnt =	|(IFtick_i[i]) ||	tick_in; 

always @(posedge gclk)
begin
 if(reset==`reset)
   tcnt <= 0;
 else if(run_tcnt)
   tcnt <= tcnt + 1;
end
 

endmodule

`undef reset
