// $Id:  $ from Russia with love

/////////////////////////////////////////////////////////////////////
//   This file is part of the GOST 28147-89 CryptoCore project     //
//                                                                 //
//   Copyright (c) 2014 Dmitry Murzinov (kakstattakim@gmail.com)   //
///////////////////////////////////////////////////////////////////// 

`timescale 1ns / 100ps

module tb ();

// clock generator settings:
parameter cycles_reset =  2;  // rst active  (clk)  
parameter clk_period   = 10;  // clk period ns
parameter clk_delay    =  0;  // clk initial delay 

reg clk;    // clock
reg rst;    // sync reset
reg mode;   // 0 - encrypt, 1 - decrypt
reg select; // if GOST_R_3411_BOTH defined: 0 - Using the GOST R 34.11-94 TestParameter S-boxes; 1 - Using the CryptoPro S-boxes
reg load;   // load plain text and start cipher cycles 
wire done;  // cipher text ready for output read
reg kload;  // load cipher key 

reg [255:0] key;   // cipher key   input
reg  [63:0] pdata; // plain  text  input 
wire [63:0] cdata; // cipher text output   

reg  [63:0] pdata_d; //  plain text  input 
wire [63:0] cdata_d; // cipher text output   

reg  [63:0] reference_data; // reference data for verify

wire EQUAL = cdata == reference_data;
wire [8*4-1:0] STATUS = EQUAL ? "OK" : "FAIL";

// instance connect
gost_28147_89 
  u_cipher  (.clk(clk), .rst(rst), .mode(mode), .select(select), .load(load), .done(done), .kload(kload), .key(key), .pdata(pdata), .cdata(cdata));

 
 reg [24:0] clk_counter; // just clock counter for debug 
 
// Clock generation
 always begin
 # (clk_delay);
   forever # (clk_period/2) clk = ~clk;
 end  
 
// Initial statement 
initial begin
 #0 clk  = 1'b0;
    load = 0;
    kload = 0;
    mode  = 0;    
    select = 0;
    key = 256'h0;
    pdata = 64'h0;
    clk_counter = 0;

  // Reset  
  #0           rst   = 1'bX;
  #0           rst   = 1'b0;
  # ( 2*clk_period *cycles_reset) rst   = 1'b1;
  # ( 2*clk_period *cycles_reset) rst   = 1'b0;
  
  // key load
  @ ( posedge clk ) #1 kload = 1; 
      key = swapkey(256'hBE5EC200_6CFF9DCF_52354959_F1FF0CBF_E95061B5_A648C103_87069C25_997C0672);
  @ ( posedge clk ) #1 kload = 0;
  

  //  Crypt mode
  @ ( posedge clk ) #1 load = 1;  mode = 0;
    pdata          = swapdata(64'h0DF82802_B741A292);
    reference_data = swapdata(64'h07F9027D_F7F7DF89);
  @ ( posedge clk ) #1 load = 0;  
  

  //  Decrypt mode
  @ ( posedge done );
  @ ( posedge clk ) #1 load = 1; mode = 1; 
    pdata          = swapdata(64'h07F9027D_F7F7DF89);
    reference_data = swapdata(64'h0DF82802_B741A292);
  @ ( posedge clk ) #1 load = 0;  

  //$finish; 
  @ ( posedge done );
  @ ( posedge clk )  
  #1 $stop;
end
 
always begin 
 @( posedge clk );
    clk_counter <=  clk_counter + 1;
end // always 
 
always  @( posedge done ) 
  if (mode == 0)
     #1 $display("KEY: %H \nCRYPT   IN: %H \t REFOUT: %H \t OUT: %H   ....%s\n", key, pdata, reference_data, cdata, STATUS); 
  else if (mode == 1)
     #1 $display("KEY: %H \nDECRYPT IN: %H \t REFOUT: %H \t OUT: %H   ....%s\n", key, pdata, reference_data, cdata, STATUS); 


// ======= swap4(x) =======
function [31:0] swap4( input [31:0] x );
begin
  swap4 = {x[7:0],x[15:8],x[23:16],x[31:24]};
end
endfunction  

// ======= swapdate(data) =======
function [63:0] swapdata( input [63:0] data );
begin
  swapdata = {swap4(data[31:0]),swap4(data[63:32])};
end
endfunction  

// ======= swapkey(key) =======
function [255:0] swapkey( input [255:0] key );
logic [31:0] K [0:7]; 
begin
    K[0] = swap4(key[255:224]);
    K[1] = swap4(key[223:192]);
    K[2] = swap4(key[191:160]);
    K[3] = swap4(key[159:128]);
    K[4] = swap4(key[127:96]);
    K[5] = swap4(key[95:64]);
    K[6] = swap4(key[63:32]);
    K[7] = swap4(key[31:0]); 
 swapkey = {K[0],K[1],K[2],K[3],K[4],K[5],K[6],K[7]};
end
endfunction  

endmodule
// eof
