//////////////////////////////////////////////////////////////////////////////////////////
//																						//
//	Verification Engineer:	Atish Jaiswal												//
//	Company Name		 :	TooMuch Semiconductor Solutions Pvt Ltd.					//
//																						//
//  Description of the Source File:														//
//	This source code implements I2C M/S Driver.											//
//	Driver will be receiving Scenario packets from Stimulus gen and accordingly it	 	//
//  will keep on monitoring/driving interface signals. 									//
//																						//		
//																						//
//////////////////////////////////////////////////////////////////////////////////////////


`include "vmm.sv"

class i2c_slave_driver extends vmm_xactor;

	vmm_log log = new("lOG", "SLAVE_DRIVER");

	virtual i2c_pin_if pif;						// Virtual Interface
	stimulus_packet_channel s_stim_req_chan;	// Scenario_gen to Driver Channel
	stimulus_packet s_stim_packet;				// Stimulus Packet's Instance	
	stimulus_packet s_temp_stim_packet;			// Stimulus Packet's Temprary Instance
	stimulus_packet s_response_packet;		
	scoreboard_pkt s_sb_pkt;					// Scoreboard Packet's Instance


// Class Constructor
	function new(string name, string instance, virtual i2c_pin_if pif, stimulus_packet_channel s_stim_req_chan = null);
		super.new("slave_driver","i2c_slave_driver");
		if(s_stim_req_chan == null) s_stim_req_chan = new("slave_stimulus_packet_channel", "s_stim_req_chan");
		this.s_stim_req_chan = s_stim_req_chan;	
        s_stim_packet = new;
        s_temp_stim_packet = new;
        s_response_packet = new;
		s_sb_pkt = new;
		this.pif = pif;
	endfunction


	reg [6:0] slave_address;    // Stores slave addess
	reg [7:0] mem_in ; 			// memory reg which receives data
	reg [7:0] mem_out;    		// memory data output
	reg [2:0] bit_cnt;   		// 3-bit down counter
	reg [2:0] state;			// State when this core is in slave mode 
	reg [7:0] sr;    	    	// 8bit shift register
	reg sta, d_sta;				// Local Start and delayed Start Signal
	reg sto, d_sto;				// Local Stop and delayed Stop Signal
	reg rw;     		   		// read/write direction
	reg ld;        				// load downcounter
	reg sda_o;    				// sda-drive level
	reg scl_o;    				// sca-drive level
	
	reg my_adr, my_adr_flag ;   // address match flags
	reg i2c_reset;				// i2c-state machine reset
	reg acc_done;				// Checks whethere 8-bits transmission done
	reg sda_dly;  			 	// delayed version of sda
    int byte_count;				// Byte count
	reg core_master_slave;		// Selects Master/Slave configuration of this driver
	reg tr;						// Selects Transmit/Receive Operation of this driver
	reg [7:0] data_out;    		// memory data output
	bit [7:0] slave_data_out[];	// memory data output
	bit load_data;				// Load new data into mem_out	
	int sent_data_count;		// Count no. of bytes already been sent
	int received_data_count;	// Count no. of bytes already been received
	int slave_bit_count;		// Control Slave bit count while sending address to DUT
	bit slave_start_sig;		// Local Start signal for generating Start
	bit slave_stop_sig;			// Local Stop Signal for generating Stop 
	bit slave_ack;				// Checks Acknowledgment from DUT
	reg [2:0] slave_state;		// Slave State when this core is in master mode
	int i =0;					
	reg temp;					// Temp signal to be assigned on sda_oe
	reg shift_data_out;			// Control Shifting of data 
	reg load_first_data_flag;

// Initialize the local variables of driver
	task i2c_slave_driver_initialize;
		sda_o = 1'b1;
		scl_o = 1'b1;
		pif.scl_oe = 1'b1;
		state = 3'b000;
		slave_state = 3'b000;
		slave_start_sig = 1'b1;
		sta = 1'b0;
		sto = 1'b0;
	endtask

// This task will invoke parallel threads which will be running continuously throughout the simulation. //
	task set_always;
		fork
			shift_reg;
			set_sda;
			set_scl;
			bit_count;
			detect_start;
			detect_stop;
			set_mem_out;
			delayed_start;
			acc_done_check;
			address_check;
			generate_scl;
			generate_start;
			set_data_out;
			set_load_first_data_flag;
		join	
	endtask

// This Task will be shifting sr register. On every scl clock it will get the data from sda line and 	//
// that data will be copied to lsb of sr register and data will be shifted left bit by bit. 			//		
	task shift_reg;
		forever @(posedge pif.scl)
		begin
			if (sta) sr = #1 {sr[6:0],pif.sda};
		end
	endtask

// This task will be counting no. of scl clock events. When ld (load Count) is one, it will initialize	//
// the counter, otherwise it will decrement the count by one on every posedge of scl					//	
	task bit_count;
		forever @(posedge pif.scl)
		begin
			if(ld)
				bit_cnt = #1 3'b111;
			else
				bit_cnt = #1 bit_cnt - 3'b001;
		end
	endtask

// This task will be comparing the slave address being received on sda line and the address assigned to	//
// this transactor. It sets the flag when addresses match.												//
	task address_check;
		forever @(posedge pif.clk)
		begin
			my_adr_flag = (sr[7:1] == slave_address);
			if (my_adr_flag && !(my_adr))
				my_adr = #1 1'b1;
		end
	endtask

// This task will set the flag load_first_data_flag								
	task set_load_first_data_flag;
		forever @(posedge pif.scl)
		begin
			load_first_data_flag = my_adr;
		end
	endtask

// This task will check whether 8 bits have been transmitted or received. In other words it checks the  //
// bit-Count. Sets the flag when 8 bits transaction is done.											//
	task acc_done_check;
		forever @(posedge pif.clk) 
		begin
			acc_done = !(|bit_cnt);
		end
	endtask

// This task will detect start signal on sda line. It sets flags when start signal is detected.			//
	task detect_start;
		forever @(negedge pif.sda)
			if(pif.scl)
			begin
				sta    = #1 1'b1;
				d_sta  = #1 1'b0;
				sto    = #1 1'b0;
				my_adr = 1'b0;
			end
			else sta  = #1 sta;
	endtask

// This task will detect stop signal on sda line. It sets flags when stop signal is detected.			//
	task detect_stop;
		forever @(posedge pif.sda);
			if(pif.scl)
			begin
				sta = #1 1'b0;
				sto = #1 1'b1;
			end		
			else sto = #1 1'b0;
	endtask

//	This task assign start signal to delayed version of start.											//	
	task delayed_start;
		forever @(posedge pif.scl)
			d_sta = #1 sta;
	endtask

// This task shifts bitwise data of mem_out. MSB of this register is transmitted when I2C M/S works as 	//
// a Trasnmitter.																						//
	task set_mem_out;
		forever @(posedge pif.scl)
		begin
			if(!acc_done && rw)
				mem_out = #1 {mem_out[6:0],1'b1};
		end
	endtask
	
// This task assign sda_o (local sda_o data) to interface sda_oe. 										//
	task set_sda;
		begin
			forever
			begin
			#5;
				temp = slave_start_sig & sda_o;
				if(slave_stop_sig)
				begin
					if(!pif.scl)
						pif.sda_oe = 1'b0;
					else
						#100 pif.sda_oe = 1'b1;
				end
				else
					pif.sda_oe = temp;
			end
		end
	endtask

// This task assigns value of local scl_o to interface port scl_o							//
	task set_scl;
		forever begin
		#10; pif.scl_oe = scl_o;
		end
	endtask


// This task will generate SCL clk when I2C Master/Slave Driver (this one) is working in Master mode.
	task generate_scl;
		int s_clk_gen_count = 0;
		forever @(posedge pif.clk)
		begin
			if(core_master_slave == 1'b0)
			begin
				if(s_clk_gen_count == 49)
				begin
					scl_o = ~scl_o;
					s_clk_gen_count = 0;
				end
				else
					s_clk_gen_count++;
			end
		end
	endtask

// This task will generate Start Signal on sda line when This Driver is working in Master Mode.
	task generate_start;
		if(core_master_slave == 1'b0)
		begin
		#100;
			forever 
			begin
				if(sta != 1'b1 && !(core_master_slave) && !(s_temp_stim_packet.reset_check) && !(s_temp_stim_packet.reset_check))
				begin 
					@(posedge pif.scl)
					begin
						if(sta != 1'b1 && !(core_master_slave))
						begin 
							#100 slave_start_sig = 1'b0;
						end
					end
					@(negedge pif.scl) slave_start_sig = 1'b1;
				end
				#100;
			end
		end
	endtask

// This task will set data out on posedge of scl		//
	task set_data_out;
		forever @(posedge pif.scl)
		begin
			if(!acc_done || shift_data_out)
			begin
				data_out = #1 {data_out[6:0],1'b1};
				#2; 
			end
		end
	endtask


// process task
	task process;
	forever
	begin
		s_stim_packet = new;
		s_stim_req_chan.peek(s_stim_packet);
		$cast(s_temp_stim_packet,s_stim_packet.copy());
		`vmm_note(log, "***********Packet Received inside I2C_SLAVE_DRIVER from GENERATOR************");
		s_temp_stim_packet.display();
		slave_address = s_temp_stim_packet.slave_address;
		byte_count = s_temp_stim_packet.byte_count;
		slave_data_out = new[byte_count]; 
		slave_data_out = s_temp_stim_packet.data_packet;
		core_master_slave = s_temp_stim_packet.master_slave;
		tr = s_temp_stim_packet.tr;
		#1;
