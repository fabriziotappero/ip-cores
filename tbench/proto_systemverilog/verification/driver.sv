/**
 * 10 GE MAC Core verification environment driver file.
 * @file: driver.sv
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
 * Driver class to send packet from test environment to DUT (10GE MAC Core).
 * Driver only talks with Tx interface of 10 GE MAC Core, This class will provide 
 * packet data to MAC Core as represented in specification requirement.
 * @class driver
 * @par virtual macCoreInterface to connect class objects with DUT
 */

class driver;

   virtual macCoreInterface virtualMacCoreInterface; ///< Virtual interface to connect class types with RTL.
   mailbox driver2Scoreboard;
   
   const bit ASSERT   = 1'b1; ///< to assert sequence while transsion of packet
   const bit DEASSERT = 1'b0; ///< to deassert sequence while transmission of packet

//   packetFrame	driverPacket;
   
   /**
    * Constructor for driver class -- main purpose is to connect design interface with class virtual interface.
    * @param virtualInterface -- virtual interface passed down from env class
    * @return: NA (creates object of type class and returns handle
    */
   function new (virtual macCoreInterface virtualInterface,
		 input mailbox driver2Scoreboard
		 );
      this.virtualMacCoreInterface = virtualInterface;
      this.driver2Scoreboard       = driver2Scoreboard;
   endfunction // new

   /**
    * Task to send complete packet data to the input of RTL (10 GE MAC Core).
    * send_packet should follow protocol requirements specified in requirement specifications (except if it is used for error injection)
    * protocol requirement:
    * 	assert: packetValid
    * 	make sure sop, eop and mod are set to 0 at start of packet (do it at the end of each packet transmission or right here)
    * 	if sending 0th frame assert sop
    * 	if sending last fram assert eop and mod
    * 	put all data on packetData
    * 	wait for a clock edge and de-assert packetValid, eop and mod (at this point sop is still asserted ??)
    * packet class itself will take care of keeping track of number of objects created.
    */
   task send_packet (input int lengthOfFrame);
      packet macCore; ///< object of type packet that will be transmitted to DUT
  
      virtualMacCoreInterface.clockingTxRx.transmitValid <= ASSERT;

      for (int i = 0; i < lengthOfFrame; i+=8)
	begin
	   macCore = new (TRANSMIT);
	   assert (macCore.randomize ());
	   macCore.startOfPacket	= DEASSERT;
	   macCore.endOfPacket		= DEASSERT;
	   macCore.packetLengthModulus	= 3'b0;
	   
	   if (i == 0) macCore.startOfPacket	= ASSERT;
//virtualMacCoreInterface.clockingTxRx.transmitStartOfPacket <= ASSERT;

	   if (i+8 >= lengthOfFrame) begin
	      macCore.endOfPacket		= ASSERT;
	      macCore.packetLengthModulus 	= lengthOfFrame % 8;
//	      virtualMacCoreInterface.clockingTxRx.transmitEndOfPacket <= ASSERT;
//	      virtualMacCoreInterface.clockingTxRx.transmitPacketLengthModulus <= lengthOfFrame % 8;
	   end

	   virtualMacCoreInterface.clockingTxRx.transmitStartOfPacket		<= macCore.startOfPacket;
	   virtualMacCoreInterface.clockingTxRx.transmitEndOfPacket		<= macCore.endOfPacket;
	   virtualMacCoreInterface.clockingTxRx.transmitPacketLengthModulus	<= macCore.packetLengthModulus;
	   
	   virtualMacCoreInterface.clockingTxRx.transmitData <= { 	macCore.packetData [7],
									macCore.packetData [6],
									macCore.packetData [5],
									macCore.packetData [4],
									macCore.packetData [3],
									macCore.packetData [2],
									macCore.packetData [1],
									macCore.packetData [0]	};
	   macCore.print (TRANSMIT);
	   driver2Scoreboard.put (macCore);
	   @(virtualMacCoreInterface.clockingTxRx);

	end // for (int i = 0; i < lengthOfFrame; i+=8)

      virtualMacCoreInterface.clockingTxRx.transmitValid <= DEASSERT;
      virtualMacCoreInterface.clockingTxRx.transmitEndOfPacket <= DEASSERT;
      virtualMacCoreInterface.clockingTxRx.transmitPacketLengthModulus <= 3'b0;
            
   endtask // send_packet

endclass // driver
