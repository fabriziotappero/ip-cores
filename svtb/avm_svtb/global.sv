//******************************************************************************************************
// Copyright (c) 2007 TooMuch Semiconductor Solutions Pvt Ltd.


//File name             :       global.sv
//Designer		:	Ravi S Gupta
//Date                  :       4 Sept, 2007
//Description   	:       Gloabl Declaration for WISHBONE_AHB Bridge used within Driver, Stimulus Generator and Monitor
//Revision              :       1.0

//******************************************************************************************************

// package decleration
package global;

parameter  int DWIDTH =32;
parameter  int AWIDTH =32;
parameter  int cyc_prd = 10;  

typedef struct {
	rand logic [AWIDTH-1:0]adr;
       	rand logic [DWIDTH-1:0]dat;
	logic wr; // write
	logic stb; 
} wb_req_pkt;

typedef struct {
	rand logic [DWIDTH-1:0]dat;
	logic rdy;// hready
	logic trans;//htrans 
} wb_res_pkt;
 
typedef struct {
	bit flag1;//read/write
	bit flag2;//ack
	logic wr; //write signal
	logic stb;//strobe for wait from master
	logic ack;//ack for wait state from slave
	logic [AWIDTH-1:0]adr1;
	logic [AWIDTH-1:0]adr2;
       	logic [DWIDTH-1:0]dat1;
	logic [DWIDTH-1:0]dat2;
} monitor_pkt;


endpackage
