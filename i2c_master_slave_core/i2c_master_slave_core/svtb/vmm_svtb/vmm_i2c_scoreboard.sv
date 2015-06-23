//////////////////////////////////////////////////////////////////////////////////////////
//																						//
//	Verification Engineer:	Atish Jaiswal												//
//	Company Name		 :	TooMuch Semiconductor Solutions Pvt Ltd.					//
//																						//
//  Description of the Source File:														//
//	This source code implements Scoreboard.												//
//	Scoreboard contains queues for data_bytes comparision and Associative Array for 	//
//  Register values comparision for read/write test-cases.								//
//  	Whenever any transaction starts, through pre_txn callback it gets oject and 	//	
//  save that object into queue. Once transaction is done, it get another objects 		//
//	through post_txn call backs from dirvers. In Scoreboard it compares both object's	//
// data_byte and reports MATCH or MISMATCH of data.										//
//  	For Register testcases it saves register value whenever any data gets written 	//														
// 	to DUT register into associative array with register address as an index. Now,		//
// 	When Register-read test occurs, it compares the data read from internal register 	//
//  with Assocative Array's dat of same index. If register was not written previously	//
//  it compread read data with initial value of that register.							//
//																						//
//////////////////////////////////////////////////////////////////////////////////////////

`include "vmm.sv"

class i2c_scoreboard extends vmm_xactor;

	scoreboard_pkt sb_pre_txn_q[$];				// Queue of scoreboard_pkt for pre_transaction
	scoreboard_pkt sb_post_txn_q[$];			// Queue of scoreboard_pkt for post_transaction
	vmm_log log;
	scoreboard_pkt sb_pre_obj;					// Scoreoard_pkt's instance for pre_transaction
	scoreboard_pkt sb_pre_obj1;					// Scoreoard_pkt's instance for pre_transaction
	scoreboard_pkt sb_post_obj;					// Scoreoard_pkt's instance for post_transaction
	scoreboard_pkt sb_post_obj1;				// Scoreoard_pkt's instance for post_transaction

	register_pkt reg_pkt;						// registet_pkt's instance
	register_pkt reg_pkt1;						// register_pkt's instance

	typedef bit [7:0] reg_addr;					
	bit [7:0] initial_reg [*];					// 8-bit wide Associative Array of to store initial_register's value
	bit [7:0] wr_reg [*];						// 8-bit wide Associative Array of to store data which were written in DUT reigsters
    bit [7:0] ref_reg_value; 					// 8-bit wide register for storing reference data to be compared.
	
// Constructor Class
	function new (string name, string instance);
		super.new("I2C_Scoreboard", "SCOREBOARD");
		this.log = new("Scoreboard", "SCOREBOARD");
	endfunction


// Write_reg Task. It saves the data written to internal register of DUT into Associative Array wr_reg
	task write_reg(register_pkt reg_pkt);
//		$display("Scoreboard: inside write_reg at %t", $time);
//		if(reg_pkt.reset_bit)
//		begin
//			wr_reg.delete;
//			for (int i = 0; i < sb_pre_txn_q.size ; i++)
//				sb_pre_txn_q.delete(i);
//			for (int j = 0; j < sb_post_txn_q.size ; j++)
//				sb_post_txn_q.delete(j);
//		end
//		else
//		begin
			$cast(reg_pkt1,reg_pkt.copy());
			wr_reg[reg_pkt1.reg_address] = reg_pkt1.data_byte;
//		end
	endtask


// Read_reg task. It Check whether data is previously written to internal register (Checks Whether data already exists for the given index,
// which is internal register's address in this case). If data already exists, it compare this data with the read data. If data with same index
// doesn't exists, it will compare this read data with initial data of that index.
	task read_reg(register_pkt reg_pkt);
		$cast(reg_pkt1,reg_pkt.copy());
		if(wr_reg.exists(reg_pkt1.reg_address))   // Data Already written into internal register of given index(address)
		begin
			ref_reg_value = wr_reg[reg_pkt1.reg_address];
			if(reg_pkt1.reg_address == 8'h0C)
				if(ref_reg_value[7:1] == reg_pkt1.data_byte[7:1])
					`vmm_note(log, "Scoreboard: Date written into Register MATCH with Date read from Register");
				else 
					`vmm_error(log, "Scoreboard: Date written into Register DO NOT MATCH with Date read from Register");
			else if (reg_pkt1.reg_address == 8'h04)
				if(ref_reg_value[7:2] == reg_pkt1.data_byte[7:2])
					`vmm_note(log, "Scoreboard: Date written into Register MATCH with Date read from Register");
				else 
					`vmm_error(log, "Scoreboard: Date written into Register DO NOT MATCH with Date read from Register");
			else
				if(ref_reg_value == reg_pkt1.data_byte)
					`vmm_note(log, "Scoreboard: Date written into Register MATCH with Date read from Register");
				else 
					`vmm_error(log, "Scoreboard: Date written into Register DO NOT MATCH with Date read from Register");
		end
		else 
		begin                      // Data was not written before
			if(reg_pkt1.data_byte == 8'h00)
				`vmm_note(log, "Scoreboard: Date written into Register MATCH with Initial Valre of Register");
			else 
				`vmm_error(log, "Scoreboard: Date written into Register DO NOT MATCH with Initial Value of Register");
		end		
	endtask
	
// Pre_txn_push task. This task will push back the data packet(object) been received by callback.	
	task pre_txn_push(scoreboard_pkt sb_pre_obj);
		$cast(sb_pre_obj1,sb_pre_obj.copy());
		this.sb_pre_obj1.display();	
		this.sb_pre_txn_q.push_back(sb_pre_obj1);
	endtask

// Post_txn_push Task. This task is used to compare both data_byte, the one to be transmitter before starting transmission and 
// the one which was received after completion of transation. This task will check whether any object is already available 
// in the queue(If size > 0). If object is alread there, It will pop_out that object and check the data_byte of both objects. 
	task post_txn_push(scoreboard_pkt sb_post_obj);
		if(sb_pre_txn_q.size > 0)
		begin
			sb_post_obj1 = this.sb_pre_txn_q.pop_front();
			if(sb_post_obj1.data_byte == sb_post_obj.data_byte)
				`vmm_note(log, $psprintf("DATA TRANSMITED AND RECEIVED MATCH WITH EACH OTHER AT TIME %t", $time));
			else
				`vmm_error(log, $psprintf("DATA TRANSMITED AND RECEIVED DO NOT MATCH WITH EACH OTHER AT TIME %t", $time));
		end
	endtask


// This task it used to display all contents of queue.
	task sb_display();
		this.log.start_msg(vmm_log::NOTE_TYP);
		void'(this.log.text($psprintf("****************************")));
		void'(this.log.text($psprintf("*****SCOREBOARD REPORT*****")));
		void'(this.log.text($psprintf("****************************")));
	
		void'(this.log.text($psprintf("\n*****PACKETS TRANSMITTED*****")));
		for (int i = 0; i < this.sb_pre_txn_q.size ; i++)
		begin
			void'(this.log.text($psprintf("Master/Slave = %0b Data_Transmitted = %b", sb_pre_txn_q[i].master_slave, sb_pre_txn_q[i].data_byte)));
		end
	
		void'(this.log.text($psprintf("\n*****PACKETS RECEIVED*****")));
		for (int i = 0; i < this.sb_post_txn_q.size ; i++)
		begin
			void'(this.log.text($psprintf("Master/Slave = %0b Data_Received = %b", sb_post_txn_q[i].master_slave, sb_post_txn_q[i].data_byte)));
		end
		this.log.end_msg();
	endtask

endclass
	
				