//		$display("begining of task process mem_out is %b and byte_count is %d and slave_address is %b", mem_out, byte_count, slave_address);
		i = 0;
		
		if(my_adr_flag && !(load_first_data_flag))
		begin
			mem_out = slave_data_out[0];
		end

// If load_data is set, it will copy a new data byte from slave_data_out array to mem_out register.
// This mem_out register's data will be outputed on sda line.
		if(load_data)
		begin
			mem_out = slave_data_out[byte_count - sent_data_count];
			// `vmm_callback
			if(core_master_slave == 1)
			begin
				s_sb_pkt.master_slave = 1'b1;
				s_sb_pkt.tx_rx = 1'b0;
			end
			else
			begin 
				s_sb_pkt.master_slave = 1'b0;
				s_sb_pkt.tx_rx = 1'b1;
			end
			s_sb_pkt.slave_address = s_temp_stim_packet.slave_address;
			s_sb_pkt.data_byte =	mem_out;
//			$display("Callback for pre_transaction in slave driver at %t", $time); 
			`vmm_callback(i2c_callback,pre_transaction(s_sb_pkt));									 
			// vmm_callback
			load_data = 1'b0;
		end

// When reset_check test case is begin run on W/B driver side (DUT) this driver will not do any operation. 	
	if(s_temp_stim_packet.reset_check)
	begin
		`vmm_note(log, $psprintf("SLave_Driver: Checking reset operation of DUT at %t", $time));
		repeat (10) @(posedge pif.clk);
		i2c_slave_driver_initialize;
		s_stim_req_chan.get(s_stim_packet);
	end

