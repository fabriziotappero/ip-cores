//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//
// Design Name: Test Bench for Present Encryptor Core             //
// Module Name: present_encryptor_top_tb                          //
// Language:    Verilog                                           //
// Date Created: 1/23/2011                                        //
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
`timescale 1ps / 1ps

//- Test Bench ----------------------------------------------------------------
module present_encryptor_top_tb;
//- Variables, Registers and Parameters ---------------------------------------
wire [63:0] data_o;
reg  [79:0] data_i;
reg  data_load;
reg  key_load;
reg  clk_i;
//- Instantiations ------------------------------------------------------------
present_encryptor_top UUT (.data_o(data_o),.data_i(data_i),.data_load(data_load),.key_load(key_load),.clk_i(clk_i));
//- Behavioral Statements -----------------------------------------------------
initial
begin
    $monitor($realtime,,"ps %h %h %h %h %h ",data_o,data_i,data_load,key_load,clk_i);
    #0   data_i = 80'h00000000_00000000_0000 ; key_load = 1; // Key
    #10  data_i = 64'h00000000_00000000      ; key_load = 0; data_load = 1; // Plaintext
    #10  data_load = 0;
    #330 data_i = 80'hFFFFFFFF_FFFFFFFF_FFFF ; key_load = 1; // Key
    #10  data_i = 64'h00000000_00000000      ; key_load = 0; data_load = 1; // Plaintext
    #10  data_load = 0;
    #330 data_i = 80'h00000000_00000000_0000 ; key_load = 1; // Key
    #10  data_i = 64'hFFFFFFFF_FFFFFFFF      ; key_load = 0; data_load = 1; // Plaintext
    #10  data_load = 0;
    #330 data_i = 80'hFFFFFFFF_FFFFFFFF_FFFF ; key_load = 1; // Key
    #10  data_i = 64'hFFFFFFFF_FFFFFFFF      ; key_load = 0; data_load = 1; // Plaintext
    #10  data_load = 0;
    #330 $finish;
end
initial
begin
    clk_i = 1'b0;
    forever #5 clk_i = ~clk_i;
end
//-----------------------------------------------------------------------------
endmodule