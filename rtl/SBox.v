/*
Project        : AES
Standard doc.  : FIPS 197
Module name    : SBox block
Dependancy     :
Design doc.    : 
References     : 
Description    : Sbox is a lookup/substitution table to 
                 substitute the input byte
Owner          : Amr Salah
*/

`timescale 1 ns/1 ps

module SBox               
(
input clk,               //system clock
input reset,             //asynch active low reset
input valid_in,          //valid input signal
input [7:0] addr,        //SBox input byte
output reg [7:0] dout    //SBox output
);

always @ ( posedge clk or negedge reset) 
  if (!reset) begin
    dout <= 8'h00;
  end  else begin
      
    if(valid_in) begin
     case (addr)          //substitution table
       8'h00              : dout <= 8'h63;
       8'h01              : dout <= 8'h7c;
       8'h02              : dout <= 8'h77;
       8'h03              : dout <= 8'h7b;
       8'h04              : dout <= 8'hf2;
       8'h05              : dout <= 8'h6b;
       8'h06              : dout <= 8'h6f;
       8'h07              : dout <= 8'hc5;
       8'h08              : dout <= 8'h30;
       8'h09              : dout <= 8'h01;
       8'h0a              : dout <= 8'h67;
       8'h0b              : dout <= 8'h2b;
       8'h0c              : dout <= 8'hfe;
       8'h0d              : dout <= 8'hd7;
       8'h0e              : dout <= 8'hab;
       8'h0f              : dout <= 8'h76;
    /****************************************/
       8'h10              : dout <= 8'hca;
       8'h11              : dout <= 8'h82;
       8'h12              : dout <= 8'hc9;
       8'h13              : dout <= 8'h7d;
       8'h14              : dout <= 8'hfa;
       8'h15              : dout <= 8'h59;
       8'h16              : dout <= 8'h47;
       8'h17              : dout <= 8'hf0;
       8'h18              : dout <= 8'had;
       8'h19              : dout <= 8'hd4;
       8'h1a              : dout <= 8'ha2;
       8'h1b              : dout <= 8'haf;
       8'h1c              : dout <= 8'h9c;
       8'h1d              : dout <= 8'ha4;
       8'h1e              : dout <= 8'h72;
       8'h1f              : dout <= 8'hc0;
    /**********************************************/
       8'h20              : dout <= 8'hb7;
       8'h21              : dout <= 8'hfd;
       8'h22              : dout <= 8'h93;
       8'h23              : dout <= 8'h26;
       8'h24              : dout <= 8'h36;
       8'h25              : dout <= 8'h3f;
       8'h26              : dout <= 8'hf7;
       8'h27              : dout <= 8'hcc;
       8'h28              : dout <= 8'h34;
       8'h29              : dout <= 8'ha5;
       8'h2a              : dout <= 8'he5;
       8'h2b              : dout <= 8'hf1;
       8'h2c              : dout <= 8'h71;
       8'h2d              : dout <= 8'hd8;
       8'h2e              : dout <= 8'h31;
       8'h2f              : dout <= 8'h15;
    /*****************************************/
       8'h30              : dout <= 8'h04;
       8'h31              : dout <= 8'hc7;
       8'h32              : dout <= 8'h23;
       8'h33              : dout <= 8'hc3;
       8'h34              : dout <= 8'h18;
       8'h35              : dout <= 8'h96;
       8'h36              : dout <= 8'h05;
       8'h37              : dout <= 8'h9a;
       8'h38              : dout <= 8'h07;
       8'h39              : dout <= 8'h12;
       8'h3a              : dout <= 8'h80;
       8'h3b              : dout <= 8'he2;
       8'h3c              : dout <= 8'heb;
       8'h3d              : dout <= 8'h27;
       8'h3e              : dout <= 8'hb2;
       8'h3f              : dout <= 8'h75;
    /*******************************************/
       8'h40              : dout <= 8'h09;
       8'h41              : dout <= 8'h83;
       8'h42              : dout <= 8'h2c;
       8'h43              : dout <= 8'h1a;
       8'h44              : dout <= 8'h1b;
       8'h45              : dout <= 8'h6e;
       8'h46              : dout <= 8'h5a;
       8'h47              : dout <= 8'ha0;
       8'h48              : dout <= 8'h52;
       8'h49              : dout <= 8'h3b;
       8'h4a              : dout <= 8'hd6;
       8'h4b              : dout <= 8'hb3;
       8'h4c              : dout <= 8'h29;
       8'h4d              : dout <= 8'he3;
       8'h4e              : dout <= 8'h2f;
       8'h4f              : dout <= 8'h84;
    /**********************************************/
       8'h50              : dout <= 8'h53;
       8'h51              : dout <= 8'hd1;
       8'h52              : dout <= 8'h00;
       8'h53              : dout <= 8'hed;
       8'h54              : dout <= 8'h20;
       8'h55              : dout <= 8'hfc;
       8'h56              : dout <= 8'hb1;
       8'h57              : dout <= 8'h5b;
       8'h58              : dout <= 8'h6a;
       8'h59              : dout <= 8'hcb;
       8'h5a              : dout <= 8'hbe;
       8'h5b              : dout <= 8'h39;
       8'h5c              : dout <= 8'h4a;
       8'h5d              : dout <= 8'h4c;
       8'h5e              : dout <= 8'h58;
       8'h5f              : dout <= 8'hcf;
       /****************************************/
       8'h60              : dout <= 8'hd0;
       8'h61              : dout <= 8'hef;
       8'h62              : dout <= 8'haa;
       8'h63              : dout <= 8'hfb;
       8'h64              : dout <= 8'h43;
       8'h65              : dout <= 8'h4d;
       8'h66              : dout <= 8'h33;
       8'h67              : dout <= 8'h85;
       8'h68              : dout <= 8'h45;
       8'h69              : dout <= 8'hf9;
       8'h6a              : dout <= 8'h02;
       8'h6b              : dout <= 8'h7f;
       8'h6c              : dout <= 8'h50;
       8'h6d              : dout <= 8'h3c;
       8'h6e              : dout <= 8'h9f;
       8'h6f              : dout <= 8'ha8;
    /*********************************************/
       8'h70              : dout <= 8'h51;
       8'h71              : dout <= 8'ha3;
       8'h72              : dout <= 8'h40;
       8'h73              : dout <= 8'h8f;
       8'h74              : dout <= 8'h92;
       8'h75              : dout <= 8'h9d;
       8'h76              : dout <= 8'h38;
       8'h77              : dout <= 8'hf5;
       8'h78              : dout <= 8'hbc;
       8'h79              : dout <= 8'hb6;
       8'h7a              : dout <= 8'hda;
       8'h7b              : dout <= 8'h21;
       8'h7c              : dout <= 8'h10;
       8'h7d              : dout <= 8'hff;
       8'h7e              : dout <= 8'hf3;
       8'h7f              : dout <= 8'hd2;
    /********************************************/
       8'h80              : dout <= 8'hcd;
       8'h81              : dout <= 8'h0c;
       8'h82              : dout <= 8'h13;
       8'h83              : dout <= 8'hec;
       8'h84              : dout <= 8'h5f;
       8'h85              : dout <= 8'h97;
       8'h86              : dout <= 8'h44;
       8'h87              : dout <= 8'h17;
       8'h88              : dout <= 8'hc4;
       8'h89              : dout <= 8'ha7;
       8'h8a              : dout <= 8'h7e;
       8'h8b              : dout <= 8'h3d;
       8'h8c              : dout <= 8'h64;
       8'h8d              : dout <= 8'h5d;
       8'h8e              : dout <= 8'h19;
       8'h8f              : dout <= 8'h73;
 /***********************************************/
       8'h90              : dout <= 8'h60;
       8'h91              : dout <= 8'h81;
       8'h92              : dout <= 8'h4f;
       8'h93              : dout <= 8'hdc;
       8'h94              : dout <= 8'h22;
       8'h95              : dout <= 8'h2a;
       8'h96              : dout <= 8'h90;
       8'h97              : dout <= 8'h88;
       8'h98              : dout <= 8'h46;
       8'h99              : dout <= 8'hee;
       8'h9a              : dout <= 8'hb8;
       8'h9b              : dout <= 8'h14;
       8'h9c              : dout <= 8'hde;
       8'h9d              : dout <= 8'h5e;
       8'h9e              : dout <= 8'h0b;
       8'h9f              : dout <= 8'hdb;
      /******************************************/
       8'ha0              : dout <= 8'he0;
       8'ha1              : dout <= 8'h32;
       8'ha2              : dout <= 8'h3a;
       8'ha3              : dout <= 8'h0a;
       8'ha4              : dout <= 8'h49;
       8'ha5              : dout <= 8'h06;
       8'ha6              : dout <= 8'h24;
       8'ha7              : dout <= 8'h5c;
       8'ha8              : dout <= 8'hc2;
       8'ha9              : dout <= 8'hd3;
       8'haa              : dout <= 8'hac;
       8'hab              : dout <= 8'h62;
       8'hac              : dout <= 8'h91;
       8'had              : dout <= 8'h95;
       8'hae              : dout <= 8'he4;
       8'haf              : dout <= 8'h79;
    /******************************************/
       8'hb0              : dout <= 8'he7;
       8'hb1              : dout <= 8'hc8;
       8'hb2              : dout <= 8'h37;
       8'hb3              : dout <= 8'h6d;
       8'hb4              : dout <= 8'h8d;
       8'hb5              : dout <= 8'hd5;
       8'hb6              : dout <= 8'h4e;
       8'hb7              : dout <= 8'ha9;
       8'hb8              : dout <= 8'h6c;
       8'hb9              : dout <= 8'h56;
       8'hba              : dout <= 8'hf4;
       8'hbb              : dout <= 8'hea;
       8'hbc              : dout <= 8'h65;
       8'hbd              : dout <= 8'h7a;
       8'hbe              : dout <= 8'hae;
       8'hbf              : dout <= 8'h08;
    /****************************************/
       8'hc0              : dout <= 8'hba;
       8'hc1              : dout <= 8'h78;
       8'hc2              : dout <= 8'h25;
       8'hc3              : dout <= 8'h2e;
       8'hc4              : dout <= 8'h1c;
       8'hc5              : dout <= 8'ha6;
       8'hc6              : dout <= 8'hb4;
       8'hc7              : dout <= 8'hc6;
       8'hc8              : dout <= 8'he8;
       8'hc9              : dout <= 8'hdd;
       8'hca              : dout <= 8'h74;
       8'hcb              : dout <= 8'h1f;
       8'hcc              : dout <= 8'h4b;
       8'hcd              : dout <= 8'hbd;
       8'hce              : dout <= 8'h8b;
       8'hcf              : dout <= 8'h8a;
    /****************************************/
       8'hd0              : dout <= 8'h70;
       8'hd1              : dout <= 8'h3e;
       8'hd2              : dout <= 8'hb5;
       8'hd3              : dout <= 8'h66;
       8'hd4              : dout <= 8'h48;
       8'hd5              : dout <= 8'h03;
       8'hd6              : dout <= 8'hf6;
       8'hd7              : dout <= 8'h0e;
       8'hd8              : dout <= 8'h61;
       8'hd9              : dout <= 8'h35;
       8'hda              : dout <= 8'h57;
       8'hdb              : dout <= 8'hb9;
       8'hdc              : dout <= 8'h86;
       8'hdd              : dout <= 8'hc1;
       8'hde              : dout <= 8'h1d;
       8'hdf              : dout <= 8'h9e;
    /*******************************************/
       8'he0              : dout <= 8'he1;
       8'he1              : dout <= 8'hf8;
       8'he2              : dout <= 8'h98;
       8'he3              : dout <= 8'h11;
       8'he4              : dout <= 8'h69;
       8'he5              : dout <= 8'hd9;
       8'he6              : dout <= 8'h8e;
       8'he7              : dout <= 8'h94;
       8'he8              : dout <= 8'h9b;
       8'he9              : dout <= 8'h1e;
       8'hea              : dout <= 8'h87;
       8'heb              : dout <= 8'he9;
       8'hec              : dout <= 8'hce;
       8'hed              : dout <= 8'h55;
       8'hee              : dout <= 8'h28;
       8'hef              : dout <= 8'hdf;
    /****************************************/
       8'hf0              : dout <= 8'h8c;
       8'hf1              : dout <= 8'ha1;
       8'hf2              : dout <= 8'h89;
       8'hf3              : dout <= 8'h0d;
       8'hf4              : dout <= 8'hbf;
       8'hf5              : dout <= 8'he6;
       8'hf6              : dout <= 8'h42;
       8'hf7              : dout <= 8'h68;
       8'hf8              : dout <= 8'h41;
       8'hf9              : dout <= 8'h99;
       8'hfa              : dout <= 8'h2d;
       8'hfb              : dout <= 8'h0f;
       8'hfc              : dout <= 8'hb0;
       8'hfd              : dout <= 8'h54;
       8'hfe              : dout <= 8'hbb;
       8'hff              : dout <= 8'h16;
       default            : dout <= 8'h00;
       
    endcase
  end
end

endmodule 
