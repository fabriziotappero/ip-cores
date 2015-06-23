///////////////////////////////////////ms_core.v////////////////////////////////////////////////////////////////////////
//														      //			
//Design engineer:	Ravi Gupta										      //		
//Company Name	 :	Toomuch Semiconductor	
//Email		 :	ravi1.gupta@toomuchsemi.com								      //	
//														      //	
//Purpose	 :	This is the core which will be used to interface I2C bus.				      //	
//Created	 :	23-11-07										      //
														      //		
//Modification : Changes made in data_reg_ld									      //	
														      //	
//Modification : Change byte_trans generation bit								      //	
														      //		
//Modification : Implemented a halt bit that will be generated at the completion of 9th scl pulse in master_mode only //
														      //					
//Modification : After core reset(time out feature) core will go in idle escaping stop generation so need to clear    //
//all 														      //
//of status register.    											      //		
														      //
//Modification : Remove the sm_state clause,so that even if there is no acknowledegement it will not stop the         //
//generation of SCL and SDA 											      //				
//untill it gets command to generate stop from processor.							      //	
														      //		
//Modification : Now also checking for detect_start in acknowledgement state for repeted start condition. 	      //	
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

 

module core(clk,rst,sda_oe,sda_in,sda_o,scl_oe,scl_in,scl_o,ack,mode,rep_start,master_rw,data_in,slave_add,bus_busy,byte_trans,slave_addressed,arb_lost,slave_rw,time_out,inter,ack_rec,i2c_up,time_out_reg,prescale_reg,inter_rst,inter_en,halt_rst,data_en,time_rst,h_rst);

////////////////////////////////////////////////signal defination////////////////////////////////////////////////////////////////

input	clk;			//System Clock
input	rst;			//Main Reset
output	sda_oe;			//I2C serial data line output to be connected to control line of bidirectional buffer on physical SDA line
input	sda_in;			//I2C serial data line input
output	sda_o;			//I2C sda line always asssign to zero this is to be connected to input of bidirectional buffer on physical SDA line
output	scl_oe;			//I2C serial clock line output to be connected to control line of bidirectiional buffer on physical scl line
input	scl_in;			//I2C serial clock line input
output	scl_o;			//SCL output line to be connected to input of bidirectional line
input	ack;			//Acknowledgement signal from control register
input	mode;			//master/slave mode select
input	rep_start;		//repeated start
input	master_rw;		//command to core in master mode
input	[7:0]data_in;		//data from processor to be outputed on I2C
input	[7:0]slave_add;		//I2C slave address
input data_en;
output time_rst;
input h_rst;

//status signal:

output	bus_busy;		//bus busy
inout	byte_trans;		//transfer of byte is in progress_reg_en

inout	slave_addressed;	//addressed as slave
inout	arb_lost;		//arbitration has lost
inout	slave_rw;		//indicates the operation by slave
inout	time_out;		//indicates that SCL LOW time has been exceeded
output	inter;			//interrupt pending,will be used for interrupting processor
input	inter_rst;		//use to clear the interrupt
input	inter_en;		//processor wants to take interrupt or not

//signal for processor
input halt_rst;
output	ack_rec;		//indicates that ack has been recieved,will be used to inform if master reciever wants to terminate the transfer
output	[7:0]i2c_up;		//I2C data for micro processor
//timing control registers
input [7:0]time_out_reg;		//max SCL low period.
input [7:0]prescale_reg;		//clock divider for generating SCL frequency.

/////////////////////////////////////////End of port defination//////////////////////////////////////////////////////////////////

wire master_slave,arbitration_lost,bb,gen_start,rep_start,byte_trans_delay,byte_trans_fall;
								 
//wire scl_out,sda_out,clk_cnt_enable,clk_cnt_rst,bit_cnt_enable,bit_cnt_rst,timer_cnt_enable,timer_cnt_rst,scl_in,sda_in,sda_out_reg,stop_scl_reg,master_sda,	gen_stop;
wire master_sda,scl_in,gen_stop,sm_stop,detect_stop,detect_start,addr_match,core_rst,stop_scl,scl_out,neg_scl_sig,sda_sig;
//reg [7:0]clk1_cnt,bit1_cnt,timer1_cnt;
reg posedge_mode,negedge_mode;
reg [2:0]scl_state;
reg [1:0]state;
reg [2:0]scl_main_state; 
wire [7:0] add_reg,shift_reg;
wire [7:0]clk_cnt,bit_cnt;
reg  [7:0]time_cnt;
reg  [7:0]i2c_up; 
wire bit_cnt_enable,bit_cnt_rst,clk_cnt_enable,clk_cnt_rst,data_reg_ld,data_reg_en,sda_in,serial_out,i2c_serial_out,add_reg_ld,add_reg_en,posedge_mode_sig,negedge_mode_sig,interrupt;
wire [7:0]zero;
wire [7:0]reg_clr;

