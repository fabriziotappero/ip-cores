//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//
// Design Name: Key Update Procedure for Present Cipher           //
// Module Name: key_update                                        //
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

module key_update(data_o,data_i,round_counter);

//- Module IOs ----------------------------------------------------------------

output wire[79 : 0] data_o; // 80-bit input
input  wire[79 : 0] data_i; // 80-bit output (will be the updated value of current key)
input  wire[4  : 0] round_counter;

//- Variables, Registers and Parameters ---------------------------------------

wire [79:0] s1,s2,s3; // intermediate signals                                  

//- Instantiations ------------------------------------------------------------

sbox key_update_sbox(.data_o(s2[79:76]),.data_i(s1[79:76])); // four left-most bits are determined by the sbox output

//- Continuous Assigments------------------------------------------------------

assign s1 = {data_i[18:0],data_i[79:19]};
assign s2[75:0] = s1[75:0]; // four left-most bits are determined by the sbox output
assign s3 = {s2[79:20],(s2[19:15])^(round_counter),s2[14:0]};   
assign data_o = s3;

//-----------------------------------------------------------------------------
endmodule
