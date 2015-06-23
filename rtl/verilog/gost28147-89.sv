// $Id:  $ From Russia with love

/////////////////////////////////////////////////////////////////////
//   This file is part of the GOST 28147-89 CryptoCore project     //
//                                                                 //
//   Copyright (c) 2014 Dmitry Murzinov (kakstattakim@gmail.com)   //
///////////////////////////////////////////////////////////////////// 

`timescale 1ns / 100ps

//`define GOST_R_3411_TESTPARAM (1)
//`define GOST_R_3411_CRYPTOPRO (1)
//`define GOST_R_3411_BOTH (1)

module gost_28147_89 (clk, rst, mode, select, load, done, kload, key, pdata, cdata);
  input  clk;    // Input clock signal for synchronous design
  input  rst;    // Syncronous Reset input
  input  mode;   // 0 - encrypt, 1 - decrypt
  input  select; // if GOST_R_3411_BOTH defined: 0 - Using the GOST R 34.11-94 TestParameter S-boxes; 1 - Using the CryptoPro S-boxes
  input  load;   // load plain text and start cipher cycles 
  output done;   // cipher text ready for output read
  input  kload;  // load cipher key 
  input [255:0] key;   // cipher key input
  input  [63:0] pdata; //  plain text input 
  output [63:0] cdata; // cipher text output 

`include "gost-sbox.vh"

reg [4:0] i; // cipher cycles counter: 0..31;

always_ff @(posedge clk)
  if(rst || load)
    i <= 5'h0;
  else //if(~&i)
    i <= i + 1;

//reg run; //running cipher cycles flag    
    
wire [2:0] enc_index = (&i[4:3]) ? ~i[2:0] : i[2:0]; //  cipher key index for encrypt
wire [2:0] dec_index = (|i[4:3]) ? ~i[2:0] : i[2:0]; //  cipher key index for decrypt
wire [2:0] kindex    = mode ? dec_index : enc_index; //  cipher key index    

reg [31:0] K [0:7]; // cipher key storage

always_ff @(posedge clk) 
  if(rst)    
    {K[0],K[1],K[2],K[3],K[4],K[5],K[6],K[7]} <= {256{1'b0}};
  else if(kload)     
    {K[0],K[1],K[2],K[3],K[4],K[5],K[6],K[7]} <= key; 

  
reg   [31:0] b, a; // MSB, LSB of input data
wire  [31:0] state_addmod32 = a + K[kindex];  // Adding by module 32
wire  [31:0] state_sbox     = `Sbox(state_addmod32,select); // S-box replacing
wire  [31:0] state_shift11  = {state_sbox[20:0],state_sbox[31:21]}; // <<11

always_ff @(posedge clk) 
  if(rst)    
    {b,a} <= {64{1'b0}};
  else if(load) 
    {b,a} <= pdata;  
  else /*if(~&i)*/ begin        
    a <= b ^ state_shift11;
    b <= a;
  end
    
reg r_done;
always_ff @(posedge clk)
  if(rst)    
    r_done <= 1'b0;
  else  
    r_done <= &i;

assign done  = r_done;  //ready flag for output data
assign cdata = {a,b}; 

endmodule

