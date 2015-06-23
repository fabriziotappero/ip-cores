/**
 * 10 GE MAC Core verification environment monitor file.
 * @file: monitor.sv
 * @author: Pratik Mahajan
 * @par Contact: pratik@e-pigeonpost.com
 * @par Company: UCSC (SV 1896 Systemverilog for advanced verification course)
 * 
 * @version: $LastChangedRevision$
 * @par Last Changed Date:
 * $LastChangedDate$
 * @par Last Changed By
 * $LastChangedBy$
 */

/**
 * Monitor class to collect packet from DUT (10 GE MAC Core) in test environment.
 * Monitor only communicate with receive interface of DUT and collects information
 * about packet, this information can be validated with expected results for error 
 * checking and proper working of protocol.
 * @class monitor
 * @par virtual macCoreInterface to collect data from interface.
 */

class monitor;

   virtual macCoreInterface virtualMacCoreInterface; ///< virtual interface to connect class type to RTL / module type
   mailbox monitor2Scoreboard;
   
   const bit ASSERT   = 1'b1; ///< to assert sequence while receiving packet from DUT
   const bit DEASSERT = 1'b0; ///< to de-assert sequence while receiving packet from DUT
//   packetFrame	monitorPacket;
   
   /**
    * Constructor for monitor class -- main purpose is to connect design interface with monitor class virtual interface.
    * @param virtualInterface -- input to constructor passed down by env class
    * @return: NA (creates an object of type monitor and returns a handle)
    */
   function new (virtual macCoreInterface virtualInterface,
		 mailbox monitor2Scoreboard
		 );
      this.virtualMacCoreInterface = virtualInterface;
      this.monitor2Scoreboard      = monitor2Scoreboard;
   endfunction // new

   /**
    * Task to collect data from output of RTL from interface as bus.
    * collect_packet should follow protocol requirements specified in requirement specifications (unless it is used for error injection)
    * Protocol requirements:
    * 	Always check for receiveAvailable (need to do it in testcase or environment? but need to be running under forever)
    * 	if(receiveAvailable) start packet collect
    * 	assert receiveReadEnable
    * 	until receive is not complete
    * 		if receiveValid
    * 			if receiveStartOfPacket -- print/do nothing/start 
    * 				packet.data = receiveData
    * 			if receiveEndOfPacket -- finish collecting packet
    * 				deassert receiveReadEnable 
    * 				display some stuff
    * 
    * MAY NEED TO LOOK IN OTHER FLAGS AS ERROR AND STUFF
    * creating new packet itself will take care of incrementing
    */
`define receivedPacket { receiveMacCore.receivedData[7], receiveMacCore.receivedData[6], receiveMacCore.receivedData[5], receiveMacCore.receivedData[4], receiveMacCore.receivedData[3], receiveMacCore.receivedData[2], receiveMacCore.receivedData[1], receiveMacCore.receivedData[0] }
   
   task collect_packet ();
      packet receiveMacCore; ///< object of type packet that will be collected from DUT.

      virtualMacCoreInterface.clockingTxRx.receiveReadEnable <= ASSERT;

      do begin
	 receiveMacCore = new (RECEIVE);
	 @(virtualMacCoreInterface.clockingTxRx);
	 if (virtualMacCoreInterface.clockingTxRx.receiveValid) begin
	    receiveMacCore.startOfPacket	= virtualMacCoreInterface.clockingTxRx.receiveStartOfPacket;
	    receiveMacCore.endOfPacket		= virtualMacCoreInterface.clockingTxRx.receiveEndOfPacket;
	    receiveMacCore.packetLengthModulus	= virtualMacCoreInterface.clockingTxRx.receivePacketLengthModulus;
	    
	    if (virtualMacCoreInterface.clockingTxRx.receiveStartOfPacket) begin
	       $display ("Starting to receive packet \n");
	    end
	    `receivedPacket = virtualMacCoreInterface.clockingTxRx.receivedData;
	    receiveMacCore.print (RECEIVE);
	    
	    monitor2Scoreboard.put (receiveMacCore);	    
	 end // if (virtualMacCoreInterface.clockingTxRx.receiveValid)
      end while (!virtualMacCoreInterface.clockingTxRx.receiveEndOfPacket); // UNMATCHED !!
	 
      virtualMacCoreInterface.clockingTxRx.receiveReadEnable <= DEASSERT;
                  
   endtask // collect_packet

endclass // monitor