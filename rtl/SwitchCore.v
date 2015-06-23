//File name=Module=SwitchCore    2005-3-18      btltz@mail.china.com    btltz from CASIC  
//Description:   The SpaceWire Routing Switch core(routing matrix).
//               Can be used as a standalone module or connected to the CODEC Core to 
//               form a complete SpaceWire Routing Switch (Router).
//Origin:        SpaceWire Std - Draft-1(Clause 9/10) of ECSS(European Cooperation for Space Standardization),ESTEC,ESA.
//               SpaceWire Router Requirements Specification Issue 1 Rev 5. Astrium & University of Dundee 
//--     TODO:   make the rtl faster
////////////////////////////////////////////////////////////////////////////////////
//
/*synthesize translate_off*/
`timescale 1ns/10ps
/*synthesize translate_on */
`define reset  1	               // WISHBONE standard reset
`define TOOL_NOTSUP_PORT_ARRAY   //if the tools not  support port array declaration  

module SwitchCore  #(parameter DW=10,PORTNUM=16,GPIO_NUM=3)	  // Actual 17 ==16 +1(external port)
            ( // Input data interface
                   output[PORTNUM-1:0] full_o,
					   `ifdef TOOL_NOTSUP_PORT_ARRAY
						 output [DW-1:0] dout0,dout1,dout2,dout3,dout4,dout5,dout6,dout7,
						                 dout8,dout9,dout10,dout11,dout12,dout13,dout14,dout15,	    // Note that these is physical order.
						 input  [DW-1:0] din0,din1,din2,din3,din4,din5,din6,din7,						 // eg. dout0 is routing logical port1
						                 din8,din9,din10,din11,din12,din13,din14,din15,				 // because port0 is reserved for config
						`else
						 output [DW-1:0] dout [PORTNUM-1:0],
                   input [DW-1:0] din [PORTNUM-1:0], 					 			 
						 `endif

                   input [PORTNUM-1:0] wr_i,	
             // Output data interface 	                    
                  output [PORTNUM-1:0] empty_o,
                  input rd_i,
                  input active_i,
             // GPIO ports
                  inout [GPIO_NUM-1:0] GPIO,
             // global signal input 
                  input reset, gclk	  // approximate 120Mhz, could also drive Xilinx gigabit transceiver.
               );
     
         //  parameter        ;

////////////////////
// Instantiation
//

SwitchMatrix   #()  inst_SwitchMatrix (
                                  );

//	16 inputs Line Schedulers
// 1 scheduler is responsible to 1 input line, distribute data into one column
generate
begin:GEN_LSers
genvar i, k;
 for (i=0; i<PORTNUM; i=i+1)                       // i : each column
 begin
   for (k=0; k<PORTNUM; k=k+1)	                  // k : in a column(sel line)
	begin
     LSer  #()  inst_LSer
	             ( .ld_SelColumn_o( ld_SelColumn ),
					   .empty_i(CellEmpty[i][k] ),      // one-hot input
						.Aempty_i(CellAfull[i][k]),		// one-hot
					   .addr_o( ScheOut[i] ),						
						.reset(reset)
						.gclk(gclk)						 
					  );
   end  // end lines in a column
 end    // end columns
end
endgenerate

endmodule

`undef reset 
`undef TOOL_NOTSUP_PORT_ARRAY