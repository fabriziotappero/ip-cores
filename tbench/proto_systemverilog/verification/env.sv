/**
 * 10 GE MAC Core verification environment file.
 * @file: env.sv
 * @author: Pratik Mahajan
 * @par Contact: pratik@e-pigeonpost.com
 * @par Company: UCSC (SV 1896 Systemverilog for advanced verification course)
 * 
 * @version: $LastChangedRevision$
 * @par Last Changed Date:
 * $LastChangedDate$
 * @par Last Changed By:
 * $LastChangedBy$
 */

/**
 * Environment class to contain all test components viz. driver, monitor and scoreboard.
 * Environment instantiates driver, monitor and scoreboard, acts as a intermediatery 
 * between all of them.
 * @class env
 * @par
 */

class env;

   driver macCoreDriver;   ///< handle for driver type object to send data to MAC Core.
   monitor macCoreMonitor; ///< handle for monitor type object to collect data from MAC Core.
   scoreboard macCoreScoreboard;

   mailbox driver2Scoreboard;
   mailbox monitor2Scoreboard;
   
   virtual macCoreInterface virtualMacCoreInterfaceDriver;  ///< virtual interface to connect driver type object to MAC core RTL
   virtual macCoreInterface virtualMacCoreInterfaceMonitor; ///< virtual interface to connect monitor type object to MAC core RTL

   /**
    * Constructor for environment class.
    * Main purpose of the constructor is to connect virtual interfaces to respective objects
    * and pass down proper parameters to scoreboard for checking
    * @param driverVirtualInterface to connect interface with driver object
    * @param monitorVirtualInterface to connect interface with monitor object
    * @return: NA (returns handle and creates object of type environment class
    */
   function new ( virtual macCoreInterface driverVirtualInterface,
		  virtual macCoreInterface monitorVirtualInterface );

      this.virtualMacCoreInterfaceDriver = driverVirtualInterface;
      this.virtualMacCoreInterfaceMonitor = monitorVirtualInterface;

      driver2Scoreboard = new ();
      monitor2Scoreboard = new ();
      
      macCoreDriver = new (virtualMacCoreInterfaceDriver, driver2Scoreboard);
      macCoreMonitor = new (virtualMacCoreInterfaceMonitor, monitor2Scoreboard);

      macCoreScoreboard = new (driver2Scoreboard, monitor2Scoreboard);
      
   endfunction // new

   /**
    * Init task for all testcases to initialize MAC core with pre simulation configuration.
    * Main purpose of the task is to initialize all inputs of simple Tx Rx interface of MAC to 0
    */
   task init ();
      virtualMacCoreInterfaceMonitor.clockingTxRx.receiveReadEnable		<= 0;

      virtualMacCoreInterfaceDriver.clockingTxRx.transmitData			<= 0;
      virtualMacCoreInterfaceDriver.clockingTxRx.transmitValid     		<= 0;
      virtualMacCoreInterfaceDriver.clockingTxRx.transmitStartOfPacket 		<= 0;
      virtualMacCoreInterfaceDriver.clockingTxRx.transmitEndOfPacket   		<= 0;
      virtualMacCoreInterfaceDriver.clockingTxRx.transmitPacketLengthModulus 	<= 0;

   endtask // init
   
   /**
    * Reset task for all testcases to put MAC Core through particular reset consitions
    */
   task reset ();
      virtualMacCoreInterfaceDriver.clockingTxRx.rstTxRxInterface_n    		<= 0;
      virtualMacCoreInterfaceDriver.clockingXGMIIRx.rstXGMIIInterfaceRx_n 	<= 0;
      virtualMacCoreInterfaceDriver.clockingXGMIITx.rstXGMIIInterfaceTx_n 	<= 0;
      virtualMacCoreInterfaceDriver.clockingTxRx.rstWishboneInterface		<= 0;
      
      repeat (10) @(virtualMacCoreInterfaceDriver.clockingTxRx);
      virtualMacCoreInterfaceDriver.clockingTxRx.rstTxRxInterface_n	    	<= 1;
      virtualMacCoreInterfaceDriver.clockingXGMIIRx.rstXGMIIInterfaceRx_n 	<= 1;
      virtualMacCoreInterfaceDriver.clockingXGMIITx.rstXGMIIInterfaceTx_n 	<= 1;
      virtualMacCoreInterfaceDriver.clockingTxRx.rstWishboneInterface		<= 1;
      
   endtask // reset
   
   /**
    * Run task for all testcases to start simulating / executing instructions / consuming time.
    * Main purpose of the task is to instantiate send_packet and collect_packet and call scoreboard checking if available
    */
   task run (int noOfPackets = 10, int lengthOfFrame = 60);
      
      fork  
	 for (int i = 0; i < noOfPackets; i++)
	   begin
	      @(virtualMacCoreInterfaceDriver.clockingTxRx)
		$display ("=========Sending Packet #%0d============ at time %0t\n", i, $time);
	      macCoreDriver.send_packet(lengthOfFrame);
	   end
	 for (int i = 0; i < noOfPackets; i++)
	   begin
	      wait (virtualMacCoreInterfaceMonitor.clockingTxRx.receiveAvailable == 1'b1);
	      $display ("========Collecting Packet #%0d===========\n", i);
	      macCoreMonitor.collect_packet();
	   end
      join

   endtask // run

   task validate (int noOfPackets = 10, int lengthOfFrame = 60);
      
      for (int i = 0; i < noOfPackets; i++)
	begin
	   for (int j = 0; j < lengthOfFrame; j += 8)
	     begin
		int bytesInFrame;
		
		if ( (j+8) > lengthOfFrame) bytesInFrame = lengthOfFrame % 8;
		else bytesInFrame = 0;
		macCoreScoreboard.compare (driver2Scoreboard, monitor2Scoreboard, bytesInFrame);
	     end
	end
   endtask // validate
   
endclass // env
