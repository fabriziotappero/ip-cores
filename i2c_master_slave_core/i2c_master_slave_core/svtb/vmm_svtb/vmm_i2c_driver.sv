//////////////////////////////////////////////////////////////////////////////////////////
//																						//
//	Verification Engineer:	Atish Jaiswal												//
//	Company Name		 :	TooMuch Semiconductor Solutions Pvt Ltd.					//
//																						//
//  Description of the Source File:														//
//	This source code implements W/B M/S Driver.											//
//	Driver will be receiving Scenario packets from Stimulus gen and accordingly it	 	//
//  will drive W/B ports of interface to configure DUT in different modes.				//
//  In every mode of operation whenever DUT is configured in interupt mode, this driver //
//  waits for posedge of interrupt and then write commands/data to internal reigster of //
//  DUT. In normal mode where interrupt will not be generated, it keeps on checking 	//
//  Status register of DUT and act accordingly.		 									//
//																						//		
//																						//
//////////////////////////////////////////////////////////////////////////////////////////

`include "vmm.sv"

class i2c_master_driver extends vmm_xactor;
  
	vmm_log log = new("lOG", "MASTER_DRIVER");
	virtual i2c_pin_if pif;								// Virtual Interface
	stimulus_packet_channel m_stim_req_chan;			// Scenario Generator to Diver Channel 
	stimulus_packet stim_packet;						// Stimulus Packet's Instance
	stimulus_packet temp_stim_packet;					// Stimulus Packet's Instance
	stimulus_packet response_packet;			
	scoreboard_pkt sb_pkt;								// Scoreboard Packet's instance for callback
	register_pkt reg_pkt;								// Register Packet's instance for callback


// Class Constructor	
	function new(string name, string instance, virtual i2c_pin_if pif, stimulus_packet_channel m_stim_req_chan = null);
		super.new("driver","i2c_master_driver");
		if(m_stim_req_chan == null) m_stim_req_chan = new("master_stimulus_packet_channel", "m_stim_req_chan");
		this.m_stim_req_chan = m_stim_req_chan;	
        stim_packet = new;
        temp_stim_packet = new;
        response_packet = new;
		sb_pkt = new;
		reg_pkt = new;
		this.pif = pif;
	endfunction


	
/* task for initial setting */
    task set_enable_signals;
	   	pif.rst = 1'b1;
        pif.clk = 1'b0;
		pif.wb_stb_i = 1'b0;
		pif.ack_o = 1'b0;
		pif.wb_cyc_i = 1'b0;
 	#10 pif.rst = 1'b0;
	#20 write_inf(1,8'h04, 8'hD0);
	#40 write_inf(1,8'h04, 8'h00);
    endtask
/* task for initial setting */

// Task to Enable core
	task enable_core;
		#20 write_inf(1,8'h04, 8'h80);   
			reg_pkt.reg_address = 8'h04;
			reg_pkt.data_byte = 8'hD0;
			reg_pkt.wr_rd = 1'b1;
			reg_pkt.reset_bit = 1'b0;
			`vmm_callback(i2c_callback,write_reg(reg_pkt));
		#40 write_inf(1,8'h04, 8'h00);
			reg_pkt.reg_address = 8'h04;
			reg_pkt.data_byte = 8'h00;
			reg_pkt.wr_rd = 1'b1;
			reg_pkt.reset_bit = 1'b0;
			`vmm_callback(i2c_callback,write_reg(reg_pkt));
	endtask	
	
// Task to reset Core. This task is called from ENV.
	task set_reset;
	   	pif.rst = 1'b1;
        pif.clk = 1'b0;
		pif.wb_stb_i = 1'b0;
		pif.ack_o = 1'b0;
		pif.wb_cyc_i = 1'b0;
   		repeat(2) @(posedge pif.clk);
		pif.rst = 1'b0;
	endtask	
 
// Task to set TimeOut Register's Value
	task set_timeout_reg;
		#40 write_inf(1,8'h0A, 8'hff);
			reg_pkt.reg_address = 8'h0A;
			reg_pkt.data_byte = 8'hff;
			reg_pkt.wr_rd = 1'b1;
			reg_pkt.reset_bit = 1'b0;
			`vmm_callback(i2c_callback,write_reg(reg_pkt));
	endtask
		

