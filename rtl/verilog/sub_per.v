//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//
// Design Name: Substitution & Permutation  for Present Cipher    //
// Module Name: sub_per                                           //
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

module sub_per(data_o,data_i); // this module cascades the substitution and permutation layers of the cipher and builds a 
                               // single entity containing both of them

//- Module IOs ----------------------------------------------------------------

output wire[63:0] data_o;
input  wire[63:0] data_i;              

//- Variables, Registers and Parameters ---------------------------------------

wire [63:0] s; // intermediate signal

//- Instantiations ------------------------------------------------------------

substitution sub_per_substitution(.data_o(s)   ,.data_i(data_i)); // input of the S-Box is data_i
permutation  sub_per_permutation (.data_o(data_o),.data_i(s)); // output os Permutation layer is data_o

//-----------------------------------------------------------------------------
endmodule
