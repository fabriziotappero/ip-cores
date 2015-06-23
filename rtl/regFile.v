//File name=Module name=regFile  2005-04-07      btltz@mail.china.com    btltz from CASIC  
//Description:   Contains status/contrl regs for CODEC
//Abbreviations:      
//Origin:        SpaceWire Std - Draft-1 of ECSS(European Cooperation for Space Standardization),ESTEC,ESA.
//--     TODO:	  Make it easy to use (but enough flexible)  
////////////////////////////////////////////////////////////////////////////////////
//
//
/*synthesis translate off*/
`timescale 1ns/100ps
/*synthesis translate on */

module regFile #(parameter WIDTH=8)
                    ();

reg [WIDTH-1:0] SPE_CTL;  //transmitter speed control register
reg [WIDTH-1:0] STA_TX;
reg [WIDTH-1:0] STA_RX;
reg [WIDTH-1:0] CTL_TX;
reg [WIDTH-1:0] CTL_RX; 

endmodule