wire slave_sda,sda_out,halt,arb_rst,interrupt_rst,d_detect_stop;

shift shift_data(neg_scl,rst,data_reg_ld,data_reg_en,sda_in,data_in,serial_out,shift_reg);	//shift register for transferring the data
shift shift_add(neg_scl,rst,add_reg_ld,add_reg_en,sda_in,reg_clr,i2c_serial_out,add_reg);	//shift register for transferring address
counter clock_counter(clk,rst,clk_cnt_enable,clk_cnt_rst,zero,clk_cnt);				//This will count number of clock pulses for prescale
counter bit_counter(neg_scl,rst,bit_cnt_enable,bit_cnt_rst,zero,bit_cnt);			//Implementation of bit counter





	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
reg clk_cnt_enable_sig;
assign clk_cnt_enable = clk_cnt_enable_sig;

reg clk_cnt_rst_sig;
assign clk_cnt_rst = clk_cnt_rst_sig;


//reg sda_in_sig;
//assign sda_in = sda_in_sig;

reg sm_stop_sig;
assign sm_stop = sm_stop_sig;

//reg scl_in_sig;
//assign scl_in = scl_in_sig;

reg gen_start_sig;
assign gen_start = gen_start_sig;

reg gen_stop_sig;
assign gen_stop = gen_stop_sig;

reg master_slave_sig;
assign master_slave = master_slave_sig;

reg detect_start_sig;
assign detect_start=detect_start_sig;

reg detect_stop_sig;
assign detect_stop=detect_stop_sig;

reg byte_trans_sig;
assign byte_trans= byte_trans_sig;

reg bb_sig;
assign bb=bb_sig;

reg slave_addressed_sig;
assign slave_addressed=slave_addressed_sig; 

reg slave_rw_sig;
assign slave_rw=slave_rw_sig;

reg inter_sig;
assign inter=inter_sig;	
assign interrupt=inter_sig;

reg time_out_sig;
assign time_out=time_out_sig;

reg ack_rec_sig;
assign ack_rec=ack_rec_sig;

reg add_reg_enable_sig;
assign add_reg_en=add_reg_enable_sig;

reg data_reg_en_sig;
assign data_reg_en=data_reg_en_sig;

reg data_reg_ld_sig;
assign data_reg_ld=data_reg_ld_sig;

reg stop_scl_sig;
assign stop_scl=stop_scl_sig;

reg core_rst_sig;
assign core_rst=core_rst_sig;

reg sda_out_sig;
assign sda_out=sda_out_sig;

reg scl_out_sig;
assign scl_out=scl_out_sig;

reg master_sda_sig;
assign master_sda=master_sda_sig;

reg slave_sda_sig;
assign slave_sda=slave_sda_sig;

reg arbitration_lost_sig;
assign arbitration_lost=arbitration_lost_sig;

reg arb_lost_sig;
assign arb_lost=arb_lost_sig;

reg byte_trans_delay_sig;
assign byte_trans_delay=byte_trans_delay_sig;

reg byte_trans_fall_sig;
assign byte_trans_fall=byte_trans_fall_sig;

reg halt_sig;
assign halt = halt_sig;

reg arb_rst_sig;
assign arb_rst=arb_rst_sig;

reg interrupt_rst_sig;
assign interrupt_rst=interrupt_rst_sig;

reg rep_start_sig;
assign time_rst = core_rst;

reg d_detect_stop_sig;
assign d_detect_stop = d_detect_stop_sig;

reg d1_detect_stop_sig;


assign bus_busy = bb;
assign reg_clr=8'b00000000;
assign neg_scl_sig=(~scl_in);
assign neg_scl=neg_scl_sig;
assign zero=8'b00000000;
assign posedge_mode_sig=posedge_mode;
assign negedge_mode_sig=negedge_mode;
assign sda_o = 1'b0;	//assign this to 0 always
assign scl_o = 1'b0;



