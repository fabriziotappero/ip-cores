/**
 * Interface file for 10 GE MAC Core.
 * Takes all clocks as input and all clocks are created from single clock source in testbench
 * @file: macCoreInterface.sv
 * @author: Pratik Mahajan
 * @par Contact: pratik@e-pigeonpost.com
 * @par Company: UCSC extension (Systemverilog for advanced verification SV1896) course
 * 
 * @version: $LastChangedRevision$
 * @par Last Changed Date:
 * $LastChangedDate$
 * @par Last Changed By
 * $LastChangedBy$
 */

/**
 * 10GE MAC Core interface.
 * @param clkWishboneInterface : clock for wishbone interface 30 - 156 MHz -- input to interface logic
 * @param clkTxRxInterface : clock for simple Tx-Rx interface 156.25 MHz -- input to interface logic
 * @param clkXGMIIInterfaceRx : clock for XGMII physical layer Rx interface 156.25 MHz -- input to interface logic
 * @param clkXGMIIInterfaceTx : clock for XGMII physical later Tx interface 156.25 MHz -- input to interface logic
 */

interface macCoreInterface (input bit clkWishboneInterface,
			    input bit clkTxRxInterface,
			    input bit clkXGMIIInterfaceRx,
			    input bit clkXGMIIInterfaceTx
			    );

   // Reset signals used in design
   bit 				      rstWishboneInterface;  ///< Wishbone interface reset signal -- de-assertion synchronous to clkWishboneInterface
   bit 				      rstTxRxInterface_n;    ///< Simple Tx-Rx interface reset signal -- de-assertion synchronous to clkTxRxInterface ACTIVE LOW
   bit 				      rstXGMIIInterfaceRx_n; ///< XGMII physical layer Rx interface reset signal -- de-assertion synchronous to clkXGMIIInterfaceRx ACTIVE LOW
   bit 				      rstXGMIIInterfaceTx_n; ///< XGMII physical later Tx interface reset signal -- de-assertion synchronous to clkXGMIIInterfaceTx ACTIVE LOW

   // Packet receive interface signals
   bit 				      receiveReadEnable;          ///< Input to Core (outoput of test) asserted when packet is available in receive FIFO
   bit 				      receiveAvailable;           ///< Output from Core indicates packet is available for reading in receive FIFO
   bit [63:0] 			      receivedData;               ///< Output from Core represents a packet data in little endian format
   bit 				      receiveEndOfPacket;         ///< Output from Core asserted when last word of packet is read form receive FIFO
   bit 				      receiveValid;               ///< Output from Core asserted a cycle after readEnable represents a valid data on bus
   bit 				      receiveStartOfPacket;       ///< Output from Core represents first word of packet is on the bus
   bit [2:0]			      receivePacketLengthModulus; ///< Output from Core updated with End of packet to represent valid bytes during last word
   bit 				      receiveError;               ///< Output from Core represents current packet is bad mainly due to CRC errors

   // Packet transmit interface signals
   bit [63:0] 			      transmitData;               ///< Input to Core represents packet data to be transmitted in Little-Endian format
   bit 				      transmitValid;              ///< Input to Core asserted for each valid data transfer to MAC Core
   bit 				      transmitStartOfPacket;      ///< Input to Core must be asserted during first word of packet to Core
   bit 				      transmitEndOfPacket;        ///< Input to Core must be asserted during last word of packet to Core
   bit [2:0] 			      transmitPacketLengthModulus;///< Input to Core should be valid during End Of Packet during last word and represents valid bytes
   bit 				      transmitFIFOFull;           ///< Output from Core represents transmit FIFO is about to be full

   // XGMII receive interface signals
   bit [7:0] 			      xgmiiReceiveControl;        ///< Input to Core - each bit corresponds to type of byte of frame; 0 - byte is data, 1 - byte is control char 
   bit [63:0] 			      xgmiiReceiveData;           ///< Input to Core - represents data on XGMII interface to be received by Core (can be broken in 32 bits)

   // XGMII transmit interface signals
   bit [7:0] 			      xgmiiTransmitControl;       ///< Output from Core - each bit corresponds to type of byte of frame; 0 - byte is data, 1 - byte is control char
   bit [63:0] 			      xgmiiTransmitData;          ///< Output from Core - represents data on XGMII interface to be transmitted by Core (can be broken in 32 bits)

   // Wishbone interface signals -- won't be used for current specification requirements
   bit [7:0] 			      wishboneInputAddress;
   bit 				      wishboneCycle;
   bit [31:0] 			      wishboneInputData;
   bit 				      wishboneStrobe;
   bit 				      wishboneWriteEnable;
   bit 				      wishboneAck;
   bit [31:0] 			      wishboneOutputData;
   bit 				      wishboneInterrupt;

   // Put XGMII interface in loopback mode --- do it in testbench if you can just connect them to each other
/*   always_comb begin
      xgmiiReceiveControl = xgmiiTransmitControl;
      xgmiiReceiveData    = xgmiiTransmitData;
   end
*/   
   /**
    * Clocking block mainly for testcase
    * Resets are used as outputs in clocking block -- to make sure they are de-asserted on clock edges
    * may need specific testcase to test asynchronous resets
    * @param clkTxRxInterface: clock to be used for clocking block
    */
   clocking clockingTxRx @(posedge clkTxRxInterface);
      // Using default delays
      default output #1000;
      
      // receive interface direction
      input 			      receiveAvailable;
      input 			      receivedData;
      input 			      receiveEndOfPacket;
      input 			      receiveValid;
      input 			      receiveStartOfPacket;
      input 			      receivePacketLengthModulus;
      input 			      receiveError;
      output 		 	      receiveReadEnable;
      // transmit interface direction
      output 			      transmitData;
      output 			      transmitValid;
      output 			      transmitStartOfPacket;
      output 			      transmitEndOfPacket;
      output 			      transmitPacketLengthModulus;
      input 			      transmitFIFOFull;

      output 			      rstTxRxInterface_n;

      output 			      rstWishboneInterface; // not necessary but doesn't matter as we need to take care of it 
      
   endclocking // clockingTxRx

   clocking clockingXGMIIRx @(posedge clkXGMIIInterfaceRx);
      output 			      xgmiiReceiveControl;
      output 			      xgmiiReceiveData;

      output 			      rstXGMIIInterfaceRx_n;
   endclocking // clockingXGMIIRx

   clocking clockingXGMIITx @(posedge clkXGMIIInterfaceTx);
      input 			      xgmiiTransmitControl;
      input 			      xgmiiTransmitData;

      output 			      rstXGMIIInterfaceTx_n;
   endclocking // clockingXGMIITx

   // Avoiding modports for 10GE MAC Core and Wishbone as functionality is not really required at this point of time
   // However for complete environment it can be extended to include all interfaces

   modport TESTMOD (clocking clockingTxRx, clocking clockingXGMIIRx, clocking clockingXGMIITx);
   

endinterface // macCoreInterface
