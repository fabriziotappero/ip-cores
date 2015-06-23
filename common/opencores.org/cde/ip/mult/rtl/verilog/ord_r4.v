////////////////////////////////////////////////////////////////////////////////
/// Booth Recoding for Higher-Radix and Signed Multiplication

// :PH: 4.6  Only describes Radix-2 Booth Recoding

 /// Basic Idea
//
// Rather than repeatedly adding either 0 or 1 times multiplicand,
// repeatedly add 0, 1, -1, 2, -2, etc. times the multiplicand.
//
 /// Benefits
//
// Performs signed multiplication without having to first compute the
// absolute value of the multiplier and multiplicand.
//
// Improved performance (when radix higher than 2).

 /// Multipliers Described Here
//
// Ordinary Radix-4 Unsigned Multiplier
//   Presented for pedagogical reasons, Booth multipliers better.
//   Twice as fast as earlier multipliers.
//   Uses more hardware than Booth multipliers below.
//
// Booth Recoding Radix-4 Multiplier
//   Multiplies signed numbers.
//   Twice as fast as earlier multipliers.
//
// Booth Recoding Radix-2 Multiplier
//   Multiplies signed numbers.
//   Uses about the same amount of hardware than earlier signed multiplier.


 /// Ordinary Radix-4 Multiplier Idea
//
// Review of Radix-2 Multiplication
//
//  Multiply 5 times 12.  Radix-2 multiplication (the usual way).
//
//     0101  Multiplicand
//     1100  Multiplier
//     """"
//     0000  0 x 0101
//    0000   0 x 0101
//   0101    1 x 0101
//  0101     1 x 0101
//  """""""
//  0111100  Product
//
// Radix-4 Multiplication
//   Let "a" denote the multiplicand and b denote the multiplier.
//   Pre-compute 2a and 3a.
//   Examine multiplier two bits at a time (rather than one bit at a time).
//   Based on the value of those bits add 0, a, 2a, or 3a (shifted by
//     the appropriate amount).
//
//   Uses n/2 additions to multiply two n-bit numbers.
//
// Two Radix-4 Multiplication Examples
//
//  Multiply 5 times 12.  Radix-4 multiplication (the faster way).
//
//     Precompute: 2a: 01010,  3a: 01111
//
//     0101  Multiplicand
//     1100  Multiplier
//     """"
//    00000  00 x 0101  
//  01111    11 x 0101
//  """""""
//  0111100  Product
//
//  Multiply 5 times 9.  Radix-4 multiplication (the faster way).
//
//     0101  Multiplicand
//     1001  Multiplier
//     """"
//    00101  01 x 0101
//  01010    10 x 0101
//  """""""
//  0101101  Product

 // Ordinary Radix-2^d Multiplier
//
// This is a generalization of the Radix-4 multiplier.
//
//   Let "a" denote the multiplicand and b denote the multiplier.
//   Pre-compute 2a, 3a, 4a, 5a, ..., (2^d-1)a
//   Examine multiplier d bits at a time.
//   Let the value of those bits be v.
//   Add v shifted by the appropriate amount.
//
//   Uses n/d additions to multiply two n-bit numbers.


// :Example:
//
// A Radix-4 multiplier.  Takes unsigned numbers.

module imult_ord_radix_4 #(parameter width=16)
(
   input   wire               clk,
   input   wire               reset,
   input   wire               start,
   input   wire [width-1:0]   multiplicand,
   input   wire [width-1:0]   multiplier,
   output  wire [2*width-1:0] prod,
   output  wire 	      ready
);
   
   reg   [width+1:0]          pp;   
   reg   [width-1:0]          bit_cnt;    
   reg   [2*width:0]          product;
   wire  [width+1:0]          multiplicand_X_1 = {2'b00,multiplicand};
   wire  [width+1:0]          multiplicand_X_2 = {1'b0,multiplicand,1'b0};
   wire  [width+1:0]          multiplicand_X_3 =  multiplicand_X_2 + multiplicand_X_1;

   

   assign   prod  =  product[2*width-1:0];
   assign   ready = ~ ( | bit_cnt);


   
   always @(*)
     begin
        case ( {product[1:0]} )
          2'd0: pp = {2'b0, product[2*width-1:width] };
          2'd1: pp = {2'b0, product[2*width-1:width] } + multiplicand_X_1;
          2'd2: pp = {2'b0, product[2*width-1:width] } + multiplicand_X_2;
          2'd3: pp = {2'b0, product[2*width-1:width] } + multiplicand_X_3;
        endcase
     end


   always @( posedge clk )
    if(reset) 
        begin
        bit_cnt <= 'b0;
        product <= 'b0;
        end
    else
    begin 
     if( ready && start ) 
        begin
        bit_cnt     <= width/2;
        product     <= {1'b0, {width{1'b0}}, multiplier };
        end 
     else if( !ready ) 
        begin
        product     <= { 1'b0,pp, product[width-1:2] };
        bit_cnt     <= bit_cnt - 1;
        end
    end
endmodule