parameter	scl_idle=3'b000,scl_start=3'b001,scl_low_edge=3'b010,scl_low=3'b011,scl_high_edge=3'b100,scl_high=3'b101;
parameter	scl_address_shift=3'b001,scl_ack_address=3'b010,scl_rx_data=3'b011,scl_tx_data=3'b100,scl_send_ack=3'b101,scl_wait_ack=3'b110,scl_main_idle=			3'b000;

parameter	a=2'b00,b=2'b01,c=2'b10;

////////////////////SCL Generator///////////////////////////////
//This machine will generate SCL and SDA when in master mode.It will
//also generate START and STOP condition.

//always@(scl_state or arbitration_lost or sm_stop or gen_stop or rep_start
//		or bb or gen_start or master_slave or clk_cnt or bit_cnt or
//		scl_in  or sda_out or master_sda or core_rst)
always@(posedge clk or posedge rst or posedge core_rst or posedge h_rst)
begin

//State machine initial conditions

if(rst || h_rst)
begin
	scl_state<=scl_idle;
	scl_out_sig<=1'b1;
	sda_out_sig<=1'b1;
	stop_scl_sig<=1'b0;
	clk_cnt_enable_sig<=1'b0;
	clk_cnt_rst_sig<=1'b1;
	//bit_cnt_rst_sig<=1'b0;
	//bit_cnt_enable_sig<=1'b0;
end

else if(core_rst)
begin

	scl_state<=scl_idle;
	scl_main_state <= scl_main_idle;
	scl_out_sig<=1'b1;
	sda_out_sig<=1'b1;
	stop_scl_sig<=1'b0;
	clk_cnt_enable_sig<=1'b0;
	clk_cnt_rst_sig<=1'b1;
	slave_addressed_sig<=1'b0;
end


