//File name=Module name=SWR_vlogcore  2005-03-23      btltz@mail.china.com    btltz from CASIC  
//Description:   The SpaceWire Router top module. 
//Abbreviations:       
//Area:  
//Origin:    SpaceWire Std - Draft-1(Clause 9/10)of ECSS(European Cooperation for Space Standardization),ESTEC,ESA.
//           SpaceWire Router Requirements Specification Issue 1 Rev 5. Astrium & University of Dundee 
//--     TODO:
////////////////////////////////////////////////////////////////////////////////////
//
//
/*synthesis translate_off*/
`timescale 1ns/10ps
/*synthesis translate_on */
`define reset      1	           // WISHBONE style reset
`define TOOL_NOTSUP_PORT_ARRAY  //if the tools not support port array declaration 

module SWR_vlogcore  #(parameter DW=10, PORTNUM=16)  
                ( output [PORTNUM-1:0] Do,Dob, So,Sob,           //LVDS pad
                  input  [PORTNUM-1:0] Si,Sib, Di,Dib,	          //LVDS pad.
                 output reg [3:0] gpio,
					  input reset, gclk
					  );
           
//////////////////
// Instantiations
SwitchCore  #()  inst_RoutingMatrix (
                                     );

Cfg_Ctrl   #()  inst_Cfg_Ctrl (
                               );
 
        
generate
begin:IO_PORTS
 genvar i;
 for (i=0; i<=PortNUM; i=i+1)
 begin:inst
  SPW_CODEC  inst_Link_I_n();
 end
end
endgenerate  //end Link Interface  1 -> PortNUM

TickCounter  #()  inst_TickCNT (
                                 );



endmodule

`undef reset
`undef TOOL_NOTSUP_PORT_ARRAY