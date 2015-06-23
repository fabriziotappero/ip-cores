////////////////////////////////////////////controller_interface.v////////////////////////////////////////
//													//
//Design Engineer:	Ravi Gupta 									//
//Company Name	 :	Toomuch Semiconductor
//Email		 :	ravi1.gupta@toomuchsemi.com							//
//													//	
//Purpose	 :	This core will be used as an interface between I2C core and Processor		//			
//Created	 :	6-12-2007									//
//													//	
//													//
//													//
//													//	
//													//			
//													//			
//													//
//													//
//Modification : Change the control register,added halt reset and inter_rst in control register
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/*// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

`include "oc8051_defines.v"*/


module processor_interface (clk,rst,add_bus,data_in,data_out,as,ds,rw,bus_busy,byte_trans,slave_addressed,arb_lost,slave_rw,inter,ack_rec,
		  core_en,inter_en,mode,master_rw,ack,rep_start,data,i2c_data,slave_add,time_out_reg,prescale,irq,time_out,inter_rst,halt,data_en,time_rst);
input clk;			//System clock
input rst;			//system reset

//signals connecting core to processor
/////////////////////////////////////

input [7:0]add_bus;		//contains address of internal register
input [7:0]data_in;		//trnasport the data for i2c core
input as;			//asserted high indicates vallid address has been placed on the address bus
input ds;			//asserted high indicates valid data on data bus
input rw;			//"1" indicates that processor has to write else read
output irq;			//interrupt to processor
output inter_rst;		//this bit will be written by processor when it will clear the interrupt.
output [7:0]data_out;
output halt;
output data_en;
input time_rst;

//signals from core to reflect te status of core and buses
///////////////////////////////////////////////////////////

input bus_busy;			//signal from core indicates bus is busy
input byte_trans;		//signal from core indicates byte transfer is in progress
input slave_addressed;		//signal from core indicares core has been identified as slave
input arb_lost;			//signal from core indicates bus error
input slave_rw;			//signal from core indicates operation of slave core
input inter;			//signal from core.this will interrupt the processor if this bit as well as interrupt enable is high
input ack_rec;			//signal from core to reflect the status of ack bit
input time_out;

//bits of control register
//////////////////////////

inout core_en;			//this bit must be cleared before any other bit of control register have any effect on core
inout inter_en;			//To intrrupt the core this bit must be set when interrupt is pending
inout mode;			//Transaction from "0" to "1" directes core to act as master else slave
inout master_rw;		//set directiion for master either to transmit or receive
inout ack;			//value of acknowledgment bit to be transmitted on SDA line during ack cycle
inout rep_start;		//set this bit if processor wants a repeated start

//data register
////////////////

inout [7:0]prescale;		//contains the value for generating SCL frequency
inout [7:0]time_out_reg;		//contains the value for maximum low period for scl
inout [7:0]slave_add;		//this is the programmble slave address
inout [7:0]data;		   //data for i2c core 
input [7:0]i2c_data;		//data from core for processor

//defining registers addresses
/////////////////////////////