else
begin

		case (scl_state)
		
			scl_idle:
			begin
				arb_rst_sig <= 1'b1;
				interrupt_rst_sig<=1'b1;
				sda_out_sig<=1'b1;
				stop_scl_sig<=1'b0;
					
					if(master_slave && !bb && gen_start)
					begin 
						scl_state<=scl_start;
						
					end
			end
	

			scl_start:
			begin
				arb_rst_sig <= 1'b0;
				interrupt_rst_sig<=1'b0;
				clk_cnt_enable_sig<=1'b1;				//enable the counter as soon as machine enters in this state.
				clk_cnt_rst_sig<=1'b0;
				//sda_out_sig<=1'b0;					//generating start condition
				stop_scl_sig<=1'b0;
			if(clk_cnt == prescale_reg / 3)
				sda_out_sig<= 1'b0;
				
					if(clk_cnt == prescale_reg)		//wait for prescale value to over
						scl_state<=scl_low_edge;
					else
						scl_state<=scl_start;
			end

			scl_low_edge:
			begin
				clk_cnt_rst_sig<=1'b1;			//This state will generate only SCL negative edge,and reset all the counters
				//timer_cnt_enable_sig<=1'b1;			//except timer counter which will be enabled at this state.
				//timer_cnt_rst_sig<=1'b0;			//also reseting the timer counter in this state.
				scl_out_sig<=1'b0;
				scl_state<=scl_low;
				stop_scl_sig<=1'b0;
			end

			scl_low:
			begin
				clk_cnt_enable_sig<=1'b1;			//enable the clock counter
				clk_cnt_rst_sig<=1'b0;
				scl_out_sig<=1'b0;
					
							if(arbitration_lost)
								stop_scl_sig<=1'b0;
						else if(rep_start_sig)
							begin	
								sda_out_sig<=1'b1;
								stop_scl_sig<=1'b0;
							end

						
						 else if((gen_stop) && ((scl_main_state != scl_ack_address) && (scl_main_state != scl_send_ack)
									&& (scl_main_state != scl_wait_ack)))		//Ravi remove sm_stop from oring with gen_stop
							begin
								sda_out_sig<=1'b0;
								stop_scl_sig<=1'b1;
										
							end  
						
							/*else if(rep_start)
							begin	
								sda_out_sig<=1'b1;
								stop_scl_sig<=1'b0;
							end*/
							else if(clk_cnt == prescale_reg / 3)
							begin
										sda_out_sig<=master_sda;
										stop_scl_sig<=1'b0;
									
							end
							
							else
								stop_scl_sig<=1'b0;					

	
											//determine next state.	
			
					if(clk_cnt == prescale_reg)
					begin
						if(bit_cnt == 8'b0000_0111 && arbitration_lost )
							scl_state<=scl_idle;
						else if(interrupt && inter_en)									//uncomenting out for cheking the core in interrupt mode 
							scl_state<=scl_low;
						else if(halt)
							scl_state<=scl_low;	
						else
							scl_state<=scl_high_edge;
					end

					else
						scl_state<=scl_low;
			end
											
						

							
			scl_high_edge:
			begin
				clk_cnt_rst_sig<=1'b1;
				scl_out_sig<=1'b1;
				if(gen_stop)				//Ravi sm_stop from oring with gen_stop
					stop_scl_sig<=1'b1;
					
				else
					stop_scl_sig<=1'b0;
				if(!scl_in)
					scl_state<=scl_high_edge;
				else
					scl_state<=scl_high;
			end

		

			scl_high:
			begin
				clk_cnt_enable_sig<=1'b1;
				clk_cnt_rst_sig<=1'b0;
				scl_out_sig<=1'b1;
				if(clk_cnt == prescale_reg) 
				begin
					if(rep_start_sig)
						scl_state<=scl_start;
					else if(stop_scl)
						scl_state<=scl_idle;
														
					else
						scl_state<=scl_low_edge;
				end

				else
					scl_state<=scl_high;
			end

						
		endcase
end
end

	
//Sample the incoming SDA and SCL line with System clock

/*always@(posedge clk or posedge rst)
begin

	if(rst)
	begin
		//sda_in_sig <= 1'b1;
		scl_in_sig <=1'b1;
	end
	else
	begin
		if(!scl)
			scl_in_sig <= 1'b0;
		else
			scl_in_sig <= 1'b1;

		if(!sda)
			sda_in_sig <= 1'b0;
		else
			sda_in_sig <= 1'b1;
			
	//sda_out_sig <= sda;
	end
end*/

//Generartion of control signal from the command based on processor.
//This will control generation of start and stop signal.
//This will also set the master_slave bit based on MODE signal
//if bus is not busy i.e bb = 0

always@(posedge clk or posedge rst or posedge h_rst)
begin
	if(rst || h_rst)
	begin
		gen_start_sig <= 1'b0;
		gen_stop_sig <= 1'b0;
		master_slave_sig <= 1'b0;
		
	end

	else
	begin
		if(posedge_mode_sig)
			gen_start_sig <= 1'b1;
		else if(detect_start)
			gen_start_sig <= 1'b0;

		if(!arbitration_lost && negedge_mode_sig)
			gen_stop_sig <= 1'b1;
		else if(detect_stop)
			gen_stop_sig <= 1'b0;

		if(!bb)
			master_slave_sig <= mode;
		else
			master_slave_sig <= master_slave;
	end
end

//State machine for detection of rising and falling edge of input mode for the generation of START and STOP.
always@(posedge clk or posedge rst or posedge h_rst)
begin
	if(rst || h_rst)
	begin
		posedge_mode<=1'b0;
		negedge_mode<=1'b0;
		state<=a;
	end

	else
	begin
		case(state)
		
			a:
				if(mode==1'b0)
				begin
					state<=b;
					posedge_mode<=1'b0;
					negedge_mode<=1'b0;
				end
				
				else
				begin
					state<=c;
					posedge_mode<=1'b1;
					negedge_mode<=1'b0;
				end

			b:
				if(mode==1'b0)
				begin
					state<=b;
					posedge_mode<=1'b0;
					negedge_mode<=1'b0;
				end
				
				else
				begin
					state<=a;
					posedge_mode<=1'b1;
					negedge_mode<=1'b0;
				end

			c:
				if(mode==1'b0)
				begin
					state<=a;
					posedge_mode<=1'b0;
					negedge_mode<=1'b1;
				end
				
				else
				begin
					state<=c;
					posedge_mode<=1'b0;
					negedge_mode<=1'b0;
				end
	
		endcase
end
end

//This is the main state machine which will be used as both master as well as slave.
//This gets triggered at falling edge of SCL.
//If stop codition gets detected then it should work as asyn reset.

always@(posedge rst or negedge scl_in or posedge detect_stop or posedge core_rst or posedge h_rst)
begin

if(rst || core_rst || h_rst)
begin
	scl_main_state<=scl_main_idle;
	sm_stop_sig<=1'b0;
end

else
begin
	case(scl_main_state)
	scl_main_idle:
		
		if(detect_start)
			scl_main_state<=scl_address_shift;
		else if(detect_stop)
		begin
			scl_main_state<=scl_main_idle;
			sm_stop_sig<=1'b0;
		end

	scl_address_shift:					//machine will remain in this state,unless all the bits of address has been transferred. 
		
		if(bit_cnt == 8'b0000_0111)
			scl_main_state<=scl_ack_address;
		else if(detect_stop)
		begin
			scl_main_state<=scl_main_idle;
			sm_stop_sig<=1'b0;
		end

	scl_ack_address:
		
		//if(arbitration_lost)					//if arbitration lost then go to idle state releasing buses.remove this because its a 
			//scl_main_state<=scl_main_idle;		//software problem if even after arb_lost it is giving wr/rd then it has to go to respective state.
		if(detect_stop)
		begin						//Go to idle state if there is stop command
			scl_main_state<=scl_main_idle;
			sm_stop_sig<=1'b0;
		end

		else if(detect_start)
		begin
			scl_main_state<=scl_address_shift;
			sm_stop_sig<=1'b0;
		end
		//else if(!sda_in)
							//If ack has been received then,check for slave/master

			else if(master_slave)
			begin				//if master then set the direction for master to either transmit 
			   if(!master_rw)				//or receive the data.
			   	scl_main_state<=scl_rx_data;
			   else
				scl_main_state<=scl_tx_data;	//Ravi: if no detect_stop then check if master send to state depending upon 
			end									//tx/rx bit of control register.
			
			else
			begin						//If slave then check if received address has matched
			   //if(addr_match)
			   //begin  					//if address matches then set the direction of communication based 
			      if(add_reg[0])				//last bit of shift register of address cycle.
				   scl_main_state<=scl_tx_data;
			      else
				    scl_main_state<=scl_rx_data;
			 end
			   //else
				//scl_main_state<=scl_main_idle;
			//end
		

		//else
		//begin
		//	scl_main_state<=scl_main_idle;				//If no ack received go to idle state.	
		//if(master_slave)
		//	sm_stop_sig<=1'b1;
		//end

	scl_rx_data:
		if(bit_cnt == 8'b0000_0111)
			scl_main_state<=scl_send_ack;
		else if(detect_stop)
		begin
			scl_main_state<=scl_main_idle;
			sm_stop_sig<=1'b0;
		end
		else if(detect_start)
		begin
			scl_main_state<=scl_address_shift;
			sm_stop_sig<=1'b0;
		end


		
			
	scl_tx_data:
		if(bit_cnt == 8'b0000_0111)
			scl_main_state<=scl_wait_ack;
		else if(detect_stop)
		begin
			scl_main_state<=scl_main_idle;
			sm_stop_sig<=1'b0;
		end
		else if(detect_start)
		begin
			scl_main_state<=scl_address_shift;
			sm_stop_sig<=1'b0;
		end


	scl_send_ack:
		if(detect_stop)
		begin
			scl_main_state<=scl_main_idle;
			sm_stop_sig<=1'b0;
		end

		else
			scl_main_state<=scl_rx_data;

	scl_wait_ack:								//Ravi: Even in this state machine will goto Tx state,if no ack or arb_lost has occur  
		//if(arbitration_lost)					//This is software part to program the control register so that it will generate stop 
			//scl_main_state<=scl_main_idle;		//and will go in idle state.So removing all clauses except detect stop.
		if(detect_stop)
		begin
			scl_main_state<=scl_main_idle;
			sm_stop_sig<=1'b0;
		end

	
		else 
			scl_main_state<=scl_tx_data;
		//else
		//begin
			//if(master_slave)
				//sm_stop_sig<=1'b1;
		//scl_main_state<=scl_main_idle;
		//end
	endcase
end
end

//Start and stop detect process
//////////////////////////////

always@(sda_in or scl_main_state)
begin

	if(rst || h_rst)
		detect_start_sig<=1'b0;
	else if(!sda_in && scl_in)
		detect_start_sig<=1'b1;
	else if(scl_address_shift)
		detect_start_sig<=1'b0;
	else
		detect_start_sig<=1'b0;
end

always@(posedge sda_in or posedge detect_start)
begin

	if(rst || h_rst)
		detect_stop_sig<=1'b0;
	else if(detect_start)
		detect_stop_sig<=1'b0;
	else if(scl_in)
		detect_stop_sig<=1'b1;
	//else if(detect_start)
		//detect_stop_sig<=1'b0;
	else
		detect_stop_sig<=1'b0;
end

//generate a delay version of byte_trans signal
//This will be used for detecting falling edge of byte_trans

always@(posedge clk or posedge rst or posedge h_rst)
begin
	if(rst || h_rst)
		byte_trans_delay_sig <= 1'b0;
	else
	begin
		byte_trans_delay_sig <= byte_trans;
		byte_trans_fall_sig <= byte_trans_delay && !byte_trans;
	end
end
		

//Processor status bits/////
//byte_trans bit
//This indicate data is being transferred,This bit will be one only after all 8 bits has
//been tranferred.i.e on rising pulse of SCL in ack cycle.

always@(negedge scl_in or posedge rst or posedge halt_rst or posedge core_rst or posedge h_rst)
begin
	if(rst || h_rst)
		byte_trans_sig<=1'b0;
	else if(halt_rst)
		byte_trans_sig <= 1'b0;
	else if(bit_cnt == 8'b0000_1000)		
		byte_trans_sig<=1'b1;
	else if(halt_rst || core_rst)			// after core_rst negate byte_trans bit
		byte_trans_sig<=1'b0;
end

//bus_busy
//This indicates that communication is in progress and bus in not free.
//This bit will be set on detection of start and will be cleared on STOP

always@(posedge clk or posedge rst or posedge h_rst)
begin
	if(rst || h_rst)
		bb_sig<=1'b0;
	else
	begin
		if(detect_start)
			bb_sig<=1'b1;
		if(detect_stop || core_rst)
			bb_sig<=1'b0;
	end
end

//slave_addressed bit
//This indicates that slave has been addressed,and after sending ack
//core will switch to slave mode.
//This bit will be set if adds matched in add ack state.

always@(posedge clk or posedge rst or posedge h_rst)
begin
	if(rst)				//Removing h_rst
	slave_addressed_sig<=1'b0;
	//else if(scl_main_state == scl_ack_address)
	else if(byte_trans)
	slave_addressed_sig<=addr_match;
	else
	slave_addressed_sig<=slave_addressed;
	//slave_addressed_sig<= 1'b0;
end

//set address match bit if address reg matches with shift register output
/*always@(negedge scl or posedge rst)
begin
	if(rst)
		addr_match_sig<=1'b0;
	else if( slave_add[7:1] == add_reg[7:1])
		addr_match_sig <=1'b1;
	else
		addr_match_sig<=1'b0;
end*/
assign addr_match = slave_add[7:1] == add_reg[7:1]? 1'b1:1'b0;
assign add_reg_ld = 1'b0;

//Slave read write
//This bit indicates slave has been addressed,this indicates
//read or write bit sent by processor.

always@(posedge clk or posedge rst or posedge h_rst)
begin
	if(rst || h_rst)
		slave_rw_sig<=1'b0;
	else if(scl_main_state == scl_ack_address)
		slave_rw_sig<=add_reg[0];
end

//interrupt pending
//This will cause an interrupt to processor if interrupt enable is set
//This bit will be set in following circumstances:
//1):Byte transfer has been completed.
//2):Arbitration lost.
//3):slave has been addressed and and bytes have been transferred.
//4):Time out condition has been reached.
//5):Repeated start condition.
//Only processor can clear the interrupt.

always@(posedge clk or posedge rst or posedge h_rst)
begin
	if(rst || h_rst)
	inter_sig<=1'b0;
	
	else
	begin
		//if(interrupt_rst)
		//inter_sig<=1'b0;
		
		if(inter_rst)
		inter_sig<=1'b0;
		
	//in below else if condition anding byte_trans with master_slave also removing add_reg[]  condition in next clause		
		else if((byte_trans && master_slave) || arbitration_lost || (slave_addressed && !master_slave && byte_trans) || rep_start)
		inter_sig<=1'b1;
	
		
		
		//else			//interrupt need to get cleared by processor,so do not reset in else condition
		//inter_sig<=1'b0;

		
	end
end

//generate delay version of detect_stop
always@(posedge clk or posedge rst or posedge h_rst)
begin
if(rst || h_rst)
d_detect_stop_sig <= 1'b0;
else
begin
d1_detect_stop_sig <= detect_stop;
d_detect_stop_sig <= d1_detect_stop_sig;
end
end


always@(posedge clk or posedge rst or posedge h_rst)
begin
	if(rst || h_rst)
	halt_sig <= 1'b0;
	
	else
	begin
		if(halt_rst)
			halt_sig<=1'b0;
	
		else if(byte_trans && master_slave)
			halt_sig<=1'b1;
	end
end

//acknoweldege recieve
//This bit indicates the data on SDA line during ack cycle.

always@(posedge clk or posedge rst or posedge h_rst)
begin
	if(rst || h_rst)
		ack_rec_sig<=1'b0;
	else if((scl_main_state == scl_wait_ack) || (scl_main_state == scl_ack_address) || (scl_main_state == scl_send_ack))
		ack_rec_sig<=sda_in;
end

//Setting control bits of shift registers and counters
//////////////////////////////////////////////////////

//Address shift register will just receive the data after start 
//condition detection.It wont be get loaded.While data shift register
//will receive as well as transmit the data.

//address shift register enable bit
always@(posedge clk or posedge rst or posedge h_rst)
begin
	if(rst || h_rst)
		add_reg_enable_sig<=1'b0;
	else if(detect_start || scl_main_state == scl_address_shift)
		add_reg_enable_sig<=1'b1;
	else
		add_reg_enable_sig<=1'b0;
end


//Data shift register.
//This register will be enabled every time when it is either transmitting or receiving the data. 
  always @(posedge clk or posedge rst or posedge h_rst)
  begin
    if (rst || h_rst)
    begin
      data_reg_en_sig <= 1'b0;
      data_reg_ld_sig <= 1'b0;
    end
    else
    begin
      if (((master_slave && scl_main_state == scl_address_shift) || (scl_main_state ==
          scl_rx_data) || (scl_main_state == scl_tx_data)))
        data_reg_en_sig <= 1'b1;
      else
        data_reg_en_sig <= 1'b0;
	
	 /*if ((master_slave && scl_main_state == scl_idle) || (scl_main_state ==
          scl_wait_ack) || (scl_main_state == scl_ack_address &&
          !add_reg[0] && !master_slave) || (scl_main_state == scl_ack_address &&
          master_rw && master_slave))*/
		if(((scl_main_state == scl_main_idle) || byte_trans) && data_en)

		data_reg_ld_sig <= 1'b1;
	 else
        data_reg_ld_sig <= 1'b0;
 
    end
 		
  end

//logic for generating control bits for bit counter
////////////////////////////////////////////////////////////////////////////////////////////////
assign bit_cnt_enable = ((scl_main_state == scl_address_shift) || (scl_main_state == scl_rx_data) || (scl_main_state == scl_tx_data));
assign bit_cnt_rst = ((scl_main_state == scl_main_idle) || (scl_main_state == scl_send_ack) || (scl_main_state == scl_wait_ack) || (scl_main_state == scl_ack_address));
/////////////////////////////////////////////////////////////////////////////////////////////
//implementation of timer counter

always@(posedge clk or posedge rst or posedge h_rst)
begin
	if(rst || h_rst)
	time_cnt<=8'b0000_0000;
	else if(!scl_in) 
	time_cnt<=time_cnt + 1'b1;
	else
	time_cnt<=8'b0000_0000;
end

always@(posedge clk or posedge rst or posedge h_rst)
begin
	if(rst || h_rst)
	begin
		core_rst_sig<=1'b0;
		time_out_sig<=1'b0;
	end
	else if((time_cnt == time_out_reg) & bb)
	begin
		core_rst_sig <= 1'b1;
		time_out_sig <= 1'b1;
	end
	/*else if((time_cnt == time_out_reg) && (scl_state == scl_idle))
	begin
		core_rst_sig <= 1'b0;
		time_out_sig <= 1'b1;
	end*/
	else
	begin	
		core_rst_sig <= 1'b0;
		time_out_sig <= 1'b0;
	end	
end

//Process for assigning Master and slave SDA.
always@(posedge clk or posedge rst or posedge h_rst)
begin
	if(rst || h_rst)
		master_sda_sig<=1'b1;
	else if((scl_main_state == scl_address_shift) || (scl_main_state == scl_tx_data))
		master_sda_sig<=serial_out;
	else if(scl_main_state == scl_send_ack)
		master_sda_sig<=ack;
	else
		master_sda_sig<=1'b1;
end

always@(posedge clk or posedge rst or posedge h_rst)
begin
	if(rst || h_rst)
		slave_sda_sig<=1'b1;
	else if(scl_main_state == scl_tx_data)
		slave_sda_sig<=serial_out;
	else if((addr_match && (scl_main_state == scl_ack_address)) || (scl_main_state == scl_send_ack))
		slave_sda_sig<=ack;
	else
		slave_sda_sig<=1'b1;
end

//assigning SCL and SDA lines in output conditions.


assign scl_oe = master_slave ? scl_out : 1'b1;
assign sda_sig = (((master_slave == 1'b1 && sda_out == 1'b0) ||
		 (master_slave == 1'b0 && slave_sda == 1'b0) || stop_scl) ? 1'b1 : 1'b0);
assign sda_oe = (sda_sig ?1'b0 : 1'b1);

//Presenting data on data_register which is for processor
always@(posedge clk or posedge rst or posedge h_rst)
begin
	if(rst || h_rst)
		i2c_up<=8'b00000000;
 	else if(scl_main_state == scl_send_ack)
		i2c_up<=shift_reg;
	else
		i2c_up<=i2c_up;
end



//This process will set arbitration lost signal
//////////////////////////////////////////////
 //   This process checks the master's outgoing SDA with the incoming SDA to determine
  //   if control of the bus has been lost. SDA is checked only when SCL is high
  //   and during the states IDLE, ADD_SHIFT, and TX_DATA to insure that START and STOP
  //   conditions are not set when the bus is busy. Note that this is only done when Master.
   always @( posedge (clk) or posedge (rst) or posedge (h_rst) )
  begin
    if (rst || h_rst)
    begin
      arbitration_lost_sig <= 1'b0;
     end
    else
    begin
      if (scl_main_state == scl_idle)
      begin
        arbitration_lost_sig <= 1'b0;
      end
      else if ((master_slave))
        //   only need to check arbitration in master mode
        //   check for SCL high before comparing data 
        if ((scl_in && scl_oe && (scl_main_state == scl_address_shift || scl_main_state
            == scl_tx_data || scl_main_state == scl_idle)))
          //   when master, will check bus in all states except ACK_ADDR and WAIT_ACK
          //   this will insure that arb_lost is set if a start or stop condition
          //   is set at the wrong time
         	//if(sda_in == 1'b0 && sda_oe == 1'b1) || (detect_stop
		
	 if (sda_in == 1'b0 && sda_oe == 1'b1)
          begin
            arbitration_lost_sig <= 1'b1;
            
          end
          else
          begin
            arbitration_lost_sig <= 1'b0;
            
          end
 
        else
        begin
          arbitration_lost_sig <= arbitration_lost;
        end
 
 
    end
 
  end

//setting the arbitration lost bit of status register
////////////////////////////////////////////////////
//this bit will be set when:
	//arbiration has lost.
	//core is in master mode and a generate strat condition has detected while bus is busy 
	//or a stop conditioin has been detected when not requested
	//or a repeate start has been detected when in slave mode.

always@(posedge clk or posedge rst or posedge core_rst or posedge h_rst)
begin
	if(rst || h_rst)
		arb_lost_sig<=1'b0;
	else
	begin
		if(arb_rst)
		arb_lost_sig<=1'b0;
		else if(master_slave)
		begin
			if((arbitration_lost)||(bus_busy && gen_start))		
				arb_lost_sig<=1'b1;
		end
	
		else if(rep_start)
			arb_lost_sig<=1'b1;
		//else if(core_rst && master_slave)
			//arb_lost_sig<=1'b0;
		else
			arb_lost_sig<=1'b0;
	end
end

always@(posedge clk or posedge rst or posedge h_rst)
begin
if(rst || h_rst)
	rep_start_sig<=1'b0;
else if(scl_main_state == scl_address_shift || scl_main_state == scl_ack_address || scl_main_state == scl_send_ack || scl_main_state == scl_wait_ack)
	rep_start_sig<=1'b0;
else
	rep_start_sig<=rep_start;
end


	
endmodule
 





	


	


	
	





	
		

		
			


	

			
		
	



						
			
				
				