// When register_check test case is begin run on W/B driver side (DUT) this driver will not do any operation. 	
	else if(s_temp_stim_packet.register_check)
	begin
		`vmm_note(log, $psprintf("SLave_Driver: Checking register test operation of DUT at %t", $time));
		repeat (10) @(posedge pif.clk);
		i2c_slave_driver_initialize;
		s_stim_req_chan.get(s_stim_packet);
	end

// Data-Transmisstion test-case is being run now. This Core (I2C M/S) is working as a Slave Device
	else if(core_master_slave)				//In slave mode
	begin	
	    @(negedge pif.scl or posedge sto)
		begin
			if(sto || (sta && !d_sta))
			begin
				sda_o = #1 1'b1;
				//scl_o = #1 1'b1;
				ld 	  = #1 1'b1;			
				state = #1 3'b000;
			end
			else
			begin
				sda_o = #1 1'b1;
				ld    = #1 1'b0;
			end

// Case 000 will be checking whether 8 bits of transaction is done, Address matches and rd/wr bit.	//
// It will assign next state to state 001, which is Address Acknowledgment State.					//		
			case (state)
				3'b000:
				begin
					if(acc_done && my_adr)
					begin
						rw 	  = #1 sr[0];
						sda_o = #5 1'b0;
					    #2;
						if(rw)
						begin
							sent_data_count = byte_count;
						//	if(sent_data_count != 0)
								//s_rsp_port.put(1);						
						 //   #1; 
						end	
						else if (!rw)
						begin
							received_data_count = byte_count;
						end
							state = #1 3'b001;
					end	
				end

// Case 001 is Acknowledgment state for address. It checks rd/wr bit received with slave address	//
// Then for I2C M/S Core(this dirver) as a Transmitter, next state will be assigned to 010 and send //
// slave address acknowledgment signal. For I2C M/S Core (This driver) as a Receiver, next state 	//
// will be assigned	to 011. Then it sets load_count bit.											//
				3'b001:
				begin
					if(rw)
					begin
	               		state = #1 3'b010; // read state
						// `vmm_callback
						s_sb_pkt.master_slave = 1'b1;
						s_sb_pkt.tx_rx = 1'b0;
						s_sb_pkt.slave_address = s_temp_stim_packet.slave_address;
						s_sb_pkt.data_byte =	mem_out;