`define		PRER 	8'b0000_0010
`define		CTR 	8'b0000_0100
`define		SR 		8'b0000_1000
`define		TO 		8'b0000_1010
`define		ADDR 	8'b0000_1100
`define		DR 		8'b0000_1110
`define		RR		8'b0000_0000

/*//defing the machine state
//////////////////////////

parameter	processor_idle=2'b00;
parameter	processor_address=2'b01;
parameter	processor_data=2'b10;
parameter	processor_ack=2'b11;*/

//Definig internal registers and wires
/////////////////////////////////////

wire core_en,inter_en,mode,master_rw,ack,rep_start,inter_rst,halt;
wire prescale_reg_en;
wire ctr_reg_en;
wire sr_reg_en;
wire to_reg_en;
wire addr_reg_en;
wire dr_reg_en;
reg [7:0]data_out,sr_reg,ctr_reg,dr_reg,rr_reg;
wire [7:0]data_in;								//if address on add_bus matches with register address then set this high.
wire data_ie;								//this is signal used for enaling the data line in read or write cycle.
wire as_d;								//delay version of address strobe signal for detection of rising and falling edge 
reg as_delay_sig;							//same signal.					
wire ds_d;								//delayed version of data strobe.
wire decode;
wire rr_reg_en;

reg ds_delay_sig;

reg prescale_reg_en_sig;
assign prescale_reg_en = prescale_reg_en_sig;

reg ctr_reg_en_sig;
assign ctr_reg_en = ctr_reg_en_sig;

reg sr_reg_en_sig;
assign sr_reg_en = sr_reg_en_sig;

reg to_reg_en_sig;
assign to_reg_en = to_reg_en_sig;

reg addr_reg_en_sig;
assign addr_reg_en = addr_reg_en_sig;

reg dr_reg_en_sig;
assign dr_reg_en = dr_reg_en_sig;

reg as_d_sig;
assign  as_d =  as_d_sig;

reg ds_d_sig;
assign ds_d = ds_d_sig;

reg data_ie_sig;
assign data_ie = data_ie_sig;

//reg core_en_sig;
//assign core_en = core_en_sig;

//reg inter_en_sig;
//assign inter_en = inter_en_sig;

//reg mode_sig;
//assign mode = mode_sig;

//reg master_rw_sig;
//assign master_rw = master_rw_sig;

//reg ack_sig;
//assign ack = ack_sig;

//reg rep_start_sig;
//assign rep_start = rep_start_sig;

reg [7:0]data_sig;
assign data = dr_reg;

reg [7:0]prescale_sig;
assign prescale = prescale_sig;

reg [7:0]time_out_sig;
assign time_out_reg = time_out_sig;

reg [7:0]slave_add_sig;
assign slave_add = slave_add_sig;

//reg [7:0]data_out_sig;
//assign data_out = data_out_sig;

reg decode_sig;
assign decode = decode_sig;

//reg inter_rst_sig;
//assign inter_rst = inter_rst_sig;

//reg halt_sig;
//assign halt = halt_sig;
assign data_en = dr_reg_en_sig;

reg rr_reg_en_sig;
assign rr_reg_en = rr_reg_en_sig;



assign			core_en	 	=	ctr_reg [7]; 
assign			inter_en	=	ctr_reg [6];
assign			mode 	 	=	ctr_reg [5];
assign			master_rw	=	ctr_reg [4];
assign			ack 	 	=	ctr_reg [3];
assign			rep_start	=	ctr_reg [2];
assign			inter_rst	=	ctr_reg [1];
assign			halt	 	=	ctr_reg [0];






//generating delayed version of inputs for detection of rising and falling edge.
//////////////////////////////////////////////////////////////////////////////

always@(posedge clk or posedge rst)
begin

if(rst)
begin
	as_delay_sig<=1'b0;
	as_d_sig<=1'b0;
	ds_delay_sig<=1'b0;
	ds_d_sig<=1'b0;
end

else
begin
	as_delay_sig<=as;
	as_d_sig<=as_delay_sig;
	ds_delay_sig<=ds;
	ds_d_sig<=ds_delay_sig;
end
end

always@(posedge clk or posedge rst)
begin
	if(rst)
		decode_sig<=1'b0;
	else if(!as_d && as)
		decode_sig<=1'b1;
	//else
		//decode_sig<=1'b0;
end

//address decoding logic
///////////////////////

//always@(posedge clk or posedge rst)
always@(rst or as or add_bus or posedge time_rst)
begin

if(rst || time_rst)
begin
prescale_reg_en_sig<=1'b0;
ctr_reg_en_sig<=1'b0;
sr_reg_en_sig<=1'b0;
to_reg_en_sig<=1'b0;
addr_reg_en_sig<=1'b0;
dr_reg_en_sig<=1'b0;
rr_reg_en_sig <= 1'b0;

//add_match_sig<=1'b0;
end


	
else if(as)
begin
		if(add_bus == `PRER)
		begin
			rr_reg_en_sig <= 1'b0;
			prescale_reg_en_sig<=1'b1;
			ctr_reg_en_sig<=1'b0;
			sr_reg_en_sig<=1'b0;
			to_reg_en_sig<=1'b0;
			addr_reg_en_sig<=1'b0;
			dr_reg_en_sig<=1'b0;
			//add_match_sig<=1'b1;
		end

		else if(add_bus == `CTR)
		begin
			rr_reg_en_sig <= 1'b0;
			prescale_reg_en_sig<=1'b0;
			ctr_reg_en_sig<=1'b1;
			sr_reg_en_sig<=1'b0;
			to_reg_en_sig<=1'b0;
			addr_reg_en_sig<=1'b0;
			dr_reg_en_sig<=1'b0;
			//add_match_sig<=1'b1;
		end

		else if(add_bus == `SR)
		begin
			rr_reg_en_sig <= 1'b0;
			prescale_reg_en_sig<=1'b0;
			ctr_reg_en_sig<=1'b0;
			sr_reg_en_sig<=1'b1;
			to_reg_en_sig<=1'b0;
			addr_reg_en_sig<=1'b0;
			dr_reg_en_sig<=1'b0;
			//add_match_sig<=1'b1;
		end

		else if(add_bus == `TO)
		begin
			rr_reg_en_sig <= 1'b0;
			prescale_reg_en_sig<=1'b0;
			ctr_reg_en_sig<=1'b0;
			sr_reg_en_sig<=1'b0;
			to_reg_en_sig<=1'b1;
			addr_reg_en_sig<=1'b0;
			dr_reg_en_sig<=1'b0;
			//add_match_sig<=1'b1;
		end

		else if(add_bus == `ADDR)
		begin
			rr_reg_en_sig <= 1'b0;
			prescale_reg_en_sig<=1'b0;
			ctr_reg_en_sig<=1'b0;
			sr_reg_en_sig<=1'b0;
			to_reg_en_sig<=1'b0;
			addr_reg_en_sig<=1'b1;
			dr_reg_en_sig<=1'b0;
			//add_match_sig<=1'b1;
		end

		else if(add_bus == `DR)
		begin
		
			prescale_reg_en_sig<=1'b0;
			ctr_reg_en_sig<=1'b0;
			sr_reg_en_sig<=1'b0;
			to_reg_en_sig<=1'b0;
			addr_reg_en_sig<=1'b0;
			dr_reg_en_sig<=1'b1;
			rr_reg_en_sig <= 1'b0;
			//add_match_sig<=1'b1;
		end
	
		else if(add_bus == `RR)
		begin
			rr_reg_en_sig <= 1'b1;
			prescale_reg_en_sig<=1'b0;
			ctr_reg_en_sig<=1'b0;
			sr_reg_en_sig<=1'b0;
			to_reg_en_sig<=1'b0;
			addr_reg_en_sig<=1'b0;
			dr_reg_en_sig<=1'b0;
			//add_match_sig<=1'b1;
		end
	
		else
		begin
			rr_reg_en_sig <= 1'b0;
			prescale_reg_en_sig<=1'b0;
			ctr_reg_en_sig<=1'b0;
			sr_reg_en_sig<=1'b0;
			to_reg_en_sig<=1'b0;
			addr_reg_en_sig<=1'b0;
			dr_reg_en_sig<=1'b0;
			//add_match_sig<=1'b0;
		end


