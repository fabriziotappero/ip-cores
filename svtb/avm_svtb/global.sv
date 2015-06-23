//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************************************************
// Copyright (c) 2007 TooMuch Semiconductor Solutions Pvt Ltd.
//
//File name		:	global.sv
//Designer		: 	Sanjay kumar	
//Date			: 	3rd Aug'2007		
//Description		: 	global : Package defining user defined transaction packets
//Revision		:	1.0
//*****************************************************************************************************************
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// package decleration
package global;

parameter  int DWIDTH =32;
parameter  int AWIDTH =16;
parameter  int cyc_prd = 10;  

typedef struct {
	rand logic [AWIDTH-1:0]adr;
       	rand logic [DWIDTH-1:0]dat;
	logic [1:0] mode; // htrans
	logic wr; // hwrite 
} ahb_req_pkt;

typedef struct {
	rand logic [DWIDTH-1:0]dat;
	logic rdy;// hready 
} ahb_res_pkt;
 
typedef struct {
	bit flag1;
	bit flag2;
	logic wr; 
	logic sel; 
	logic [1:0]mode;  
	logic [AWIDTH-1:0]adr1;
	logic [AWIDTH-1:0]adr2;
       	logic [DWIDTH-1:0]dat1;
	logic [DWIDTH-1:0]dat2;
} monitor_pkt;
// convert to strings
function string convert2string(ahb_req_pkt p);
string s;
	$sformat(s,"adr:%0d dat:%0d mst_mode:%0d Wr_Rd:%0d",p.adr,p.dat,p.mode,p.wr);
	return s;
endfunction
	

endpackage
