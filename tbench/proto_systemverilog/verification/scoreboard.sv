/**
 * Scoreboard / Checker for 10 GE MAC Core verification environment.
 * It takes packet data from driver as well as monitor class and comapre them for equality for error checking purpose
 * @file: scoreboard.sv
 * @author: Pratik Mahajan
 * @par Contact: pratik@e-pigeonpost.com
 * @par Company: UCSC 1896 course 
 * 
 * @version: $LastChangedRevision$
 * @par Last Changed Date
 * $LastChangedDate$
 * $par Last Changed By
 * $LastChangedBy$
 */

/**
 * Scoreboard class for error checking of 10GE MAC Core.
 * Collects packet data from driver and monitor in the form of mailboxes and then compare them for equality.
 * If they are equal then communication was successful
 * @class scoreboard
 * @par mailbox driver2Scoreboard collects transmitted packets from driver.
 * @par mailbox monitor2Scoreboard collects received packets through monitor.
 */

class scoreboard;

   mailbox driver2Scoreboard;  ///< packet data passed down from driver as source or expected data
   mailbox monitor2Scoreboard; ///< packet data from monitor as source for actual data
   static bit 	   error = 0; ///< Error flag to keep track of correctness of verification environment
   /**
    * Constructor for scoreboard class.
    * purpose is to create an object for scoreboard which will take mailboxes from respective classes
    * @param mailbox receivedFromDriver to hold mailbox received from Driver 
    * @param mailbox receivedFromMonitor to hold mailbox received from Monitor
    * @return: NA (creates object of type scoreboard and returns handle)
    */
   function new (input mailbox receivedFromDriver, input mailbox receivedFromMonitor);
      this.driver2Scoreboard  = receivedFromDriver;
      this.monitor2Scoreboard = receivedFromMonitor;
   endfunction: new

   /**
    * Compare task for error checking.
    * This task compares actual and expected results for correctness of design.
    * @param mailbox driver2Scoreboard expected results to be validated
    * @param mailbox monitor2Scoreboard actual results to be compared
    */
   task compare ( input mailbox driver2Scoreboard, 
		  input mailbox monitor2Scoreboard,
		  int bytesInFrame);
            
      packet 	driverPacket;
      packet	monitorPacket;

      driver2Scoreboard.get  (driverPacket);
      monitor2Scoreboard.get (monitorPacket);

`define driverData { driverPacket.packetData [7], driverPacket.packetData [6], driverPacket.packetData [5], driverPacket.packetData [4], driverPacket.packetData [3], driverPacket.packetData [2], driverPacket.packetData [1], driverPacket.packetData [0] }
`define monitorData { monitorPacket.receivedData [7], monitorPacket.receivedData [6], monitorPacket.receivedData [5], monitorPacket.receivedData [4], monitorPacket.receivedData [3], monitorPacket.receivedData [2], monitorPacket.receivedData [1], monitorPacket.receivedData [0] }
            
      if (bytesInFrame != 0) begin
	 for (int i = 0; i < bytesInFrame; i++) begin
	    if (driverPacket.packetData [7-i] != monitorPacket.receivedData [7-i]) begin
	       $display ("ERROR: Packet data [%0d] the data was %x and %x mismatched", i, driverPacket.packetData[7-i], monitorPacket.receivedData[7-i]);
	       error = 1;
	    end
	 end
      end
      
      if (bytesInFrame == 0)
	if (`driverData != `monitorData) begin
	   $display ("ERROR: Packet frame mismatched");
	   error = 1;
	end
            
      if (driverPacket.startOfPacket != monitorPacket.startOfPacket || driverPacket.endOfPacket != monitorPacket.endOfPacket) 
	begin 
	   error = 1;	 
	   $display ("ERROR: Packet control mismatched "); 
	end
      
/*      if (error == 0) begin
	 $display ("PASS: Packet matched properly ");
      end
*/
   endtask // compare

endclass // scoreboard
