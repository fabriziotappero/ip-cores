//2005-1-18      btltz@mail.china.com      btltz from CASIC,China  
//File=Module=SPW_I_vlogcore    2005-2-18      btltz@mail.china.com      btltz from CASIC,China 
//Description:   SpaceWire RxTx top module with Wishbone interface to node device(the host) or communication memory.    
//                "A SpaceWire node comprise one or more SpaceWire link interfaces
//                (encoder-decoders) and an interface to the host system,represents an interface between 
//                a SpaceWire network and an application system using the network services."
//Approximate area:
//Origin:        SpaceWire Std-Draft-1 of ECSS(European Cooperation for Space Standardization),ESTEC,ESA
//               
//--     TODO:
////////////////////////////////////////////////////////////////////////////////////
//

/*synthesis translate off*/
`include "timescale.v"
/*synthesis translate on */
`define reset     1       			 // WISHBONE style reset
`define USE_XIL_DEVICE	  			 // If use Xilinx device
`define TOOL_NOTSUP_PORT_ARRAY  //if the tools not support port array declaration 

module SPW_I_vlogcore #(parameter CH_NUM = 3)		                   //Triple Modulo Redundant (TMR)
                      ( output [CH_NUM-1:0] Dout,Doutb, Sout,Soutb,   //LVDS pad
                        input  [CH_NUM-1:0] Sin, Sinb,  Din, Dinb,	 //LVDS pad. 8 pads/pin for 1 channel

							  output int_LnkErr_o,
							  output TICK_o, TICK_i,

                       input  reset,gclk
                        );	                          

  
//////////////
// LVDS IO
//
`ifdef USE_XIL_DEVICE
wire [CH_NUM-1:0] Si,Di,  So,Do;

generate 
begin:Gen_LVDS_PADS
genvar k;
 for (k=0; k<CH_NUM, k=k+1) 
 IBUFDS_LVDS_25   inst_LVDS_Di ( .I(Din[k])		    // P-channel data 
                                 .IB(Dinb[k])	    // N-channel data 
										   .O(Di[k]) );	    // Non-differential data input
 IBUFDS_LVDS_25   inst_LVDS_Si ( .I(Sin[k])		    // P-channel strobe 
                                 .IB(Sinb[k])	    // N-channel strobe 
										   .O(Si[k]) );	    // Non-differential strobe input


 OBUFDS_LVDS_25   inst_LVDS_Do ( .I(Do[k]),			 //Non-differential data output
                                .O(Dout[k]),			 //P-channel output 
                                .OB(Doutb[k])  );	 //N-channel output
 OBUFDS_LVDS_25   inst_LVDS_So ( .I(So[k]),			 //Non-differential strobe output
                                .O(Sout[k]),			 //P-channel output
                                .OB(Soutb[k])  );	 //N-channel output
end    //end block Gen_LVDS_PADS
endgenerate
`endif

//////////////////////////
// Synchronizer 
// between 2 clock domain 
synchronizer_flop  #(WIDTH*2) inst_Syn_flops(.sync_data_out(),
                                      .data_in(),
                                      .clk(),
                                      .async_reset()
                                      );

/********** Instantiations of low level modules ****************/	
////// Channels //////
generate 
begin:G_channel
genvar i;
 for(i=0; i<CHANNEL_NUM; i=i+1)
   SPW_CODEC  #() CODEC_xChannels  (
                                 );
end
endgenerate

Gluelogic inst_fifo_crc  ();

WB_COMI_HOCI inst_WB_IF  ();

JTAG_spw  inst_JTAG_IO  ();


endmodule

`undef reset
`undef USE_XIL_DEVICE
`undef TOOL_NOTSUP_PORT_ARRAY

