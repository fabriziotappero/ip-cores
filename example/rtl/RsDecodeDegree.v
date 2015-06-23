//===================================================================
// Module Name : RsDecodeDegree
// File Name   : RsDecodeDegree.v
// Function    : Rs Decoder Degree Module
// 
// Revision History:
// Date          By           Version    Change Description
//===================================================================
// 2009/02/03  Gael Sapience     1.0       Original
//
//===================================================================
// (C) COPYRIGHT 2009 SYSTEM LSI CO., Ltd.
//


module RsDecodeDegree(
   polynom_0,
   polynom_1,
   polynom_2,
   polynom_3,
   polynom_4,
   polynom_5,
   polynom_6,
   polynom_7,
   polynom_8,
   polynom_9,
   polynom_10,
   polynom_11,
   polynom_12,
   polynom_13,
   polynom_14,
   polynom_15,
   polynom_16,
   polynom_17,
   polynom_18,
   polynom_19,
   polynom_20,
   polynom_21,
   degree
);


   input  [7:0]   polynom_0;    // polynom 0
   input  [7:0]   polynom_1;    // polynom 1
   input  [7:0]   polynom_2;    // polynom 2
   input  [7:0]   polynom_3;    // polynom 3
   input  [7:0]   polynom_4;    // polynom 4
   input  [7:0]   polynom_5;    // polynom 5
   input  [7:0]   polynom_6;    // polynom 6
   input  [7:0]   polynom_7;    // polynom 7
   input  [7:0]   polynom_8;    // polynom 8
   input  [7:0]   polynom_9;    // polynom 9
   input  [7:0]   polynom_10;   // polynom 10
   input  [7:0]   polynom_11;   // polynom 11
   input  [7:0]   polynom_12;   // polynom 12
   input  [7:0]   polynom_13;   // polynom 13
   input  [7:0]   polynom_14;   // polynom 14
   input  [7:0]   polynom_15;   // polynom 15
   input  [7:0]   polynom_16;   // polynom 16
   input  [7:0]   polynom_17;   // polynom 17
   input  [7:0]   polynom_18;   // polynom 18
   input  [7:0]   polynom_19;   // polynom 19
   input  [7:0]   polynom_20;   // polynom 20
   input  [7:0]   polynom_21;   // polynom 21
   output [4:0]   degree;       // polynom degree



   //------------------------------------------------------------------------
   //- registers
   //------------------------------------------------------------------------
//---------------------------------------------------------------
//- step 0
//---------------------------------------------------------------
wire [4:0]   winner0Step0;
assign winner0Step0 =(polynom_1 [7:0] == 8'd0) ? ((polynom_0 [7:0] == 8'd0) ? 5'd0 : 5'd0):  5'd1;
wire [4:0]   winner1Step0;
assign winner1Step0 =(polynom_3 [7:0] == 8'd0) ? ((polynom_2 [7:0] == 8'd0) ? 5'd0 : 5'd2):  5'd3;
wire [4:0]   winner2Step0;
assign winner2Step0 =(polynom_5 [7:0] == 8'd0) ? ((polynom_4 [7:0] == 8'd0) ? 5'd0 : 5'd4):  5'd5;
wire [4:0]   winner3Step0;
assign winner3Step0 =(polynom_7 [7:0] == 8'd0) ? ((polynom_6 [7:0] == 8'd0) ? 5'd0 : 5'd6):  5'd7;
wire [4:0]   winner4Step0;
assign winner4Step0 =(polynom_9 [7:0] == 8'd0) ? ((polynom_8 [7:0] == 8'd0) ? 5'd0 : 5'd8):  5'd9;
wire [4:0]   winner5Step0;
assign winner5Step0 =(polynom_11 [7:0] == 8'd0) ? ((polynom_10 [7:0] == 8'd0) ? 5'd0 : 5'd10):  5'd11;
wire [4:0]   winner6Step0;
assign winner6Step0 =(polynom_13 [7:0] == 8'd0) ? ((polynom_12 [7:0] == 8'd0) ? 5'd0 : 5'd12):  5'd13;
wire [4:0]   winner7Step0;
assign winner7Step0 =(polynom_15 [7:0] == 8'd0) ? ((polynom_14 [7:0] == 8'd0) ? 5'd0 : 5'd14):  5'd15;
wire [4:0]   winner8Step0;
assign winner8Step0 =(polynom_17 [7:0] == 8'd0) ? ((polynom_16 [7:0] == 8'd0) ? 5'd0 : 5'd16):  5'd17;
wire [4:0]   winner9Step0;
assign winner9Step0 =(polynom_19 [7:0] == 8'd0) ? ((polynom_18 [7:0] == 8'd0) ? 5'd0 : 5'd18):  5'd19;
wire [4:0]   winner10Step0;
assign winner10Step0 =(polynom_21 [7:0] == 8'd0) ? ((polynom_20 [7:0] == 8'd0) ? 5'd0 : 5'd20):  5'd21;
//---------------------------------------------------------------
//- step 1
//---------------------------------------------------------------
wire [4:0]   winner0Step1;
assign winner0Step1 =( winner1Step0 [4:0] < winner0Step0  [4:0]) ? winner0Step0  [4:0]:  winner1Step0  [4:0];
wire [4:0]   winner1Step1;
assign winner1Step1 =( winner3Step0 [4:0] < winner2Step0  [4:0]) ? winner2Step0  [4:0]:  winner3Step0  [4:0];
wire [4:0]   winner2Step1;
assign winner2Step1 =( winner5Step0 [4:0] < winner4Step0  [4:0]) ? winner4Step0  [4:0]:  winner5Step0  [4:0];
wire [4:0]   winner3Step1;
assign winner3Step1 =( winner7Step0 [4:0] < winner6Step0  [4:0]) ? winner6Step0  [4:0]:  winner7Step0  [4:0];
wire [4:0]   winner4Step1;
assign winner4Step1 =( winner9Step0 [4:0] < winner8Step0  [4:0]) ? winner8Step0  [4:0]:  winner9Step0  [4:0];
//---------------------------------------------------------------
//- step 2
//---------------------------------------------------------------
wire [4:0]   winner0Step2;
assign winner0Step2 =( winner1Step1 [4:0] < winner0Step1  [4:0]) ? winner0Step1  [4:0]:  winner1Step1  [4:0];
wire [4:0]   winner1Step2;
assign winner1Step2 =( winner3Step1 [4:0] < winner2Step1  [4:0]) ? winner2Step1  [4:0]:  winner3Step1  [4:0];
wire [4:0]   winner2Step2;
assign winner2Step2 =( winner10Step0 [4:0] < winner4Step1  [4:0]) ? winner4Step1  [4:0]:  winner10Step0  [4:0];
//---------------------------------------------------------------
//- step 3
//---------------------------------------------------------------
wire [4:0]   winner0Step3;
assign winner0Step3 =( winner1Step2 [4:0] < winner0Step2  [4:0]) ? winner0Step2  [4:0]:  winner1Step2  [4:0];
//---------------------------------------------------------------
//- step 4
//---------------------------------------------------------------
wire [4:0]   winner0Step4;
assign winner0Step4 =( winner2Step2 [4:0] < winner0Step3  [4:0]) ? winner0Step3  [4:0]:  winner2Step2  [4:0];
//---------------------------------------------------------------
//---------------------------------------------------------------
assign degree [4:0] =  winner0Step4 [4:0] ;



endmodule
