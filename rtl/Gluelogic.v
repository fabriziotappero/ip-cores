//File name=Module name=Gluelogic  2005-2-18      btltz@mail.china.com      btltz from CASIC,China 
//Description:   SpaceWire ,     
//Origin:        SpaceWire Std - Draft-1 of ESTEC,ESA
//--     TODO:
////////////////////////////////////////////////////////////////////////////////////
//
/*synthesis translate off*/
`include "timescale.v"
/*synthesis translate on */
//`include "defines.v"

module Gluelogic();

synfifo  inst_fifo ();
crc_32_8_incremental_pipelined_1  inst_crc ();

endmodule