//						$display("Callback for pre_transaction in slave driver at %t", $time); 
						`vmm_callback(i2c_callback,pre_transaction(s_sb_pkt));									 
						sda_o = #1 mem_out[7];
					end
	                else
						state = #1 3'b011; // write state
					ld = #2 1'b1;
				end

// When I2C M/S DUT is acting as a Master trasnmitter and access is done, it will send msb of	//
// mem_out to sda_o	which will get assigned to sda_oe line on interface. When Access is done,	//
// next State will be assigned to 100, which is Data Acknowledgment state. It also checks 		//
// whether byte_count is 0.	If it is not 0,  load_data will be set to 1 for next byte.			//
				3'b010:
				begin
					if(rw)
				#1 sda_o = mem_out[7];
					
					if(acc_done)
					begin
						sda_o = #1 rw;
						state = #1 3'b100; // Data Acknoledgment
						if(rw)
						begin
							sent_data_count --;
							if(sent_data_count != 0)
								load_data = 1'b1;
						end	
					end
				end

// When I2C M/S core (this core) is acting as a receiver and access is done, it will get data_byte 	//
// from shift register sr and send acknowledgement signal to interface through sda_o signal. Next	//
// State will be assigned to 100, which is Data Acknowledgment state.								//	
				3'b011:
				begin
					if(acc_done)
					begin 
						mem_in =  #1 sr;
						sda_o = #1 1'b0;
						// `vmm_callback
						s_sb_pkt.master_slave = 1'b1;
						s_sb_pkt.tx_rx = 1'b0;
						s_sb_pkt.slave_address = s_temp_stim_packet.slave_address;
						s_sb_pkt.data_byte =	mem_in;
