//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//
// Design Name: Substitution Layer for Present Cipher             //
// Module Name: substitution                                      //
// Language:    Verilog                                           //
// Date Created: 1/16/2011                                        //
// Author: Reza Ameli                                             //
//         Digital Systems Lab                                    //
//         Ferdowsi University of Mashhad, Iran                   //
//         http://commeng.um.ac.ir/dslab                          //
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//
//                                                                //
// This source file may be used and distributed without           //
// restriction provided that this copyright statement is not      //
// removed from the file and that any derivative work contains    //
// the original copyright notice and the associated disclaimer.   //
//                                                                //
// This source file is free software; you can redistribute it     //
// and/or modify it under the terms of the GNU Lesser General     //
// Public License as published by the Free Software Foundation;   //
// either version 2.1 of the License, or (at your option) any     //
// later version.                                                 //
//                                                                //
// This source is distributed in the hope that it will be         //
// useful, but WITHOUT ANY WARRANTY; without even the implied     //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR        //
// PURPOSE. See the GNU Lesser General Public License for more    //
// details.                                                       //
//                                                                //
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//

module substitution(data_o,data_i); // Present cipher uses 16 S-Boxes in parallel to process the data
                                    // this module implements those 16 S-Boxes using the sbox module

//- Module IOs ----------------------------------------------------------------

output wire [63:0] data_o;
input  wire [63:0] data_i;

//- Variables, Registers and Parameters ---------------------------------------

genvar j;

//- Instantiations ------------------------------------------------------------

generate
    for (j = 0; j < 16; j = j+1)
    begin : boxes
        sbox substitution_sbox (.data_o(data_o[j*4+3 : j*4]),.data_i(data_i[j*4+3 : j*4]));    
    end
endgenerate

//-----------------------------------------------------------------------------
endmodule