end
else
begin
			prescale_reg_en_sig<=1'b0;
			ctr_reg_en_sig<=1'b0;
			sr_reg_en_sig<=1'b0;
			to_reg_en_sig<=1'b0;
			addr_reg_en_sig<=1'b0;
			dr_reg_en_sig<=1'b0;
			rr_reg_en_sig <= 1'b0;
	end

end

//assigning value of data_ie line
//////////////////////////////////
always@(posedge clk or posedge rst)
begin
	if(rst)
		data_ie_sig<=1'b0;
	else if(!ds_d && ds)
		data_ie_sig<=1'b1;
	
end


//read data to/from the register specified by processor addrress.


//always@(rst or addr_reg_en or ctr_reg_en or dr_reg_en or sr_reg_en or prescale_reg_en or to_reg_en or data_ie or rw or data_in )

always@(posedge clk or posedge rst)
begin
if(rst)
begin
	sr_reg <= 8'b0;
	dr_reg <= 8'b0;
	rr_reg <= 8'b0;	
//ctr_reg <= 8'b0;
end

/*else if(ctr_reg_en) 
begin
	//sr_reg <= {byte_trans,slave_addressed,bus_busy,arb_lost,time_out,slave_rw,inter,ack_rec};
	ctr_reg <= data_in;
end*/
else
begin
		sr_reg <= {byte_trans,slave_addressed,bus_busy,arb_lost,time_out,slave_rw,inter,ack_rec};
		rr_reg <= i2c_data;