//						$display("Callback for post_transaction in slave driver when DUT is in master at %t", $time); 
						`vmm_callback(i2c_callback,post_transaction(s_sb_pkt));									 
						// vmm_callback
						state = #1 3'b100; // Data Acknoledgment
					end
				//	#1;
				end				

// This is Data Acknowledgment State. When I2C M/S Core (this driver) is acting as a trasmitter and when after 	//
// sending data byte it doesn't get acknowledgment from Master DUT, next state will assigned to 000.			//
// If it gets the acknoeledgment, next state will be assigned to 010. Similerly when I2C M/S core (this core) 	//
// as a receiver, next state will be assigned to 011.												//				
				3'b100:   
				begin
					ld = #1 1'b1;
					if(rw)
					begin
						if(sr[0])  // read and master send NACK
						begin
							sda_o = #1 1'b1;
							state = 3'b000;
						end
						else
						begin
							sda_o = mem_out[7];		
							//if(byte_count == 0)
							if(sent_data_count == 0)
							begin
								state = 3'b000;
								ld = 1'b0;
								#5000 s_stim_req_chan.get(s_stim_packet);   
								i2c_slave_driver_initialize;  
							end
							else 
								state = 3'b010;
						end
					end
					else
					begin
						received_data_count--;
						if(received_data_count != 0)
						begin
							state = #1 3'b011;
							sda_o = #1 1'b1;					
						end
						else
						begin
							#5000 s_stim_req_chan.get(s_stim_packet);
							i2c_slave_driver_initialize;
						end	
					end			
				end
				default : $display("default case");	
			endcase
		end   // @(negedge pif.scl or posedge sto)
	end 	// (s_stim_packet.master_slave))

// Data Transmission test-case and this core (I2C M/S Core) is working as a Master Device.
	else if(core_master_slave == 1'b0) 	// This core works as in master mode (DUT core in slave mode)
	begin
		#100;
		rw = tr;
		shift_data_out = 1'b1;
		@(negedge pif.scl)
		begin
		if(sto || (sta && !d_sta))
		begin
			data_out = {slave_address,!tr};
			ld = 1'b1;
			slave_state =  #1 3'b000;
		end	
		else
		begin
			ld = 1'b0;
		end

		case(slave_state)

// State 000 will be generating SCL and then check Ack  bit and accordingly set next state.  //
// For I2C M/S Core(this driver) as a Transmitter it will be setting next state to 001 and   // 
// for I2C M/S Core(this dirver) to be a Receiver this will be setting next state to 010.	 //								
		3'b000:
		begin
			if(acc_done && slave_bit_count > 7)
			begin
				sent_data_count = byte_count;
				received_data_count = byte_count;
				ld = #2 1'b1;
				slave_state = 3'b001;
				sda_o = 1'b1;
				@(posedge pif.scl)
				begin
					slave_ack = pif.sda;
					if(!slave_ack && tr) // This slave will be sending data to DUT core
					begin
						mem_out = slave_data_out[0];
					end
					else if (!slave_ack && !tr) // This slave will be receiving data from DUT core
					begin
//						$display("slave ack is 0 and tr is 1 at %t", $time);
					end
				end
			end
			else
			begin
				if(sta)
				begin	
					sda_o = data_out[7];
					slave_bit_count++;
				end
			end
		end

// Case 001 is Acknowledgment state for address. It checks rd/wr bit received with slave address	//
// Then for I2C M/S Core(this dirver) as a Transmitter, next state will be assigned to 010 and send //
// slave address acknowledgment signal. For I2C M/S Core (This driver) as a Receiver, next state 	//
// will be assigned	to 011. Then it sets load_count bit.											//
		3'b001:
		begin
			if(rw)
			begin
       			slave_state = #1 3'b010; // I2C M/S Core (this dirver) transmit state
				// `vmm_callback
				s_sb_pkt.master_slave = 1'b0;
				s_sb_pkt.tx_rx = 1'b1;
				s_sb_pkt.slave_address = s_temp_stim_packet.slave_address;
				s_sb_pkt.data_byte =	mem_out;
