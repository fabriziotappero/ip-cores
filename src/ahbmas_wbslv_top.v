//******************************************************************************************************
// Copyright (c) 2007 TooMuch Semiconductor Solutions Pvt Ltd.


//File name		:	ahbmas_wbslv_top.v
//Designer		:	Ravi S Gupta
//Date			: 	23 May, 2007
//Description	: 	Wishbone to AHB interface protocol converter
//Revision		:	1.0


//******************************************************************************************************
`timescale 1 ns / 1 ns
//DEFINES
//TOP MODULE

module AHBMAS_WBSLV_TOP ( 
  
  hclk,hresetn,
// AHB Master Interface (Connect to AHB Slave) 
  haddr,htrans,hwrite,hsize,
  hburst,hwdata,hrdata,hready,hresp,

// WISHBONE Slave Interface (Connect to WB Master)
  data_o, data_i, addr_i,clk_i,rst_i,
  cyc_i, stb_i, sel_i, we_i, ack_o
);


//PARAMETER
	parameter AWIDTH = 32,DWIDTH = 32;//Address Width,Data Width
	
//INPUTS AND OUTPUTS	
// --------------------------------------
//Top level ports for AHB 
input hresetn;		 //AHB Clk 
input hclk;		 //AHB Active Low Reset

// AHB Master Interface (Connect to AHB Slave)
input [DWIDTH-1:0]hrdata;		//Read data bus

//Transfer Response	from AHB Slave
input [1:0]hresp;		
input hready;

//Address and Control Signals
output [AWIDTH-1:0]haddr;		//Address
output hwrite;					//Write/Read Control 
output [2:0]hsize;				//Size of Data Control
output [2:0]hburst;				//Burst Control
output [31:0]hwdata;			//Write data bus
output [1:0]htrans;				//Transfer type


// --------------------------------------
// WISHBONE Slave Interface (Connect to WB Master)
output	[DWIDTH-1:0]		data_o;   //Wishbobe Data Ouput
output					ack_o;	   //Wishbone Acknowledge

input	[DWIDTH-1:0]		data_i;   //Wishbone Data Input
input	[AWIDTH-1:0]		addr_i;   //Wishbone Address Input
input					cyc_i;    //Wishbone Cycle Input
input 					stb_i;	   //Wishbone Strobe Input
input	[3:0]			sel_i;	   //Wishbone Selection Input
input					we_i;	   //Wishbone Write/Read Control
input					clk_i;	   //Wishbone Clk Input	
input					rst_i;	   //Wishbone Active High Reset Input 

// datatype declaration
reg [AWIDTH-1:0]haddr;		
wire hwrite;			
reg [2:0]hsize;		
reg [2:0]hburst;		
reg [31:0]hwdata;	
reg [1:0]htrans;		
reg	[DWIDTH-1:0]data_o;
reg	ack_o;

//SIGNAL DECLARATIONS
	reg flag;
	reg hready_temp;

//*******************************************************************
// WISHBONE logic Write and Read Operation
//*******************************************************************

//ASSIGN STATEMENTS
assign #2 hwrite = we_i;

//Sysncronous Reset
always @ (posedge clk_i) 
	begin
	//	hready_temp <= hready;
		if (rst_i) begin
			hsize = 3'b010;		//Size of Data Control
			hburst = 3'b000;		//Burst Control
		//	hready_temp <= 'b1;
			flag <= 'b1;
		end
	
//Write Operation : Wait for a valid Cycle, Strobe and Active High Write enable signal
		else if (cyc_i & stb_i) begin
				if (we_i) begin //Write Cycle: No Need To Check for hready signal for data to be send out
					hwdata <= data_i;
					end
//Read Operation : Wait for a valid Cycle, Strobe and Active Low Write enable signal
			else begin		//	Read Cycle
				if (hready) begin
					if(flag) begin
						flag <= #2 'b0;
						end
					else begin
						flag <= #2 'b1;
						end		
				end
					
			end
		end
		//else begin
		//wb_ack_o<='b0;
		//hwdata <= data_i;//when stb goes active low send asyncronously the data
		//end
end

always @ (we_i or stb_i or addr_i or flag or hready or hrdata) begin
	if(we_i) begin
		if (hready) begin
			haddr <= addr_i;
		end
	end
	else begin 
		if (flag) begin
			haddr <= addr_i;	  //During Flag set Accept Address
			end
		else begin
			data_o <= #2 hrdata;	  //During Flag reset Accept Data
			end
	end
end

//Logic for Acknowledge from Wishbone Slave
always @(we_i or addr_i or hrdata or hready or flag )  begin
	if (rst_i) begin
		ack_o<='b0;
		end
	else if (we_i) 
		ack_o <= hready;
	else
		ack_o<=!flag & hready;
	end

//Logic for Transfer Type 
always @(cyc_i or stb_i) begin
	if (rst_i) begin
		htrans<=2'b00;
		end
	else if (cyc_i) begin
		if (stb_i) begin
			htrans <= 2'b10;	//Transfer type Non Sequential
		end
		else begin
			htrans <= 2'b01;	//Transfer type Busy
		end
	end
	else begin
	htrans<=2'b00;	//Transfer type Idle 
	end
end


endmodule	
