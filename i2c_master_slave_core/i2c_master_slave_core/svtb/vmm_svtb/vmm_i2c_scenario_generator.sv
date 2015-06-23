//////////////////////////////////////////////////////////////////////////////////////////
//																						//
//	Verification Engineer:	Atish Jaiswal												//
//	Company Name		 :	TooMuch Semiconductor Solutions Pvt Ltd.					//
//																						//
//  Description of the Source File:														//
//	This source code implements Scenario Generator. Please note that this Scenario		//
//  Generator is coded and its different than the one getting created by using macro 	//
//	`vmm_scenario_gen(defined in VMM).													//
//																						//
//	If type of test-case to be run is given in command line(rand_gen=0) and other		//
//  variable are assgined then it will use those values and then randomize only stimlus //
//  packet and data packet and then stimulus packet will be sent to both drivers.		//
//																						//
//  When type of test-case to be run is not given in command line (rand_gen=1) then it 	//
//  will randomize Scenario Packet first to find out what kind of test-case it to be run//
//  Accordingly it will randomized stimulus and data_pkt and then Stimulus packet will 	//
//  be sent to both drivers.															//
//																						//
//////////////////////////////////////////////////////////////////////////////////////////

`include "vmm.sv"
class i2c_scenario_generator extends vmm_xactor;

	vmm_log log = new("lOG", "GENERATOR");

   	scenario_packet sc_packet;					// Scenario Packet	
    stimulus_packet stim_packet;				// Stimulus Packet
	i2c_data_packet d_pkt;						// Data Packet
	stimulus_packet_channel m_req_chan;			// Scenario_Gen to W/B Driver 
	stimulus_packet_channel s_req_chan;			// Scenario_Gen to I2C Master/Slave Driver
	int stop_after_n_inst;				
	static int DONE;							// Done to check whether all scenarios have been sent
			
	bit rand_gen = 1'b0;
	integer transaction_count;
	bit master_slave;
	bit register_check;	
	bit reset_check;	
	bit tx_rx;
	
	function new( string name, string instance_name, stimulus_packet_channel m_req_chan = null, stimulus_packet_channel s_req_chan = null);
		super.new("scenario_generator ", "scenario_generator");
		if(m_req_chan == null) m_req_chan = new("master_stimulus_packet_channel", "m_req_chan");
		this.m_req_chan = m_req_chan;	
		if(s_req_chan == null) s_req_chan = new("slave_stimulus_packet_channel", "s_req_chan");
		this.s_req_chan = s_req_chan;	
		this.DONE = this.notify.configure(1,vmm_notify::ON_OFF); 
        sc_packet = new;
        stim_packet = new;
		d_pkt = new;
		$value$plusargs("rand_gen=%b",rand_gen);				// Gets value of read_gen from Command line 
		$value$plusargs("master_slave=%b",master_slave);		// Gets value of master_slave from Command line
		$value$plusargs("register_check=%b",register_check);	// Gets value of register_check bit from Command line
		$value$plusargs("reset_check=%b",reset_check);			// Gets vlaue of reset_check bit from Command line
		$value$plusargs("tx_rx=%b",tx_rx);						// Gets value of tx_rx from Command line
	endfunction



 	virtual protected task main(); 
		 super.main();
	begin 
		string str;
		stimulus_packet m_response;
		stimulus_packet s_response;
		`vmm_note(log,"I2C Scenario from Scenario generator");

		while (transaction_count != 0)
		begin
			if(!rand_gen) // If type of test-cases to run is assigned in command line
			begin
				sc_packet.master_slave = master_slave;
				sc_packet.transaction_count = transaction_count;
				sc_packet.register_check = register_check;
				sc_packet.tx_rx = tx_rx;
			end
			else		// If type of test-cases to run is to be randomized.
			begin
				if(sc_packet.randomize()); else `vmm_error(log, "I2C Scenario Generator : Randomization of I2C Scenario Packet Packet Failed");
				master_slave = sc_packet.master_slave;
				sc_packet.transaction_count = transaction_count;
				register_check = sc_packet.register_check;
				reset_check = sc_packet.reset_check;
				tx_rx = sc_packet.tx_rx;	
			end
			sc_packet.display();
	 		`vmm_note(log, $psprintf("Scenario Generator: packet to Driver @ %t", $time));

// If register read_write testcase are to be run, it will randomize stimulus packet for register data and addres and read/write operation.
// Other fields of stimulus packet will be assigned here only.
			if(register_check)			// Register test-case to be run
			begin
				stim_packet.master_slave = master_slave;
		  		stim_packet.tr = tx_rx;
		  		stim_packet.register_check = register_check;
		  		stim_packet.reset_check = reset_check;
		  		if(stim_packet.randomize()); else `vmm_error(log, "I2C Master Stimulus: Randomization of I2C Stimulus Packet Failed");
		  		stim_packet.display();
		  		this.m_req_chan.put(stim_packet);   // sending packet to master driver
				this.s_req_chan.put(stim_packet);	// sending packet to slave driver
			end

// If data transacation test-caser are to be run, it will stimulus packet, get the size of data_bytes(no of bytes) and again randomized
// data_pkt class for data_bytes. All fields of stimulus packet wil be assigned here and then sent to both dirvers.

			else						// Data Transacation test-case to be run
			begin
				stim_packet.master_slave = master_slave;
				stim_packet.tr = tx_rx;
				stim_packet.register_check = register_check;
				stim_packet.reset_check = reset_check;
				if(stim_packet.randomize()); else `vmm_error(log, "I2C Master Stimulus: Randomization of I2C Stimulus Packet Failed");
				d_pkt.data_pkt = new[stim_packet.byte_count];
				if(d_pkt.randomize()); else `vmm_error(log, "I2C Master Stimulus: Randomization of I2C Data Packet Failed");
				stim_packet.data_packet = d_pkt.data_pkt;
				stim_packet.display();
				d_pkt.display();
				this.m_req_chan.put(stim_packet); 	// sending packet to master driver
				this.s_req_chan.put(stim_packet);	// sending packet to slave driver
			end
			transaction_count--;
		end
			notify.indicate(DONE);			// Indicate Enviorment that all scenarios have been sent to drivers.
		end		
	endtask


endclass
	


