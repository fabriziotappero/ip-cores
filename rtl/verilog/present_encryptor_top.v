//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//
// Design Name: Present Cipher Encryption Core                    //
// Module Name: present_encryptor_top                             //
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

module present_encryptor_top(data_o,data_i,data_load,key_load,clk_i);
//- Module IOs ----------------------------------------------------------------

output wire[63:0] data_o; // ciphertext will appear here
input  wire[79:0] data_i; // plaintext and key must be fed here
input  wire clk_i; // clock signal
input  wire key_load; // when '1', data_i will loaded into key register
input  wire data_load; // when '1', first 64 bits of data_i will be loaded into state register

//- Variables, Registers and Parameters ---------------------------------------

reg  [63 : 0] state; // 64-bit state of the cipher
reg  [4  : 0] round_counter; // 5-bit round-counter (from 1 to 31)
reg  [79 : 0] key; // 80-bit register holding the key and updates of the key

wire [63 : 0] round_key; // 64-bit round-key. The round-keys are derived from the key register
wire [63 : 0] sub_per_input; // 64-bit input to the substitution-permutation network
wire [63 : 0] sub_per_output; // 64-bit output of the substitution-permutation network
wire [79 : 0] key_update_output; // 80-bit output of the keyupdate procedure. This value replaces the value of the key register

//- Instantiations ------------------------------------------------------------

sub_per present_cipher_sp(.data_o(sub_per_output),.data_i(sub_per_input)); 
    // instantion of  substitution and permutation module
    // this module is used 31 times iteratively

key_update present_cipher_key_update(.data_o(key_update_output),.data_i(key),.round_counter(round_counter)); 
    // instantiation of the key-update procedure
    // this module is used 31 times iteratively
    
//- Continuous Assigments------------------------------------------------------

assign round_key = key[79:16]; // iurrent round-key is the 64 left most bits of the key register

assign sub_per_input = state^round_key; // input to the Substitution-Permutation network is the cipher state xored by the round key

assign data_o = sub_per_input; // the output of the cipher will finally be one of the inputs to the Substitution-Permutation network.
                             // output will be valid when round-counter is 31

//- Behavioral Statements -----------------------------------------------------

always @(posedge clk_i)
begin
    if(key_load) // loading the key
    begin
        key <= data_i;
    end
    else if(!key_load) // not loading the key
    begin
        if(data_load) // loading plaintext
        begin
            state <= data_i[63:0];
            round_counter <= 5'b00001; // round_counter starts from 1 and ends at 31
        end
        else if(!data_load) // normal operation (neither loading the key nor loading the plaitext)
        begin                  
            round_counter <= round_counter + 1'b1; // round counter is increased by one
            state <= sub_per_output; // state is updated
            key <= key_update_output; // key register is updated
        end
    end
end
//-----------------------------------------------------------------------------
endmodule