/* Write Task to write data and address on interface */
	task write_inf;
		input delay;	
		input [7:0] reg_addr;
		input [7:0] reg_value;
		integer delay;
	begin
		repeat(delay) @(posedge pif.clk)
			#1;
			pif.addr_in = reg_addr;
			pif.data_in = reg_value;	
			pif.we = 1'b1;
           	pif.wb_stb_i = 1'b1;
			pif.wb_cyc_i = 1'b1;
			@(posedge pif.clk)
			while (~pif.ack_o)  @(posedge pif.clk)
			#1;
			pif.addr_in = {3{1'bx}};
			pif.data_in = {8{1'bx}};		
			pif.we = 1'bx;
           	pif.wb_stb_i = 1'bx;
			pif.wb_cyc_i = 1'b0;
	end
	endtask

// Task to Set Prescale Register's Value              
	task set_prescale_register;
		#40 write_inf(1,8'h02, 8'h64);
			reg_pkt.reg_address = 8'h02;
			reg_pkt.data_byte = 8'h64;
			reg_pkt.wr_rd = 1'b1;
			reg_pkt.reset_bit = 1'b0;
			`vmm_callback(i2c_callback,write_reg(reg_pkt));
	endtask  
	
/* Read Task to read data from the design core through interface */
	task read_inf;
		input delay;	
		input [7:0] reg_addr;
		output [7:0] reg_value;
		integer delay;
		repeat(delay) @(posedge pif.clk)
			#1;
			pif.addr_in = reg_addr;
			pif.we = 1'b0;
          	pif.wb_stb_i = 1'b1;
			pif.wb_cyc_i = 1'b1;
			pif.data_in = {8{1'bx}};

			@(posedge pif.clk)
			while (~pif.ack_o)  @(posedge pif.clk)
				#1;
				pif.wb_cyc_i = 1'b0;
				pif.we = 1'bx;
       			pif.wb_stb_i = 1'bx;
				pif.addr_in = {3{1'bx}};
				pif.data_in = {8{1'bx}};		
				reg_value = pif.data_out;
	endtask


//	task process;

	virtual protected task main();
		super.main();
	begin
		stimulus_packet stim_packet;
		int byte_count;
		reg intr_check;
		reg register_check;
		reg register_write;
		string s;
		reg [7:0] status_reg;
		reg [7:0] reg_data_register;
		forever
		begin
			m_stim_req_chan.peek(stim_packet);
			$cast(temp_stim_packet,stim_packet.copy());
			`vmm_note(log, "***********Packet Received inside I2C_DRIVER from GENERATOR************");
			temp_stim_packet.display();
			byte_count = temp_stim_packet.byte_count;
			register_write = temp_stim_packet.intr_en;
			`vmm_callback(i2c_callback,send_pkt_to_monitor(temp_stim_packet));   // Sending packet to monitor

// Reset test-case. Driver will driver high on pif.rst to Reset DUT	
// This will set reset_bit of reg_pkt and then invoke callback for scoreboad.		
			if(temp_stim_packet.reset_check)			// reset check
			begin
				repeat (10)
				begin
					@(posedge pif.clk)
						pif.rst = 1'b1;
				end
					@(posedge pif.clk)
						pif.rst = 1'b0;
				reg_pkt.reg_address = 8'h00;
				reg_pkt.data_byte = 8'h00;
				reg_pkt.wr_rd = 1'b1;
				reg_pkt.reset_bit = 1'b1;
				`vmm_callback(i2c_callback,write_reg(reg_pkt));
				m_stim_req_chan.get(stim_packet);		// get(remove) the packet from channel
			end											// reset check

// Register Test-case. If register_write is 1, it will write internal register, set fields of reg_pkt and invoke callback.
// If register_write is 0, it will read value of internal register, set fields of reg_pkt and invoke callback for
// comparision of register datas in Scoreboard.
			else if(temp_stim_packet.register_check)	//Internal register read and write check
			begin
				if(register_write)				// write				
				begin
					write_inf(1,temp_stim_packet.register_addr,temp_stim_packet.register_data);
					reg_pkt.reg_address = temp_stim_packet.register_addr;
					reg_pkt.data_byte = temp_stim_packet.register_data;
					reg_pkt.wr_rd = 1'b1;
					reg_pkt.reset_bit = 1'b0;
					`vmm_callback(i2c_callback,write_reg(reg_pkt));
				end
				else								//read
				begin
				 	read_inf(1,temp_stim_packet.register_addr,reg_data_register);
					reg_pkt.reg_address = temp_stim_packet.register_addr;
					reg_pkt.data_byte = reg_data_register;
					reg_pkt.wr_rd = 1'b0;
					`vmm_callback(i2c_callback,read_reg(reg_pkt));
					
				end
				m_stim_req_chan.get(stim_packet);	// get (remove) packet from channel
			end											//Internal register read and write check

// Data Transfer test-case starts
			else										//Data Transfer check
			begin
				m_stim_req_chan.get(stim_packet);	// get (remove) packet from channel
				enable_core;
				set_prescale_register;
				set_timeout_reg;

// DUT (W/B Driver) is in Master Mode. 
				if(temp_stim_packet.master_slave)       //Core in Master Mode	
				begin
// DUT (W/B Driver) in Master Mode and Transmitting data. 
					if(temp_stim_packet.tr == 1)  // Writing data packets to slave device
					begin

// DUT (W/B Driver) in Master/Transmiter and in Interrupt mode. 
// Driver will configure DUT in given mode and then write data to Tx reg of DUT on each posedge of irq after slave acknowledgment.
// After transmission of last byte it will configure DUT to generate Stop Signal
						if(temp_stim_packet.intr_en)      // Interrupt Mode
						begin
							write_inf(1,8'h0E, {{temp_stim_packet.slave_address},{1'b0}});	// Slave Address + rd/wr bit
								reg_pkt.reg_address = 8'h0E;
								reg_pkt.data_byte = {{temp_stim_packet.slave_address},{1'b0}};
								reg_pkt.wr_rd = 1'b1;
								reg_pkt.reset_bit = 1'b0;
								`vmm_callback(i2c_callback,write_reg(reg_pkt));
							write_inf(1,8'h04, 8'h70);	    //Enable the core,set mode into interrupt and tx and generate Start
								reg_pkt.reg_address = 8'h04;
								reg_pkt.data_byte = 8'h70;
								reg_pkt.wr_rd = 1'b1;
								reg_pkt.reset_bit = 1'b0;
								`vmm_callback(i2c_callback,write_reg(reg_pkt));
							while(byte_count != 0)
							begin
								@(posedge pif.irq)
								begin
									write_inf(1,8'h0E, temp_stim_packet.data_packet[byte_count-1]);
										reg_pkt.reg_address = 8'h0E;
										reg_pkt.data_byte = temp_stim_packet.data_packet[byte_count-1];
										reg_pkt.wr_rd = 1'b1;
										reg_pkt.reset_bit = 1'b0;
										`vmm_callback(i2c_callback,write_reg(reg_pkt));
									// vmm_callback
									sb_pkt.master_slave = 1'b1;
									sb_pkt.tx_rx = 1'b1;
									sb_pkt.slave_address = temp_stim_packet.slave_address;
									sb_pkt.data_byte =	temp_stim_packet.data_packet[byte_count-1];
									`vmm_callback(i2c_callback,pre_transaction(sb_pkt));									 
									// vmm_callback
									write_inf(1,8'h04, 8'h73);
										reg_pkt.reg_address = 8'h04;
										reg_pkt.data_byte = 8'h73;
										reg_pkt.wr_rd = 1'b1;
										reg_pkt.reset_bit = 1'b0;
										`vmm_callback(i2c_callback,write_reg(reg_pkt));
								end 
								byte_count-- ;
							end	
							read_inf(1,8'h08,status_reg);
							while (!status_reg[7] && !status_reg[0])
							begin
								read_inf(1,8'h08,status_reg);
							end
							if(byte_count == 0 && status_reg[7])
								write_inf(1,8'h04, 8'h01); 				// Generate Stop Command
									reg_pkt.reg_address = 8'h04;
									reg_pkt.data_byte = 8'h01;
									reg_pkt.wr_rd = 1'b1;
									reg_pkt.reset_bit = 1'b0;
									`vmm_callback(i2c_callback,write_reg(reg_pkt));
						    #1200; 	response_packet.tr = 1'b1; 
						end		// Interrupt Mode

// DUT (W/B Driver) in Master/Transmiter and in Non-Interrupt mode.
//Driver will configure DUT in given mode,then it will keep on checking status register and wait for bit 7 of Status Register (TIP) to be set, 
// After Slave Acknowledgment detection, it will write data to Transmit Register of DUT.
// After transmission of last byte it will configure DUT to generate Stop Signal
						else    // Non-Interrupt Mode
						begin
							write_inf(1,8'h0E, {{temp_stim_packet.slave_address},{1'b0}});
								reg_pkt.reg_address = 8'h0E;
								reg_pkt.data_byte = {{temp_stim_packet.slave_address},{1'b0}};
								reg_pkt.wr_rd = 1'b1;
								reg_pkt.reset_bit = 1'b0;
								`vmm_callback(i2c_callback,write_reg(reg_pkt));
							write_inf(1,8'h04, 8'h30);	    //Enable the core,set mode into non-interrupt and tx and generate Start
								reg_pkt.reg_address = 8'h04;
								reg_pkt.data_byte = 8'h30;
								reg_pkt.wr_rd = 1'b1;
								reg_pkt.reset_bit = 1'b0;
								`vmm_callback(i2c_callback,write_reg(reg_pkt));
							while(byte_count != 0)
							begin
								read_inf(1,8'h08,status_reg);
								while(!status_reg[7])
								begin
									read_inf(1,8'h08,status_reg);
								end	
								write_inf(1,8'h0E, temp_stim_packet.data_packet[byte_count-1]); 
									reg_pkt.reg_address = 8'h0E;
									reg_pkt.data_byte = temp_stim_packet.data_packet[byte_count-1];
									reg_pkt.wr_rd = 1'b1;
									reg_pkt.reset_bit = 1'b0;
									`vmm_callback(i2c_callback,write_reg(reg_pkt));
								read_inf(1,8'h08,status_reg);
								while (!status_reg[7] && !status_reg[0])
								begin
									read_inf(1,8'h08,status_reg);
								end
								// vmm_callback
								sb_pkt.master_slave = 1'b1;
								sb_pkt.tx_rx = 1'b1;
								sb_pkt.slave_address = temp_stim_packet.slave_address;
								sb_pkt.data_byte =	temp_stim_packet.data_packet[byte_count-1];
								`vmm_callback(i2c_callback,pre_transaction(sb_pkt));									 
								// vmm_callback
								write_inf(1,8'h04, 8'h31); 
									reg_pkt.reg_address = 8'h04;
									reg_pkt.data_byte = 8'h31;
									reg_pkt.wr_rd = 1'b1;
									reg_pkt.reset_bit = 1'b0;
									`vmm_callback(i2c_callback,write_reg(reg_pkt));
								byte_count-- ;
								read_inf(1,8'h08,status_reg);
								while (!status_reg[7] && !status_reg[0])
								begin
									read_inf(1,8'h08,status_reg);
								end
								if(byte_count == 0 && status_reg[7])
									write_inf(1,8'h04, 8'h01);				// Generate Stop Signal 
									reg_pkt.reg_address = 8'h04;
									reg_pkt.data_byte = 8'h01;
									reg_pkt.wr_rd = 1'b1;
									reg_pkt.reset_bit = 1'b0;
									`vmm_callback(i2c_callback,write_reg(reg_pkt));
							end
						   	#1200; response_packet.tr = 1'b1;
						end		// Non-Interrupt Mode
					end

// DUT (W/B Driver) in Master/Receiver and in Interrupt mode. 
// Driver will configure DUT in given mode and then After Slave Acknowledgment detection, it will read data from Receive Register on
// on every posedge of irq. After Reception of last byte it will configure DUT to generate Stop Signal
					else  // Reading Data Packets from Slave Address
					begin
						if(stim_packet.intr_en)      // Interrupt Mode
						begin
							write_inf(1,8'h0E, {{temp_stim_packet.slave_address},{1'b1}});
									reg_pkt.reg_address = 8'h0E;
									reg_pkt.data_byte = {{temp_stim_packet.slave_address},{1'b1}};
									reg_pkt.wr_rd = 1'b1;
									reg_pkt.reset_bit = 1'b0;
									`vmm_callback(i2c_callback,write_reg(reg_pkt));
							write_inf(1,8'h04, 8'h63);	    //Enable the core,set mode into interrupt and tx and generate Start
									reg_pkt.reg_address = 8'h04;
									reg_pkt.data_byte = 8'h63;
									reg_pkt.wr_rd = 1'b1;
									reg_pkt.reset_bit = 1'b0;
									`vmm_callback(i2c_callback,write_reg(reg_pkt));
							@(posedge pif.irq)
							while(byte_count != 0)
							begin
								write_inf(1,8'h04, 8'h63);
									reg_pkt.reg_address = 8'h04;
									reg_pkt.data_byte = 8'h63;
									reg_pkt.wr_rd = 1'b1;
									reg_pkt.reset_bit = 1'b0;
									`vmm_callback(i2c_callback,write_reg(reg_pkt));
								@(posedge pif.irq)
								begin
									read_inf(1,8'h00,status_reg);
//									$display("In Driver - Received Data in interrupt mode is %b",status_reg);
									// vmm_callback
									sb_pkt.master_slave = 1'b1;
									sb_pkt.tx_rx = 1'b1;
									sb_pkt.slave_address = temp_stim_packet.slave_address;
									sb_pkt.data_byte =	status_reg;
									`vmm_callback(i2c_callback,post_transaction(sb_pkt));									 
									// vmm_callback
								end
								byte_count--;
							end
							read_inf(1,8'h08,status_reg);
							while (!status_reg[7])
								read_inf(1,8'h08,status_reg);
							if(byte_count == 0)
								write_inf(1,8'h04, 8'h43);					//Generate Stop Signal 
									reg_pkt.reg_address = 8'h04;
									reg_pkt.data_byte = 8'h43;
									reg_pkt.wr_rd = 1'b1;
									reg_pkt.reset_bit = 1'b0;
									`vmm_callback(i2c_callback,write_reg(reg_pkt));
						    #1200;  response_packet.tr = 1'b1;
						end

// DUT (W/B Driver) in Master/Receiver and in Non-Interrupt mode. 
// Driver will configure DUT in given mode,then it will keep on checking status register and wait for bit 7 of Status Register (TIP) to be set,
// After Slave Acknowledgment detection, it will read data from Receive Register everytime TIP bit is set.
// After Reception of last byte it will configure DUT to generate Stop Signal
						else               // non-interrupt mode
						begin	
							write_inf(1,8'h0E, {{temp_stim_packet.slave_address},{1'b1}});
								reg_pkt.reg_address = 8'h0E;
								reg_pkt.data_byte = {{temp_stim_packet.slave_address},{1'b1}};
								reg_pkt.wr_rd = 1'b1;
								reg_pkt.reset_bit = 1'b0;
								`vmm_callback(i2c_callback,write_reg(reg_pkt));
							write_inf(1,8'h04, 8'h20);	    //Enable the core,set mode into interrupt and tx and generate Start
								reg_pkt.reg_address = 8'h04;
								reg_pkt.data_byte = 8'h20;
								reg_pkt.wr_rd = 1'b1;
								reg_pkt.reset_bit = 1'b0;
								`vmm_callback(i2c_callback,write_reg(reg_pkt));
							read_inf(1,8'h08,status_reg);
							while(!status_reg[7])
								read_inf(1,8'h08,status_reg);
						
							while(byte_count != 0)
							begin
								write_inf(1,8'h04, 8'h21);	
								reg_pkt.reg_address = 8'h04;
								reg_pkt.data_byte = 8'h21;
								reg_pkt.wr_rd = 1'b1;
								reg_pkt.reset_bit = 1'b0;
								`vmm_callback(i2c_callback,write_reg(reg_pkt));
								read_inf(1,8'h08,status_reg);
								while(!status_reg[7])
									read_inf(1,8'h08,status_reg);
								read_inf(1,8'h08,status_reg);
								while (!status_reg[7] && !status_reg[0])
								begin
									read_inf(1,8'h08,status_reg);
								end
								read_inf(1,8'h00,status_reg);
//								$display("In Driver - Received Data in non-interrupt mode is %b",status_reg);
								// vmm_callback
								sb_pkt.master_slave = 1'b1;
								sb_pkt.tx_rx = 1'b1;
								sb_pkt.slave_address = temp_stim_packet.slave_address;
								sb_pkt.data_byte =	status_reg;
								`vmm_callback(i2c_callback,post_transaction(sb_pkt));									 
								// vmm_callback
								byte_count--;
								read_inf(1,8'h08,status_reg);
								while (!status_reg[7])
									read_inf(1,8'h08,status_reg);
								if(byte_count == 0 && status_reg[7] )
									write_inf(1,8'h04, 8'h01);				// Generate Stop signal 
										reg_pkt.reg_address = 8'h04;
										reg_pkt.data_byte = 8'h01;
										reg_pkt.wr_rd = 1'b1;
										reg_pkt.reset_bit = 1'b0;
										`vmm_callback(i2c_callback,write_reg(reg_pkt));
							end	
						    #1200;	response_packet.tr = 1'b1;
						end	
					end

				end

// DUT (W/B Driver) in Slave mode.
				else 			// core in slave mode
				begin
// DUT (W/B Driver) in Slave Mode and Transmitting data.
					if(temp_stim_packet.tr == 1) // Core in Slave mode: Receiving
					begin

// DUT (W/B Driver) in Slave/Receiver and in Interrupt mode. 
// Driver will configure DUT in given mode, on posedge on irq it will again configure core to receive data and
// then it will read data from Receive Register on every posedge of irq.
						if (temp_stim_packet.intr_en) // Interrupt Mode
						begin
							write_inf(1,8'h0C, {{temp_stim_packet.slave_address},{1'b1}});	// Slave Address + 1'b1 bit
								reg_pkt.reg_address = 8'h0C;
								reg_pkt.data_byte = {{temp_stim_packet.slave_address},{1'b1}};
								reg_pkt.wr_rd = 1'b1;
								reg_pkt.reset_bit = 1'b0;
								`vmm_callback(i2c_callback,write_reg(reg_pkt));
							write_inf(1,8'h04, 8'h40);	    //Enable the core,keep it in slave mode
								reg_pkt.reg_address = 8'h04;
								reg_pkt.data_byte = 8'h40;
								reg_pkt.wr_rd = 1'b1;
								reg_pkt.reset_bit = 1'b0;
								`vmm_callback(i2c_callback,write_reg(reg_pkt));
							@(posedge pif.irq)
							while(byte_count != 0)
							begin
								write_inf(1,8'h04, 8'h43);
									reg_pkt.reg_address = 8'h04;
									reg_pkt.data_byte = 8'h43;
									reg_pkt.wr_rd = 1'b1;
									reg_pkt.reset_bit = 1'b0;
									`vmm_callback(i2c_callback,write_reg(reg_pkt));
								@(posedge pif.irq)
								begin
									read_inf(1,8'h00,status_reg);
//									$display("In Driver - When core is in slave mode: Received Data in interrupt mode is %b",status_reg);
									// vmm_callback
									sb_pkt.master_slave = 1'b0;
									sb_pkt.tx_rx = 1'b1;
									sb_pkt.slave_address = temp_stim_packet.slave_address;
									sb_pkt.data_byte =	status_reg;
									`vmm_callback(i2c_callback,post_transaction(sb_pkt));									 
									// vmm_callback
								end
								byte_count--;
							end
						end

// DUT (W/B Driver) in Slave/Receiver and in Non-Interrupt mode. 
// Driver will configure DUT in given mode, it will keep on waiting for tip bit (bit 7) of Status Register to be set.
// After first occurance of tip to be set it will again configure DUT core to receive data and then it will read data 
// from Receive Register every time tip bit of Status Register is set.
						else             // Non-interrupt mode
						begin
							write_inf(1,8'h0C, {{temp_stim_packet.slave_address},{1'b1}});	// Slave Address + 1'b1 bit
								reg_pkt.reg_address = 8'h0C;
								reg_pkt.data_byte = {{temp_stim_packet.slave_address},{1'b1}};
								reg_pkt.wr_rd = 1'b1;
								reg_pkt.reset_bit = 1'b0;
								`vmm_callback(i2c_callback,write_reg(reg_pkt));
							write_inf(1,8'h04, 8'h00);	    //Enable the core,keep it in slave mode , non-interrupt mode
								reg_pkt.reg_address = 8'h04;
								reg_pkt.data_byte = 8'h00;
								reg_pkt.wr_rd = 1'b1;
								reg_pkt.reset_bit = 1'b0;
								`vmm_callback(i2c_callback,write_reg(reg_pkt));
							read_inf(1,8'h08,status_reg);
							while(!status_reg[7])
								read_inf(1,8'h08,status_reg);
							while(byte_count != 0)
							begin
								write_inf(1,8'h04, 8'h01);	
									reg_pkt.reg_address = 8'h04;
									reg_pkt.data_byte = 8'h01;
									reg_pkt.wr_rd = 1'b1;
									reg_pkt.reset_bit = 1'b0;
									`vmm_callback(i2c_callback,write_reg(reg_pkt));
								read_inf(1,8'h08,status_reg);
								while(!status_reg[7])
									read_inf(1,8'h08,status_reg);
								read_inf(1,8'h08,status_reg);
								while (!status_reg[7] && !status_reg[0])
								begin
									read_inf(1,8'h08,status_reg);
								end
								read_inf(1,8'h00,status_reg);
//								$display("In Driver - When core is in slave mode: Received Data in non-interrupt mode is %b",status_reg);
								// vmm_callback
								sb_pkt.master_slave = 1'b0;
								sb_pkt.tx_rx = 1'b1;
								sb_pkt.slave_address = temp_stim_packet.slave_address;
								sb_pkt.data_byte =	status_reg;
								`vmm_callback(i2c_callback,post_transaction(sb_pkt));									 
								// vmm_callback
								byte_count--;
								read_inf(1,8'h08,status_reg);
								while (!status_reg[7])
									read_inf(1,8'h08,status_reg);
								if(byte_count == 0 && status_reg[7] )
									write_inf(1,8'h04, 8'h01); 
										reg_pkt.reg_address = 8'h04;
										reg_pkt.data_byte = 8'h01;
										reg_pkt.wr_rd = 1'b1;
										reg_pkt.reset_bit = 1'b0;
										`vmm_callback(i2c_callback,write_reg(reg_pkt));
							end
						end
					end
 
// DUT (W/B Driver) in Slave/Transmiter Mode. 
					else				// Core in Slave Mode: Transmitting
					begin

// DUT (W/B Driver) in Slave/Transmiter and in Interrupt mode.
// Driver will configure DUT in given mode and then it will write data to Transmit Register of DUT on every posedge of irq.
						if (temp_stim_packet.intr_en) // Interrupt Mode
						begin
							write_inf(1,8'h0C, {{temp_stim_packet.slave_address},{1'b1}});	// Slave Address + 1'b1 bit
								reg_pkt.reg_address = 8'h0C;
								reg_pkt.data_byte = {{temp_stim_packet.slave_address},{1'b1}};
								reg_pkt.wr_rd = 1'b1;
								reg_pkt.reset_bit = 1'b0;
								`vmm_callback(i2c_callback,write_reg(reg_pkt));
							write_inf(1,8'h04, 8'h40);	    //Enable the core,keep it in slave mode , non-interrupt mode
								reg_pkt.reg_address = 8'h04;
								reg_pkt.data_byte = 8'h40;
								reg_pkt.wr_rd = 1'b1;
								reg_pkt.reset_bit = 1'b0;
								`vmm_callback(i2c_callback,write_reg(reg_pkt));
							while(byte_count != 0)
							begin
								@(posedge pif.irq)
								begin
									write_inf(1,8'h0E, temp_stim_packet.data_packet[byte_count-1]); 
										reg_pkt.reg_address = 8'h0E;
										reg_pkt.data_byte = temp_stim_packet.data_packet[byte_count-1];
										reg_pkt.wr_rd = 1'b1;
										reg_pkt.reset_bit = 1'b0;
										`vmm_callback(i2c_callback,write_reg(reg_pkt));
									write_inf(1,8'h04, 8'h43);
										reg_pkt.reg_address = 8'h04;
										reg_pkt.data_byte = 8'h43;
										reg_pkt.wr_rd = 1'b1;
										reg_pkt.reset_bit = 1'b0;
										`vmm_callback(i2c_callback,write_reg(reg_pkt));
									// vmm_callback
									sb_pkt.master_slave = 1'b0;
									sb_pkt.tx_rx = 1'b0;
									sb_pkt.slave_address = temp_stim_packet.slave_address;
									sb_pkt.data_byte =	temp_stim_packet.data_packet[byte_count-1];
									`vmm_callback(i2c_callback,pre_transaction(sb_pkt));									 
									// vmm_callback
								end 
									byte_count-- ;
							end
								read_inf(1,8'h08,status_reg);
								while (!status_reg[7])
									read_inf(1,8'h08,status_reg);
								if(byte_count == 0 && status_reg[7] )   
								begin
									write_inf(1,8'h0E, 8'hFF);
									reg_pkt.reg_address = 8'h0E;
									reg_pkt.data_byte = 8'hFF;
									reg_pkt.wr_rd = 1'b1;
									reg_pkt.reset_bit = 1'b0;
									`vmm_callback(i2c_callback,write_reg(reg_pkt));
								end	 
						end

// DUT (W/B Driver) in Slave/Transmiter and in Non-Interrupt mode. 
// Driver will configure DUT in given mode it will keep on waiting for tip bit (bit 7) of Status Register to be set
// and then it will write data to transmit register of DUT.
						else			// Non-Interrupt Mode
						begin
							write_inf(1,8'h0C, {{temp_stim_packet.slave_address},{1'b1}});	// Slave Address + 1'b1 bit
								reg_pkt.reg_address = 8'h0C;
								reg_pkt.data_byte = {{temp_stim_packet.slave_address},{1'b1}};
								reg_pkt.wr_rd = 1'b1;
								reg_pkt.reset_bit = 1'b0;
								`vmm_callback(i2c_callback,write_reg(reg_pkt));
							write_inf(1,8'h04, 8'h00);	    //Enable the core,keep it in slave mode , non-interrupt mode
								reg_pkt.reg_address = 8'h04;
								reg_pkt.data_byte = 8'h00;
								reg_pkt.wr_rd = 1'b1;
								reg_pkt.reset_bit = 1'b0;
								`vmm_callback(i2c_callback,write_reg(reg_pkt));
							
							while(byte_count != 0)
							begin
								read_inf(1,8'h08,status_reg);
								while(!status_reg[7])
								begin
									read_inf(1,8'h08,status_reg);
								end	
								write_inf(1,8'h0E, temp_stim_packet.data_packet[byte_count-1]); 
									reg_pkt.reg_address = 8'h0E;
									reg_pkt.data_byte = temp_stim_packet.data_packet[byte_count-1];
									reg_pkt.wr_rd = 1'b1;
									reg_pkt.reset_bit = 1'b0;
									`vmm_callback(i2c_callback,write_reg(reg_pkt));
								write_inf(1,8'h04, 8'h01);
									reg_pkt.reg_address = 8'h04;
									reg_pkt.data_byte = 8'h01;
									reg_pkt.wr_rd = 1'b1;
									reg_pkt.reset_bit = 1'b0;
									`vmm_callback(i2c_callback,write_reg(reg_pkt));
								// vmm_callback
								sb_pkt.master_slave = 1'b0;
								sb_pkt.tx_rx = 1'b0;
								sb_pkt.slave_address = temp_stim_packet.slave_address;
								sb_pkt.data_byte =	temp_stim_packet.data_packet[byte_count-1];
								`vmm_callback(i2c_callback,pre_transaction(sb_pkt));									 
								// vmm_callback
								read_inf(1,8'h08,status_reg);
								while (!status_reg[7] && !status_reg[0])
								begin
									read_inf(1,8'h08,status_reg);
								end
								//write_inf(1,8'h04, 8'h01); 
								byte_count-- ;
							end
							read_inf(1,8'h08,status_reg);
							while (!status_reg[7] && !status_reg[0])
							begin
								read_inf(1,8'h08,status_reg);
							end
							if(byte_count == 0 && status_reg[7])
								write_inf(1,8'h0E, 8'hFF); 
									reg_pkt.reg_address = 8'h0E;
									reg_pkt.data_byte = 8'hFF;
									reg_pkt.wr_rd = 1'b1;
									reg_pkt.reset_bit = 1'b0;
									`vmm_callback(i2c_callback,write_reg(reg_pkt));
						    #1200; 	response_packet.tr = 1'b1; 
						end
					end
				end
			end		
		end

	end
	endtask


endclass : i2c_master_driver