//				$display("Callback for pre_transaction in slave driver when DUT is in slave mode at %t", $time); 
				`vmm_callback(i2c_callback,pre_transaction(s_sb_pkt));									 
				// vmm_callback
				sda_o = #1 mem_out[7];
			end
           	else
				slave_state = #1 3'b011; // I2C M/S Core (this dirver) receive state

				ld = #2 1'b1;
		end
						
// State 010 will be transmitting serial data from mem_out to sda_o.                 //
// If 8 bits are transmitted (acc_done set) it will decrese the sent_data_count.     //
// If sent_data_count is not 0, it will set load_data to load new data into mem_out. //
		3'b010:
		begin
		 	#1	sda_o = mem_out[7];
			if(acc_done)
			begin
				slave_state = 3'b100;
				sent_data_count--;
				if(sent_data_count != 0)
					load_data = 1'b1;
			end
		end
			
// State 011 will be receiving data from sda_in.          					       	//
// If 8 bits are received (acc_done set) it will copy sr into mem_in and			//
// decrese the received_data_count.												    //
		3'b011:
		begin
			if(acc_done)
			begin 
				mem_in =  #1 sr;
				sda_o = #1 1'b0;
				// `vmm_callback
				s_sb_pkt.master_slave = 1'b0;
				s_sb_pkt.tx_rx = 1'b0;
				s_sb_pkt.slave_address = s_temp_stim_packet.slave_address;
				s_sb_pkt.data_byte =	mem_in;
//				$display("Callback for post_transaction in driver  when DUT is in slave mode at %t", $time); 
				`vmm_callback(i2c_callback,post_transaction(s_sb_pkt));									 
				// vmm_callback
				slave_state = #1 3'b100; // Data Acknoledgment
			end
		//	#1; 
		end


// State 100 is for acknowledgment of data byte tx/rx									// 
// In transmit mode it will check ack from DUT and then if sent_data_count is not zero, //
// It will set the next state to 010. If sent_data_count is 0, it will set next state   //
// to 000 and set all local variable to their initial values.							//		
// Similerly, In Receive mode when received_data_count is not 0, it will set next state	//
// to 011. If its 0, next state will be set to 000 and set all local variable to their  //
// initial values.																		// 
		3'b100:
		begin
			if(rw)
			begin
				sda_o = mem_out[7];		
				if(sent_data_count == 0)
				begin
					slave_state = 3'b000;
					ld = 1'b0;
					if(sto != 1'b1)
						#10 slave_stop_sig = 1'b1;
					else
					begin 
						@(posedge pif.scl);
						begin 
							#1000 slave_stop_sig = 1'b0;
						end
					end
					#1000 slave_stop_sig = 1'b0;
					slave_bit_count = 0;
					sda_o =1'b1;
					scl_o = 1'b1;		
					sta = 1'b0;
					s_stim_req_chan.get(s_stim_packet);
				end
				else
				begin
					ld = #1 1'b1;
					slave_state = 3'b010;
				end
			end
			else
			begin
				received_data_count--;
				if(received_data_count != 0)
				begin
					slave_state = #1 3'b011;
					sda_o = #1 1'b1;
					ld = 1'b1;					
				end
				else
				begin
					slave_state = 3'b000;
					ld = 1'b0;
					if(sto != 1'b1)
						#10 slave_stop_sig = 1'b1;
					else
					begin 
						@(posedge pif.scl);
						begin 
							#1000 slave_stop_sig = 1'b0;
						end
					end
					#1000 slave_stop_sig = 1'b0;
					slave_bit_count = 0;
					sda_o = 1'b1;
					scl_o = 1'b1;		// to check scl generation when this core's mode got changed from m to s ...
					sta = 1'b0;
					s_stim_req_chan.get(s_stim_packet);
				end	
			end
		end
		endcase
		end
	end
	else
	begin
	    #10; 
//		$display("Slave Driver: no condition matches");
	end
	end
	endtask

virtual protected task main();
		super.main();
	begin
		fork
			i2c_slave_driver_initialize;
			set_always;
			process;
		join	
	end
	endtask
		

endclass	