end
end

always@(posedge clk or posedge rst or posedge time_rst)
begin
	if(rst || time_rst)
	begin
		//initializing control register
		ctr_reg <= 8'b0;
		/*core_en_sig <= 1'b0;
		inter_en_sig <= 1'b0;
		mode_sig <= 1'b0;
		master_rw_sig <= 1'b0;
		ack_sig <= 1'b0;
		rep_start_sig <= 1'b0;
		inter_rst_sig<=1'b0;*/
		//initializing data and timer register
		data_sig <= 8'b00000000;
		prescale_sig <= 8'b00000000;
		time_out_sig <= 8'b00000000;
		data_out     <= 8'b00000000;
	end
	
	else if (data_ie)
	begin
		//address register
		if(addr_reg_en)						//if address matches with slave address register
		begin
		  if(rw)						//processor write cycle
			slave_add_sig <= {data_in[7:1] , 1'b0};
		  else							//processor read cycle
			data_out <= slave_add;
		end
		
		//control register
		if(ctr_reg_en)						//if address matches with cntrol register
		begin
		  if(rw)						//processor write cycle
		  //begin
			/*core_en_sig	 	<=	#2	ctr_reg [7];
			inter_en_sig 	<=	#2	ctr_reg [6];
			mode_sig 		<=	#2	ctr_reg [5];
			master_rw_sig	<= 	#2	ctr_reg [4];
			ack_sig 	 	<=	#2	ctr_reg [3];
			rep_start_sig	<=	#2	ctr_reg [2];
			inter_rst_sig	<=	#2	ctr_reg [1];
			halt_sig		<=	#2	ctr_reg [0];*/
		  //end

		  //else
			ctr_reg <= data_in;							//processor read cycle
			else
	  		data_out <= ctr_reg;
		end  	
		
		else if(!byte_trans && bus_busy)
			ctr_reg[1:0] <= 2'b0;
		//data register
		
		if(dr_reg_en)
		begin
		  if(rw)
			dr_reg <= data_in;
		  else
			data_out <= dr_reg;
		end

		if(rr_reg_en)
		begin
			data_out <= rr_reg;
		end

		//staus register

		if(sr_reg_en)
		begin
		  	if(!rw)
		  	//begin
				//if(data_in[0]==1'b0)	
				//inter_rst_sig <= 1'b0;
				//else
				//inter_rst_sig <= 1'b1;
		  	//end	
			//else
			//begin
				data_out <= sr_reg;
				//inter_rst_sig<=1'b0;
			//end
			//else
				//inter_rst_sig<=1'b0;

		end
		
		
		//prescale register

		if(prescale_reg_en)
		begin
		  if(rw)
			prescale_sig <= data_in;
		  else
			data_out <= prescale;
		end	

		//time_out register

		if(to_reg_en)
		begin
		  if(rw)
			time_out_sig <= data_in;
		  else
			data_out <= time_out_reg;
		end
	end
end

//assigning values to bidirectional bus
//////////////////////////////////////

//assign data_bus = (!rw && data_ie) ? data_out : 8'bzzzzzzzz;
//assign data_in  = (rw)  ? data_bus : 8'bzzzzzzzz;

//interuupt pin to processor
assign irq = (inter && inter_en) ? 1'b1 : 1'b0;
endmodule
			


		

		


 
	
