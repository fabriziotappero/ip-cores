
// Copyright (c) 2007 TooMuch Semiconductor Solutions Pvt Ltd.


//File name		:	ahb2wb_tb.v
//Designer		:	Manish Agarwal
//Date			: 	18 May, 2007
//Description	: 	Test bench for AHB-Wishbone BRIDGE 
//Revision		:	1.0


//******************************************************************************************************

`include "../src/ahb2wb.v"


module ahb2wb_tb  ; 

parameter DWIDTH =32;
parameter TON   = 5;
parameter TOFF  = 5 ;
parameter AWIDTH  = 16 ; 

integer  address = 0;
integer data = 0;   

  reg  [1:0]  htrans   ; 
  reg  [DWIDTH-1:0]  dat_i   ; 
  reg    hresetn   ; 
  reg    hclk   ; 
  reg    hwrite   ; 

  wire  [DWIDTH-1:0]  hrdata   ; 
  reg    hsel   ; 
  wire    hready   ; 
  wire  [DWIDTH-1:0]  dat_o   ; 
  reg    ack_i   ; 
  reg  [2:0]  hburst   ; 
  reg  [DWIDTH-1:0]  hwdata   ; 
  wire  [1:0]  hresp   ; 

  wire    we_o   ; 
  reg  [2:0]  hsize   ; 
  reg  [AWIDTH-1:0]  haddr   ; 
  wire  [AWIDTH-1:0]  adr_o   ; 
  wire    cyc_o   ; 
  wire    stb_o   ; 
 
//module instantiation

  ahb2wb    
   DUT  ( 
       .htrans (htrans ) ,
      .dat_i (dat_i ) ,
      .hresetn (hresetn ) ,
      .hclk (hclk ) ,
      .hwrite (hwrite ) ,
      .hrdata (hrdata ) ,
      .hsel (hsel ) ,
      .hready (hready ) ,
      .dat_o (dat_o ) ,
      .ack_i (ack_i ) ,
      .hburst (hburst ) ,
      .hwdata (hwdata ) ,
      .hresp (hresp ) ,
      .we_o (we_o ) ,
      .hsize (hsize ) ,
      .haddr (haddr ) ,
      .adr_o (adr_o ) ,
      .cyc_o (cyc_o ) ,
      .stb_o (stb_o ),
	  .clk_i(),
	  .rst_i()); 

// local memory in wishbone slave model
	reg [DWIDTH-1 : 0] wb_mem [AWIDTH-1 : 0]; 


//*************************************************
// Wishbone slave model
//*************************************************

	always @(stb_o or we_o or adr_o or dat_o) begin
		
		ack_i = 'b1;
		
		if (!stb_o) begin
			 ack_i = #2 'b0;
		end

		if (we_o) begin	
			wb_mem[adr_o] = dat_o;					// data stored in wb slave
		end
		else begin
			dat_i = wb_mem[adr_o];
		end
			
	end



// Reset operation --as per wishbone requirement
	initial begin
		hresetn = 'b1;
		#3
		hresetn = 'b0;
		#10
		@(posedge hclk)
		hresetn = 'b1;
	end


// Clock operation
	always begin	
		#TOFF 
		hclk = 'b0;				
		#TON 
		hclk = 'b1;
	end


// signal states
	initial begin
		// deassertions
		htrans = 'b00; 								// default value - idle 
		@(negedge hresetn) 
		@(posedge hclk) #1 hsel = 'b0;
		
		// assertions
		@(posedge hresetn) 
		@(posedge hclk) #2 hsel = 'b1;
		ack_i = 'b0;
		hsize = 'b010; 								// 32 bit size (word transfer)
		hburst = 'b000;								// single transfer
				
//*************************************
//Write cycle
//*************************************
		repeat(4) ahb_write;

// wait state inserted by wishbone slave
		#2 ack_i = 'b0;							

		repeat(4) ahb_write;

		#2 ack_i = 'b1;
			
		repeat(4) ahb_write;

// wait state inserted by master AHB

		#2
		htrans = 'b01;	
		#20
		htrans = 'b10;
		
		repeat(4) ahb_write;
							
// wait state inserted by master AHB
		#2
		htrans = 'b01;											
		#20
		htrans = 'b10;

		
//*************************************
//Read cycle
//*************************************
		repeat(6) ahb_read; 

// wait state inserted by master AHB
		#2
		htrans = 'b01;											
		#20
		htrans = 'b10;

		repeat(3) ahb_read;

// wait state inserted by wishbone slave
		#2 ack_i = 'b0;							

		repeat(3) ahb_read;

		#2 ack_i = 'b1;


//*************************************
//write cycle
//*************************************
		repeat(4) ahb_write;
			
		htrans = 'b00;		// bus idle
		#100 $stop;
	end



//*****************************************
//AHB  write cycle (master model)
//*****************************************

task ahb_write;								
	begin
		@(posedge hclk) begin
			if (hready) begin
				#2
				htrans = 'b10;						// non sequential transfer
				address = address + 1;
				hwrite = 'b1;
				haddr =  address;					// address of current address phase
				hwdata = data;						// data of previous address phase
				data = data +1;	
			end
		end
	end
endtask


//*********************************************
// AHB read cycle (master model)
//*********************************************

task ahb_read;
	begin
		@(posedge hclk) begin
			if (hready) begin
				#2
				htrans = 'b10;								// non sequential transfer
				hwrite = 'b0;
				haddr = address;
				address = address-1;
			end
		end
	end
endtask 

		

endmodule


