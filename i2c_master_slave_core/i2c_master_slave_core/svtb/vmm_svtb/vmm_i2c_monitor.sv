//////////////////////////////////////////////////////////////////////////////////////////
//																						//
//	Verification Engineer:	Atish Jaiswal												//
//	Company Name		 :	TooMuch Semiconductor Solutions Pvt Ltd.					//
//																						//
//  Description of the Source File:														//
//	This source code implements I2C Master-Slave Monitor.								//
//	Monitor does protocol validations. It checks generation of Start, Stop, interrupt 	//
//	request, slave and data acknowledgment for every trnasaction. It will create		//
//	monitor packet on every transaction and send that packet to Coverage Module.		//		
//																						//
//////////////////////////////////////////////////////////////////////////////////////////

`include "vmm.sv"

class i2c_monitor extends vmm_xactor;
  
	vmm_log log = new("lOG", "MONITOR");
	virtual i2c_pin_if pif;					// Virtual Interface
	stimulus_packet mon_stim_packet;		// Stimulus Packet
	stimulus_packet temp_mon_stim_packet;	// Stimulus Packet
	monitor_pkt mon_pkt;					// Monitor Packet

// Class Constructor 
	function new(string name, string instance, virtual i2c_pin_if pif);
		super.new("Monitor","I2C_MONITOR");
        mon_stim_packet = new;
        temp_mon_stim_packet = new;
		mon_pkt = new;
		this.pif = pif;
	endfunction

	reg sta, d_sta;							// Local Variable of start and delayed start
	reg sto, d_sto;							// Local variable of stop and delayed stop
	reg slave_ack;							// Local Variable for Slave Acknowledgment 
	reg data_ack;							// Local variable for Data Acknowledgment
	reg intr_ack;							// Local variable for Genaration of Interrupt
	reg first_stop_flag;					// Local variable for First Stop bit
	integer local_byte_count;				// Track byte_count
	integer ack_count;						// Track Acknowledgment pulse count
	integer intr_count;						// Track Interrupt Count
	reg [3:0] bit_count;					// 3-bit Counter
	reg load_counter;						// load_counter flag


// This task gets packet from driver. Though this call monitor will be aware of what kind of test-case is being run.
	task get_packet_from_driver(stimulus_packet mon_stim_packet);
		`vmm_note(log, $psprintf("Received Packet IN MONITOR at time %t", $time));
		$cast(temp_mon_stim_packet, mon_stim_packet.copy());
		temp_mon_stim_packet.display();
	endtask
	
// Initialize the local variables of Monitor
	task initialize;
		sta = 1'b0;
		d_sta = 1'b0;
		sto = 1'b0;
		d_sto = 1'b0;
		slave_ack = 1'b0;
		data_ack = 1'b0;
		intr_ack = 1'b0;
		bit_count = 4'h0;
		load_counter = 1'b0;
		ack_count = 0;
		intr_count = 0;
	endtask


// This task will be counting no. of scl clock events. When load_counter is one, it will initialize	//
// the counter, otherwise it will decrement the count by one on every posedge of scl				//	
	task bit_counter;
		forever @(posedge pif.scl)
		begin
			if(load_counter)
				bit_count = 4'h8;
			else
				bit_count = bit_count - 4'h1;
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
				load_counter = 1'b1;
			end
			else sta  = #1 sta;
	endtask
	
// This task will detect stop signal on sda line. It sets flags when stop signal is detected.			//
	task detect_stop;
		forever @(posedge pif.sda)
			if(pif.scl)
			begin
				sto = #1 1'b1;
			end		
			else sto = #1 1'b0;
	endtask
	
//	This task assign start signal to delayed version of start.											//	
	task delayed_start;
		forever @(posedge pif.scl)
			d_sta = #1 sta;
	endtask
	
//	This task assign stop signal to delayed version of start.											//	
	task delayed_stop;
		forever @(posedge pif.clk)
			d_sto = #1 sto;
	endtask

// This task will detect interrupt signal on sda line. If bit_count is 0, it will increment intr_count.	//
	task detect_intr;
		forever @(posedge pif.irq)
		begin
			if(bit_count == 0)
				intr_count++;
			else if(bit_count != 0 && temp_mon_stim_packet.intr_en && !(temp_mon_stim_packet.register_check) && !(temp_mon_stim_packet.reset_check))
				`vmm_error(log, "INTERRUPT SIGNAL NOT GENERATED ON RIGHT TIME");
		end		
	endtask

// Process Task
	task process;
	forever	 @(posedge pif.scl or posedge sto)
	begin
		if(sta && !(d_sta) && !(sto))			// First SCL posedge after Start pulse
		begin
			load_counter = 1'b0;
			`vmm_note(log, $psprintf("START DETECTED IN MONITOR AT %t", $time));
		end
		else if (sta && d_sta && !(sto))
		begin
			load_counter = 1'b0;
// It checks the value of sda line when bit_count is 0 for acknowledgment. First Acknowledgment pulse is Slave Acknowledgment
// and from then it will be Data acknowldgment.
			if(bit_count == 4'h0 && !pif.sda)	
			begin
				if(ack_count == 0)
					`vmm_note(log,$psprintf("SLAVE ADDRESS ACKNOWLEDGMENT DETECTED AT %t", $time));
				else 
					`vmm_note(log,$psprintf("DATA ACKNOWLEDGMENT DETECTED AT %t", $time));
				ack_count++;
				load_counter = 1'b1;
			end
		end
		else if (sto && !(d_sto))
		begin
			if(!first_stop_flag)
				first_stop_flag = 1'b1;
			else
			begin
// Checks whether the testcase being run is not of register_check or reset_check type.				
				if(!(temp_mon_stim_packet.register_check) && !(temp_mon_stim_packet.reset_check))
				begin
					`vmm_note(log, $psprintf("STOP DETECTED IN MONITOR AT %t", $time));
					if(!(sta || d_sta))
						`vmm_error(log, "START PULSE NOT DETECTED");
					if(temp_mon_stim_packet.byte_count != (ack_count-1))
						`vmm_error(log, "ACKNOWLEDGMENT NOT DETECTED");
					if(temp_mon_stim_packet.intr_en && temp_mon_stim_packet.byte_count != (intr_count-1))
						`vmm_error(log, "INTERRUPT BIT NOT CLEARED FOR ALL INTERRUPT MODE TRANSACTIONS");
					if (sta) 
					begin
// Create a monitor pkt and sent it to and coverage module through callback
						mon_pkt.start_bit = 1'b1;
						mon_pkt.stop_bit  = 1'b1;
						mon_pkt.slave_ack = 1'b1;
						mon_pkt.data_ack  = 1'b1;		
						mon_pkt.intr_ack  = 1'b1;		
						`vmm_callback(i2c_callback,protocol_checks_coverage(mon_pkt));
	 		 			@(posedge pif.clk) initialize;
					end	
				end
			end
		end
	end
	endtask

// Main Task
	virtual protected task main();
		super.main();
		begin
			first_stop_flag = 1'b0;
			fork
				initialize;
				bit_counter;
				delayed_start;
				delayed_stop;
				detect_start;
				detect_stop;
				detect_intr;
				process;
			join
		end
	endtask

endclass			



