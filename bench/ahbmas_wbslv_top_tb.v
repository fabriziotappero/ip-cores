//******************************************************************************************************
// Copyright (c) 2007 TooMuch Semiconductor Solutions Pvt Ltd.


//File name		:	ahbmas_wbslv_top_tb.v
//Designer		: 	Ravi S Gupta
//Date			: 	23 May, 2007
//Description	: 	Wishbone to AHB interface protocol converter Testbench
//Revision		:	1.0


//******************************************************************************************************

//DEFINES
`define DEL 1 //Clock to output delay, zero time delays can cause problems
//TOP MODULE
module AHBMAS_WBSLV_TOP_tb  ; 
//PARAMETERS
parameter DWIDTH  = 32 ;
parameter AWIDTH  = 32 ; 
parameter TON = 5 ;
parameter TOFF = 5 ;

integer  address = 0;
integer data = 0;  
//SIGNAL DECLARATIONS
  wire  [1:0]  htrans   ; 
  reg    stb_i   ; 
  reg  [DWIDTH-1:0]  data_i   ; 
  wire    hwrite   ; 
  reg  [3:0]  sel_i   ; 
  reg  [DWIDTH-1:0]  hrdata   ; 
  wire    ack_o   ; 
  reg    hready   ; 
  wire  [DWIDTH-1:0]  data_o   ; 
  wire  [2:0]  hburst   ; 
  wire  [31:0]  hwdata   ; 
  reg  [1:0]  hresp   ; 
  reg  [AWIDTH-1:0]  addr_i   ; 
  wire  [AWIDTH-1:0]  haddr   ; 
  wire  [2:0]  hsize   ; 
  reg    we_i   ; 
  reg    cyc_i   ;
  reg    clk_i	;
  reg 	 rst_i	;
  reg 	hclk;
  reg   hresetn;

//MAIN CODE
//Instantiate the DUT
  AHBMAS_WBSLV_TOP    #( DWIDTH , AWIDTH  )
   DUT  ( 
       .htrans (htrans ) ,
      .stb_i (stb_i ) ,
      .data_i (data_i ) ,
      .hwrite (hwrite ) ,
      .sel_i (sel_i ) ,
      .hrdata (hrdata ) ,
      .ack_o (ack_o ) ,
      .hready (hready ) ,
      .data_o (data_o ) ,
      .hburst (hburst ) ,
      .hwdata (hwdata ) ,
      .hresp (hresp ) ,
      .addr_i (addr_i ) ,
      .haddr (haddr ) ,
      .hsize (hsize ) ,
      .we_i (we_i ) ,
      .cyc_i (cyc_i ) ,
	  .clk_i (clk_i),
	  .rst_i (rst_i),
	  .hclk (hclk),
	  .hresetn(hresetn)); 

// Clock Generation
	always begin	
		#TOFF //clk generation with OFF timeperiod = 5
		clk_i = 'b0;
		#TON //clk generation with ON timeperiod = 5
		clk_i = 'b1;
	end
// local memory in AHB slave model
	reg [DWIDTH-1 : 0] ahb_mem [AWIDTH-1 : 0]; 
	reg [AWIDTH-1:0] haddr_temp;
	reg [DWIDTH-1 :0] hrdata_temp;
	reg hwrite_temp;
	
//	always@(posedge clk_i)
//		hrdata <= hrdata_temp;
//*************************************************
// AHB slave model
//*************************************************

	always @(posedge clk_i) begin
		if (hready) begin
			haddr_temp <= #2 haddr;
			hwrite_temp<=#2 hwrite;
			if (hwrite_temp) begin
				ahb_mem[haddr_temp] <= #2 hwdata;			// data stored in ahb slave
			end
			else if (!hwrite) begin
				hrdata <= #2 ahb_mem[haddr];
			end	
		end
	end
	
//*****************************************
//Write operations with no wait states
//*****************************************
task write_data;
		
		input [AWIDTH-1:0] addr;
		input [DWIDTH-1:0] Data;
			begin
			#2
			cyc_i=1'b1;
			stb_i=1'b1;
			we_i=1'b1;
			//if(ack_o) begin
			addr_i <= addr;
			data_i <= Data;//Send Data
			//end
			hready <= 'b1;
			end
endtask
//************************************************
//Write operations with wait states from AHB Slave
//************************************************
task write_data_WSAHB;
		begin
		@(posedge clk_i) begin
		#2 cyc_i = 1'b1;
		stb_i = 1'b1;
		we_i = 1'b1;
		hready = 1'b0;		//AHB Master is in Wait State
		end
	end

endtask

//***********************************************
//Write operations with wait states from WB Master
//***********************************************
task write_data_WSWB;
		begin
		@(posedge clk_i) begin
		#2 cyc_i = 1'b1;
		stb_i = 1'b0;//WB Master is in Wait State
		we_i = 1'b1;
		hready = 1'b1;
		end
	end

endtask

//*************************************
//Read operations without wait states
//*************************************
task read_data;
	input [31:0] addr;
	begin #2
		cyc_i=1'b1;
		stb_i=1'b1;
		we_i=1'b0;
		if (ack_o) begin
			addr_i = addr;
		end
	//	else begin
//			hrdata_temp = ahb_mem[haddr];
//		end
		hready = 1'b1;	
	end
endtask
//**********************************************
//Read operations with wait states from AHB Slave
//**********************************************
task read_data_WSAHB;
begin
		@(posedge clk_i) begin
		#2 cyc_i = 1'b1;
		stb_i = 1'b1;
		we_i = 1'b0;
		hready = 1'b0;		//AHB Master is in Wait State
		end
end
endtask

//**********************************************
//Read operations with wait states from WB Master
//**********************************************
task read_data_WSWB;
begin
		@(posedge clk_i) begin
		#2 cyc_i = 1'b1;
		stb_i = 1'b0;		//WB Master in in Wait state
		we_i = 1'b0;
		hready = 1'b1;		
		end
end
endtask



// Initialize Inputs
	initial
		begin
			clk_i=1'b0;
	
			rst_i = 'b0;
			#2
			rst_i = 'b1;
			#23
			rst_i = 'b0;			// reset for more than one clock cycle
			
			hready = 1'b1;
			hresp = 2'b00;
			# 20 cyc_i='b0;
			stb_i='b0;
			sel_i=4'b0000;


//*************************************
//Block Write cycle
//*************************************
		repeat(7) begin 
			address = address + 1;
			@(posedge clk_i) write_data(address, data);			// format : write_data(A[n+1], d[n])
			data = data +1;	
		end
//*************************************
//Write cycle with wait states from AHB Slave
//*************************************
	//	#10;
		repeat(2) 
		write_data_WSAHB;
//*************************************
//Block Write cycle
//*************************************
	//	#10;
		repeat(4) begin 
			address = address + 1;
			@(posedge clk_i) write_data(address, data);			// format : write_data(A[n+1], d[n])
			data = data +1;	
		end
//*************************************
//Write cycle with wait states from WB Master
//*************************************
	//	#10;
		repeat(2) 
		write_data_WSWB;

//*************************************
//Block Write cycle
//*************************************
	//	#10;
		repeat(4) begin 
			address = address + 1;
			@(posedge clk_i) write_data(address, data);			// format : write_data(A[n+1], d[n])
			data = data +1;	
		end
		
//*************************************
//Block Read cycle
//*************************************
	//	#10;
		repeat(6) begin
			@(posedge clk_i) read_data(address);			
			address = address -1;
		end

//*************************************
//Read cycle with Wait State from AHB Slave
//*************************************
	//	#10;
		repeat(2) 
		read_data_WSAHB;

//*************************************
//Block Read cycle
//*************************************
	//	#10;
		repeat(4) begin
			@(posedge clk_i) read_data(address);			
			address = address -1;
		end

//*************************************
//Read cycle with Wait State from WB Master
//*************************************
	//	#10;
		repeat(2) 
		read_data_WSWB;
//*************************************
//Block Read cycle
//*************************************
	//	#10;
		repeat(5) begin 
			address = address + 1;
			@(posedge clk_i) write_data(address, data);			// format : write_data(A[n+1], d[n])
			data = data +1;	
		end

//*************************************
//Block Write cycle
//*************************************
		repeat(4) begin 
			address = address + 1;
			@(posedge clk_i) write_data(address, data);			// format : write_data(A[n+1], d[n])
			data = data +1;	
		end

			#20 stb_i='b0;
			#5	 cyc_i='b0;

		#200 $stop;
	end			
			
endmodule	 
