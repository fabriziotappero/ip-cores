`include "vmm.sv"

class i2c_callback extends vmm_xactor_callbacks;

	virtual task pre_transaction(scoreboard_pkt sb_pkt);
	endtask
	 
	virtual task post_transaction(scoreboard_pkt sb_pkt);
	endtask
	
	virtual task write_reg(register_pkt reg_pkt);
	endtask
	
	virtual task read_reg(register_pkt reg_pkt);
	endtask

	virtual task send_pkt_to_monitor(stimulus_packet mon_stim_pkt);
	endtask
	
	virtual task protocol_checks_coverage(monitor_pkt mon_pkt);
	endtask
	

endclass
